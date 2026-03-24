import 'dart:convert';
import 'dart:io';

class VideoMetadata {
  const VideoMetadata({
    required this.durationMs,
    required this.fileSizeBytes,
    required this.fileExtension,
    required this.metadataIncomplete,
    required this.lastValidatedAt,
    required this.warning,
  });

  final int durationMs;
  final int fileSizeBytes;
  final String fileExtension;
  final bool metadataIncomplete;
  final DateTime lastValidatedAt;
  final String? warning;
}

class VideoMetadataService {
  VideoMetadataService({String? ffprobeExecutablePath}) : _ffprobeExecutablePath = ffprobeExecutablePath;

  final String? _ffprobeExecutablePath;

  static const int fallbackDurationMs = 7000;

  Future<VideoMetadata> analyzeFile({
    required String filePath,
    required String fileName,
  }) async {
    final file = File(filePath);
    final fileSize = await _safeFileLength(file);
    final extension = _extractExtension(fileName);
    final validationTime = DateTime.now();

    final probeDuration = await _probeDurationViaFfprobe(filePath);
    if (probeDuration != null && probeDuration > 0) {
      return VideoMetadata(
        durationMs: probeDuration,
        fileSizeBytes: fileSize,
        fileExtension: extension,
        metadataIncomplete: false,
        lastValidatedAt: validationTime,
        warning: null,
      );
    }

    return VideoMetadata(
      durationMs: fallbackDurationMs,
      fileSizeBytes: fileSize,
      fileExtension: extension,
      metadataIncomplete: true,
      lastValidatedAt: validationTime,
      warning: 'Videodauer konnte nicht ermittelt werden. Fallback ${fallbackDurationMs ~/ 1000}s verwendet.',
    );
  }

  Future<int?> _probeDurationViaFfprobe(String filePath) async {
    final executable = await _resolveFfprobeExecutable();
    if (executable == null) {
      return null;
    }

    try {
      final result = await Process.run(
        executable,
        [
          '-v',
          'quiet',
          '-print_format',
          'json',
          '-show_format',
          filePath,
        ],
      );

      if (result.exitCode != 0) {
        return null;
      }

      final output = (result.stdout ?? '').toString().trim();
      if (output.isEmpty) {
        return null;
      }

      final payload = jsonDecode(output) as Map<String, dynamic>;
      final format = payload['format'] as Map<String, dynamic>?;
      final durationRaw = format?['duration'];
      final durationSeconds = double.tryParse(durationRaw?.toString() ?? '');
      if (durationSeconds == null || durationSeconds.isNaN || durationSeconds <= 0) {
        return null;
      }

      return (durationSeconds * 1000).round();
    } catch (_) {
      return null;
    }
  }

  Future<String?> _resolveFfprobeExecutable() async {
    final override = _ffprobeExecutablePath?.trim();
    final candidates = <String>[
      if (override != null && override.isNotEmpty) override,
      if (Platform.isWindows) r'C:\ffmpeg\bin\ffprobe.exe',
      if (Platform.isWindows) r'C:\Program Files\ffmpeg\bin\ffprobe.exe',
      if (Platform.isWindows) r'C:\Program Files (x86)\ffmpeg\bin\ffprobe.exe',
      'ffprobe',
    ];

    for (final candidate in candidates) {
      if (candidate == 'ffprobe') {
        return candidate;
      }
      if (await File(candidate).exists()) {
        return candidate;
      }
    }
    return null;
  }

  Future<int> _safeFileLength(File file) async {
    try {
      return await file.length();
    } catch (_) {
      return 0;
    }
  }

  String _extractExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex >= fileName.length - 1) {
      return 'unknown';
    }
    return fileName.substring(dotIndex + 1).toLowerCase();
  }
}
