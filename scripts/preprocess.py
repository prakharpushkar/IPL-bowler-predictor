import pandas as pd 
import numpy as np

df = pd.read_csv("../data/raw/IPL.csv")

def get_phase(over):
    if over <= 6:
        return 0
    elif over <=15:
        return 1
    else :
        return 2

def most_frequent(x):
    return x.value_counts().idxmax()

df['phase'] = df['over'].apply(get_phase)
df['overz']  = df['over'] + 1

# batter strike rate
df['batter_sr'] = (df['batter_runs'] / df['batter_balls']) * 100 

overs_df = df.groupby(['match_id','innings','overz']).agg(
    venue=('venue','first'),
    phase=('phase','first'),
    striker=('batter', most_frequent),
    non_striker=('non_striker', most_frequent),
    runs_batter=('runs_batter','sum'),
    bowler=('bowler', "first"),
    bowler_runs=('runs_bowler','sum'),
    wicket=('bowler_wicket','max'),
    team_runs=('team_runs','max'),
    team_wickets=('team_wicket','max'),
    target=('runs_target','max'),
    total_runs=('runs_total','sum')
).reset_index()

# current run rate
overs_df['current_run_rate'] = (overs_df['team_runs'] /  overs_df['overz']) 
overs_df['current_run_rate'] = overs_df['current_run_rate'].fillna(0)

# required run rate
overs_df['req_rr'] = np.where(
    overs_df['target'].notna(),
    ((overs_df['target'] - overs_df['team_runs'] )/ (20 - overs_df['overz'])),
    0
)
overs_df.fillna(0,inplace=True)
columns_to_drop = ['match_id','venue','innings','overz','runs_batter','bowler_runs','wicket','target',]
final_over_df = overs_df.drop(columns=columns_to_drop)
final_over_df.head(12)








# lookup table for bowler 
bdf = df[df['valid_ball']==1] 
bdf = bdf.groupby('bowler').agg(
    total_balls = ('valid_ball','count'),
).reset_index()

Bowler_lookup = df.groupby('bowler').agg(
    total_runs = ('runs_bowler','sum'),
    total_wickets = ('bowler_wicket','sum'),
).reset_index()

# merge total balls (valid only)
Bowler_lookup = Bowler_lookup.merge(bdf[['bowler','total_balls']], on='bowler', how='left')
Bowler_lookup['total_balls'] = Bowler_lookup['total_balls'].fillna(0).astype(int)
Bowler_lookup['total_overs'] = Bowler_lookup['total_balls'] / 6.0

# guard division by zero when computing overall_economy
Bowler_lookup['overall_economy'] = np.where(
    Bowler_lookup['total_overs'] > 0,
    Bowler_lookup['total_runs'] / Bowler_lookup['total_overs'],
    np.nan
)

demo = df.groupby(['bowler','phase']).agg(
    phase_runs = ('runs_bowler','sum'),
    phase_wicket = ('bowler_wicket','sum'),
).reset_index()

cdf = df[df['valid_ball']==1]
cdf = cdf.groupby(['bowler','phase']).agg(
    phase_balls = ('valid_ball','count'),
).reset_index()

demo = demo.merge(cdf[['bowler','phase','phase_balls']], on=['bowler','phase'], how='left')
demo['phase_balls'] = demo['phase_balls'].fillna(0).astype(int)
demo['phase_economy'] = np.where(
    demo['phase_balls'] > 0,
    demo['phase_runs'] / (demo['phase_balls'] / 6.0),
    np.nan
)
demo['phase_wk'] = np.where(
    demo['phase_balls'] > 0,
    demo['phase_wicket'] / (demo['phase_balls'] / 6.0),
    0.0
)

w = demo.pivot(index='bowler',columns='phase',values='phase_wk').rename(
    columns={     0: 'pp_wk_po', 1: 'middle_wk_po', 2: 'death_wk_po'   }
)

b = demo.pivot(index='bowler',columns='phase',values='phase_balls').rename(
    columns={     0: 'pp_balls', 1: 'middle_balls', 2: 'death_balls'   }
)

ww = demo.pivot(index='bowler',columns='phase',values='phase_wicket').rename(
    columns={     0: 'pp_wickets', 1: 'middle_wickets', 2: 'death_wickets'   }
)

e = demo.pivot(index='bowler',columns='phase',values='phase_economy').rename(
    columns={     0: 'pp_economy', 1: 'middle_economy', 2: 'death_economy'   }
)

# Bowler_lookup = Bowler_lookup.merge(r, on='bowler', how='left')
Bowler_lookup = Bowler_lookup.merge(b, on='bowler', how='left')
Bowler_lookup = Bowler_lookup.merge(w, on='bowler', how='left') 
Bowler_lookup = Bowler_lookup.merge(ww, on='bowler', how='left')
Bowler_lookup = Bowler_lookup.merge(e, on='bowler', how='left') 


