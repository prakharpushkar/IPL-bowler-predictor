# training the model
from xgboost import XGBRegressor
from sklearn.model_selection import train_test_split 
from sklearn.metrics import mean_squared_error
from xgboost import plot_importance
import pandas as pd
import numpy as np
import joblib

df = pd.read_csv("data/processed/final_training_data.csv")

X = df.drop(columns=['total_runs'])
y = df['total_runs']

X_temp,X_test,y_temp,y_test = train_test_split(
    X,y ,
    test_size = 0.2,
    random_state = 45
)

X_train,X_cv,y_train,y_cv = train_test_split(
   X_temp,y_temp,
   test_size = 0.15,
   random_state = 45 
)  

model = XGBRegressor (
    objective='reg:squarederror',
    n_estimators=1000,
    learning_rate=0.05,
    max_depth=6,
    subsample=0.8,
    colsample_bytree=0.8,
    early_stopping_rounds = 50,
    tree_method='hist'
)

model.fit(
    X_train, y_train,
    eval_set=[(X_cv, y_cv)],
    verbose=50
)

model_filename = "xgb_model.pkl"
feature_list_filename = "feature_names.pkl"
batter_lookup_filename = "batter_lookup.pkl"
bowler_lookup_filename  = "bowler_lookup.pkl"
interaction_filename    = "batter_bowler_interaction.pkl"

batter_lookup = pd.read_csv("data/intermediate/batter_lookup.csv")
bowler_lookup = pd.read_csv("data/intermediate/bowler_lookup.csv")
interaction_lookup = pd.read_csv("data/intermediate/interaction.csv")

#saving 
joblib.dump(model,model_filename)
joblib.dump(X_train.columns.to_list(),feature_list_filename)
batter_lookup.to_pickle(batter_lookup_filename)
bowler_lookup.to_pickle(bowler_lookup_filename)
interaction_lookup.to_pickle(interaction_filename)