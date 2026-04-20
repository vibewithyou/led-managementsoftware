import 'package:flutter/material.dart';
import 'package:led_management_software/app/routing/app_route.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/core/theme/app_radius.dart';
import 'package:led_management_software/shared/widgets/layout/sidebar_navigation_item.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';

class SidebarNavigation extends StatelessWidget {
  const SidebarNavigation({
    required this.currentRoute,
    required this.compact,
    required this.onSelect,
    super.key,
  });

  final AppRoute currentRoute;
  final bool compact;
  final ValueChanged<AppRoute> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 94 : 286,
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        border: Border(right: BorderSide(color: AppColors.border.withValues(alpha: 0.75))),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
            child: Row(
              mainAxisAlignment: compact ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(Icons.live_tv_rounded, color: AppColors.textPrimary, size: 20),
                ),
                if (!compact) ...[
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('LED Regie', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        Text('Live Broadcast Control', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  const StatusBadge(label: 'LIVE', type: StatusBadgeType.active, compact: true),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.sm),
              itemBuilder: (context, index) {
                final route = AppRoute.values[index];
                return SidebarNavigationItem(
                  label: route.label,
                  icon: route.icon,
                  selected: route == currentRoute,
                  compact: compact,
                  onTap: () => onSelect(route),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.xs),
              itemCount: AppRoute.values.length,
            ),
          ),
        ],
      ),
    );
  }
}
