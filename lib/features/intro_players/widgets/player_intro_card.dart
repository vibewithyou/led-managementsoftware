import 'package:flutter/material.dart';
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
    super.key,
  });

  final IntroLineupItemModel item;
  final int orderIndex;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleActive;

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
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.surfaceStrong,
          child: Text('${orderIndex + 1}'),
        ),
        title: Text(entry.playerName),
        subtitle: Text('Clip: ${item.clipTitle} • Kategorie: ${item.categoryLabel}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!item.hasClip)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: StatusBadge(
                  label: 'Clip fehlt',
                  type: StatusBadgeType.error,
                  compact: true,
                ),
              ),
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
