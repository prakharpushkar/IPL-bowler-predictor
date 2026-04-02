from app.services.build_feature import build_inference_df
from app.schema.pyandantic import InputRequest
from app.core import state

def prediction(predictions: list[dict]) -> tuple[str, float]: 
    final_bowler_prediction = None
    runs_conceeded = None
    for x in predictions:
        pred = x['predicted_runs']
        if(runs_conceeded is None) or (runs_conceeded > pred):
            runs_conceeded = round(pred, 2)
            final_bowler_prediction = x['bowler']
    return final_bowler_prediction, runs_conceeded

def all_bowler_prediction(user_input:InputRequest, candidate_bowlers: list) -> list[dict]:
    predictions = []
    for b in candidate_bowlers:
        user_input_modified = user_input.model_copy(update={'bowler': b})
        feature=build_inference_df(user_input_modified)
        temp = state.model.predict(feature)[0]
        predictions.append({
            'bowler': b,
            'predicted_runs': round(float(temp), 2)
        })
    return predictions  