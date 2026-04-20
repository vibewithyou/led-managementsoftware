import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/core/theme/app_radius.dart';
import 'package:led_management_software/features/intro_players/model/intro_lineup_item_model.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';

class PlayerIntroCard extends StatelessWidget {
  const PlayerIntroCard({
    required this.item,
    required this.orderIndex,
    required this.onDelete,
    required this.onToggleActive,
    this.onEdit,
    this.onAssignClip,
    this.onChangeClip,
    this.onRemoveClip,
    super.key,
  });

  final IntroLineupItemModel item;
  final int orderIndex;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback? onEdit;
  final VoidCallback? onAssignClip;
  final VoidCallback? onChangeClip;
  final VoidCallback? onRemoveClip;

  @override
  Widget build(BuildContext context) {
    final entry = item.entry;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      key: ValueKey(entry.id),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: item.hasClip ? AppColors.border : AppColors.warning),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.surfaceStrong,
                  child: Text('${orderIndex + 1}'),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.playerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Nummer: ${entry.jerseyNumber.trim().isEmpty ? '-' : entry.jerseyNumber}'
                        '  ·  ${entry.position.trim().isEmpty ? '-' : entry.position}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit?.call();
                    }
                    if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    if (onEdit != null) const PopupMenuItem(value: 'edit', child: Text('Bearbeiten')),
                    const PopupMenuItem(value: 'delete', child: Text('Spieler entfernen')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Clip: ${item.clipTitle}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 2),
            Text(
              'Kategorie: ${item.categoryLabel}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (!item.hasClip && onAssignClip != null)
                  FilledButton.tonalIcon(
                    onPressed: onAssignClip,
                    icon: const Icon(Icons.add_link_rounded, size: 16),
                    label: const Text('Clip zuweisen'),
                  ),
                if (item.hasClip && onChangeClip != null)
                  OutlinedButton.icon(
                    onPressed: onChangeClip,
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text('Clip ändern'),
                  ),
                if (item.hasClip && onRemoveClip != null)
                  OutlinedButton.icon(
                    onPressed: onRemoveClip,
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text('Clip entfernen'),
                  ),
                if (!item.hasClip)
                  const StatusBadge(
                    label: 'Clip fehlt',
                    type: StatusBadgeType.error,
                    compact: true,
                  ),
                StatusBadge(
                  label: entry.isActive ? 'AKTIV' : 'DEAKTIVIERT',
                  type: entry.isActive ? StatusBadgeType.ready : StatusBadgeType.disabled,
                  compact: true,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Aktiv',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 4),
                    Switch(
                      value: entry.isActive,
                      onChanged: onToggleActive,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
