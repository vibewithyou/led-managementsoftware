import 'package:flutter/material.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/data/services/video_metadata_service.dart';
import 'package:led_management_software/domain/enums/cue_type.dart';
import 'package:led_management_software/domain/enums/media_category.dart';
import 'package:led_management_software/shared/utils/media_formatters.dart';

class MediaImportDialogResult {
  const MediaImportDialogResult({
    required this.title,
    required this.category,
    required this.sponsorName,
    required this.playerName,
    required this.tags,
    required this.cueType,
    required this.isSponsorLocked,
    required this.isFavorite,
    required this.detectedDurationMs,
    required this.detectedFileExtension,
    required this.analysisWarning,
  });

  final String title;
  final MediaCategory category;
  final String? sponsorName;
  final String? playerName;
  final List<String> tags;
  final CueType cueType;
  final bool isSponsorLocked;
  final bool isFavorite;
  final int? detectedDurationMs;
  final String? detectedFileExtension;
  final String? analysisWarning;
}

MediaCategory _suggestCategory(String fileName) {
  final lower = fileName.toLowerCase();
  if (lower.contains('sponsor') || lower.contains('logo') || lower.contains('brand')) {
    return MediaCategory.sponsor;
  }
  if (lower.contains('intro') && (lower.contains('home') || lower.contains('heim'))) {
    return MediaCategory.introHome;
  }
  if (lower.contains('intro') && (lower.contains('guest') || lower.contains('gast') || lower.contains('away'))) {
    return MediaCategory.introGuest;
  }
  if (lower.contains('intro')) {
    return MediaCategory.introHome;
  }
  if (lower.contains('pregame') || lower.contains('pre_game') || lower.contains('countdown') || lower.contains('opening')) {
    return MediaCategory.pregame;
  }
  if (lower.contains('halftime') || lower.contains('half_time') || lower.contains('halbzeit') || lower.contains('pause')) {
    return MediaCategory.halftime;
  }
  if (lower.contains('postgame') || lower.contains('post_game') || lower.contains('abschluss')) {
    return MediaCategory.postgame;
  }
  if (lower.contains('player') || lower.contains('spieler') || lower.contains('portrait')) {
    return MediaCategory.player;
  }
  if (lower.contains('tor') || lower.contains('goal') || lower.contains('event') || lower.contains('jubel')) {
    return MediaCategory.event;
  }
  if (lower.contains('emergency') || lower.contains('notfall') || lower.contains('filler')) {
    return MediaCategory.emergency;
  }
  return MediaCategory.general;
}

class MediaImportDialog extends StatefulWidget {
  const MediaImportDialog({
    required this.fileName,
    required this.filePath,
    super.key,
  });

  final String fileName;
  final String filePath;

  @override
  State<MediaImportDialog> createState() => _MediaImportDialogState();
}

class _MediaImportDialogState extends State<MediaImportDialog> {
  late final TextEditingController _titleController;
  final TextEditingController _sponsorController = TextEditingController();
  final TextEditingController _playerController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final VideoMetadataService _metadataService = VideoMetadataService();

  late MediaCategory _category;
  CueType _cueType = CueType.oneShot;
  bool _isSponsorLocked = false;
  bool _isFavorite = false;
  bool _categoryWasAutoSuggested = false;
  bool _isAnalyzing = true;
  VideoMetadata? _analysis;

  @override
  void initState() {
    super.initState();
    final baseName = widget.fileName.contains('.')
        ? widget.fileName.substring(0, widget.fileName.lastIndexOf('.'))
        : widget.fileName;
    _titleController = TextEditingController(text: _humanizeFileName(baseName));

    final suggested = _suggestCategory(widget.fileName);
    _category = suggested;
    _categoryWasAutoSuggested = suggested != MediaCategory.general;

    if (suggested == MediaCategory.sponsor) {
      _cueType = CueType.lockedSponsor;
      _isSponsorLocked = true;
    } else if (suggested == MediaCategory.pregame || suggested == MediaCategory.halftime) {
      _cueType = CueType.loop;
    }

    _analyzeFile();
  }

