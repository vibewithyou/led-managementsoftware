import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/core/theme/app_durations.dart';
import 'package:led_management_software/core/theme/app_radius.dart';
import 'package:led_management_software/core/theme/app_shadows.dart';

class LargeActionButton extends StatefulWidget {
  const LargeActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.active = false,
    this.destructive = false,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool active;
  final bool destructive;

  @override
  State<LargeActionButton> createState() => _LargeActionButtonState();
}

class _LargeActionButtonState extends State<LargeActionButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    final base = widget.destructive ? AppColors.error : AppColors.primary;
    final bg = disabled
        ? AppColors.surfaceStrong
        : (_pressed || widget.active)
            ? base
            : _hovered
                ? base.withValues(alpha: 0.85)
                : base.withValues(alpha: 0.72);

    final scale = _pressed ? 0.985 : _hovered ? 1.01 : 1.0;

    return MouseRegion(
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
        onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
        onTapCancel: disabled ? null : () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: TweenAnimationBuilder<double>(
          duration: AppDurations.fast,
          tween: Tween(begin: 1, end: scale),
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: AnimatedContainer(
            duration: AppDurations.medium,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: disabled ? AppColors.border : base.withValues(alpha: 0.95)),
              boxShadow: disabled ? const [] : (_hovered || widget.active) ? AppShadows.glow(base) : AppShadows.panel,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 20, color: disabled ? AppColors.textMuted : AppColors.textPrimary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: disabled ? AppColors.textMuted : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
