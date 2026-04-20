import 'package:flutter/material.dart';
import 'package:led_management_software/domain/entities/media_asset_entity.dart';
import 'package:led_management_software/domain/enums/cue_type.dart';
import 'package:led_management_software/domain/enums/media_category.dart';

class MediaEditResult {
  const MediaEditResult({
    required this.title,
    required this.category,
    required this.sponsorName,
    required this.playerName,
    required this.tags,
    required this.cueType,
    required this.isCueLocked,
    required this.isFavorite,
  });

  final String title;
  final MediaCategory category;
  final String? sponsorName;
  final String? playerName;
  final List<String> tags;
  final CueType cueType;
  final bool isCueLocked;
  final bool isFavorite;
}

class MediaEditDialog extends StatefulWidget {
  const MediaEditDialog({required this.asset, super.key});

  final MediaAssetEntity asset;

  @override
  State<MediaEditDialog> createState() => _MediaEditDialogState();
}

class _MediaEditDialogState extends State<MediaEditDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _sponsorController;
  late final TextEditingController _playerController;
  late final TextEditingController _tagsController;
  late MediaCategory _category;
  late CueType _cueType;
  late bool _isLocked;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.asset.title);
    _sponsorController = TextEditingController(text: widget.asset.sponsorName ?? '');
    _playerController = TextEditingController(text: widget.asset.playerName ?? '');
    _tagsController = TextEditingController(text: widget.asset.tags.join(', '));
    _category = widget.asset.category;
    _cueType = widget.asset.cueType;
    _isLocked = widget.asset.isCueLocked;
    _isFavorite = widget.asset.isFavorite;
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
      title: const Text('Clip bearbeiten'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Titel')),
              const SizedBox(height: 12),
              DropdownButtonFormField<MediaCategory>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Kategorie'),
                items: MediaCategory.values
                    .map((item) => DropdownMenuItem(value: item, child: Text(item.name)))
                    .toList(growable: false),
                onChanged: (value) => setState(() => _category = value ?? _category),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CueType>(
                initialValue: _cueType,
                decoration: const InputDecoration(labelText: 'CueType'),
                items: CueType.values
                    .map((item) => DropdownMenuItem(value: item, child: Text(item.name)))
                    .toList(growable: false),
                onChanged: (value) => setState(() => _cueType = value ?? _cueType),
              ),
              const SizedBox(height: 12),
              TextField(controller: _sponsorController, decoration: const InputDecoration(labelText: 'Sponsorname')),
              const SizedBox(height: 12),
              TextField(controller: _playerController, decoration: const InputDecoration(labelText: 'Spielername')),
              const SizedBox(height: 12),
              TextField(controller: _tagsController, decoration: const InputDecoration(labelText: 'Tags (kommagetrennt)')),
              SwitchListTile(
                value: _isLocked,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) => setState(() => _isLocked = value),
                title: const Text('Gesperrter Cue'),
              ),
              SwitchListTile(
                value: _isFavorite,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) => setState(() => _isFavorite = value),
                title: const Text('Favorit'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Abbrechen')),
        FilledButton(
          onPressed: () {
            final title = _titleController.text.trim();
            if (title.isEmpty) return;
            Navigator.of(context).pop(
              MediaEditResult(
                title: title,
                category: _category,
                sponsorName: _normalize(_sponsorController.text),
                playerName: _normalize(_playerController.text),
                tags: _tagsController.text
                    .split(',')
                    .map((item) => item.trim())
                    .where((item) => item.isNotEmpty)
                    .toList(growable: false),
                cueType: _cueType,
                isCueLocked: _isLocked,
                isFavorite: _isFavorite,
              ),
            );
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }

  String? _normalize(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }
}
