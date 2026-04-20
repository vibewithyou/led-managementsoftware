import 'package:flutter/material.dart';
import 'package:led_managementsoftware_app/core/theme/app_colors.dart';

class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    this.hint,
  });

  final String label;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
