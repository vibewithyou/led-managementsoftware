import 'package:flutter/material.dart';
import 'package:led_management_software/core/theme/app_colors.dart';

class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> panel = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];

  static List<BoxShadow> glow(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.22),
        blurRadius: 22,
        spreadRadius: 1,
      ),
      const BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 18,
        offset: Offset(0, 8),
      ),
    ];
  }

  static final List<BoxShadow> topBar = [
    BoxShadow(
      color: AppColors.shadow.withValues(alpha: 0.35),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}