# stablise small sample estimates for economies using simple Bayesian shrinkage towards global mean economy
k = 48 # prior strength in balls (e.g., 36 balls)

global_mean_economy = (Bowler_lookup['total_runs'].sum()) / (Bowler_lookup['total_overs'].replace(0,np.nan).dropna().sum())

Bowler_lookup['effe_overall_economy'] = np.where(
    Bowler_lookup['total_overs'] > 8,
    Bowler_lookup['total_runs'] / Bowler_lookup['total_overs'],
    ((Bowler_lookup['overall_economy'] * Bowler_lookup['total_balls']) + (global_mean_economy * k))
    / (Bowler_lookup['total_balls'] + k)
)
#  phase wise
for phase,p_eco,p_ball,name in [
    (0,'pp_economy','pp_balls','effe_pp_economy'),
    (1,'middle_economy','middle_balls','effe_middle_economy'),
    (2,'death_economy','death_balls','effe_death_economy')
]:
    Bowler_lookup[p_eco] = Bowler_lookup[p_eco].fillna(Bowler_lookup['overall_economy'])
    Bowler_lookup[name] = ((Bowler_lookup[p_eco]*Bowler_lookup[p_ball])+(global_mean_economy*k))/(Bowler_lookup[p_ball]+k)

columns_to_drop = ['total_runs','total_overs','overall_economy','pp_economy','middle_economy','death_economy','pp_wickets',
       'middle_wickets', 'death_wickets']

Bowler_lookup = Bowler_lookup.fillna(0)

final_bowler_lookup = Bowler_lookup.drop(columns=columns_to_drop)
for c in final_bowler_lookup.columns :
    if c.startswith('effe_'):
        final_bowler_lookup.rename(
            columns={
                c: c.replace('effe_',"")
            },
            inplace=True
        )
final_bowler_lookup.columns








# lookup for batter
batter_lookup = df[df['valid_ball']==1].groupby(['batter']).agg(
    runs = ('runs_batter','sum'),
    balls_faced=('balls_faced','sum'),
    ones = ('runs_batter', lambda x: (x == 1).sum()),
    threes = ('runs_batter', lambda x: (x == 3).sum())      
)
batter_lookup['overall_strike_rate'] = (batter_lookup['runs'] / batter_lookup['balls_faced']) * 100
batter_lookup['rotation_rate'] = (batter_lookup['ones'] + batter_lookup['threes']) / batter_lookup['balls_faced']
batter_lookup.reset_index(inplace=True)

temp = df[df['valid_ball']==1].groupby(['batter','phase']).agg(
    pruns = ('runs_batter','sum'),
    pballs = ('valid_ball','count')
)
temp['p_sr'] = np.where(
    temp['pballs'] > 0,
    (temp['pruns'] / temp['pballs']) * 100,
    0
)
temp.reset_index(inplace=True)

sr_pivot = (
    temp.pivot(index='batter', columns='phase', values='p_sr')
    .rename(columns={0: 'pp_sr', 1: 'middle_sr', 2: 'death_sr'})
    .fillna(0)
    .reset_index()
)

runs_pivot = (
    temp.pivot(index='batter', columns='phase', values='pruns')
    .rename(columns={0: 'pp_runs', 1: 'middle_runs', 2: 'death_runs'})
    .fillna(0)
    .reset_index()
)

balls_pivot = (
    temp.pivot(index='batter', columns='phase', values='pballs')
    .rename(columns={0: 'pp_balls', 1: 'middle_balls', 2: 'death_balls'})
    .fillna(0)
    .reset_index()
)

# Combine them
t = sr_pivot.merge(runs_pivot, on='batter').merge(balls_pivot, on='batter')
batter_lookup = batter_lookup.merge(t[['batter','pp_sr','middle_sr','death_sr','pp_runs','middle_runs','death_runs','pp_balls','middle_balls','death_balls']], on='batter', how='left')

# # stabilise small sample estimates for strike rates using simple Bayesian shrinkage towards global mean strike rate
k = 60   # prior strength (60 balls ≈ 10 overs)

global_runs = df['runs_batter'].sum()
global_balls = df[df['valid_ball']==1]['valid_ball'].count()

global_rpb = global_runs / global_balls  # runs per ball

batter_lookup['overall_sr_shrunk'] = (
    batter_lookup['runs'] + global_rpb * k
) / (batter_lookup['balls_faced'] + k) * 100

# phase wise shrinkage
batter_lookup['pp_sr_shrunk'] = (
    batter_lookup['pp_runs'] + global_rpb * k
) / (batter_lookup['pp_balls'] + k) * 100

batter_lookup['middle_sr_shrunk'] = (batter_lookup['middle_runs'] + global_rpb*k) / (batter_lookup['middle_balls']+ k)*100

batter_lookup['death_sr_shrunk'] = (batter_lookup['death_runs'] + global_rpb*k) / (batter_lookup['death_balls'] + k) * 100

