import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/core/theme/app_radius.dart';
import 'package:led_management_software/core/theme/app_shadows.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({required this.child, this.padding = const EdgeInsets.all(16), super.key});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.glass,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.borderStrong.withValues(alpha: 0.7)),
            boxShadow: AppShadows.panel,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x14FFFFFF), Color(0x08FFFFFF)],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
