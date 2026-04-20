import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/domain/entities/project.dart';
import 'package:led_management_software/features/projects/model/project_cue_option_model.dart';

/// Opens a single-slot clip picker dialog.
///
/// Returns:
/// - `null`  → cancelled (dialog dismissed or "Abbrechen")
/// - `''`    → user cleared the slot ("Nicht gesetzt" selected and confirmed)
/// - non-empty String → selected cue ID
Future<String?> showProjectClipPicker(
  BuildContext context, {
  required ProjectCueSlot slot,
  required String? currentCueId,
  required List<ProjectCueOptionModel> options,
}) {
  return showDialog<String?>(
    context: context,
    builder: (context) => _ProjectClipPickerDialog(
      slot: slot,
      currentCueId: currentCueId,
      options: options,
    ),
  );
}

class _ProjectClipPickerDialog extends StatefulWidget {
  const _ProjectClipPickerDialog({
    required this.slot,
    required this.currentCueId,
    required this.options,
  });

  final ProjectCueSlot slot;
  final String? currentCueId;
  final List<ProjectCueOptionModel> options;

  @override
  State<_ProjectClipPickerDialog> createState() =>
      _ProjectClipPickerDialogState();
}

class _ProjectClipPickerDialogState extends State<_ProjectClipPickerDialog> {
  late final TextEditingController _searchController;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedId = widget.currentCueId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? widget.options
        : widget.options
            .where((o) => o.title.toLowerCase().contains(query))
            .toList(growable: false);

    return AlertDialog(
      title: Text('Clip für ${widget.slot.label}'),
      content: SizedBox(
        width: 520,
        height: 480,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Clip suchen',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: ListView(
                children: [
                  _PickerTile(
                    id: null,
                    title: 'Nicht gesetzt',
                    subtitle: 'Slot leeren',
                    isSelected:
                        _selectedId == null || _selectedId!.isEmpty,
                    isLocked: false,
                    onTap: () => setState(() => _selectedId = null),
                  ),
                  ...filtered.map(
                    (option) => _PickerTile(
                      id: option.id,
                      title: option.title,
                      subtitle:
                          '${option.categoryLabel} · ${option.cueTypeLabel} · ${option.fileStatusLabel}',
                      isSelected: _selectedId == option.id,
                      isLocked: option.isLocked,
                      onTap: () => setState(() => _selectedId = option.id),
                    ),
                  ),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        'Keine Clips gefunden.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(_selectedId ?? ''),
          child: const Text('Übernehmen'),
        ),
      ],
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  final String? id;
  final String title;
  final String subtitle;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: isSelected,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
      leading: Icon(
        id == null
            ? Icons.remove_circle_outline_rounded
            : isLocked
                ? Icons.lock_rounded
                : Icons.lock_open_rounded,
        size: 18,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }
}
