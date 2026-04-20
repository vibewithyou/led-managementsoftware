import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/core/theme/app_radius.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';

class LiveMetricCard extends StatelessWidget {
  const LiveMetricCard({
    required this.title,
    required this.value,
    required this.delta,
    required this.status,
    super.key,
  });

  final String title;
  final String value;
  final String delta;
  final StatusBadgeType status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: Theme.of(context).textTheme.labelMedium)),
              StatusBadge(label: status.name.toUpperCase(), type: status, compact: true),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(delta, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
