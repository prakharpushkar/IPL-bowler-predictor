/// Request model matching the backend InputRequest schema.
class PredictionRequest {
  final int over;
  final int teamRuns;
  final int teamWickets;
  final int target;
  final String striker;
  final String nonStriker;
  final int strikerRuns;
  final int strikerBalls;
  final List<String> candidateBowlers;

  const PredictionRequest({
    required this.over,
    required this.teamRuns,
    required this.teamWickets,
    required this.target,
    required this.striker,
    required this.nonStriker,
    required this.strikerRuns,
    required this.strikerBalls,
    required this.candidateBowlers,
  });

  Map<String, dynamic> toJson() => {
        'over': over,
        'team_runs': teamRuns,
        'team_wickets': teamWickets,
        'target': target,
        'striker': striker,
        'non_striker': nonStriker,
        'striker_runs': strikerRuns,
        'striker_balls': strikerBalls,
        'candidate_bowlers': candidateBowlers,
      };

  @override
  String toString() => 'PredictionRequest(over: $over, striker: $striker, '
      'nonStriker: $nonStriker, bowlers: $candidateBowlers)';
}
