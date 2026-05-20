import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color borderColor;
  final Color glowColor;
  final double borderWidth;
  final double blur;
  final List<Color>? gradientColors;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.borderColor = AppColors.borderGlowDefault,
    this.glowColor = Colors.transparent,
    this.borderWidth = 1.0,
    this.blur = 15.0,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: glowColor != Colors.transparent
            ? [
                BoxShadow(
                  color: glowColor.withOpacity(0.08),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors ??
                    [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.01),
                    ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
