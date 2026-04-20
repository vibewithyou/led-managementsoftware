import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/core/theme/app_durations.dart';
import 'package:led_management_software/core/theme/app_radius.dart';

enum StatusBadgeType {
  normal,
  hover,
  pressed,
  active,
  selected,
  locked,
  queued,
  disabled,
  error,
  ready,
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.label, required this.type, this.compact = false, super.key});

  final String label;
  final StatusBadgeType type;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final config = _config(type);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppDurations.medium,
      builder: (context, value, _) {
        return AnimatedContainer(
          duration: AppDurations.medium,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? AppSpacing.xs : AppSpacing.sm,
            vertical: compact ? AppSpacing.nano : AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: Color.lerp(config.background.withValues(alpha: 0.55), config.background, value),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: config.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: config.foreground,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        );
      },
    );
  }

  _BadgeConfig _config(StatusBadgeType state) {
    return switch (state) {
      StatusBadgeType.ready => const _BadgeConfig(AppColors.success, AppColors.success, AppColors.textInverted),
      StatusBadgeType.queued => const _BadgeConfig(AppColors.warning, AppColors.warning, AppColors.textInverted),
      StatusBadgeType.locked => const _BadgeConfig(AppColors.error, AppColors.error, AppColors.textPrimary),
      StatusBadgeType.disabled => const _BadgeConfig(AppColors.surfaceStrong, AppColors.disabled, AppColors.textMuted),
      StatusBadgeType.error => const _BadgeConfig(AppColors.error, AppColors.error, AppColors.textPrimary),
      StatusBadgeType.selected => const _BadgeConfig(AppColors.primary, AppColors.primary, AppColors.textPrimary),
      StatusBadgeType.active => const _BadgeConfig(AppColors.secondary, AppColors.secondary, AppColors.textInverted),
      StatusBadgeType.hover => const _BadgeConfig(AppColors.surfaceStrong, AppColors.borderStrong, AppColors.textPrimary),
      StatusBadgeType.pressed => const _BadgeConfig(AppColors.primary, AppColors.primary, AppColors.textPrimary),
      _ => const _BadgeConfig(AppColors.surfaceMuted, AppColors.border, AppColors.textMuted),
    };
  }
}

class _BadgeConfig {
  const _BadgeConfig(this.background, this.border, this.foreground);

  final Color background;
  final Color border;
  final Color foreground;
}
