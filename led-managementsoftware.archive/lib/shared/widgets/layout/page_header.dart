import 'package:flutter/material.dart';
import 'package:led_management_software/shared/widgets/layout/section_header.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({required this.title, required this.description, super.key});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SectionHeader(
      title: title,
      description: description,
    );
  }
}
