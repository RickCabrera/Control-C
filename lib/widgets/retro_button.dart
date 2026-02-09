import 'package:flutter/material.dart';
import '../theme/pip_boy_theme.dart';

class RetroButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isSelected;

  const RetroButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? PipBoyColors.primaryBright : PipBoyColors.primary,
          width: 2,
        ),
        color: isSelected ? PipBoyColors.primaryDim : PipBoyColors.background,
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: PipBoyColors.primaryBright.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 0,
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          splashColor: PipBoyColors.primary.withOpacity(0.2),
          highlightColor: PipBoyColors.primary.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Center(
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: isSelected
                      ? PipBoyColors.background
                      : PipBoyColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
