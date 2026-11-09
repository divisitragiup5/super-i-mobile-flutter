import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Label untuk InputDecoration atau header form dengan tanda asterisk merah (*) jika required.
class AppInputLabel extends StatelessWidget {
  final String text;
  final bool isRequired;
  final TextStyle? style;

  const AppInputLabel(
    this.text, {
    super.key,
    this.isRequired = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: text,
        style: style ?? const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
