import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/prediction_response.dart';
import '../providers/prediction_provider.dart';
import 'glass_card.dart';
import 'animated_pie_chart.dart';

/// Displays prediction results with animated entrance:
/// 1. Best bowler highlight card
/// 2. Pie chart breakdown of all candidate bowlers
class PredictionResult extends StatefulWidget {
  const PredictionResult({super.key});

  @override
  State<PredictionResult> createState() => _PredictionResultState();
}

class _PredictionResultState extends State<PredictionResult>
  with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _revealController;
  late Animation<double> _slideAnimation;
  late Animation<double> _revealAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    );

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _revealAnimation = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOutBack,
    );

    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _revealController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PredictionProvider>();
    final result = provider.predictionResult;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1000;

    if (result == null) return const SizedBox.shrink();

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: FadeTransition(
        opacity: _slideAnimation,
        child: Column(
          children: [
            // ── Best Bowler Highlight ──
            ScaleTransition(
              scale: _revealAnimation,
              child: _buildBestBowlerCard(result, isDesktop),
            ),
            const SizedBox(height: 32),

            // ── Pie Chart Section ──
            FadeTransition(
              opacity: _revealAnimation,
              child: GlassCard(
                glowColor: AppColors.neonViolet,
                padding: EdgeInsets.all(isDesktop ? 40 : 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.neonViolet,
                                AppColors.neonPurple,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'BOWLER ANALYSIS',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Predicted runs conceded by each candidate bowler',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    AnimatedPieChart(predictions: result.allPredictions),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Detailed Breakdown Table ──
            FadeTransition(
              opacity: _revealAnimation,
              child: GlassCard(
                padding: EdgeInsets.all(isDesktop ? 40 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.neonCyan,
                                AppColors.neonGreen,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'DETAILED BREAKDOWN',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ..._buildBreakdownRows(result),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestBowlerCard(PredictionResponse result, bool isDesktop) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.neonGreen.withOpacity(0.04),
        border: Border.all(
          color: AppColors.neonGreen.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      padding: EdgeInsets.all(isDesktop ? 40 : 28),
      child: Column(
        children: [
          // Trophy icon
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neonGold.withOpacity(0.15),
              border: Border.all(
                color: AppColors.neonGold.withOpacity(0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.15),
                  blurRadius: 25,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: AppColors.neonGold.withOpacity(0.2),
                  blurRadius: 15,
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: AppColors.neonGold,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'BEST BOWLER FOR THE OVER',
            style: TextStyle(
              color: AppColors.neonGreen.withOpacity(0.8),
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 12),

          // Bowler name with gradient
          Text(
            result.predictedBowler,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),

          // Predicted runs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.background,
              border: Border.all(
                color: AppColors.neonGreen.withOpacity(0.4),
              ),
            ),
            child: RichText(
              text: TextSpan(
                text: 'Predicted: ',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
                children: [
                  TextSpan(
                    text:
                        '${result.predictedRuns.toStringAsFixed(2)} runs',
                    style: const TextStyle(
                      color: AppColors.neonGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBreakdownRows(PredictionResponse result) {
    // Sort by predicted runs (ascending = best first)
    final sorted = List<BowlerPrediction>.from(result.allPredictions)
      ..sort((a, b) => a.predictedRuns.compareTo(b.predictedRuns));

    final maxRuns = sorted.last.predictedRuns;

    return sorted.asMap().entries.map((entry) {
      final index = entry.key;
      final bp = entry.value;
      final isBest = bp.bowler == result.predictedBowler;
      final barFraction = maxRuns > 0 ? bp.predictedRuns / maxRuns : 0.0;
      final originalIndex = result.allPredictions.indexOf(bp);
      final color =
          AppColors.chartPalette[originalIndex % AppColors.chartPalette.length];

      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 600 + index * 150),
        curve: Curves.easeOutCubic,
        builder: (context, animValue, child) {
          return Opacity(
            opacity: animValue,
            child: Transform.translate(
              offset: Offset(30 * (1 - animValue), 0),
              child: child,
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isBest
                ? AppColors.neonGreen.withOpacity(0.05)
                : Colors.transparent,
            border: Border.all(
              color: isBest
                  ? AppColors.neonGreen.withOpacity(0.2)
                  : AppColors.textMuted.withOpacity(0.08),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Rank
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.15),
                      border: Border.all(
                        color: color.withOpacity(0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Name
                  Expanded(
                    child: Text(
                      bp.bowler,
                      style: TextStyle(
                        color: isBest
                            ? AppColors.neonGreen
                            : AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight:
                            isBest ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),

                  // Best badge
                  if (isBest)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: AppColors.neonGreen.withOpacity(0.15),
                        border: Border.all(
                          color: AppColors.neonGreen.withOpacity(0.3),
                        ),
                      ),
                      child: const Text(
                        '★ BEST',
                        style: TextStyle(
                          color: AppColors.neonGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  const SizedBox(width: 14),

                  // Runs
                  Text(
                    '${bp.predictedRuns.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: color,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'runs',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Progress bar
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: barFraction),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 6,
                      backgroundColor: AppColors.surface,
                      valueColor: AlwaysStoppedAnimation(
                        color.withOpacity(0.7),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
