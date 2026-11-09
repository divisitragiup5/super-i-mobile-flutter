import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Widget pembungkus untuk menampilkan wallpaper latar belakang `background.jpg`
/// secara seragam di seluruh halaman aplikasi, seperti pada legacy `super-i-mobile`.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/background.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppColors.backgroundLight,
          ),
        ),
        child,
      ],
    );
  }
}
