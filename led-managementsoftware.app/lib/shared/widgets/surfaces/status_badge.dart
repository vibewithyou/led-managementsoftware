import 'package:flutter/material.dart';
import 'package:led_managementsoftware_app/core/theme/app_colors.dart';

enum StatusBadgeTone { neutral, info, success, warning, danger }

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    required this.tone,
    this.compact = false,
    super.key,
  });

  final String label;
  final StatusBadgeTone tone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = switch (tone) {
      StatusBadgeTone.neutral => (AppColors.surfaceStrong, AppColors.textSoft),
      StatusBadgeTone.info => (AppColors.info.withValues(alpha: 0.18), AppColors.info),
      StatusBadgeTone.success => (AppColors.success.withValues(alpha: 0.18), AppColors.success),
      StatusBadgeTone.warning => (AppColors.warning.withValues(alpha: 0.18), AppColors.warning),
      StatusBadgeTone.danger => (AppColors.danger.withValues(alpha: 0.18), AppColors.danger),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: compact ? 5 : 7),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.$2.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.$2,
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}