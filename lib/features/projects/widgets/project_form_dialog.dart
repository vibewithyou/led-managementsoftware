import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/features/projects/model/project_cue_option_model.dart';
import 'package:led_management_software/features/projects/model/project_item_model.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';

class ProjectFormResult {
  const ProjectFormResult({
    required this.name,
    required this.opponent,
    required this.venue,
    required this.date,
    required this.sponsorLoopCueId,
    required this.fallbackCueId,
  });

  final String name;
  final String opponent;
  final String venue;
  final DateTime date;
  final String? sponsorLoopCueId;
  final String? fallbackCueId;
}

class ProjectFormDialog extends StatefulWidget {
  const ProjectFormDialog({
    required this.sponsorLoopOptions,
    required this.fallbackOptions,
    this.initialProject,
    super.key,
  });

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
  String? _selectedSponsorLoopCueId;
  String? _selectedFallbackCueId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialProject?.name ?? '');
    _opponentController = TextEditingController(text: widget.initialProject?.opponent ?? '');
    _venueController = TextEditingController(text: widget.initialProject?.venue ?? '');
    _date = widget.initialProject?.date ?? DateTime.now();
    _selectedSponsorLoopCueId = widget.initialProject?.sponsorLoopCueId;
    _selectedFallbackCueId = widget.initialProject?.fallbackCueId;
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
        width: 560,
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
              _buildStatusRow(),
              const SizedBox(height: AppSpacing.md),
              _buildCuePicker(
                label: 'Sponsor Loop Cue',
                helperText: 'Bevorzugt Clips aus Sponsor-Kategorie sowie CueType lockedSponsor/loop',
                value: _selectedSponsorLoopCueId,
                onSelected: (value) => setState(() => _selectedSponsorLoopCueId = value),
                options: widget.sponsorLoopOptions,
                warningText:
                    'Kein passender Sponsor-Loop vorhanden. Du kannst trotzdem speichern, das Projekt wird als unvollständig markiert.',
              ),
              const SizedBox(height: AppSpacing.md),
              _buildCuePicker(
                label: 'Fallback Cue',
                helperText: 'Bevorzugt Clips mit CueType fallback/loop',
                value: _selectedFallbackCueId,
                onSelected: (value) => setState(() => _selectedFallbackCueId = value),
                options: widget.fallbackOptions,
                warningText:
                    'Kein passender Fallback-Clip vorhanden. Du kannst trotzdem speichern, das Projekt wird als unvollständig markiert.',
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
          onPressed: _submit,
          child: Text(isEdit ? 'Speichern' : 'Erstellen'),
        ),
      ],
    );
  }

  Widget _buildStatusRow() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        StatusBadge(
          label: _selectedSponsorLoopCueId == null ? 'Sponsor Loop fehlt' : 'Sponsor Loop gesetzt',
          type: _selectedSponsorLoopCueId == null ? StatusBadgeType.error : StatusBadgeType.ready,
        ),
        StatusBadge(
          label: _selectedFallbackCueId == null ? 'Fallback fehlt' : 'Fallback gesetzt',
          type: _selectedFallbackCueId == null ? StatusBadgeType.error : StatusBadgeType.ready,
        ),
      ],
    );
  }

  Widget _buildCuePicker({
    required String label,
    required String helperText,
    required String? value,
    required ValueChanged<String?> onSelected,
    required List<ProjectCueOptionModel> options,
    required String warningText,
  }) {
    final hasOptions = options.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownMenu<String>(
          width: 520,
          initialSelection: value,
          requestFocusOnTap: true,
          enableSearch: true,
          label: Text(label),
          helperText: helperText,
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
                    warningText,
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
        sponsorLoopCueId: _selectedSponsorLoopCueId?.isEmpty ?? true ? null : _selectedSponsorLoopCueId,
        fallbackCueId: _selectedFallbackCueId?.isEmpty ?? true ? null : _selectedFallbackCueId,
      ),
    );
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day.$month.${value.year}';
  }
}
