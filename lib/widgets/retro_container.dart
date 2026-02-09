import 'package:flutter/material.dart';
import '../theme/pip_boy_theme.dart';

class RetroContainer extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const RetroContainer({
    super.key,
    this.title,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: PipBoyColors.primary, width: 2),
        color: PipBoyColors.surface,
        boxShadow: [
          BoxShadow(
            color: PipBoyColors.primary.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: PipBoyColors.primary, width: 2),
                ),
              ),
              child: Text(
                '// ${title!.toUpperCase()}',
                style: const TextStyle(
                  color: PipBoyColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
          Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}
