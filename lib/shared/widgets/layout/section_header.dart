import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, required this.description, this.trailing, super.key});

  final String title;
  final String description;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
