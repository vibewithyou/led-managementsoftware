import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/domain/entities/project.dart';
import 'package:led_management_software/features/projects/model/project_cue_option_model.dart';
import 'package:led_management_software/features/projects/model/project_item_model.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';

class ProjectFormResult {
  const ProjectFormResult({
    required this.name,
    required this.opponent,
    required this.venue,
    required this.date,
    required this.cueAssignments,
  });

  final String name;
  final String opponent;
  final String venue;
  final DateTime date;
  final Map<ProjectCueSlot, String?> cueAssignments;

  String? cueIdForSlot(ProjectCueSlot slot) => cueAssignments[slot];
}

class ProjectFormDialog extends StatefulWidget {
  const ProjectFormDialog({
    required this.allCueOptions,
    required this.sponsorLoopOptions,
    required this.fallbackOptions,
    this.initialProject,
    super.key,
  });

  final List<ProjectCueOptionModel> allCueOptions;
  final List<ProjectCueOptionModel> sponsorLoopOptions;
  final List<ProjectCueOptionModel> fallbackOptions;
  final ProjectItemModel? initialProject;

  @override
  State<ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<ProjectFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _opponentController;
  late final TextEditingController _venueController;
  late DateTime _date;
  late final Map<ProjectCueSlot, String?> _selectedCueIds;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialProject?.name ?? '');
    _opponentController = TextEditingController(text: widget.initialProject?.opponent ?? '');
    _venueController = TextEditingController(text: widget.initialProject?.venue ?? '');
    _date = widget.initialProject?.date ?? DateTime.now();
    _selectedCueIds = {
      for (final slot in ProjectCueSlot.values) slot: widget.initialProject?.cueIdForSlot(slot),
    };
  }

  @override
  void dispose() {
    _nameController.dispose();
    _opponentController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialProject != null;

    return AlertDialog(
      title: Text(isEdit ? 'Projekt bearbeiten' : 'Projekt erstellen'),
      content: SizedBox(
        width: 760,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(controller: _nameController, label: 'Projektname', icon: Icons.stadium_rounded),
              const SizedBox(height: AppSpacing.md),
              _buildTextField(controller: _opponentController, label: 'Gegner', icon: Icons.groups_rounded),
              const SizedBox(height: AppSpacing.md),
              _buildTextField(controller: _venueController, label: 'Halle', icon: Icons.location_on_rounded),
              const SizedBox(height: AppSpacing.md),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Datum'),
                  child: Row(
                    children: [
                      const Icon(Icons.event_rounded, size: 18),
                      const SizedBox(width: AppSpacing.sm),
                      Text(_formatDate(_date)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildSetupHint(),
              const SizedBox(height: AppSpacing.md),
              _buildMinimalSetupSection(),
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
          onPressed: _submit,
          child: Text(isEdit ? 'Speichern' : 'Erstellen'),
        ),
      ],
    );
  }

  Widget _buildStatusRow() {
    final sponsorSet = _selectedCueIds[ProjectCueSlot.sponsorLoop] != null;
    final fallbackSet = _selectedCueIds[ProjectCueSlot.fallback] != null;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        StatusBadge(
          label: sponsorSet ? 'Sponsor Loop gesetzt' : 'Sponsor Loop offen',
          type: sponsorSet ? StatusBadgeType.ready : StatusBadgeType.queued,
        ),
        StatusBadge(
          label: fallbackSet ? 'Fallback gesetzt' : 'Fallback offen',
          type: fallbackSet ? StatusBadgeType.ready : StatusBadgeType.queued,
        ),
      ],
    );
  }

  Widget _buildSetupHint() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hinweis zur Konfiguration',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Die vollständige Slot-Konfiguration (Basisclips, Eventclips, Spielerstatus) erfolgt im Projektdetail.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalSetupSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Initial-Setup (optional)', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Sponsor-Loop und Fallback können bereits hier gesetzt werden.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildStatusRow(),
        const SizedBox(height: AppSpacing.md),
        _buildCuePicker(
          slot: ProjectCueSlot.sponsorLoop,
          value: _selectedCueIds[ProjectCueSlot.sponsorLoop],
          onSelected: (value) => setState(() => _selectedCueIds[ProjectCueSlot.sponsorLoop] = value),
          options: _optionsForSlot(ProjectCueSlot.sponsorLoop),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildCuePicker(
          slot: ProjectCueSlot.fallback,
          value: _selectedCueIds[ProjectCueSlot.fallback],
          onSelected: (value) => setState(() => _selectedCueIds[ProjectCueSlot.fallback] = value),
          options: _optionsForSlot(ProjectCueSlot.fallback),
        ),
      ],
    );
  }

  Widget _buildCuePicker({
    required ProjectCueSlot slot,
    required String? value,
    required ValueChanged<String?> onSelected,
    required List<ProjectCueOptionModel> options,
  }) {
    final hasOptions = options.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownMenu<String>(
          width: 720,
          initialSelection: value,
          requestFocusOnTap: true,
          enableSearch: true,
          label: Text(slot.label),
          helperText: _helperTextForSlot(slot),
          onSelected: (value) => onSelected((value == null || value.isEmpty) ? null : value),
          dropdownMenuEntries: [
            const DropdownMenuEntry<String>(
              value: '',
              label: 'Nicht gesetzt',
              leadingIcon: Icon(Icons.remove_circle_outline_rounded),
            ),
            ...options.map(
              (option) => DropdownMenuEntry<String>(
                value: option.id,
                label: option.title,
                leadingIcon: Icon(option.isLocked ? Icons.lock_rounded : Icons.lock_open_rounded),
                trailingIcon: Text(option.categoryLabel),
              ),
            ),
          ],
        ),
        if (!hasOptions)
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _warningTextForSlot(slot),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: _date,
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _date = picked;
    });
  }

  void _submit() {
    final name = _nameController.text.trim();
    final opponent = _opponentController.text.trim();
    final venue = _venueController.text.trim();

    if (name.isEmpty || opponent.isEmpty || venue.isEmpty) {
      return;
    }

    Navigator.of(context).pop(
      ProjectFormResult(
        name: name,
        opponent: opponent,
        venue: venue,
        date: _date,
        cueAssignments: {
          for (final entry in _selectedCueIds.entries)
            entry.key: entry.value?.isEmpty ?? true ? null : entry.value,
        },
      ),
    );
  }

  List<ProjectCueOptionModel> _optionsForSlot(ProjectCueSlot slot) {
    return switch (slot) {
      ProjectCueSlot.sponsorLoop => widget.sponsorLoopOptions,
      ProjectCueSlot.fallback => widget.fallbackOptions,
      _ => widget.allCueOptions,
    };
  }

  String _helperTextForSlot(ProjectCueSlot slot) {
    return switch (slot) {
      ProjectCueSlot.sponsorLoop => 'Bevorzugt Sponsor-Kategorie sowie lockedSponsor/loop',
      ProjectCueSlot.fallback => 'Bevorzugt fallback- oder loop-Clips als Rückfallebene',
      _ => 'Konfiguration erfolgt im Projektdetail',
    };
  }

  String _warningTextForSlot(ProjectCueSlot slot) {
    return '${slot.label} hat aktuell keine verfügbaren Clips. Das Projekt kann gespeichert werden, bleibt aber unvollständig.';
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day.$month.${value.year}';
  }
}
