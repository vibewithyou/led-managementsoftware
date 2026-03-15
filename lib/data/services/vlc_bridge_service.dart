import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class VlcService {
  VlcService({String? executablePath}) : _executablePathOverride = executablePath;

  final String? _executablePathOverride;

  Process? _process;
  String? _resolvedExecutablePath;
  bool _fullscreenOutputEnabled = true;
  bool _running = false;

  bool isRunning() {
    return _running && _process != null;
  }

  Future<void> startVlc() async {
    if (isRunning()) {
      _log('startVlc() skipped: VLC already running.');
      return;
    }

    await _launchVlc();
  }

  Future<void> playFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw StateError('Videodatei nicht gefunden: $path');
    }
    if (isRunning()) {
      _log('Restarting VLC for new file: $path');
      await stop();
    } else {
      _log('VLC not running. Starting before playback.');
    }

    await _launchVlc(filePath: path);
  }

  Future<void> stop() async {
    final process = _process;
    if (process == null) {
      _running = false;
      _log('stop() skipped: VLC was not running.');
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
      _attachProcess(process);
    } on ProcessException catch (error) {
      _running = false;
      throw StateError('VLC konnte nicht gestartet werden: ${error.message}');
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
        _resolvedExecutablePath = candidate;
        return candidate;
      }

      if (await File(candidate).exists()) {
        _resolvedExecutablePath = candidate;
        return candidate;
      }
    }

    throw StateError('Keine VLC-Installation gefunden.');
  }

  void _attachProcess(Process process) {
    _process = process;
    _running = true;

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
        }
      }),
    );
  }

  void _log(String message) {
    debugPrint('[VlcService] $message');
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
