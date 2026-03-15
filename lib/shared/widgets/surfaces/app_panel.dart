import 'package:flutter/material.dart';
import 'package:led_management_software/shared/widgets/surfaces/section_card.dart';

class AppPanel extends StatelessWidget {
  const AppPanel({
    required this.title,
    required this.child,
    this.trailing,
    this.height,
    super.key,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: title,
      trailing: trailing,
      height: height,
      child: child,
    );
  }
}
