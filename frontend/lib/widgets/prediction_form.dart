import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/prediction_request.dart';
import '../providers/prediction_provider.dart';
import 'glass_card.dart';
import 'neon_text_field.dart';
import 'neon_dropdown.dart';
import 'neon_multi_select.dart';
import 'glowing_button.dart';

/// Complete prediction input form with all required fields,
/// validation, and neon-styled components.
class PredictionForm extends StatefulWidget {
  const PredictionForm({super.key});

  @override
  State<PredictionForm> createState() => _PredictionFormState();
}

class _PredictionFormState extends State<PredictionForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _overController = TextEditingController();
  final _teamRunsController = TextEditingController();
  final _teamWicketsController = TextEditingController();
  final _targetController = TextEditingController(text: '0');
  final _strikerRunsController = TextEditingController();
  final _strikerBallsController = TextEditingController();

  // Dropdown selections
  String? _selectedStriker;
  String? _selectedNonStriker;
  List<String> _selectedBowlers = [];

  // Animation
  late AnimationController _animController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _overController.dispose();
    _teamRunsController.dispose();
    _teamWicketsController.dispose();
    _targetController.dispose();
    _strikerRunsController.dispose();
    _strikerBallsController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onPredict() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedStriker == null || _selectedNonStriker == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select both striker and non-striker'),
          backgroundColor: AppColors.neonPink.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (_selectedBowlers.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Select at least 2 candidate bowlers'),
          backgroundColor: AppColors.neonPink.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final request = PredictionRequest(
      over: int.parse(_overController.text),
      teamRuns: int.parse(_teamRunsController.text),
      teamWickets: int.parse(_teamWicketsController.text),
      target: int.tryParse(_targetController.text) ?? 0,
      striker: _selectedStriker!,
      nonStriker: _selectedNonStriker!,
      strikerRuns: int.parse(_strikerRunsController.text),
      strikerBalls: int.parse(_strikerBallsController.text),
      candidateBowlers: _selectedBowlers,
    );

    context.read<PredictionProvider>().predict(request);
  }

  String? _validateInt(String? value, String fieldName,
      {int? min, int? max}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final parsed = int.tryParse(value);
    if (parsed == null) return 'Enter a valid number';
    if (min != null && parsed < min) return '$fieldName must be ≥ $min';
    if (max != null && parsed > max) return '$fieldName must be ≤ $max';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PredictionProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1000;
    final isTablet = screenWidth > 600;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: FadeTransition(
        opacity: _slideAnimation,
        child: GlassCard(
          glowColor: AppColors.neonBlue,
          padding: EdgeInsets.all(isDesktop ? 40 : 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Section header ──
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.neonBlue, AppColors.neonViolet],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'MATCH SITUATION',
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
                Text(
                  'Enter the current match details to get AI-powered bowling recommendations',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Row 1: Over, Team Runs, Wickets, Target ──
                _buildResponsiveRow(
                  isDesktop: isDesktop,
                  isTablet: isTablet,
                  children: [
                    Expanded(
                      child: NeonTextField(
                        label: 'Over',
                        hint: '0-20',
                        controller: _overController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.sports_cricket,
                        validator: (v) =>
                            _validateInt(v, 'Over', min: 0, max: 20),
                      ),
                    ),
                    SizedBox(width: isDesktop ? 20 : 12),
                    Expanded(
                      child: NeonTextField(
                        label: 'Team Runs',
                        hint: '0+',
                        controller: _teamRunsController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.scoreboard_outlined,
                        validator: (v) =>
                            _validateInt(v, 'Team Runs', min: 0),
                      ),
                    ),
                    SizedBox(width: isDesktop ? 20 : 12),
                    Expanded(
                      child: NeonTextField(
                        label: 'Team Wickets',
                        hint: '0-10',
                        controller: _teamWicketsController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.remove_circle_outline,
                        validator: (v) =>
                            _validateInt(v, 'Wickets', min: 0, max: 10),
                      ),
                    ),
                    SizedBox(width: isDesktop ? 20 : 12),
                    Expanded(
                      child: NeonTextField(
                        label: 'Target (optional)',
                        hint: '0',
                        controller: _targetController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.flag_outlined,
                        validator: (v) {
                          if (v == null || v.isEmpty) return null;
                          return _validateInt(v, 'Target', min: 0);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Divider with label ──
                _buildSectionDivider('BATSMEN DETAILS'),
                const SizedBox(height: 24),

                // ── Row 2: Striker & Non-Striker dropdowns ──
                _buildResponsiveRow(
                  isDesktop: isDesktop,
                  isTablet: isTablet,
                  children: [
                    Expanded(
                      child: NeonSearchableDropdown(
                        label: 'Striker',
                        items: provider.batters,
                        selectedValue: _selectedStriker,
                        onChanged: (v) =>
                            setState(() => _selectedStriker = v),
                        prefixIcon: Icons.person,
                        validator: (v) =>
                            v == null ? 'Select striker' : null,
                      ),
                    ),
                    SizedBox(width: isDesktop ? 20 : 12),
                    Expanded(
                      child: NeonSearchableDropdown(
                        label: 'Non-Striker',
                        items: provider.batters,
                        selectedValue: _selectedNonStriker,
                        onChanged: (v) =>
                            setState(() => _selectedNonStriker = v),
                        prefixIcon: Icons.person_outline,
                        validator: (v) =>
                            v == null ? 'Select non-striker' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Row 3: Striker Runs & Balls Faced ──
                _buildResponsiveRow(
                  isDesktop: isDesktop,
                  isTablet: isTablet,
                  children: [
                    Expanded(
                      child: NeonTextField(
                        label: 'Striker Runs',
                        hint: '0+',
                        controller: _strikerRunsController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.looks_one_outlined,
                        validator: (v) =>
                            _validateInt(v, 'Striker Runs', min: 0),
                      ),
                    ),
                    SizedBox(width: isDesktop ? 20 : 12),
                    Expanded(
                      child: NeonTextField(
                        label: 'Striker Balls Faced',
                        hint: '0+',
                        controller: _strikerBallsController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.sports_baseball,
                        validator: (v) =>
                            _validateInt(v, 'Balls Faced', min: 0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Divider with label ──
                _buildSectionDivider('CANDIDATE BOWLERS'),
                const SizedBox(height: 24),

                // ── Multi-select bowlers ──
                NeonMultiSelectDropdown(
                  label: 'Select Candidate Bowlers (2-5)',
                  items: provider.bowlers,
                  selectedValues: _selectedBowlers,
                  onChanged: (values) =>
                      setState(() => _selectedBowlers = values),
                  prefixIcon: Icons.sports,
                  minSelect: 2,
                  maxSelect: 5,
                  validator: (values) {
                    if (values.length < 2) return 'Select at least 2 bowlers';
                    return null;
                  },
                ),
                const SizedBox(height: 36),

                // ── Predict Button ──
                Center(
                  child: GlowingButton(
                    text: 'PREDICT BEST BOWLER',
                    icon: Icons.auto_awesome,
                    isLoading:
                        provider.predictionState == PredictionState.loading,
                    onPressed: provider.predictionState ==
                            PredictionState.loading
                        ? null
                        : _onPredict,
                    width: isDesktop ? 400 : double.infinity,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveRow({
    required bool isDesktop,
    required bool isTablet,
    required List<Widget> children,
  }) {
    if (isTablet) {
      return Row(children: children);
    }
    return Column(
      children: children.map((child) {
        if (child is SizedBox) return const SizedBox(height: 16);
        return SizedBox(width: double.infinity, child: child);
      }).toList(),
    );
  }

  Widget _buildSectionDivider(String label) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.neonBlue.withOpacity(0.3),
                  AppColors.textMuted.withOpacity(0.1),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.neonBlue.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.textMuted.withOpacity(0.1),
                  AppColors.neonViolet.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
