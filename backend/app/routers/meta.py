from fastapi import APIRouter
from app.core import state

router = APIRouter(tags=["meta"])

@router.get("/health")
def health():
    return {"status": "ok", "model_loaded": state.model is not None}

@router.get("/batters")
def get_batters():
    return {"batters": sorted(state.batter_lookup["batter"].tolist())}

@router.get("/bowlers")
def get_bowlers():
    return {"bowlers": sorted(state.bowler_lookup["bowler"].tolist())}