import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppScreenBackground extends StatelessWidget {
  const AppScreenBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        gradient: RadialGradient(
          center: Alignment(-0.8, -0.9),
          radius: 1.25,
          colors: [
            Color(0x553B1D7A),
            Color(0x220EA5E9),
            AppColors.background,
          ],
          stops: [0, 0.38, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -90,
            child: _BlurCircle(
              size: 280,
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -110,
            child: _BlurCircle(
              size: 260,
              color: AppColors.secondary.withValues(alpha: 0.14),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(color: color, blurRadius: 96, spreadRadius: 36),
          ],
        ),
      ),
    );
  }
}
