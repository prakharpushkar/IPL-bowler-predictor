import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/prediction_provider.dart';
import '../widgets/hero_section.dart';
import '../widgets/prediction_form.dart';
import '../widgets/prediction_result.dart';
import '../widgets/team_showcase.dart';
import '../widgets/glass_card.dart';

/// Main home screen assembling all sections:
/// 1. Navigation header
/// 2. Hero section with trophy
/// 3. IPL Teams carousel
/// 4. Prediction form
/// 5. Results (conditional)
/// 6. Footer
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Initialize provider data on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PredictionProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToForm() {
    final formContext = _formKey.currentContext;
    if (formContext != null) {
      Scrollable.ensureVisible(
        formContext,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PredictionProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1100;
    final contentPadding = isDesktop ? 80.0 : (screenWidth > 600 ? 40.0 : 20.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Background grid pattern ──
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPatternPainter(),
            ),
          ),

          // ── Main content ──
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // ── Navigation bar ──
              SliverToBoxAdapter(
                child: _buildNavBar(contentPadding),
              ),

              // ── Hero section ──
              const SliverToBoxAdapter(
                child: HeroSection(),
              ),

              // ── Scroll-to-predict CTA ──
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: _buildScrollCTA(),
                  ),
                ),
              ),

              // ── Content with background image ──
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    // ── IPL Background Image ──
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.15,
                        child: Image.asset(
                          'assets/images/1743063350659_IPL2025(1).webp',
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                    // ── Top fade for smooth transition ──
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 80,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.background,
                              AppColors.background.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // ── Bottom fade for smooth transition ──
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 80,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              AppColors.background,
                              AppColors.background.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // ── Actual content ──
                    Column(
                      children: [
                        // ── Teams showcase ──
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: contentPadding,
                            vertical: 20,
                          ),
                          child: const TeamShowcase(),
                        ),

                        // ── Connection status ──
                        if (provider.isLoadingPlayers)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: contentPadding,
                              vertical: 30,
                            ),
                            child: _buildLoadingIndicator(),
                          )
                        else if (provider.errorMessage != null &&
                            provider.predictionState != PredictionState.error)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: contentPadding,
                              vertical: 30,
                            ),
                            child: _buildConnectionError(provider),
                          ),

                        // ── Prediction form ──
                        if (!provider.isLoadingPlayers && provider.batters.isNotEmpty)
                          Padding(
                            key: _formKey,
                            padding: EdgeInsets.symmetric(
                              horizontal: contentPadding,
                              vertical: 20,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1100),
                                child: const PredictionForm(),
                              ),
                            ),
                          ),

                        // ── Error message ──
                        if (provider.predictionState == PredictionState.error)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: contentPadding,
                              vertical: 10,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1100),
                                child: _buildPredictionError(provider),
                              ),
                            ),
                          ),

                        // ── Prediction results ──
                        if (provider.predictionState == PredictionState.success)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: contentPadding,
                              vertical: 20,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1100),
                                child: const PredictionResult(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Footer ──
              SliverToBoxAdapter(
                child: _buildFooter(contentPadding),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar(double padding) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: AppColors.neonBlue.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo/Brand
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [AppColors.neonBlue, AppColors.neonViolet],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonBlue.withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/images/ipl_batter.png',
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'IPL PREDICTOR',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const Spacer(),

          // Backend status indicator
          Consumer<PredictionProvider>(
            builder: (context, provider, _) {
              final isHealthy = provider.isBackendHealthy;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: (isHealthy ? AppColors.neonGreen : AppColors.neonPink)
                      .withOpacity(0.1),
                  border: Border.all(
                    color:
                        (isHealthy ? AppColors.neonGreen : AppColors.neonPink)
                            .withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isHealthy
                            ? AppColors.neonGreen
                            : AppColors.neonPink,
                        boxShadow: [
                          BoxShadow(
                            color: (isHealthy
                                    ? AppColors.neonGreen
                                    : AppColors.neonPink)
                                .withOpacity(0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isHealthy ? 'API Connected' : 'API Offline',
                      style: TextStyle(
                        color: isHealthy
                            ? AppColors.neonGreen
                            : AppColors.neonPink,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScrollCTA() {
    return GestureDetector(
      onTap: _scrollToForm,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Column(
          children: [
            Text(
              'START PREDICTION',
              style: TextStyle(
                color: AppColors.neonBlue,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 10),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 8 * (0.5 - (value - 0.5).abs())),
                  child: child,
                );
              },
              child: Icon(
                Icons.keyboard_double_arrow_down_rounded,
                color: AppColors.neonBlue,
                size: 36,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return GlassCard(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: const AlwaysStoppedAnimation(AppColors.neonBlue),
              backgroundColor: AppColors.neonBlue.withOpacity(0.1),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Connecting to prediction engine...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Loading player database',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionError(PredictionProvider provider) {
    return GlassCard(
      borderColor: AppColors.neonPink.withOpacity(0.3),
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neonPink.withOpacity(0.1),
              border: Border.all(
                color: AppColors.neonPink.withOpacity(0.3),
              ),
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.neonPink,
              size: 28,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Backend Unavailable',
            style: TextStyle(
              color: AppColors.neonPink,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            provider.errorMessage ?? 'Cannot connect to the prediction server',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => provider.initialize(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('RETRY CONNECTION'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.neonPink,
              side: BorderSide(color: AppColors.neonPink.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionError(PredictionProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.neonPink.withOpacity(0.08),
        border: Border.all(
          color: AppColors.neonPink.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.neonPink,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Prediction Failed',
                  style: TextStyle(
                    color: AppColors.neonPink,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider.errorMessage ?? 'An error occurred',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textMuted, size: 18),
            onPressed: () => provider.resetPrediction(),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(double padding) {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 32),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.neonBlue.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  gradient: const LinearGradient(
                    colors: [AppColors.neonBlue, AppColors.neonViolet],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset(
                    'assets/images/ipl_batter.png',
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'IPL BOWLING PREDICTOR',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Powered by XGBoost ML Model  •  Built with Flutter',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '© 2026 IPL Predictor. For educational purposes only.',
            style: TextStyle(
              color: AppColors.textMuted.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Subtle grid pattern painter for the background.
class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neonBlue.withOpacity(0.02)
      ..strokeWidth = 0.5;

    const spacing = 60.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
