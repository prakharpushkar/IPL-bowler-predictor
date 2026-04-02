from pydantic import BaseModel, Field

class InputRequest(BaseModel):
    over: int = Field(..., ge=0, le=20)  
    team_runs: int = Field(..., ge=0)
    team_wickets: int = Field(..., ge=0, le=10)
    target: int = Field(..., ge=0)
    striker: str
    non_striker: str
    striker_runs: int = Field(..., ge=0)
    striker_balls: int = Field(..., ge=0)
    candidate_bowlers: list[str] = Field(...,min_length=2, max_length=5)

class PredictRequest(BaseModel):
    over: int = Field(..., ge=0, le=20)  
    team_runs: int = Field(..., ge=0)
    team_wickets: int = Field(..., ge=0, le=10)
    target: int = Field(..., ge=0)
    striker: str
    non_striker: str
    striker_runs: int = Field(..., ge=0)
    striker_balls: int = Field(..., ge=0)
    bowler: str

class BowlerPrediction(BaseModel):
    bowler: str
    predicted_runs: float

class PredictResponse(BaseModel):
    predicted_bowler: str         
    predicted_runs: float          
    all_predictions: list[BowlerPrediction]  