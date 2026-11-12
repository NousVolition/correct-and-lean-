"""Render audited observations; this renderer does not simulate or prove them."""
import csv,hashlib,json
from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'outputs/observer540-872';LEAN=ROOT/'outputs/observer540-872-lean'
TAGS=['n40_dt0p0005','n48_dt0p0005','n48_dt0p00025'];FINE=TAGS[-1];IDS=[540,872]
INK='#26343c';OLD='#236c91';OTHER='#be7043';NEW='#c5a53e'
def rows(p):
    with p.open(newline='',encoding='utf-8') as f:return list(csv.DictReader(f))
def read(p):return json.loads(p.read_text(encoding='utf-8'))
def write(p,s):p.write_text(s,encoding='utf-8')
def main():
    a=read(OUT/'analysis.json');receipt=read(LEAN/'receipt.json');assert receipt['status']=='PASS'
    points={t:rows(OUT/t/'point-history.csv') for t in TAGS};windows={t:rows(OUT/t/'window-history.csv') for t in TAGS}
    ends={i:next(r for r in a['window_endpoints'] if r['run']==FINE and r['observer']==i) for i in IDS}
    plt.rcParams.update({'font.family':'DejaVu Sans','font.size':11,'axes.titlesize':14,'axes.labelsize':11,'axes.spines.top':False,'axes.spines.right':False,'text.color':INK,'axes.labelcolor':INK,'axes.titleweight':'bold','savefig.facecolor':'white'})
    fig,axes=plt.subplots(2,2,figsize=(14.8,10.2))
    fig.subplots_adjust(left=.085,right=.96,top=.84,bottom=.22,hspace=.52,wspace=.25)
    fig.suptitle('Follow 540 out and 872 in',x=.085,ha='left',y=.973,fontsize=25,weight='bold')
    fig.text(.085,.925,'After-write tick 41 (time 1.2) → time 1.3 · historical breathing-on simulation',fontsize=12)
    fig.text(.085,.893,'The labels persist. What is nearby changes. An observation boundary is not a physical break.',fontsize=12)
    for col,owner in enumerate(IDS):
        ax=axes[0,col]
        for tag,style,color,width,label in zip(TAGS,['--',':','-'],['#8b9295','#8b9295',OLD],[1.5,2,2.2],['40³ / 0.0005','48³ / 0.0005','48³ / 0.00025']):
            rr=[r for r in points[tag] if int(r['observer'])==owner]
            ax.plot([float(r['time']) for r in rr],[float(r['distance_pair_union']) for r in rr],ls=style,color=color,lw=width,label=label)
        cross=next(r for r in a['crossings'] if r['run']==FINE and r['observer']==owner)
        ax.axhline(.1,color=INK,lw=1,ls='--');ax.axvspan(cross['time_before'],cross['time_after'],color=OTHER,alpha=.3)
        ax.set_title(f'{owner}: '+('leaves the pair’s view' if owner==540 else 'enters the pair’s view'),loc='left')
        ax.set(xlim=(1.2,1.3),xlabel='Model time',ylabel='Distance to nearer pair position')
        ax.ticklabel_format(axis='y',style='plain',useOffset=False)
        ax.text(.02,.93 if owner==540 else .13,'Pair view edge: distance 0.10',transform=ax.transAxes,fontsize=10,va='top')
        if owner==540:ax.legend(loc='lower right',frameon=False,fontsize=9)
        else:ax.legend(loc='upper right',bbox_to_anchor=(1,.82),frameon=False,fontsize=9)
        ax.text(0,-.28,f'Crossing bracket: ({cross["time_before"]:.5f}, {cross["time_after"]:.5f}]',transform=ax.transAxes,fontsize=10)
        ax=axes[1,col];rr=[r for r in windows[FINE] if int(r['observer'])==owner];t=np.array([float(r['time']) for r in rr]);initial=float(rr[0]['entry_original'])
        series=lambda k:np.array([float(r[k]) for r in rr])/initial*100
        old=series('original_inside');other=series('other_origin_inside');added=series('later_source_inside');total=series('native_total_inside')
        ax.stackplot(t,old,other,added,colors=[OLD,OTHER,NEW],alpha=.95,labels=['Originally near this label','Other initial origins','Later source input'])
        ax.plot(t,total,color=INK,lw=1.2)
        ax.axvline(cross['time_after'],ymax=.8,color=INK,alpha=.5,lw=1,ls=':')
        ax.set(title=f'Context near {owner}, by where it began',xlim=(1.2,1.3),ylim=(0,140),xlabel='Model time',ylabel='% of this window’s starting context')
        ax.text(.025,.95,f'At time 1.3 — original still nearby: {old[-1]:.1f}%\nOriginal elsewhere: {100*ends[owner]["elsewhere_starting_context_fraction"]:.1f}%',transform=ax.transAxes,va='top',fontsize=10)
        ax.text(.025,.06,f'Final local total: {total[-1]:.1f}% of starting amount',transform=ax.transAxes,fontsize=10,color='white',weight='bold')
    handles,labels=axes[1,0].get_legend_handles_labels();fig.legend(handles,labels,loc='upper left',bbox_to_anchor=(.077,.151),ncol=3,frameon=False,fontsize=11)
    fig.text(.085,.104,'Local windows: radius 0.075, moving with each label; they overlap. These are views, not owned parcels.',fontsize=11)
    fig.text(.085,.075,'C is model context, not water mass. The chart uses 48³ / step 0.00025; origin shares still vary with the grid.',fontsize=10)
    fig.text(.085,.044,f'Lean: {receipt["target_count"]} passing finite checks of rules and records. Fluid evolution and complete retention are not proved.',fontsize=10)
    fig.text(.085,.018,'AI-generated implementation and diagram; dictated and directed by NousVolition.',fontsize=9,color='#67747b')
    for ax in axes.flat:ax.grid(axis='y',alpha=.12);ax.set_axisbelow(True)
    for ext in ['png','svg','pdf']:fig.savefig(OUT/('following-540-872.'+ext),dpi=170)
    plt.close(fig)
    lines=['# Following 540 out and 872 in','',
      'Both labels keep their identities as they cross the original pair’s viewing boundary. Their local neighborhoods and context change along the way; this does not establish that either one carries a complete, private parcel or hands it to the other.','',
      '![540 and 872 followed through the crossings](following-540-872.png)','',
      '## What was followed','',
      'The same after-write tick-41 state at model time 1.2 was followed to 1.3, using 40³ / step 0.0005, 48³ / step 0.0005 and 48³ / step 0.00025. These are the existing threshold-0.015, breathing-on historical simulations, kept separate from the intended unforced Hug system. No new write or physical force was added.','',
      '540 and 872 each have a moving position in the source model. They do not have a separately assigned memory store or complete cargo list. We therefore followed their positions, nearby material and observer labels, point samples of velocity/context/temperature, and the origins of model context in a moving radius-0.075 window around each. Radius 0.05 and 0.10 are neighbor-sensitivity views. The original pair (825/850) uses a separate radius-0.10 union to define these crossings.','',
      'The local windows overlap. Initial context was partitioned into four disjoint grid regions: near 540 only, near 872 only, near both, and near neither. A fifth passive component records later source input. “Originally near 540” includes the shared region; so does “originally near 872.” Their two accounts must not be added as disjoint holdings. C is model context, not water mass.','',
      '## Crossings and nearby context','',
      '| Run | 540 leaves, bracket | 872 arrives, bracket | Original near 540 still nearby at 1.3 | Original near 872 still nearby at 1.3 |','|---|---|---|---:|---:|']
    for tag in TAGS:
        cc=[next(r for r in a['crossings'] if r['run']==tag and r['observer']==i) for i in IDS]
        ee=[next(r for r in a['window_endpoints'] if r['run']==tag and r['observer']==i) for i in IDS]
        lines.append('| '+tag.replace('n','',1).replace('_dt','³ / ').replace('p','.')+' | '+' | '.join(f'({r["time_before"]:.5f}, {r["time_after"]:.5f}]' for r in cc)+' | '+' | '.join(f'{100*r["retained_starting_context_fraction"]:.6f}%' for r in ee)+' |')
    lines += ['', 'The bracket bounds are consecutive recorded steps, not exact continuous crossing times. Both crossings retain the same identities on all three runs, but their timings still differ between grids. Crossing a viewing boundary does not itself cause a change or destroy a label.','',
      '| Finest run at time 1.3 | 540 window | 872 window |','|---|---:|---:|']
    for label,col in [('Original context still nearby','original_inside'),('Original context elsewhere','original_elsewhere'),('Other initial origins now nearby','other_origin_inside'),('Later source now nearby','later_source_inside'),('Current local total','native_total_inside')]:
        lines.append('| '+label+' | '+' | '.join(f'{100*ends[i][col]/ends[i]["entry_original"]:.6f}%' for i in IDS)+' |')
    lines += ['', 'Every percentage in this table uses that window’s starting amount as its denominator. “Elsewhere” is still in the modeled basin, outside the current local view. It is not destruction or escape from the basin. The incoming amount is a contribution from other initial regions, not proof of transfer from one observer to the other.','',
      'At each crossing, the finest run gives the following immediate-after observations. These use the first recorded step on the new side of the original pair’s boundary; the local observation radius remains 0.075.','',
      '| Label and crossing | First step after | Original context still locally nearby (% of entry) | Point C before → after | Point temperature before → after |','|---|---:|---:|---:|---:|']
    for owner in IDS:
        c=next(r for r in a['crossings'] if r['run']==FINE and r['observer']==owner)
        w=next(r for r in windows[FINE] if int(r['observer'])==owner and int(r['step'])==c['step_after'])
        lines.append(f'| {owner} '+('leaves' if owner==540 else 'arrives')+f' | {c["time_after"]:.5f} | {100*float(w["original_inside"])/float(w["entry_original"]):.6f}% | {c["C_before"]:.9f} → {c["C_after"]:.9f} | {c["theta_before"]:.9f} → {c["theta_after"]:.9f} |')
    lines += ['', 'The point samples are field readings at each moving position, not inventories carried by the label. Both C and temperature change across each recorded bracket; the observation boundary does not establish the cause. The full five-origin readings before and after are retained in [crossing-readouts.csv](crossing-readouts.csv).','',
      '## Neighbors and shared records','',
      '| Finest run, radius 0.075 | Entry | Exit | Stayed | Left | Returned | Arrived | Visited |','|---|---:|---:|---:|---:|---:|---:|---:|']
    for r in a['primary_neighbors']:
        if r['run']==FINE:lines.append(f'| Near {r["observer"]}: {r["population"]} labels | '+' | '.join(str(r[k]) for k in ['entry','exit','stayed','left','returned','arrived','visited'])+' |')
    shared=next(r for r in a['runs'] if r['run']==FINE)['shared_entry_material_ids']
    lines += ['',f'The two initial material neighborhoods share IDs {", ".join(map(str,shared))}. Counts are unweighted labels, not mass. A label can remain nearby while its deformation and directional-memory fields change. Those material-field changes were read from the preserved, hash-checked material trajectory; this new run did not assign those fields to 540 or 872.','',
      f'The three shared decoded event records remained byte-for-byte unchanged in {a["shared_payload_comparisons"]:,} record comparisons across all recorded steps and runs. This is a shared record check, not evidence of private memories carried by either observer.','',
      'The full neighbor counts at radii 0.05, 0.075 and 0.10 are in [neighbor-summary.csv](neighbor-summary.csv). Primary histories are retained in the Lean source data. Sparse or empty windows remain visible rather than being treated as a complete material inventory.','',
      '## Grid and time-step differences','',
      '| Comparison | Label | Endpoint change in retained original (percentage points) | Largest difference at 51 common times |','|---|---:|---:|---:|']
    for r in a['context_grid_time_comparisons']:
        m=r['metrics']['original_inside'];lines.append(f'| {r["comparison"]} | {r["observer"]} | {m["endpoint_delta_percentage_points"]:+.8f} | {m["max_common_time_delta_percentage_points"]:.8f} |')
    lines += ['', 'These measured differences are sensitivity evidence. No continuum-convergence tolerance was declared or established for the new origin shares. The sharp initial region masks and moving grid-cell windows can also affect those shares. Neighbor differences at common times are recorded separately in [analysis.json](analysis.json).','',
      '## What passed, and what Lean checked','',
      'The passive-origin runs reproduced all 17 native exit arrays exactly, and all 926 observer positions at every recorded step matched the preceding native trajectories. The new components did not feed back into native dynamics. Each run passed the declared context reconstruction (≤1e−12), original-component global drift (≤1e−12), later-source account (≤1e−10), nonnegativity within 1e−12, and shared-record checks.','',
      'A separate numerical recount checked initial-region masks, saved grid sums, periodic memberships, crossings, raw trilinear corners and weights, independently sampled fields, input hashes, and complete shared-record bytes. These are numerical/source checks, separate from Lean.','',
      f'{receipt["compiler"]} passed **{receipt["target_count"]} theorem targets**. It checked general finite rules for identity, overlapping views and origin accounts; the recorded neighbor histories and crossing brackets; exact-decimal point/window balances and endpoint rounding; selected material-field numbers; and every saved shared-record byte. The source checker matched the actual Lean literals to the recorded arrays and tables and rejected eight deliberately altered copies.','',
      f'Proof-input fingerprint: `{receipt["proof_input_fingerprint"]}`. Standard axiom dependencies: '+', '.join(sorted({x for v in receipt['axiom_dependencies'].values() for x in v}))+'. No added axioms, `sorry`, or `native_decide`. [Full Lean receipt](../observer540-872-lean/receipt.json).','',
      '**Still unknown:** whether everything stays with either label; all physical or microscopic contents; causal transfer from 540 to 872; origin histories for every changing field; behavior between sampled steps; and continuum fluid convergence. Lean has not proved the fluid evolution, interpolation, geometric membership calculation or complete retention.','',
      '## Reproducibility and preservation','',
      'The frozen runner, independent analyzer, exact source hashes, raw grids/stencils, tables and proof package are retained locally. Earlier pair-origin and retention studies, their failures and receipts, and the published PR26 evidence remain unchanged. This new follow-up is local; it has not been put on GitHub.','',
      'AI-generated implementation, report and diagram; dictated and directed by NousVolition. Numerical observations come from the saved runs, not image generation.','']
    write(OUT/'README.md','\n'.join(lines))
    print(json.dumps({'report':str(OUT/'README.md'),'diagram':str(OUT/'following-540-872.png'),'targets':receipt['target_count'],'endpoint_percentages':{str(i):100*ends[i]['retained_starting_context_fraction'] for i in IDS}},indent=2))
if __name__=='__main__':main()
