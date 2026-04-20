import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/core/theme/app_durations.dart';
import 'package:led_management_software/core/theme/app_radius.dart';
import 'package:led_management_software/core/theme/app_shadows.dart';
import 'package:led_management_software/domain/entities/project.dart';
import 'package:led_management_software/features/projects/model/project_item_model.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';

class ProjectCard extends StatefulWidget {
  const ProjectCard({
    required this.project,
    required this.isSelected,
    required this.isLiveReady,
    required this.onSetActive,
    required this.onEdit,
    required this.onDelete,
    required this.onSelect,
    this.homePlayersCount = 0,
    this.guestPlayersCount = 0,
    super.key,
  });

  final ProjectItemModel project;
  final bool isSelected;
  final bool isLiveReady;
  final VoidCallback onSetActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSelect;
  final int homePlayersCount;
  final int guestPlayersCount;

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final status = widget.project.isActive ? StatusBadgeType.active : StatusBadgeType.disabled;
    final scale = _hovered || widget.isSelected ? 1.02 : 1.0;
    final borderColor = widget.isSelected
        ? AppColors.primary
        : _hovered
            ? AppColors.borderStrong
            : widget.isLiveReady
                ? AppColors.success.withValues(alpha: 0.6)
                : AppColors.border;
    final baseSlots = const [
      ProjectCueSlot.sponsorLoop,
      ProjectCueSlot.fallback,
      ProjectCueSlot.wiper,
      ProjectCueSlot.halftime,
      ProjectCueSlot.gameEnd,
    ];
    final eventSlots = const [
      ProjectCueSlot.goal,
      ProjectCueSlot.yellowCard,
      ProjectCueSlot.redCard,
      ProjectCueSlot.penalty,
      ProjectCueSlot.sevenMeter,
      ProjectCueSlot.timeoutHome,
      ProjectCueSlot.timeoutGuest,
    ];
    final requiredConfigured = Project.requiredSlots
      .where((slot) => widget.project.cueIdForSlot(slot) != null)
      .length;
    final baseConfigured = baseSlots.where((slot) => widget.project.cueIdForSlot(slot) != null).length;
    final eventConfigured = eventSlots.where((slot) => widget.project.cueIdForSlot(slot) != null).length;
    final hasPlayerClips = widget.homePlayersCount > 0 && widget.guestPlayersCount > 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onSelect,
        child: AnimatedScale(
          duration: AppDurations.medium,
          scale: scale,
          child: AnimatedContainer(
            duration: AppDurations.medium,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: borderColor),
              boxShadow: _hovered || widget.isSelected ? AppShadows.glow(AppColors.primary) : AppShadows.panel,
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.project.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      StatusBadge(
                        label: widget.isLiveReady ? 'READY' : 'OFFEN',
                        type: widget.isLiveReady ? StatusBadgeType.ready : StatusBadgeType.queued,
                        compact: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Gegner: ${widget.project.opponent}', style: Theme.of(context).textTheme.bodyMedium),
                  Text('Datum: ${_formatDate(widget.project.date)}', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Setup $requiredConfigured/${widget.project.requiredCueCount} · Basis $baseConfigured/${baseSlots.length} · Event $eventConfigured/${eventSlots.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: widget.project.requiredCueCount > 0
                          ? requiredConfigured /
                              widget.project.requiredCueCount
                          : 0,
                      minHeight: 4,
                      backgroundColor: AppColors.border,
                      color: widget.isLiveReady ? AppColors.success : AppColors.primary,
                    ),
                  ),
                  if (widget.homePlayersCount > 0 || widget.guestPlayersCount > 0) ...[  
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Heim: ${widget.homePlayersCount} · Gast: ${widget.guestPlayersCount}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      StatusBadge(
                        label: baseConfigured == baseSlots.length ? 'Basis OK' : 'Basis offen',
                        type: baseConfigured == baseSlots.length ? StatusBadgeType.ready : StatusBadgeType.error,
                        compact: true,
                      ),
                      StatusBadge(
                        label: eventConfigured == eventSlots.length ? 'Event OK' : 'Event offen',
                        type: eventConfigured == eventSlots.length ? StatusBadgeType.ready : StatusBadgeType.queued,
                        compact: true,
                      ),
                      StatusBadge(
                        label: hasPlayerClips ? 'Spielerclips vorhanden' : 'Spielerclips offen',
                        type: hasPlayerClips ? StatusBadgeType.ready : StatusBadgeType.queued,
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
