import joblib
import pandas as pd

#loading the model and the dataset
model = joblib.load("xgb_model.pkl")
features = joblib.load("models/feature_names.pkl")
batter_lookup = pd.read_pickle("models/lookups/batter_lookup.pkl")
bowler_lookup = pd.read_pickle("models/lookups/boler_lookup.pkl")
interaction_lookup = pd.read_pickle("models/lookups/batter_bowler_interaction.pkl")


# default map for missing players
default_values = {}

for c in final_batter_lookup.columns:
    if c != "batter":   # skip the batter name column
        default_values[f"striker_{c}"] = final_batter_lookup[c].mean()
        default_values[f"non_striker_{c}"] = final_batter_lookup[c].mean()

for c in final_bowler_lookup.columns:
    if c != "bowler":   # skip the bowler name column
        default_values[f"bowler_{c}"] = final_bowler_lookup[c].mean()

for c in final_interaction_lookup.columns:
    if c not in ["batter", "bowler"]:   # skip name columns
        default_values[f"inter_{c}"] = final_interaction_lookup[c].mean()


# functions
def get_player(name, lookup_df, preffix, default_map):
    try:
        if name in lookup_df[lookup_df.columns[0]].values:
            row = lookup_df.set_index(lookup_df.columns[0]).loc[name]
            if preffix=='non_striker' or preffix=='striker':
                return {f"{preffix}_{c}": row[c] for c in row.index}
            else:
                return {c : row[c] for c in row.index}
        else:
            raise KeyError
    except:
        if preffix=='bowler':
            return {
                (k.replace('bowler_','')) : default_map[k] for k in default_map if k.startswith("bowler_")
            }
        else:
            return {k: default_map.get(k, 0.0) for k in default_map if k.startswith(preffix)}

def interaction_stats(batter_name, bowler_name, preffix,inter_df, default_map):
    try:
        row = inter_df[(inter_df['batter'] == batter_name) & (inter_df['bowler'] == bowler_name)].iloc[0]
        return {
            f"{c}_{preffix}": row[c] for c in row.index if c != 'batter' and c != 'bowler'
        }
    except:
        return {
            (k.replace("inter_",'')): default_map[k] for k in default_map if k.startswith("inter_")
        }

def build_inference_df(user_input):
    row = {}
    for ip in ['phase', 'team_runs','team_wickets', 'current_run_rate','req_rr']:
        if ip in user_input:
            row[ip] = user_input[ip]
    row.update(get_player(user_input['bowler'],final_bowler_lookup,'bowler',default_values))
    row.update(get_player(user_input['striker'],final_batter_lookup,'striker',default_values))
    row.update(get_player(user_input['non_striker'],final_batter_lookup,'non_striker', default_values))
    row.update(interaction_stats(user_input['striker'],user_input['bowler'],"striker",final_interaction_lookup,default_values))
    row.update(interaction_stats(user_input['non_striker'],user_input['bowler'],"non_striker",final_interaction_lookup,default_values))
    df = pd.DataFrame([row])
    df = df.fillna(0)
    return df

def predict(model, X_train):
    return model.predict(X_train)

def recommend_best_bowler(candidate_bowlers,base_user_input,batter_lookup,bowler_lookup,interaction_lookup,default_map,model):
    best = None
    best_pred = float("inf")
    for b in candidate_bowlers:
        ui = base_user_input.copy()
        ui['bowler'] = b
        X_row = build_inference_df(ui)
        # print(X_row.columns)
        pred = predict(model, X_row)
        if pred < best_pred:
            best_pred = pred
            best = b
    return {
        "best_bowler": best,
        "predicted_runs": best_pred
    } 

#     candidate_bowlers = [
#     'MA Starc',
#     'SP Narine',
#     'DJ Bravo',
#     'JP Faulkner',
#     'SL Malinga'
# ]
# inputs = {
#     'over' : 16,
#    'team_runs' : 132,
#    'team_wickets' : 5,
#    'target' : 172,
#    'striker' : 'AD Russell',
#    'non_striker' : 'MS Dhoni'
# }
# inputs['phase'] = get_phase(inputs['over'])
# inputs['req_rr'] = (
#     (inputs['target'] - inputs['team_runs']) /
#     (20 - inputs['over'])
# )
# inputs['current_run_rate'] = inputs['team_runs']/inputs['over']
# del inputs['over']
# recommend_best_bowler(candidate_bowlers,inputs,final_batter_lookup,final_bowler_lookup,final_interaction_lookup,default_values,model)
