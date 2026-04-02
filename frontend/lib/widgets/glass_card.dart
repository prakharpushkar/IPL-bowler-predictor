import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A glassmorphism-style card with frosted glass effect, gradient border,
/// and optional neon glow.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final double borderRadius;
  final double blurAmount;
  final Color? glowColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderColor,
    this.borderRadius = 20,
    this.blurAmount = 12,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final border = borderColor ?? AppColors.neonBlue.withOpacity(0.15);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: glowColor != null
            ? AppShadows.subtleGlow(glowColor!)
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: AppColors.cardBg.withOpacity(0.7),
              border: Border.all(color: border, width: 1),
              gradient: LinearGradient(
                colors: [
                  AppColors.surface.withOpacity(0.6),
                  AppColors.cardBg.withOpacity(0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
