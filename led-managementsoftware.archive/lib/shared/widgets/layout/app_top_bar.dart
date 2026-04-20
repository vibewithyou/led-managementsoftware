import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 1160;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.backgroundElevated,
            border: Border(bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.7))),
            boxShadow: AppShadows.topBar,
          ),
          child: compact ? _compactLayout(context) : _wideLayout(context),
        );
      },
    );
  }

  Widget _wideLayout(BuildContext context) {
    return Row(
      children: [
        if (onMenuTap != null) ...[
          IconButton.filledTonal(
            onPressed: onMenuTap,
            icon: const Icon(Icons.menu_rounded),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Expanded(child: _titleBlock(context)),
        const SizedBox(width: AppSpacing.md),
        const Flexible(
          child: Align(
            alignment: Alignment.centerRight,
            child: SearchInput(hintText: 'Clip, Projekt oder Cue suchen...'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        const StatusBadge(label: 'SYSTEM READY', type: StatusBadgeType.ready),
      ],
    );
  }

  Widget _compactLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (onMenuTap != null) ...[
              IconButton.filledTonal(
                onPressed: onMenuTap,
                icon: const Icon(Icons.menu_rounded),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(child: _titleBlock(context)),
            const SizedBox(width: AppSpacing.sm),
            const StatusBadge(label: 'SYSTEM READY', type: StatusBadgeType.ready, compact: true),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const SearchInput(hintText: 'Clip, Projekt oder Cue suchen...'),
      ],
    );
  }

  Widget _titleBlock(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xxs),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