columns_to_drop = ['runs','ones','threes','overall_strike_rate','pp_runs','middle_runs','death_runs','pp_sr','middle_sr','death_sr']

final_batter_lookup = batter_lookup.drop(columns=columns_to_drop, axis=0).fillna(0)
final_bowler_lookup = final_bowler_lookup.rename(
    columns={'total_balls':'total_balls_bowled','total_wickets':'total_wickets_taken','overall_economy':'overall_economy_bowling'}
)
for c in final_batter_lookup.columns:
    if c.endswith('_shrunk'):
        final_batter_lookup.rename(columns={
            c : c.replace('_shrunk','')
        },inplace=True)
final_batter_lookup.head()
# final_batter_lookup.to_csv("batter_lookup.csv",index=False)











# interaction table
legal_balls = df[df['valid_ball'] == 1].copy()

interaction_table = legal_balls.groupby(['batter', 'bowler']).agg(
    total_balls = ('valid_ball', 'count'),
    total_runs = ('runs_bowler','sum'),
    wickets = ('bowler_wicket', 'sum'),
).reset_index()

interaction_table['wicket_rate'] = (
    interaction_table['wickets'] / interaction_table['total_balls'] * 100
)

# global stats for batter
batter_global = legal_balls.groupby('batter').agg(
    g_runs=('runs_batter','sum'),
    g_balls=('valid_ball','count')
).reset_index()

batter_global['global_SR'] = (
    batter_global['g_runs'] / batter_global['g_balls']
) * 100

interaction_table = interaction_table.merge(
    batter_global[['batter','global_SR']],
    on='batter',
    how='left'
)

# reliability threshold
k = 30 

interaction_table['strike_rate'] = np.where(
    interaction_table['total_balls'] > 30,
    (interaction_table['total_runs'] / interaction_table['total_balls']) * 100,
    ((interaction_table['total_runs'] * 100) + (k * interaction_table['global_SR'])) / (interaction_table['total_balls'] + k)
)

columns_to_drop =['total_runs','global_SR']
final_interaction_lookup = interaction_table.drop(columns=columns_to_drop)
final_interaction_lookup.head()










# merging all the lookup tables together with the over df

finally_over_df = final_over_df.copy()
finally_over_df = finally_over_df.merge(
    final_bowler_lookup,
    on='bowler',
    how='left',
)

# merge striker lookup
f_over_df = finally_over_df.copy()

striker_lookup = final_batter_lookup.copy()
striker_lookup = striker_lookup.add_prefix('striker_')
striker_lookup = striker_lookup.rename(columns={'striker_batter': 'striker'})

f_over_df = f_over_df.merge(
    striker_lookup,
    on='striker',
    how='left'
)
# merge non-striker lookup
non_striker_lookup = final_batter_lookup.copy()
non_striker_lookup = non_striker_lookup.add_prefix('non_striker_')
non_striker_lookup = non_striker_lookup.rename(columns={'non_striker_batter': 'non_striker'})
f_over_df = f_over_df.merge(
    non_striker_lookup,
    on='non_striker',
    how='left'
)

# merge interaction lookup for striker-bowler
inter_lookup = final_interaction_lookup.copy()
inter_lookup = inter_lookup.rename(
    columns={'batter': 'striker','total_balls': 'total_matchup_balls'}
)
f_over_df = f_over_df.merge(inter_lookup, on=['striker','bowler'], how='left')
f_over_df = f_over_df.merge(inter_lookup.rename(columns={'striker': 'non_striker'}), on=['non_striker','bowler'], how='left', suffixes=('_striker','_non_striker'))

f_over_df = f_over_df.reindex(columns=['phase','team_runs',
       'team_wickets', 'current_run_rate', 'req_rr',
       'total_wickets', 'total_balls', 'pp_balls', 'middle_balls',
       'death_balls', 'pp_wk_po', 'middle_wk_po', 'death_wk_po',
       'overall_economy', 'pp_economy', 'middle_economy', 'death_economy',
       'striker_balls_faced', 'striker_rotation_rate', 'striker_pp_balls',
       'striker_middle_balls', 'striker_death_balls', 'striker_overall_sr',
       'striker_pp_sr', 'striker_middle_sr', 'striker_death_sr',
       'non_striker_balls_faced', 'non_striker_rotation_rate',
       'non_striker_pp_balls', 'non_striker_middle_balls',
       'non_striker_death_balls', 'non_striker_overall_sr',
       'non_striker_pp_sr', 'non_striker_middle_sr', 'non_striker_death_sr',
       'total_matchup_balls_striker', 'wickets_striker', 'wicket_rate_striker',
       'strike_rate_striker', 'total_matchup_balls_non_striker',
       'wickets_non_striker', 'wicket_rate_non_striker',
       'strike_rate_non_striker','total_runs' ])

f_over_df.replace([np.inf,-np.inf],np.nan,inplace=True)
f_over_df.fillna(0,inplace=True)

f_over_df.to_csv("final_training_data.csv", index=False)
f_over_df.columns