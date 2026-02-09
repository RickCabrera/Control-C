import 'package:flutter/material.dart';
import '../theme/pip_boy_theme.dart';

class RetroInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final int maxLines;

  const RetroInput({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '> ${label.toUpperCase()}',
          style: const TextStyle(
            color: PipBoyColors.primaryDim,
            fontSize: 14,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: PipBoyColors.primary, width: 2),
            color: PipBoyColors.surfaceVariant,
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(
              color: PipBoyColors.primary,
              fontSize: 16,
              letterSpacing: 1,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
              hintText: hintText ?? '_',
              hintStyle: const TextStyle(
                color: PipBoyColors.primaryDim,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
