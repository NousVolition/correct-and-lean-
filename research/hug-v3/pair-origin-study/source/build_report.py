"""Render the audited origin records; no simulation or proof is performed here."""
import csv, json, hashlib
from datetime import datetime, timezone
from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'outputs/pair25-origins'; LEAN=ROOT/'outputs/pair25-origins-lean'
TAGS=['n40_dt0p0005','n48_dt0p0005','n48_dt0p00025']
LABELS=['40³ · step 0.0005','48³ · step 0.0005','48³ · step 0.00025']
FINE=TAGS[-1]
COLORS={'old':'#1D648B','elsewhere':'#64717A','incoming':'#B6632F','added':'#C59E34','ink':'#26343C'}
def rows(p):
    with p.open(newline='',encoding='utf-8') as f:return list(csv.DictReader(f))
def write(p,text):p.write_text(text,encoding='utf-8')
def dump(p,x):write(p,json.dumps(x,indent=2,allow_nan=False)+'\n')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    a=json.loads((OUT/'analysis.json').read_text());receipt=json.loads((LEAN/'receipt.json').read_text())
    assert receipt['status']=='PASS'
    for r in a['primary_union']:
        assert r['entry']==r['stayed']==r['exit']==(133 if r['population']=='material' else 276)
        assert all(r[k]==0 for k in ['left','returned','arrived','visited'])
    assert all(r['different_membership_observations']==0 for r in a['identity_comparisons'])
    tables={t:rows(OUT/t/'context-window-origins.csv') for t in TAGS}
    primary={t:[r for r in tables[t] if float(r['radius'])==.075] for t in TAGS}
    endpoint={t:primary[t][-1] for t in TAGS};end=endpoint[FINE]
    fine=primary[FINE];times=np.array([float(r['time']) for r in fine])
    initial=float(end['entry_inside_context'])
    def series(name):return np.array([float(r[name]) for r in fine])/initial*100
    old=series('original_inside_now');away=series('original_elsewhere_now')
    incoming=series('outside_origin_inside_now');added=series('later_source_inside_now')
    total=series('total_inside_now')
    retained=lambda row:100*float(row['original_inside_now'])/float(row['entry_inside_context'])
    grid_delta=retained(endpoint[TAGS[1]])-retained(endpoint[TAGS[0]])
    time_delta=retained(endpoint[TAGS[2]])-retained(endpoint[TAGS[1]])
    comparisons=[]
    component_keys=['original_inside_now','original_elsewhere_now','outside_origin_inside_now','later_source_inside_now','total_inside_now']
    for first,last,kind in [(TAGS[0],TAGS[1],'40 to 48 grid'),(TAGS[1],TAGS[2],'48 grid: half time step')]:
        for key in component_keys:
            x=np.array([float(r[key])/float(r['entry_inside_context']) for r in primary[first]])
            y=np.array([float(r[key])/float(r['entry_inside_context']) for r in primary[last]])
            comparisons.append({'comparison':kind,'quantity':key,'maximum_common_time_difference_percentage_points':float(100*abs(x-y).max()),'endpoint_signed_difference_percentage_points':float(100*(y[-1]-x[-1]))})
    dump(OUT/'origin-comparisons.json',comparisons)
    grid_path_difference=next(r['maximum_common_time_difference_percentage_points'] for r in comparisons if r['comparison']=='40 to 48 grid' and r['quantity']=='original_inside_now')
    time_path_difference=next(r['maximum_common_time_difference_percentage_points'] for r in comparisons if r['comparison']=='48 grid: half time step' and r['quantity']=='original_inside_now')
    plt.rcParams.update({'font.family':'DejaVu Sans','font.size':12,'axes.titlesize':14,'axes.labelsize':11,'axes.spines.top':False,'axes.spines.right':False,'text.color':COLORS['ink'],'axes.labelcolor':COLORS['ink'],'axes.titleweight':'bold','savefig.facecolor':'white'})
    fig,axes=plt.subplots(2,2,figsize=(14.6,10.4))
    fig.subplots_adjust(left=.075,right=.94,top=.86,bottom=.20,hspace=.51,wspace=.30)
    fig.suptitle('Pair 25: nearby identities and context origins',x=.075,ha='left',y=.973,fontsize=22,weight='bold')
    fig.text(.075,.925,'After-write tick 41 (time 1.2) → time 1.3 · unchanged historical breathing-on simulation',fontsize=12)
    fig.text(.075,.895,'Main view: two moving windows of radius 0.075 · 48³ grid, step 0.00025',fontsize=12)
    ax=axes[0,0]
    census=rows(OUT/FINE/'window-census.csv')
    for pop,color,style,label in [('observer',COLORS['ink'],'--','Other observer labels'),('material',COLORS['old'],'-','Material point labels')]:
        table=[r for r in census if r['population']==pop and r['view']=='union' and float(r['radius'])==.075]
        tt=[float(r['time']) for r in table];vals=[int(r['inside']) for r in table]
        ax.plot(tt,vals,color=color,linestyle=style,lw=2.3)
        ax.text(1.203,vals[-1]+13,f'{vals[-1]} {label.lower()}',color=color,fontsize=11)
    ax.set(title='A. Labels inside the moving windows',ylabel='Count of unweighted labels',ylim=(0,330),xlim=(1.2,1.3),xlabel='Model time')
    ax.text(.02,.055,'Primary view: no recorded arrivals or departures.\nWider view (radius 0.10): 540 leaves, 872 arrives;\nstarting and ending count both 364.',transform=ax.transAxes,fontsize=10)
    ax=axes[0,1]
    ax.plot(times,old,color=COLORS['old'],lw=2.5,label='Starting origin still inside')
    ax.plot(times,away,color=COLORS['elsewhere'],lw=2.5,ls='--',label='Starting origin elsewhere')
    ax.scatter([1.3,1.3],[old[-1],away[-1]],c=[COLORS['old'],COLORS['elsewhere']],s=27)
    ax.text(1.301,old[-1]-4,f'{old[-1]:.1f}%',color=COLORS['old'],fontsize=11)
    ax.text(1.301,away[-1]+2,f'{away[-1]:.1f}%',color=COLORS['elsewhere'],fontsize=11)
    ax.set(title='B. Where the starting context goes',ylabel='% of context inside at time 1.2',ylim=(0,110),xlim=(1.2,1.3),xlabel='Model time')
    ax.legend(loc='upper right',frameon=False,fontsize=10)
    ax=axes[1,0]
    ax.stackplot(times,old,incoming,added,colors=[COLORS['old'],COLORS['incoming'],COLORS['added']],labels=['Starting inside origin','Starting outside origin','Added after time 1.2'],alpha=.92)
    ax.plot(times,total,color=COLORS['ink'],lw=1.8,ls='--')
    ax.text(1.203,106,f'Final local total: {total[-1]:.2f}% of its starting amount',fontsize=10)
    ax.set(title='C. What makes up the context inside now',ylabel='% of context inside at time 1.2',ylim=(0,117),xlim=(1.2,1.3),xlabel='Model time')
    handles,legend_labels=ax.get_legend_handles_labels()
    fig.legend(handles,legend_labels,loc='upper left',bbox_to_anchor=(.075,.115),ncol=3,frameon=False,fontsize=10)
    ax=axes[1,1]
    markers=['o','s','x'];styles=['--',':','-'];cs=[COLORS['elsewhere'],COLORS['incoming'],COLORS['old']]
    for tag,label,marker,style,color in zip(TAGS,LABELS,markers,styles,cs):
        e=[r for r in a['context_endpoints'] if r['run']==tag]
        ax.plot([r['radius'] for r in e],[100*r['original_inside_fraction_of_entry'] for r in e],marker=marker,ms=7,ls=style,color=color,lw=1.6,label=label)
    ax.set(title='D. Changing the window and resolution',xlabel='Window radius (model lengths)',ylabel='% of starting context still inside at 1.3',ylim=(0,100),xlim=(.045,.105),xticks=[.05,.075,.1])
    ax.legend(loc='upper left',fontsize=9,frameon=False)
    ax.text(.04,.07,f'Earlier in the interval, retained shares differ by\nup to {grid_path_difference:.3f} percentage points between grids.',transform=ax.transAxes,fontsize=9)
    for ax in axes.flat:
        ax.grid(axis='y',color='#dce1e3',lw=.6);ax.set_axisbelow(True)
    for ax in [axes[0,0],axes[0,1],axes[1,0]]:ax.set_xticks([1.2,1.225,1.25,1.275,1.3],['1.200','1.225','1.250','1.275','1.300'])
    fig.text(.075,.065,'Context C is a model scalar, not water mass. The windows are views, not ownership or closed material parcels.',fontsize=10)
    fig.text(.075,.04,f'Lean: {receipt["target_count"]} finite rules and recorded-data statements checked. Fluid evolution and complete physical retention remain outside these proofs.',fontsize=10)
    fig.text(.075,.015,'AI-generated; dictated and directed by NousVolition. Source: saved pair25-origins records and independent recount.',fontsize=9,color='#65737b')
    fig.savefig(OUT/'pair25-origins.png',dpi=160)
    fig.savefig(OUT/'pair25-origins.svg')
    plt.close(fig)
    identity_lines=[]
    for r in a['primary_union']:
        identity_lines.append(f'| {r["run"]} | {r["population"]} | {r["entry"]} | {r["stayed"]} | {r["left"]} | {r["returned"]} | {r["arrived"]} | {r["visited"]} |')
    origin_lines=[]
    for tag in TAGS:
        r=endpoint[tag];den=float(r['entry_inside_context'])
        vals=[100*float(r[k])/den for k in ['original_inside_now','original_elsewhere_now','outside_origin_inside_now','later_source_inside_now','total_inside_now']]
        origin_lines.append('| '+tag+' | '+' | '.join(f'{v:.6f}' for v in vals)+' |')
    radius_lines=[]
    for r in a['context_endpoints']:
        radius_lines.append(f'| {r["run"]} | {r["radius"]} | {r["original_inside_fraction_of_entry"]*100:.6f}% |')
    checks=[json.loads((OUT/t/'result.json').read_text()) for t in TAGS]
    field=rows(LEAN/'source-data/material-field-changes.csv')
    changes=[r for r in field if r['run']==FINE]
    max_reconstruction=max(r['max_context_reconstruction_defect'] for r in checks)
    max_drift=max(r['max_global_original_component_drift'] for r in checks)
    max_source=max(r['max_later_source_account_defect'] for r in checks)
    min_boundary=min(r['minimum_boundary_distance'] for r in a['runs'])
    all_summary=rows(OUT/'identity-summary.csv')
    nonprimary=[r for r in all_summary if (float(r['radius'])!=.075 or r['view']!='union') and any(int(r[k]) for k in ['left','returned','arrived','visited'])]
    control_note=f'{len(nonprimary)} sensitivity views contain departures, returns, arrivals or visits; see the full [identity summary](identity-summary.csv).' if nonprimary else 'No recorded crossing occurred in the smaller or larger windows or the separate A/B views either.'
    cross=[r for r in rows(OUT/'crossings.csv') if r['view']=='union']
    crossing_lines=[f'| {r["run"]} | {r["id"]} | {r["event"]} | ({r["last_time_before"]}, {r["first_time_after"]}] |' for r in cross]
    for tag in TAGS:
        assert {(r['id'],r['event']) for r in cross if r['run']==tag}=={('540','leave'),('872','arrive')}
    report=f'''# Pair 25: what stays nearby, and what changes origin

The same **133 material point labels and 276 other observer labels** stay inside the chosen moving windows at every recorded step in all three runs. The context inside those windows changes origin: in the finest time-step run, **{old[-1]:.2f}% of the starting inside contribution is still inside**, while **{away[-1]:.2f}% is elsewhere** in the domain. Outside-origin and later-source contributions enter the local account, leaving the total at **{total[-1]:.2f}%** of its starting amount.

![Pair 25 origin tracking](pair25-origins.png)

## What “came in with” means here

This follows the saved **after-write tick-41 state, time 1.2, through time 1.3**. Pair 25 is stored ID24, observer slots 825/850. It does not reconstruct the earlier encounter's missing starting inventory at time 1.1. The observation window is the union of two periodic spheres of radius **0.075** centered on the existing A/B trajectories. Radius 0.05, radius 0.10, and each separate sphere are sensitivity views. These are observation boundaries, not physical walls, ownership, or material parcels. Nothing is forced to close into a loop.

The historical threshold-0.015, breathing-on, 384-material-point setup is preserved. This added-drive experiment does not redefine the intended unforced system. Passive diagnostic labels do not feed the fluid, the material, or the shared memory. All 17 native exit arrays and all 51 common pair positions exactly match the earlier unlabelled continuations.

## The labels stay; their fields change

All 384 material IDs and all 924 other observer IDs were followed at each completed native step. A/B are excluded from neighbor counts. These are unweighted labels, not mass. The primary entry windows contain 132 material points near A and only **one** near B; this uneven coverage is not a representative inventory of all fluid.

| Run | Population | At start | Stayed at every sample | Left at exit | Left and returned | New at exit | Visited then left |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
{chr(10).join(identity_lines)}

**A wider view catches a membership change that the total hides.** At radius 0.10, observer **540 leaves** and **872 arrives** in every run. Of the 364 labels present at the start, 363 stay and one leaves; the new arrival restores the ending count to 364. Arrival occurs before departure, so the count briefly reaches 365. This records changing membership, not a tested transfer from one label to the other.

| Run | Observer | Event in the wider union | Recorded crossing bracket (model time) |
| --- | ---: | --- | --- |
{chr(10).join(crossing_lines)}

The crossing identities agree across runs. The 40³ and 48³ crossing brackets differ, so the crossing times are not established as grid-converged. These brackets locate changes between adjacent saved steps; they are not exact continuous crossing times.

All 384 material points change both their deformation field F and directional-memory field m during the interval; the identity stays while its state changes. On the finest run, the per-point maximum F change ranges from {min(float(r['F_max_change']) for r in changes):.9g} to {max(float(r['F_max_change']) for r in changes):.9g}; the corresponding m change ranges from {min(float(r['m_max_change']) for r in changes):.9g} to {max(float(r['m_max_change']) for r in changes):.9g}. No m component decreases at the recorded steps. This is a finite numerical observation, not a statement that those fields are complete contents.

The original three shared event records remain byte-for-byte unchanged in **{a['shared_payload_checks']}** comparisons. They are shared system records, not a private inventory belonging to A/B. {control_note} The closest recorded label was {min_boundary:.9g} model lengths from any tested boundary, outside the declared 1e-8 ambiguity band. Crossings between sampled steps remain untested.

## The context total hides changing origins

At time 1.2, the native context field C is split by its location: initially inside or outside the chosen union. A third component records context added afterward. These passive fields use the native transport/diffusion operator and Heun stages. They reconstruct C within the declared tolerance. **C is the model's signed context scalar, not water mass or a molecular inventory.** Components in these runs remain nonnegative within the declared roundoff allowance.

Every percentage below uses that run's context inside at time 1.2 as denominator. “Starting origin elsewhere” is outside the current window but still in the domain; it is not destroyed. The three current-inside contributions sum to the current local total. This is numerical origin accounting, not identification of which water molecules replace which others.

| Run | Starting origin still inside (%) | Starting origin elsewhere (%) | Outside origin now inside (%) | Added later, now inside (%) | Current local total (%) |
| --- | ---: | ---: | ---: | ---: | ---: |
{chr(10).join(origin_lines)}

Changing 40³ to 48³ shifts the endpoint retained-origin fraction by **{grid_delta:+.6f} percentage points**, but its difference reaches **{grid_path_difference:.6f} percentage points earlier in the interval**. Halving the 48³ time step shifts the endpoint by **{time_delta:+.6f} percentage points**, with a maximum common-time difference of **{time_path_difference:.6f} percentage points**. Primary-window identity memberships agree at all common times. The other context-account differences over all 51 common times are in [origin-comparisons.json](origin-comparisons.json). No convergence tolerance was declared for these new origin fractions, so these comparisons do not establish continuum convergence. Each grid represents the initial spherical boundary with its own cells.

The window choice itself matters:

| Run | Radius | Starting context still inside at time 1.3 |
| --- | ---: | ---: |
{chr(10).join(radius_lines)}

## What Lean checked

**{receipt['target_count']} statements passed locally.** [The separate Lean package](../pair25-origins-lean/README.md) checks finite classification rules, recorded primary and wider-union identity histories (including 540 leaving and 872 arriving), per-material field-change numbers, complete shared-record bytes, and exact decimal context-origin accounts and numerical bounds. It also checks the recorded positive original-origin departure and incoming/later-source contributions in each run. Its [receipt](../pair25-origins-lean/receipt.json) records the exact inputs, target list and standard axiom dependencies.

An independent saved-data recount computed membership from positions, compared native endpoints, recomputed origin sums from saved fields, and interpolated A/B components by a separate routine. The data certificate matches Lean's constants to these saved records; it does not prove that the simulator or the recount code is correct. Runtime stage extrema are recorded checks, not an independent replay of every stage. Lean does not prove the fluid equations, numerical trajectory, geometric interpolation, crossings between samples, thermal origins, or complete physical retention. **We still do not know whether everything stays with the pair.**

## Checks and preserved evidence

The largest reconstruction defect is {max_reconstruction:.9g} (limit 1e-12); original-component global drift is {max_drift:.9g} (limit 1e-12); later-source account defect is {max_source:.9g} (limit 1e-10). The instrumented pilot matched all 17 native one-step arrays; batched transport matched the native scalar operator. The new labels change none of the original fluid state. Six refusal tests reject changed primary or wider membership bits, identities, origin decimals, memory bytes, or material-field numbers.

[Declared plan](../../work/pair25-origins/PLAN.md) · [Independent recount](analysis.json) · [Complete finite classifications](identity-classification.csv) · [Lean receipt](../pair25-origins-lean/receipt.json) · [SVG figure](pair25-origins.svg)

Full trajectories and origin fields are saved locally. This follow-up is local; it does not change GitHub or supersede the earlier publication and receipts.

**AI-generated; dictated and directed by NousVolition.**
'''
    write(OUT/'README.md',report)
    write(LEAN/'README.md',f'''# Pair 25: finite origin records

**{receipt['target_count']} checked statements, local Lean {receipt['compiler']}.** See the separate [simulation report](../pair25-origins/README.md) for measurement scope.

`OriginTracking.lean` supplies finite classification and account rules. `RecordedOrigins.lean` checks complete primary-window membership histories, wider-union observer histories and departing/arriving IDs, material-field changes, full shared memory bytes, and exact recorded decimal accounts. The primary observation convention is two moving radius-0.075 spheres; the wider union uses radius 0.10, and context accounts also cover radius 0.05. Neither the window geometry nor the fluid evolution is proved by Lean.

The source certificate matches {receipt['data_certificate_check']['histories_matched']} primary histories ({receipt['data_certificate_check']['membership_bits_matched']} membership bits), {receipt['data_certificate_check']['wider_observer_histories_matched']} wider observer histories ({receipt['data_certificate_check']['wider_observer_membership_bits_matched']} membership bits), {receipt['data_certificate_check']['full_record_payloads_matched']} full payload comparisons, {receipt['data_certificate_check']['window_accounts_matched']} window accounts, {receipt['data_certificate_check']['point_accounts_matched']} point accounts, and {receipt['data_certificate_check']['material_field_records_matched']} material-field records. The material-field table is derived by the independent saved-state recount. All decimal literals use a common power-of-ten denominator; tolerance checks are exact integer checks of recorded decimal numbers.

The [receipt](receipt.json) lists all proof-input hashes, all targets and each target's axiom dependencies. No added axioms, `sorry`, or `native_decide` are used. Standard Lean axioms are reported rather than concealed.

Run `python check_certificate.py --self-test`, then `python verify_lean.py --lean <path-to-lean-4.34.0-rc2>`. NumPy is needed for saved-data matching. The simulation is not rerun by these checks. The six refusal tests alter independent evidence types and require rejection.

Proof-input fingerprint: `{receipt['proof_input_fingerprint']}`.

These proofs do not establish microscopic ownership, all-physical-content retention, continuous-time residence, or continuum convergence. Published earlier receipts remain historical and unchanged.

AI-generated; dictated and directed by NousVolition.
''')
    dump(OUT/'report-values.json',{'generated_utc':datetime.now(timezone.utc).isoformat(),'primary_endpoint':end,'retained_origin_percent':float(old[-1]),'elsewhere_origin_percent':float(away[-1]),'inside_outside_origin_percent_of_entry':float(incoming[-1]),'inside_later_source_percent_of_entry':float(added[-1]),'total_inside_percent_of_entry':float(total[-1]),'grid_endpoint_difference_percentage_points':grid_delta,'time_endpoint_difference_percentage_points':time_delta,'nonprimary_views_with_crossings':len(nonprimary),'lean_target_count':receipt['target_count'],'diagram_sha256':sha(OUT/'pair25-origins.png')})
    print(json.dumps({'report':str(OUT/'README.md'),'diagram':str(OUT/'pair25-origins.png'),'retained_origin_percent':float(old[-1]),'elsewhere_origin_percent':float(away[-1]),'total_inside_percent':float(total[-1]),'grid_delta_pp':grid_delta,'time_delta_pp':time_delta,'sensitivity_views_with_crossings':len(nonprimary)},indent=2))
if __name__=='__main__':main()
