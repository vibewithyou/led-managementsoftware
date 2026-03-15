import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/core/theme/app_radius.dart';
import 'package:led_management_software/core/theme/app_shadows.dart';
import 'package:led_management_software/shared/widgets/inputs/search_input.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({required this.title, required this.subtitle, this.onMenuTap, super.key});

  final String title;
  final String subtitle;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        border: Border(bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.7))),
        boxShadow: AppShadows.topBar,
      ),
      child: Row(
        children: [
          if (onMenuTap != null) ...[
            IconButton.filledTonal(
              onPressed: onMenuTap,
              icon: const Icon(Icons.menu_rounded),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xxs),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const SearchInput(hintText: 'Clip, Projekt oder Cue suchen...'),
          const SizedBox(width: AppSpacing.md),
          const StatusBadge(label: 'SYSTEM READY', type: StatusBadgeType.ready),
          const SizedBox(width: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.65)),
            ),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
              ),
              onPressed: () {},
              icon: const Icon(Icons.play_circle_outline_rounded),
              label: const Text('Test-Output'),
            ),
          ),
        ],
      ),
    );
  }
}
