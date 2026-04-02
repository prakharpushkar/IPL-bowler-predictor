import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/prediction_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IPLPredictorApp());
}

/// Root application widget.
/// Sets up Provider for state management and applies the neon dark theme.
class IPLPredictorApp extends StatelessWidget {
  const IPLPredictorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PredictionProvider(),
      child: MaterialApp(
        title: 'IPL Bowling Predictor - AI Cricket Analytics',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
