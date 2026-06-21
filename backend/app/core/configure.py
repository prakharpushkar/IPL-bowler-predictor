import os
from pathlib import Path
from pydantic_settings import BaseSettings

# BASE_DIR is backend/
BASE_DIR = Path(__file__).resolve().parent.parent.parent

class Settings(BaseSettings):
    MODEL_PATH : str = str(BASE_DIR / 'models/xgb_model.pkl')
    BATTER_PATH : str = str(BASE_DIR / 'models/lookups/batter_lookup.pkl')
    BOWLER_PATH : str = str(BASE_DIR / 'models/lookups/bowler_lookup.pkl')
    INTERACTION_PATH : str = str(BASE_DIR / 'models/lookups/batter_bowler_interaction.pkl')
    DEFAULT_VALUES_PATH : str = str(BASE_DIR / 'data/intermediate/default_values.csv')
    FEATURE_NAMES_PATH : str = str(BASE_DIR / 'models/feature_names.pkl')
    APP_NAME : str = 'Next Bowler Predictor'

settings = Settings()