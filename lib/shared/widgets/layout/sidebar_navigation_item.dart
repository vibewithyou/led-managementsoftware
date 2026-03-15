import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/core/theme/app_durations.dart';
import 'package:led_management_software/core/theme/app_radius.dart';

class SidebarNavigationItem extends StatefulWidget {
  const SidebarNavigationItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.compact,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  State<SidebarNavigationItem> createState() => _SidebarNavigationItemState();
}

class _SidebarNavigationItemState extends State<SidebarNavigationItem> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.selected
        ? AppColors.primary.withValues(alpha: 0.24)
        : _pressed
            ? AppColors.surfaceStrong
            : _hovered
                ? AppColors.surfaceMuted
                : Colors.transparent;

    final border = widget.selected ? AppColors.primary.withValues(alpha: 0.75) : (_hovered ? AppColors.borderStrong : Colors.transparent);
    final iconColor = widget.selected ? AppColors.secondary : (_hovered ? AppColors.textPrimary : AppColors.textMuted);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppDurations.medium,
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisAlignment: widget.compact ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(widget.icon, color: iconColor, size: 21),
              if (!widget.compact) ...[
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    widget.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: widget.selected ? AppColors.textPrimary : AppColors.textMuted,
                      fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
