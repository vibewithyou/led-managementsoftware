import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

enum VlcTransportStatus {
  ready,
  starting,
  playing,
  error,
  fileMissing,
  stopped,
}

class VlcStatusSnapshot {
  const VlcStatusSnapshot({
    required this.status,
    required this.operatorMessage,
    required this.updatedAt,
    this.technicalMessage,
    this.filePath,
    this.executablePath,
    this.lastExitCode,
  });

  final VlcTransportStatus status;
  final String operatorMessage;
  final String? technicalMessage;
  final String? filePath;
  final String? executablePath;
  final int? lastExitCode;
  final DateTime updatedAt;
}

class VlcOperationException implements Exception {
  const VlcOperationException({
    required this.operatorMessage,
    required this.technicalMessage,
    this.status = VlcTransportStatus.error,
  });

  final String operatorMessage;
  final String technicalMessage;
  final VlcTransportStatus status;

  @override
  String toString() {
    return '$operatorMessage ($technicalMessage)';
  }
}

class VlcService {
  VlcService({String? executablePath}) : _executablePathOverride = executablePath;

  final String? _executablePathOverride;

  Process? _process;
  String? _resolvedExecutablePath;
  bool _fullscreenOutputEnabled = true;
  bool _running = false;
  VlcStatusSnapshot _status = VlcStatusSnapshot(
    status: VlcTransportStatus.stopped,
    operatorMessage: 'VLC gestoppt',
    updatedAt: DateTime.now(),
  );
  final StreamController<VlcStatusSnapshot> _statusController = StreamController<VlcStatusSnapshot>.broadcast();

  VlcStatusSnapshot get status => _status;
  Stream<VlcStatusSnapshot> get statusStream => _statusController.stream;

  bool isRunning() {
    return _running && _process != null;
  }

  Future<void> startVlc() async {
    if (isRunning()) {
      _log('startVlc() skipped: VLC already running.');
      return;
    }

    _emitStatus(
      VlcTransportStatus.starting,
      operatorMessage: 'VLC startet …',
    );
    await _launchVlc();
  }

