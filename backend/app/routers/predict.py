from fastapi import APIRouter, HTTPException
from app.schema.pyandantic import PredictResponse,InputRequest
from app.services.prediction import prediction, all_bowler_prediction

router = APIRouter(prefix="/predict", tags=["prediction"])

@router.post("", response_model=PredictResponse)
def predict(req: InputRequest):
    try:
        all_bowler_list = all_bowler_prediction(req, req.candidate_bowlers)
        bowler, runs = prediction(all_bowler_list)
        return PredictResponse(
            predicted_runs=round(float(runs), 2),
            predicted_bowler=bowler,
            all_predictions=all_bowler_list
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))