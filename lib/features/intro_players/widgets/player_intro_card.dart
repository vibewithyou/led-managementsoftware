import 'package:flutter/material.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/core/theme/app_radius.dart';
import 'package:led_management_software/domain/entities/lineup_entry.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';

class PlayerIntroCard extends StatelessWidget {
  const PlayerIntroCard({
    required this.entry,
    required this.orderIndex,
    required this.onDelete,
    required this.onToggleActive,
    super.key,
  });

  final LineupEntry entry;
  final int orderIndex;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(entry.id),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.surfaceStrong,
          child: Text('${orderIndex + 1}'),
        ),
        title: Text(entry.playerName),
        subtitle: Text('cueId: ${entry.introCueId ?? '-'} • orderIndex: ${entry.sortOrder}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusBadge(
              label: entry.isActive ? 'AKTIV' : 'DEAKTIVIERT',
              type: entry.isActive ? StatusBadgeType.ready : StatusBadgeType.disabled,
              compact: true,
            ),
            const SizedBox(width: 8),
            Switch(
              value: entry.isActive,
              onChanged: onToggleActive,
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