  Future<void> playFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      _emitStatus(
        VlcTransportStatus.fileMissing,
        operatorMessage: 'Datei fehlt',
        technicalMessage: 'Videodatei nicht gefunden: $path',
        filePath: path,
      );
      throw VlcOperationException(
        operatorMessage: 'Datei fehlt: $path',
        technicalMessage: 'Videodatei nicht gefunden',
        status: VlcTransportStatus.fileMissing,
      );
    }
    if (isRunning()) {
      _log('Restarting VLC for new file: $path');
      await stop();
    } else {
      _log('VLC not running. Starting before playback.');
    }

    _emitStatus(
      VlcTransportStatus.starting,
      operatorMessage: 'VLC startet Wiedergabe …',
      filePath: path,
    );
    await _launchVlc(filePath: path);
  }

  Future<void> stop() async {
    final process = _process;
    if (process == null) {
      _running = false;
      _log('stop() skipped: VLC was not running.');
      _emitStatus(
        VlcTransportStatus.stopped,
        operatorMessage: 'VLC gestoppt',
      );
      return;
    }

    _log('Stopping VLC process...');
    process.kill(ProcessSignal.sigterm);

    try {
      await process.exitCode.timeout(const Duration(seconds: 2));
    } on TimeoutException {
      _log('VLC did not exit gracefully. Killing process.');
      process.kill(ProcessSignal.sigkill);
      await process.exitCode.timeout(const Duration(seconds: 2), onTimeout: () => -1);
    } finally {
      _process = null;
      _running = false;
      _emitStatus(
        VlcTransportStatus.stopped,
        operatorMessage: 'VLC gestoppt',
      );
    }
  }

  Future<void> setFullscreenOutput() async {
    _fullscreenOutputEnabled = true;
    _log('Fullscreen output enabled.');
  }

  Future<void> _launchVlc({String? filePath}) async {
    final executable = await _resolveExecutablePath();
    final args = <String>[
      if (_fullscreenOutputEnabled) '--fullscreen',
      '--video-on-top',
      ...?switch (filePath) {
        final value? => [value],
        _ => null,
      },
    ];

    _log('Launching VLC: $executable ${args.join(' ')}');

    try {
      final process = await Process.start(executable, args, mode: ProcessStartMode.normal);
      _attachProcess(process, filePath: filePath, executablePath: executable);
    } on ProcessException catch (error) {
      _running = false;
      final looksLikeMissingInstall = error.errorCode == 2 ||
          error.message.toLowerCase().contains('cannot find') ||
          error.message.toLowerCase().contains('no such file');
      final operatorMessage =
          looksLikeMissingInstall ? 'VLC ist nicht installiert oder Pfad ist ungültig.' : 'VLC konnte nicht gestartet werden.';
      _emitStatus(
        VlcTransportStatus.error,
        operatorMessage: operatorMessage,
        technicalMessage: error.toString(),
        filePath: filePath,
        executablePath: executable,
      );
      throw VlcOperationException(
        operatorMessage: operatorMessage,
        technicalMessage: error.toString(),
      );
    }
  }

  Future<String> _resolveExecutablePath() async {
    if (_resolvedExecutablePath != null) {
      return _resolvedExecutablePath!;
    }

    final executableOverride = _executablePathOverride?.trim();

    final candidates = <String>[
      ...?switch (executableOverride) {
        final value? when value.isNotEmpty => [value],
        _ => null,
      },
      if (Platform.isWindows) r'C:\Program Files\VideoLAN\VLC\vlc.exe',
      if (Platform.isWindows) r'C:\Program Files (x86)\VideoLAN\VLC\vlc.exe',
      'vlc',
    ];

    for (final candidate in candidates) {
      if (candidate == 'vlc') {
        if (await _isExecutableOnPath(candidate)) {
          _resolvedExecutablePath = candidate;
          return candidate;
        }
        continue;
      }

      if (await File(candidate).exists()) {
        _resolvedExecutablePath = candidate;
        return candidate;
      }
    }

    _emitStatus(
      VlcTransportStatus.error,
      operatorMessage: 'VLC ist nicht installiert oder Pfad ist ungültig.',
      technicalMessage: 'Keine VLC-Installation gefunden.',
    );
    throw const VlcOperationException(
      operatorMessage: 'VLC ist nicht installiert oder Pfad ist ungültig.',
      technicalMessage: 'Keine VLC-Installation gefunden.',
    );
  }

  void _attachProcess(Process process, {String? filePath, required String executablePath}) {
    _process = process;
    _running = true;
    _emitStatus(
      filePath == null ? VlcTransportStatus.ready : VlcTransportStatus.playing,
      operatorMessage: filePath == null ? 'VLC bereit' : 'VLC spielt',
      filePath: filePath,
      executablePath: executablePath,
    );

    process.stdout.transform(utf8.decoder).listen((output) {
      final normalized = output.trim();
      if (normalized.isNotEmpty) {
        _log('stdout: $normalized');
      }
    });

    process.stderr.transform(utf8.decoder).listen((output) {
      final normalized = output.trim();
      if (normalized.isNotEmpty) {
        _log('stderr: $normalized');
      }
    });

    unawaited(
      process.exitCode.then((code) {
        _log('VLC exited with code $code');
        if (identical(_process, process)) {
          _process = null;
          _running = false;
          final crashed = code != 0 && code != 143;
          _emitStatus(
            crashed ? VlcTransportStatus.error : VlcTransportStatus.stopped,
            operatorMessage: crashed ? 'VLC Fehler/Absturz erkannt.' : 'VLC gestoppt',
            technicalMessage: 'VLC exit code: $code',
            lastExitCode: code,
            filePath: filePath,
            executablePath: executablePath,
          );
        }
      }),
    );
  }

  Future<bool> _isExecutableOnPath(String executable) async {
    final command = Platform.isWindows ? 'where' : 'which';
    try {
      final result = await Process.run(command, [executable]);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  void _emitStatus(
    VlcTransportStatus status, {
    required String operatorMessage,
    String? technicalMessage,
    String? filePath,
    String? executablePath,
    int? lastExitCode,
  }) {
    _status = VlcStatusSnapshot(
      status: status,
      operatorMessage: operatorMessage,
      technicalMessage: technicalMessage,
      filePath: filePath,
      executablePath: executablePath ?? _resolvedExecutablePath,
      lastExitCode: lastExitCode,
      updatedAt: DateTime.now(),
    );
    _statusController.add(_status);
  }

  void _log(String message) {
    debugPrint('[VlcService] $message');
  }

  void dispose() {
    _statusController.close();
  }
}

class VlcBridgeService extends VlcService {
  VlcBridgeService({super.executablePath});

  Future<void> connectLocalEngine() async {
    await startVlc();
  }

  Future<void> playClip(String clipPath) async {
    await playFile(clipPath);
  }

  Future<void> stopPlayback() async {
    await stop();
  }
}
