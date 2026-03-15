import 'package:flutter/material.dart';
import 'package:led_management_software/features/projects/model/project_item_model.dart';

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
  const ProjectFormDialog({required this.availableCueIds, this.initialProject, super.key});

  final List<String> availableCueIds;
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
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Projektname'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _opponentController,
                decoration: const InputDecoration(labelText: 'Gegner'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _venueController,
                decoration: const InputDecoration(labelText: 'Halle'),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Datum'),
                  child: Row(
                    children: [
                      const Icon(Icons.event_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(_formatDate(_date)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedSponsorLoopCueId,
                decoration: const InputDecoration(labelText: 'Standard Sponsorloop auswählen'),
                items: _buildCueItems(),
                onChanged: (value) => setState(() => _selectedSponsorLoopCueId = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedFallbackCueId,
                decoration: const InputDecoration(labelText: 'Fallback Cue auswählen'),
                items: _buildCueItems(),
                onChanged: (value) => setState(() => _selectedFallbackCueId = value),
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

  List<DropdownMenuItem<String>> _buildCueItems() {
    return widget.availableCueIds
        .map(
          (cueId) => DropdownMenuItem<String>(
            value: cueId,
            child: Text(cueId),
          ),
        )
        .toList(growable: false);
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
        sponsorLoopCueId: _selectedSponsorLoopCueId,
        fallbackCueId: _selectedFallbackCueId,
      ),
    );
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day.$month.${value.year}';
  }
}
