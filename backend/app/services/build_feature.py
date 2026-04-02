import pandas as pd
from app.schema.pyandantic import PredictRequest
from app.core import state


def get_phase(over : int):
    if over <= 6:
        return {'phase': 0}
    elif over < 16:
        return {'phase': 1}
    else:
        return {'phase': 2}
    
def curr_rr(team_runs,team_balls):
    if team_balls == 0:
        return {'current_run_rate': 0.0}
    else:
        return {'current_run_rate': (team_runs / (team_balls / 6))}
    
def req_rr(target,team_runs,over):
    remaining_runs = target - team_runs
    remaining_overs = 20 - over
    if remaining_overs == 0:
        return {'req_rr': 0.0}
    else:
        return {'req_rr': (remaining_runs / remaining_overs)}
    
def striker_sr(striker_runs, striker_balls):
    if striker_balls == 0:
        return {'striker_current_sr': 0.0}
    else:
        return {'striker_current_sr': (striker_runs / striker_balls) * 100}

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
            (f"{k.replace('inter_','')}_{preffix}"): default_map[k] for k in default_map if k.startswith("inter_")
        }
        
def build_inference_df(user_input: PredictRequest):
    row = {}
    row.update(get_phase(user_input.over))

    row['team_runs'] = user_input.team_runs
    row['team_wickets'] = user_input.team_wickets

    row.update(curr_rr(user_input.team_runs, user_input.over * 6))
    row.update(req_rr(user_input.target, user_input.team_runs, user_input.over))
    row.update(striker_sr(user_input.striker_runs, user_input.striker_balls))

    row.update(get_player(user_input.bowler, state.bowler_lookup,'bowler',state.default_value))
    row.update(get_player(user_input.striker,state.batter_lookup,'striker',state.default_value))
    row.update(get_player(user_input.non_striker,state.batter_lookup,'non_striker',state.default_value))
    row.update(interaction_stats(user_input.striker,user_input.bowler,'striker',state.interaction_lookup, state.default_value))
    row.update(interaction_stats(user_input.non_striker,user_input.bowler,'non_striker',state.interaction_lookup, state.default_value))

    df = pd.DataFrame([row])
    features_list = state.feature_names
    df = df.reindex(columns=features_list).fillna(0)
    df = df.apply(pd.to_numeric, errors='coerce').fillna(0)
    return df