  String _humanizeFileName(String raw) {
    return raw.replaceAll(RegExp(r'[_\-]+'), ' ').trim();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _sponsorController.dispose();
    _playerController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Clip importieren'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFileInfo(theme),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titel'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<MediaCategory>(
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: 'Kategorie',
                  suffixIcon: _categoryWasAutoSuggested
                      ? Tooltip(
                          message: 'Automatisch aus Dateiname erkannt',
                          child: Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.secondary),
                        )
                      : null,
                ),
                items: MediaCategory.values
                    .map(
                      (category) => DropdownMenuItem<MediaCategory>(
                        value: category,
                        child: Text(_categoryLabel(category)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _category = value;
                    _categoryWasAutoSuggested = false;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _sponsorController,
                decoration: const InputDecoration(
                  labelText: 'Sponsorname',
                  hintText: 'optional',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _playerController,
                decoration: const InputDecoration(
                  labelText: 'Spielername',
                  hintText: 'optional',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  hintText: 'z. B. tor, intro, heimteam  (kommagetrennt)',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CueType>(
                initialValue: _cueType,
                decoration: const InputDecoration(labelText: 'CueType'),
                items: CueType.values
                    .map(
                      (cueType) => DropdownMenuItem<CueType>(
                        value: cueType,
                        child: Text(_cueTypeLabel(cueType)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _cueType = value);
                },
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _isSponsorLocked,
                onChanged: (value) => setState(() => _isSponsorLocked = value ?? false),
                title: const Text('Sponsor gesperrt (Locked)'),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _isFavorite,
                onChanged: (value) => setState(() => _isFavorite = value ?? false),
                title: const Text('Als Favorit markieren'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.file_upload_rounded, size: 18),
          onPressed: _titleController.text.trim().isNotEmpty ? _submit : null,
          label: const Text('Importieren'),
        ),
      ],
    );
  }

  Widget _buildFileInfo(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.video_file_rounded, size: 16, color: AppColors.secondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.fileName,
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.filePath,
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          if (_isAnalyzing)
            Row(
              children: [
                const SizedBox(
                  height: 14,
                  width: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text('Datei wird analysiert...', style: theme.textTheme.bodySmall),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dauer: ${formatDurationMs(_analysis?.durationMs ?? 0)}', style: theme.textTheme.bodySmall),
                Text('Dateityp: ${(_analysis?.fileExtension ?? 'unknown').toUpperCase()}', style: theme.textTheme.bodySmall),
                if (_analysis?.warning != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _analysis!.warning!,
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.warning),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _analyzeFile() async {
    setState(() {
      _isAnalyzing = true;
    });

    final metadata = await _metadataService.analyzeFile(filePath: widget.filePath, fileName: widget.fileName);
    if (!mounted) {
      return;
    }
    setState(() {
      _analysis = metadata;
      _isAnalyzing = false;
    });
  }

  void _submit() {
    Navigator.of(context).pop(
      MediaImportDialogResult(
        title: _titleController.text.trim(),
        category: _category,
        sponsorName: _normalizeOptional(_sponsorController.text),
        playerName: _normalizeOptional(_playerController.text),
        tags: _tagsController.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(growable: false),
        cueType: _cueType,
        isSponsorLocked: _isSponsorLocked,
        isFavorite: _isFavorite,
        detectedDurationMs: _analysis?.durationMs,
        detectedFileExtension: _analysis?.fileExtension,
        analysisWarning: _analysis?.warning,
      ),
    );
  }

  String? _normalizeOptional(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  String _categoryLabel(MediaCategory category) {
    switch (category) {
      case MediaCategory.general:
        return 'Allgemein';
      case MediaCategory.pregame:
        return 'Vorspiel / Pre-Game';
      case MediaCategory.sponsor:
        return 'Sponsor';
      case MediaCategory.introHome:
        return 'Intro Heimteam';
      case MediaCategory.introGuest:
        return 'Intro Gastteam';
      case MediaCategory.player:
        return 'Spieler';
      case MediaCategory.event:
        return 'Event (Tor, Jubel…)';
      case MediaCategory.halftime:
        return 'Halbzeit';
      case MediaCategory.postgame:
        return 'Nachspiel / Post-Game';
      case MediaCategory.emergency:
        return 'Notfall / Filler';
    }
  }

  String _cueTypeLabel(CueType cueType) {
    switch (cueType) {
      case CueType.loop:
        return 'Loop';
      case CueType.oneShot:
        return 'Einmalig (OneShot)';
      case CueType.lockedSponsor:
        return 'Sponsor Locked';
      case CueType.event:
        return 'Event';
      case CueType.fallback:
        return 'Fallback';
    }
  }
}
