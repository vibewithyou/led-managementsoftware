import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/core/theme/app_radius.dart';
import 'package:led_management_software/domain/entities/project.dart';
import 'package:led_management_software/features/projects/model/project_cue_file_status.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';

class ProjectSlotRow extends StatelessWidget {
  const ProjectSlotRow({
    required this.slot,
    required this.cueId,
    required this.cueTitle,
    required this.onAssign,
    required this.onChange,
    required this.onRemove,
    this.cueCategoryLabel,
    this.fileStatus,
    super.key,
  });

  final ProjectCueSlot slot;
  final String? cueId;
  final String? cueTitle;
  final String? cueCategoryLabel;
  final ProjectCueFileStatus? fileStatus;
  final VoidCallback onAssign;
  final VoidCallback onChange;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isSet = cueId != null && cueId!.trim().isNotEmpty;
    final isRequired = !Project.optionalSlots.contains(slot);
    final displayTitle = isSet ? (cueTitle ?? cueId!) : 'Nicht gesetzt';
    final categoryLabel = cueCategoryLabel?.trim().isNotEmpty ?? false ? cueCategoryLabel! : '-';
    final status = fileStatus;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: isSet
              ? AppColors.border
              : isRequired
                  ? AppColors.error.withValues(alpha: 0.4)
                  : AppColors.warning.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _iconForSlot(slot),
            size: 16,
            color: isSet ? AppColors.textMuted : AppColors.error.withValues(alpha: 0.7),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.xs,
                  children: [
                    Text(
                      slot.label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                    ),
                    StatusBadge(
                      label: isRequired ? 'PFLICHT' : 'OPTIONAL',
                      type: isRequired ? StatusBadgeType.hover : StatusBadgeType.disabled,
                      compact: true,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  displayTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSet ? AppColors.textPrimary : AppColors.textMuted,
                        fontWeight: isSet ? FontWeight.w600 : FontWeight.normal,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Kategorie: $categoryLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  'Dateistatus: ${status?.label ?? (isSet ? 'Unbekannt' : '-')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _fileStatusColor(status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(
                label: isSet ? 'GESETZT' : 'FEHLT',
                type: isSet ? StatusBadgeType.ready : StatusBadgeType.error,
                compact: true,
              ),
              const SizedBox(height: AppSpacing.xs),
              if (!isSet)
                FilledButton.tonalIcon(
                  onPressed: onAssign,
                  icon: const Icon(Icons.add_link_rounded, size: 16),
                  label: const Text('Zuweisen'),
                )
              else
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  alignment: WrapAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: onChange,
                      icon: const Icon(Icons.edit_rounded, size: 16),
                      label: const Text('Aendern'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onRemove,
                      icon: const Icon(Icons.delete_outline_rounded, size: 16),
                      label: const Text('Entfernen'),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _fileStatusColor(ProjectCueFileStatus? status) {
    return switch (status) {
      ProjectCueFileStatus.available => AppColors.success,
      ProjectCueFileStatus.missing => AppColors.error,
      ProjectCueFileStatus.metadataIncomplete => AppColors.warning,
      null => AppColors.textMuted,
    };
  }

  IconData _iconForSlot(ProjectCueSlot slot) {
    return switch (slot) {
      ProjectCueSlot.sponsorLoop => Icons.loop_rounded,
      ProjectCueSlot.fallback => Icons.radio_button_on_rounded,
      ProjectCueSlot.intro => Icons.celebration_rounded,
      ProjectCueSlot.goal => Icons.sports_soccer_rounded,
      ProjectCueSlot.yellowCard => Icons.style_rounded,
      ProjectCueSlot.redCard => Icons.report_rounded,
      ProjectCueSlot.penalty => Icons.timer_rounded,
      ProjectCueSlot.sevenMeter => Icons.sports_handball_rounded,
      ProjectCueSlot.timeoutHome => Icons.pause_circle_filled_rounded,
      ProjectCueSlot.timeoutGuest => Icons.pause_circle_rounded,
      ProjectCueSlot.wiper => Icons.cleaning_services_rounded,
      ProjectCueSlot.halftime => Icons.sports_score_rounded,
      ProjectCueSlot.gameEnd => Icons.flag_rounded,
    };
  }
}
