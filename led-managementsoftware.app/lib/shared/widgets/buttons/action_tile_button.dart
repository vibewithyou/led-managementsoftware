import 'package:flutter/material.dart';
import 'package:led_managementsoftware_app/core/theme/app_colors.dart';

class ActionTileButton extends StatelessWidget {
  const ActionTileButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
  });

  final String label;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: (color ?? AppColors.primary).withValues(alpha: 0.16),
        foregroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: (color ?? AppColors.primary).withValues(alpha: 0.45)),
        ),
      ),
      onPressed: onPressed,
      child: Text(label, textAlign: TextAlign.center),
    );
  }
}
