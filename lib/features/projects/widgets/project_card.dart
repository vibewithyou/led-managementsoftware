import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/core/theme/app_durations.dart';
import 'package:led_management_software/core/theme/app_radius.dart';
import 'package:led_management_software/core/theme/app_shadows.dart';
import 'package:led_management_software/features/projects/model/project_item_model.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';

class ProjectCard extends StatefulWidget {
  const ProjectCard({
    required this.project,
    required this.onSetActive,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final ProjectItemModel project;
  final VoidCallback onSetActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final status = widget.project.isActive ? StatusBadgeType.active : StatusBadgeType.disabled;
    final scale = _hovered ? 1.02 : 1.0;
    final borderColor = _hovered ? AppColors.borderStrong : AppColors.border;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        duration: AppDurations.medium,
        scale: scale,
        child: AnimatedContainer(
          duration: AppDurations.medium,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: borderColor),
            boxShadow: _hovered ? AppShadows.glow(AppColors.primary) : AppShadows.panel,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.project.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text('Gegner: ${widget.project.opponent}', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 2),
                Text('Datum: ${_formatDate(widget.project.date)}', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                Text('Halle: ${widget.project.venue}', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                Text('Clips: ${widget.project.clipCount}', style: Theme.of(context).textTheme.bodySmall),

                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    StatusBadge(
                      label: widget.project.sponsorLoopCueId == null ? 'Sponsor fehlt' : 'Sponsor gesetzt',
                      type: widget.project.sponsorLoopCueId == null ? StatusBadgeType.error : StatusBadgeType.ready,
                      compact: true,
                    ),
                    StatusBadge(
                      label: widget.project.fallbackCueId == null ? 'Fallback fehlt' : 'Fallback gesetzt',
                      type: widget.project.fallbackCueId == null ? StatusBadgeType.error : StatusBadgeType.ready,
                      compact: true,
                    ),
                    if (!widget.project.isConfigurationComplete)
                      const StatusBadge(
                        label: 'Unvollständig',
                        type: StatusBadgeType.queued,
                        compact: true,
                      ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    StatusBadge(
                      label: widget.project.isActive ? 'AKTIV' : 'INAKTIV',
                      type: status,
                      compact: true,
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Projekt aktiv setzen',
                      onPressed: widget.onSetActive,
                      icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
                    ),
                    IconButton(
                      tooltip: 'Projekt bearbeiten',
                      onPressed: widget.onEdit,
                      icon: const Icon(Icons.edit_rounded, size: 18),
                    ),
                    IconButton(
                      tooltip: 'Projekt löschen',
                      onPressed: widget.onDelete,
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day.$month.$year';
  }
}
