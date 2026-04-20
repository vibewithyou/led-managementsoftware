import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/domain/entities/project.dart';
import 'package:led_management_software/features/projects/model/project_cue_option_model.dart';
import 'package:led_management_software/features/projects/model/project_item_model.dart';
import 'package:led_management_software/features/projects/widgets/project_slot_row.dart';

class ProjectClipSlotSection extends StatelessWidget {
  const ProjectClipSlotSection({
    required this.title,
    required this.slots,
    required this.project,
    required this.cueLookup,
    required this.onAssign,
    required this.onChange,
    required this.onRemove,
    this.description,
    super.key,
  });

  final String title;
  final String? description;
  final List<ProjectCueSlot> slots;
  final ProjectItemModel project;
  final ProjectCueOptionModel? Function(String? cueId) cueLookup;
  final ValueChanged<ProjectCueSlot> onAssign;
  final ValueChanged<ProjectCueSlot> onChange;
  final ValueChanged<ProjectCueSlot> onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          if (description != null && description!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              description!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          for (var i = 0; i < slots.length; i++) ...[
            Builder(
              builder: (_) {
                final slot = slots[i];
                final cueId = project.cueIdForSlot(slot);
                final cue = cueLookup(cueId);
                return ProjectSlotRow(
                  slot: slot,
                  cueId: cueId,
                  cueTitle: cue?.title,
                  cueCategoryLabel: cue?.categoryLabel,
                  fileStatus: cue?.fileStatus,
                  onAssign: () => onAssign(slot),
                  onChange: () => onChange(slot),
                  onRemove: () => onRemove(slot),
                );
              },
            ),
            if (i < slots.length - 1) const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}