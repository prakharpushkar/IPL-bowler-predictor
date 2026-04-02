import joblib
import pandas as pd
from app.core.configure import settings

model=None
batter_lookup=None
bowler_lookup=None
interaction_lookup=None
default_value = None
feature_names = None

def load_all():
    global model,batter_lookup,bowler_lookup,interaction_lookup,default_value,feature_names
    
    model = joblib.load(settings.MODEL_PATH)
    batter_lookup = joblib.load(settings.BATTER_PATH)
    bowler_lookup = joblib.load(settings.BOWLER_PATH)
    interaction_lookup = joblib.load(settings.INTERACTION_PATH)
    default_value = pd.read_csv(settings.DEFAULT_VALUES_PATH)
    feature_names = joblib.load(settings.FEATURE_NAMES_PATH)
