import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../models/prediction_response.dart';

/// Animated pie chart showing runs conceded by each candidate bowler.
/// Each bowler gets a unique neon color from the design palette.
class AnimatedPieChart extends StatefulWidget {
  final List<BowlerPrediction> predictions;

  const AnimatedPieChart({super.key, required this.predictions});

  @override
  State<AnimatedPieChart> createState() => _AnimatedPieChartState();
}

class _AnimatedPieChartState extends State<AnimatedPieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color _getColor(int index) {
    return AppColors.chartPalette[index % AppColors.chartPalette.length];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 768;
    final totalRuns = widget.predictions
        .fold(0.0, (sum, bp) => sum + bp.predictedRuns);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Column(
          children: [
            // ── Chart ──
            SizedBox(
              height: isSmall ? 220 : 280,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 3,
                  centerSpaceRadius: isSmall ? 40 : 55,
                  startDegreeOffset: -90,
                  sections: List.generate(
                    widget.predictions.length,
                    (index) {
                      final bp = widget.predictions[index];
                      final isTouched = index == _touchedIndex;
                      final percentage = totalRuns > 0
                          ? (bp.predictedRuns / totalRuns * 100)
                          : 0.0;
                      final color = _getColor(index);
                      final animValue = _animation.value;

                      return PieChartSectionData(
                        color: color.withOpacity(0.85),
                        value: bp.predictedRuns * animValue,
                        title: '${percentage.toStringAsFixed(1)}%',
                        radius: (isTouched ? 75 : 60) * animValue,
                        titleStyle: TextStyle(
                          fontSize: isTouched ? 16 : 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        badgePositionPercentageOffset: 1.2,
                        titlePositionPercentageOffset: 0.55,
                        borderSide: isTouched
                            ? BorderSide(
                                color: color, width: 2)
                            : BorderSide.none,
                      );
                    },
                  ),
                ),
                duration: const Duration(milliseconds: 300),
              ),
            ),
            const SizedBox(height: 28),

            // ── Legend ──
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: List.generate(
                widget.predictions.length,
                (index) {
                  final bp = widget.predictions[index];
                  final color = _getColor(index);
                  final isTouched = index == _touchedIndex;

                  return MouseRegion(
                    onEnter: (_) => setState(() => _touchedIndex = index),
                    onExit: (_) => setState(() => _touchedIndex = -1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isTouched
                            ? color.withOpacity(0.1)
                            : Colors.transparent,
                        border: Border.all(
                          color: isTouched
                              ? color.withOpacity(0.4)
                              : AppColors.textMuted.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.4),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                bp.bowler,
                                style: TextStyle(
                                  color: isTouched
                                      ? color
                                      : AppColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${bp.predictedRuns.toStringAsFixed(2)} runs',
                                style: const TextStyle(
                                  color: Color(0xFFCCCCDD),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// AnimatedBuilder shorthand
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
