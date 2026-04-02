import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Hero section with animated trophy background, floating particles,
/// and gradient text overlay.
class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmall = screenWidth < 768;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SizedBox(
        width: double.infinity,
        height: screenHeight,
        child: Stack(
          children: [
            // ── Animated gradient background ──
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, _) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        AppColors.neonBlue
                            .withOpacity(_pulseAnimation.value * 0.08),
                        AppColors.neonViolet
                            .withOpacity(_pulseAnimation.value * 0.05),
                        AppColors.background,
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                );
              },
            ),

            // ── Trophy image with fade overlay ──
            Positioned.fill(
              child: Opacity(
                opacity: 0.3,
                child: Image.asset(
                  'assets/images/trophy_bg.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback gradient if image not found
                    return Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          colors: [
                            AppColors.neonBlue.withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── Fade edges ──
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.background.withOpacity(0.3),
                      Colors.transparent,
                      Colors.transparent,
                      AppColors.background,
                    ],
                    stops: const [0.0, 0.2, 0.7, 1.0],
                  ),
                ),
              ),
            ),

            // ── Floating particles ──
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, _) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _ParticlePainter(
                    progress: _particleController.value,
                  ),
                );
              },
            ),

            // ── Content overlay ──
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Subtitle
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _fadeController,
                      curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
                    )),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppColors.neonBlue.withOpacity(0.3),
                        ),
                        color: AppColors.neonBlue.withOpacity(0.05),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/ipl_batter.png',
                            width: isSmall ? 18 : 22,
                            height: isSmall ? 18 : 22,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'AI-POWERED CRICKET ANALYTICS',
                            style: TextStyle(
                              color: AppColors.neonBlue,
                              fontSize: isSmall ? 11 : 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isSmall ? 16 : 24),

                  // Main title
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _fadeController,
                      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
                    )),
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return const LinearGradient(
                          colors: [
                            AppColors.neonBlue,
                            AppColors.neonCyan,
                            AppColors.neonViolet,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds);
                      },
                      child: Text(
                        'IPL BOWLING\nPREDICTOR',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isSmall ? 42 : 64,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2,
                          height: 1.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isSmall ? 12 : 20),

                  // Description
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _fadeController,
                      curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
                    )),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Predict the best bowler to deploy using advanced machine learning.\nAnalyze match situations and optimize your bowling strategy.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmall ? 14 : 17,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isSmall ? 20 : 32),

                  // Stats row
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _fadeController,
                      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                    )),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatBadge('500+', 'Players', AppColors.neonBlue),
                        const SizedBox(width: 24),
                        _buildStatBadge(
                            'XGBoost', 'ML Model', AppColors.neonViolet),
                        const SizedBox(width: 24),
                        _buildStatBadge(
                            'Real-time', 'Analysis', AppColors.neonGreen),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// AnimatedBuilder shorthand widget
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) => builder(context, child);
}

/// Particle painter for floating light particles
class _ParticlePainter extends CustomPainter {
  final double progress;

  _ParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);

    for (int i = 0; i < 30; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final speed = 0.3 + random.nextDouble() * 0.7;
      final phase = random.nextDouble() * math.pi * 2;

      final x = baseX + math.sin(progress * math.pi * 2 * speed + phase) * 30;
      final y = baseY + math.cos(progress * math.pi * 2 * speed + phase) * 20;

      final opacity = 0.1 + math.sin(progress * math.pi * 2 + phase) * 0.15;
      final radius = 1.0 + random.nextDouble() * 2.0;

      final color = i % 3 == 0
          ? AppColors.neonBlue
          : i % 3 == 1
              ? AppColors.neonViolet
              : AppColors.neonCyan;

      final paint = Paint()
        ..color = color.withOpacity(opacity.clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
