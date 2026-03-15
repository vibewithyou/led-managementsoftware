import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/core/theme/app_durations.dart';
import 'package:led_management_software/core/theme/app_radius.dart';
import 'package:led_management_software/core/theme/app_shadows.dart';

class SectionCard extends StatefulWidget {
  const SectionCard({
    required this.title,
    required this.child,
    this.trailing,
    this.height,
    this.glassy = false,
    super.key,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final double? height;
  final bool glassy;

  @override
  State<SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<SectionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.glassy ? AppColors.glass : (_hovered ? AppColors.surfaceMuted : AppColors.surface);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppDurations.medium,
        curve: Curves.easeOutCubic,
        height: widget.height,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: _hovered ? AppColors.borderStrong : AppColors.border),
          boxShadow: _hovered ? AppShadows.glow(AppColors.primary) : AppShadows.panel,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(widget.title, style: Theme.of(context).textTheme.titleLarge)),
                if (widget.trailing != null) widget.trailing!,
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }
}
