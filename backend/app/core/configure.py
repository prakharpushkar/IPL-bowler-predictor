from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    MODEL_PATH : str = '../models/xgb_model.pkl'
    BATTER_PATH : str = '../models/lookups/batter_lookup.pkl'
    BOWLER_PATH : str = '../models/lookups/bowler_lookup.pkl'
    INTERACTION_PATH : str = '../models/lookups/batter_bowler_interaction.pkl'
    DEFAULT_VALUES_PATH : str = '../data/intermediate/default_values.csv'
    FEATURE_NAMES_PATH : str = '../models/feature_names.pkl'
    APP_NAME : str = 'Next Bowler Predictor'

settings = Settings()