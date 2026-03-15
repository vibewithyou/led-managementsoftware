import 'package:flutter/material.dart';
import 'package:led_management_software/domain/enums/cue_type.dart';
import 'package:led_management_software/domain/enums/media_category.dart';

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
  });

  final String title;
  final MediaCategory category;
  final String? sponsorName;
  final String? playerName;
  final List<String> tags;
  final CueType cueType;
  final bool isSponsorLocked;
  final bool isFavorite;
}

class MediaImportDialog extends StatefulWidget {
  const MediaImportDialog({required this.fileName, super.key});

  final String fileName;

  @override
  State<MediaImportDialog> createState() => _MediaImportDialogState();
}

class _MediaImportDialogState extends State<MediaImportDialog> {
  late final TextEditingController _titleController;
  final TextEditingController _sponsorController = TextEditingController();
  final TextEditingController _playerController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  MediaCategory _category = MediaCategory.general;
  CueType _cueType = CueType.oneShot;
  bool _isSponsorLocked = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.fileName);
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
    return AlertDialog(
      title: const Text('Clip importieren'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Datei: ${widget.fileName}', style: Theme.of(context).textTheme.bodySmall),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titel'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<MediaCategory>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Kategorie'),
                items: MediaCategory.values
                    .map(
                      (category) => DropdownMenuItem<MediaCategory>(
                        value: category,
                        child: Text(category.name),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _category = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _sponsorController,
                decoration: const InputDecoration(labelText: 'Sponsorname (optional)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _playerController,
                decoration: const InputDecoration(labelText: 'Spielername (optional)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  hintText: 'z. B. tor, intro, heimteam',
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
                        child: Text(cueType.name),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _cueType = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _isSponsorLocked,
                onChanged: (value) {
                  setState(() {
                    _isSponsorLocked = value ?? false;
                  });
                },
                title: const Text('Sponsor Locked'),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _isFavorite,
                onChanged: (value) {
                  setState(() {
                    _isFavorite = value ?? false;
                  });
                },
                title: const Text('Favorit'),
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
        FilledButton(
          onPressed: () {
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
              ),
            );
          },
          child: const Text('Import starten'),
        ),
      ],
    );
  }

  String? _normalizeOptional(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }
}
