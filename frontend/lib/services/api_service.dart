import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prediction_request.dart';
import '../models/prediction_response.dart';

/// Centralized API service for the IPL predictor backend.
///
/// Change [baseUrl] to point to your deployed backend.
class ApiService {
  // ══════════════════════════════════════════════════════════════════════
  //  ⚠️  UPDATE THIS URL to your backend address
  // ══════════════════════════════════════════════════════════════════════
  static const String baseUrl = 'http://127.0.0.1:8000';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // ── Helper ──
  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ── Fetch batter names ──
  Future<List<String>> fetchBatters() async {
    try {
      final response = await _client.get(_uri('/batters'), headers: _headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['batters']);
      }
      throw ApiException(
        'Failed to load batters',
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error fetching batters: $e');
    }
  }

  // ── Fetch bowler names ──
  Future<List<String>> fetchBowlers() async {
    try {
      final response = await _client.get(_uri('/bowlers'), headers: _headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['bowlers']);
      }
      throw ApiException(
        'Failed to load bowlers',
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error fetching bowlers: $e');
    }
  }

  // ── Health check ──
  Future<bool> checkHealth() async {
    try {
      final response = await _client.get(_uri('/health'), headers: _headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'ok' && data['model_loaded'] == true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ── Prediction ──
  Future<PredictionResponse> predict(PredictionRequest request) async {
    try {
      final response = await _client.post(
        _uri('/predict'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return PredictionResponse.fromJson(jsonDecode(response.body));
      }

      // Parse backend error detail if available
      String detail = 'Prediction failed';
      try {
        final errBody = jsonDecode(response.body);
        detail = errBody['detail'] ?? detail;
      } catch (_) {}

      throw ApiException(detail, statusCode: response.statusCode);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error during prediction: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Custom exception for API errors.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() =>
      'ApiException: $message${statusCode != null ? ' (HTTP $statusCode)' : ''}';
}
