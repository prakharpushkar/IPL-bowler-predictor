/// Single bowler prediction from the backend.
class BowlerPrediction {
  final String bowler;
  final double predictedRuns;

  const BowlerPrediction({
    required this.bowler,
    required this.predictedRuns,
  });

  factory BowlerPrediction.fromJson(Map<String, dynamic> json) {
    return BowlerPrediction(
      bowler: json['bowler'] as String,
      predictedRuns: (json['predicted_runs'] as num).toDouble(),
    );
  }

  @override
  String toString() => 'BowlerPrediction($bowler: $predictedRuns runs)';
}

/// Complete response from the /predict endpoint.
class PredictionResponse {
  final String predictedBowler;
  final double predictedRuns;
  final List<BowlerPrediction> allPredictions;

  const PredictionResponse({
    required this.predictedBowler,
    required this.predictedRuns,
    required this.allPredictions,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      predictedBowler: json['predicted_bowler'] as String,
      predictedRuns: (json['predicted_runs'] as num).toDouble(),
      allPredictions: (json['all_predictions'] as List)
          .map((e) => BowlerPrediction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Total runs across all bowlers (for percentage calculations).
  double get totalRuns =>
      allPredictions.fold(0.0, (sum, bp) => sum + bp.predictedRuns);

  @override
  String toString() =>
      'PredictionResponse(best: $predictedBowler @ $predictedRuns runs)';
}
