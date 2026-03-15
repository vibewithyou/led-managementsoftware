import 'package:flutter/material.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/core/theme/app_radius.dart';
import 'package:led_management_software/features/intro_players/model/player_intro_model.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';

class PlayerIntroCard extends StatelessWidget {
  const PlayerIntroCard({required this.player, super.key});

  final PlayerIntroModel player;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        title: Text('#${player.number} ${player.name}'),
        subtitle: Text('${player.position} • ${player.clip}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const StatusBadge(label: 'READY', type: StatusBadgeType.ready, compact: true),
            const SizedBox(width: 8),
            FilledButton.tonal(onPressed: () {}, child: const Text('Trigger')),
          ],
        ),
      ),
    );
  }
}
