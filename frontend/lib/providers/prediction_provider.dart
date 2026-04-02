import 'package:flutter/material.dart';
import '../models/prediction_request.dart';
import '../models/prediction_response.dart';
import '../services/api_service.dart';

/// Prediction state enum for clean UI state management.
enum PredictionState { idle, loading, success, error }

/// Central state manager for the IPL Predictor app.
///
/// Holds player lists, form state, prediction results, and loading/error states.
class PredictionProvider extends ChangeNotifier {
  final ApiService _apiService;

  PredictionProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // ── Player lists ──
  List<String> _batters = [];
  List<String> _bowlers = [];
  List<String> get batters => _batters;
  List<String> get bowlers => _bowlers;

  // ── Loading states ──
  bool _isLoadingPlayers = false;
  bool get isLoadingPlayers => _isLoadingPlayers;

  PredictionState _predictionState = PredictionState.idle;
  PredictionState get predictionState => _predictionState;

  // ── Prediction result ──
  PredictionResponse? _predictionResult;
  PredictionResponse? get predictionResult => _predictionResult;

  // ── Error message ──
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Backend health ──
  bool _isBackendHealthy = false;
  bool get isBackendHealthy => _isBackendHealthy;

  // ══════════════════════════════════════════════════════════════════════
  //  Initialize — load player lists from backend
  // ══════════════════════════════════════════════════════════════════════
  Future<void> initialize() async {
    _isLoadingPlayers = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Run health check and data fetch concurrently
      final results = await Future.wait([
        _apiService.checkHealth(),
        _apiService.fetchBatters(),
        _apiService.fetchBowlers(),
      ]);

      _isBackendHealthy = results[0] as bool;
      _batters = results[1] as List<String>;
      _bowlers = results[2] as List<String>;
    } catch (e) {
      _errorMessage = 'Failed to connect to backend. '
          'Make sure the server is running at ${ApiService.baseUrl}';
      _isBackendHealthy = false;
    } finally {
      _isLoadingPlayers = false;
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  //  Predict — call the prediction API
  // ══════════════════════════════════════════════════════════════════════
  Future<void> predict(PredictionRequest request) async {
    _predictionState = PredictionState.loading;
    _errorMessage = null;
    _predictionResult = null;
    notifyListeners();

    try {
      _predictionResult = await _apiService.predict(request);
      _predictionState = PredictionState.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _predictionState = PredictionState.error;
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
      _predictionState = PredictionState.error;
    } finally {
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  //  Reset prediction state
  // ══════════════════════════════════════════════════════════════════════
  void resetPrediction() {
    _predictionState = PredictionState.idle;
    _predictionResult = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
