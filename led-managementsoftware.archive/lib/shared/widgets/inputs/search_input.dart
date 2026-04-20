import 'package:flutter/material.dart';
import 'package:led_management_software/core/theme/app_colors.dart';

class SearchInput extends StatelessWidget {
  const SearchInput({this.hintText = 'Suchen...', this.controller, this.onChanged, super.key});

  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
          suffixIcon: const Icon(Icons.tune_rounded, color: AppColors.textMuted, size: 18),
        ),
      ),
    );
  }
}
