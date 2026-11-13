"""Figures and readable report from completed, source-bound heat-grid evidence."""
import json,runpy
from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'outputs/heat-grid';LEAN=ROOT/'outputs/heat-grid-lean'
def load(p):return json.loads(p.read_text(encoding='utf-8-sig'))
a=load(OUT/'analysis.json');assert a['status']=='completed'
tags=[r['run'] for r in a['runs']];runs=a['runs'];cs=a['comparisons']
readouts={t:load(OUT/t/'analysis.json')['readouts'] for t in tags}
colors=['#8d99ae','#c77627','#218c74','#2459a6','#9b3a85'];writecolors=['#195b9c','#d47a2b','#309478']
labels=['16³','24³','32³','40³','40³, half step'];pairs=['16³ → 24³','24³ → 32³','32³ → 40³','40³: half step']
credit='AI-generated; dictated and directed by NousVolition.'
plt.rcParams.update({'font.family':'DejaVu Sans','font.size':11,'axes.spines.top':False,'axes.spines.right':False,'axes.titleweight':'bold','axes.grid':True,'grid.alpha':.16,'savefig.facecolor':'#fbfaf7','figure.facecolor':'#fbfaf7','axes.facecolor':'#fbfaf7'})
def save(fig,name):
 fig.text(.02,.014,credit+'  Signed heat accounts in the threshold-1 model; numerical evidence, separate from Lean.',fontsize=8,color='#4f5861')
 fig.savefig(OUT/(name+'.png'),dpi=165,bbox_inches='tight');fig.savefig(OUT/(name+'.svg'),bbox_inches='tight');plt.close(fig)

fig,axes=plt.subplots(2,2,figsize=(14,10));fig.subplots_adjust(top=.87,bottom=.14,hspace=.4,wspace=.3)
fig.suptitle('Heat after three writes: what changes as the fluid grid gets finer',x=.06,ha='left',fontsize=19,weight='bold')
fig.text(.06,.915,'Same threshold, physical parameters, 384 material points and encoding. Fluid grids: 16³, 24³, 32³, 40³.',fontsize=11)
ax=axes[0,0]
for j,r in enumerate(runs):
 h=np.cumsum([w['deposited_heat'] for w in r['writes']])*1e5
 ax.plot([1,2,3],h,marker='o',ls='--' if j==4 else '-',color=colors[j],label=labels[j])
ax.set(title='A. The write contribution builds up',xlabel='Write number',ylabel='Cumulative deposited heat (×10⁻⁵ model units)',xticks=[1,2,3]);ax.legend(ncol=2,fontsize=9)
for ax,key,title in [(axes[0,1],'relative_deposited_heat_change','B. Heat deposited by each write'),(axes[1,0],'normalized_field_L1','C. Spatial pattern, after dividing by its total heat')]:
 for i in range(3):
  yy=[100*c['writes'][i][key] for c in cs[:3]];xx=np.arange(3)+(i-1)*.24
  ax.scatter(xx,yy,s=65,color=writecolors[i],label=f'Write {i+1}',zorder=3)
  for x,y in zip(xx,yy):ax.annotate(f'{y:.4g}%',(x,y),xytext=(0,7),textcoords='offset points',ha='center',fontsize=8)
 ax.axhline(1,color='#9c2944',ls=':',lw=1.5,label='1% preset limit');ax.set_yscale('log');ax.set(title=title,ylabel='Difference (%)',xticks=np.arange(3),xticklabels=pairs[:3])
 ax.tick_params(axis='x',labelsize=9);ax.set_ylim(bottom=max(1e-5,min(100*c['writes'][i][key] for c in cs[:3] for i in range(3))*.4),top=max(100*c['writes'][i][key] for c in cs[:3] for i in range(3))*1.7)
 ax.legend(fontsize=8,ncol=2)
ax=axes[1,1]
for j,r in enumerate(runs):ax.plot([1,2,3],[100*w['final_common']['96']['outside025_share'] for w in r['writes']],marker='o',ls='--' if j==4 else '-',color=colors[j],label=labels[j])
ax.set(title='D. Heat outside each birth region at time 1.6',xlabel='Write number',ylabel='Signed share outside radius 0.25 (%)',xticks=[1,2,3]);ax.legend(ncol=2,fontsize=9)
control=cs[-1];fig.text(.06,.065,f'Separate 40³ time-step control: maximum write-heat difference {100*max(w["relative_deposited_heat_change"] for w in control["writes"]):.5g}%; maximum pattern difference {100*max(w["normalized_field_L1"] for w in control["writes"]):.5g}%. Heat criteria: '+('PASS' if control['all_heat_criteria_pass'] else 'FAIL')+'.',fontsize=10)
save(fig,'heat-grid-summary')

fig,axes=plt.subplots(1,3,figsize=(16,5.5));fig.subplots_adjust(top=.76,bottom=.19,wspace=.27)
fig.suptitle('Follow each write’s heat as it spreads',x=.055,ha='left',fontsize=20,weight='bold')
fig.text(.055,.86,'All fields measured on the same 96³ observation grid; 128³ provides a quadrature check. These are not finer fluid simulations.',fontsize=11)
for i,ax in enumerate(axes):
 for j,t in enumerate(tags):
  rr=[r for r in readouts[t] if r['event_id']==i and r['side']!='before_write']
  ax.plot([r['time'] for r in rr],[100*r['common']['96']['outside025_share'] for r in rr],color=colors[j],ls='--' if j==4 else '-',label=labels[j],lw=1.8)
 ax.set(title=f'Write {i+1} · begins at {[.4,.8,1.2][i]}',xlabel='Model time',ylabel='Signed share outside birth radius 0.25 (%)');ax.legend(fontsize=9)
save(fig,'heat-grid-spread')

fig,axes=plt.subplots(2,1,figsize=(15,9),sharex=True);fig.subplots_adjust(top=.86,bottom=.13,hspace=.25)
fig.suptitle('The exact record bits and the heat cost are separate measurements',x=.06,ha='left',fontsize=19,weight='bold')
fig.text(.06,.91,'Each comparison uses saved record bytes and saved cell states. No replacement write or counterfactual fluid run is performed.',fontsize=11)
rr=[w['record_bits'] for c in cs for w in c['writes']];x=np.arange(12);base=np.zeros(12)
for part,color in [('strain','#d48832'),('checksum','#765496'),('header','#8d99ae')]:
 y=np.array([r['regions'][part]['changed_bits'] for r in rr]);axes[0].bar(x,y,bottom=base,color=color,label=part.capitalize());base+=y
for xx,yy in zip(x,base):axes[0].text(xx,yy+max(base)*.018,str(int(yy)),ha='center',fontsize=9)
axes[0].set(title='A. Differing bit positions in a 37,264-bit record',ylabel='Changed bits');axes[0].legend(ncol=3);axes[0].margins(y=.18)
encoded=np.array([r['changed_targets_at_right_prestate'] for r in rr])*1e6;prior=np.array([r['prior_state_at_fixed_left_targets'] for r in rr])*1e6;actual=np.array([r['heat_difference'] for r in rr])*1e6
axes[1].bar(x-.16,encoded,width=.32,color='#2a739e',label='Changed encoded targets, same saved state')
axes[1].bar(x+.16,prior,width=.32,color='#bb4b70',label='Changed prior state, fixed reference targets')
axes[1].scatter(x,actual,marker='x',color='#202d3b',s=35,label='Actual write-heat difference',zorder=4)
axes[1].axhline(0,color='#68757d',lw=.8);axes[1].set(title='B. Write-cost partition on saved cell states',ylabel='Heat difference (×10⁻⁶ model units)',xticks=x,xticklabels=[f'W{i+1}\n{pairs[j] if i==1 else ""}' for j in range(4) for i in range(3)])
axes[1].legend(fontsize=9,ncol=2);fig.text(.06,.055,f'Largest absolute prior-state term: {max(abs(prior))*1e-6:.3g} model heat units.',fontsize=9)
for ax in axes:
 for boundary in [2.5,5.5,8.5]:ax.axvline(boundary,color='#aaa',lw=.8,ls='--')
save(fig,'heat-grid-record-bits')

proof=load(LEAN/'receipt.json') if (LEAN/'receipt.json').exists() else None
settled=a['settled_across_tested_grids_by_predeclared_criteria'];step=a['time_step_all_criteria_pass']
rising=[]
for i in range(3):
 for key,label in [('relative_deposited_heat_change','deposited heat'),('normalized_field_L1','normalized pattern'),('outside_share_difference','outside share'),('effective_volume_relative_difference','concentration volume'),('peak_relative_difference','peak')]:
  left,right=[c['writes'][i][key] for c in cs[1:3]]
  if right>left:rising.append(f'write {i+1} {label}: {100*left:.5g} to {100*right:.5g}'+(' percentage points' if key=='outside_share_difference' else '%'))
trend_note='The per-write refinement discrepancies are not uniformly decreasing: '+'; '.join(rising)+'. This also prevents the declared settling test from passing.' if rising else 'Every per-write refinement discrepancy decreases in the last two grid comparisons.'
lines=['# Threshold-1 heat: finer fluid grids','',('The reported heat observables meet the declared finite-grid settling test.' if settled else 'The reported heat observables have not met the declared finite-grid settling test.'),'',f'The finest-grid time-step comparison {"passes" if step else "does not pass"} the heat criteria. The exact record bits are assessed separately. This is a local numerical follow-up to the published 16³ heat study; the earlier receipts remain unchanged.','',credit,'','![Heat grid comparisons](heat-grid-summary.png)','',
'Four fluid grids (16³, 24³, 32³ and 40³) use time step 0.002. A separate 40³ run uses 0.001. All five continue through model time 1.6, with writes at 0.4, 0.8 and 1.2. Threshold 1, breathing peak 0.5 and period 0.6, the periodic box, 384 material quadrature points, physical parameters and record encoding stay fixed. This is fluid-grid refinement; material quadrature has not been refined.','',
'## Does the heat settle?','',
'Limits were declared before the runs: 1% for deposited heat, cumulative write heat, normalized whole-field L1 difference, concentration volume and peak; 0.5 percentage point for the share outside radius 0.25. The table shows the worst of the three writes and all saved instants, except cumulative heat, which is compared after each write. All relative differences use the coarser/reference run as denominator.','',
'| Comparison | Write heat | Cumulative heat | Normalized spatial pattern | Outside share | Concentration volume | Peak | All heat limits |',
'|---|---:|---:|---:|---:|---:|---:|---|']
for label,c in zip(pairs,cs):
 maximum=lambda k:max(w[k] for w in c['writes'])
 lines.append(f'| {label} | {100*maximum("relative_deposited_heat_change"):.5g}% | {100*c["maximum_relative_cumulative_write_heat"]:.5g}% | {100*maximum("normalized_field_L1"):.5g}% | {100*maximum("outside_share_difference"):.5g} pp | {100*maximum("effective_volume_relative_difference"):.5g}% | {100*maximum("peak_relative_difference"):.5g}% | {"PASS" if c["all_heat_criteria_pass"] else "FAIL"} |')
lines+=['','The declared settling test requires both 24³→32³ and 32³→40³ to pass, no increase in each write’s successive discrepancy, and a passing 40³ time-step control. A failure remains a failure even when the finer comparison improves. The complete per-write and per-instant results are in [analysis.json](analysis.json).','',
'For the finest spatial comparison (32³→40³), the heat differences for writes 1, 2 and 3 are '+', '.join(f'{100*w["relative_deposited_heat_change"]:.4f}%' for w in cs[2]['writes'])+'. The largest normalized pattern differences are '+', '.join(f'{100*w["normalized_field_L1"]:.4f}%' for w in cs[2]['writes'])+'; at the final saved instant they are '+', '.join(f'{100*w["history"][-1]["normalized_field_L1"]:.4f}%' for w in cs[2]['writes'])+'. This separates disagreement around a new write from the smaller disagreement later in its spread.','',
trend_note+' Lean checks these recorded trend inequalities alongside the comparisons with the preset limits.','',
'![Pattern differences through the encounter](heat-grid-detail.png)','',
'## Spread and buildup','',
'Each write has its own signed source account, carried through the actual coupled run. Its spatial integral remains in that account, while its spatial pattern spreads. The three positive write amounts accumulate. This bookkeeping does not identify positive physical heat particles or prove that material retains everything it carried.','',
'![Follow each write](heat-grid-spread.png)','',
'| Fluid grid / step | Heat after all three writes | First-write final outside share | Second-write final outside share | Third-write final outside share | Write share of thermal increase |',
'|---|---:|---:|---:|---:|---:|']
for label,r in zip(labels,runs):
 shares=[100*w['final_common']['96']['outside025_share'] for w in r['writes']]
 lines.append(f'| {label} | {r["final_write_total"]:.12g} | {shares[0]:.4f}% | {shares[1]:.4f}% | {shares[2]:.4f}% | {100*r["write_share_of_thermal_increase"]:.4f}% |')
lines+=['','The outside-share measurement uses a fixed radius 0.25 around each pulse’s own birth centroid, with periodic distances. Whole-field L1 uses the same physical coordinates for both runs and divides each pulse by its own deposited total. Concentration volume is mean(field)² / mean(field²); it is a concentration measure, not a literal occupied volume. Peak comparisons use the unnormalized pulse. Signed negative spectral ripples are retained.','',
'All comparison criteria use the predeclared common 96³ observation grid. Evaluating the same retained Fourier modes on 128³ checks observation quadrature; it adds no physical fluid modes. The allowed 96³/128³ changes are 0.05 percentage point for outside share and 0.001 absolute for normalized L1. '+('All four comparison quadrature controls pass.' if all(c['quadrature_control_pass'] for c in cs) else 'At least one comparison quadrature control fails; see analysis.json.'),'',
'**A measurement issue found in the review:** on the unchanged 16³ second-pulse field at time 1.6, native-grid counting gives '+f'{100*runs[0]["writes"][1]["final_outside025_share"]:.4f}%'+', while the same field evaluated on 128³ gives '+f'{100*runs[0]["writes"][1]["final_common"]["128"]["outside025_share"]:.4f}%'+'. This is the effect of sampling the spherical observation region, not fluid-grid refinement. Both readouts are preserved.','',
'## Exact record bits and write cost','',
'![Record bits and write heat](heat-grid-record-bits.png)','',
'Each record has 4,658 bytes: a 46-byte header, 2,304 signed 16-bit strain words, and a four-byte CRC. The comparison recounts the actual bytes and all bit positions, verifies each CRC in Python, and separates header, strain and checksum changes. Different checksums are not a measurement of heat error.','',
'For a saved state b and target T, each cell’s write cost is weight × 0.05 × (T − b)² / 0.02. The recorded heat difference is partitioned as:',
'','`C(right target, right state) − C(left target, left state)`',
'','`= [C(right target, right state) − C(left target, right state)]`',
'','`  + [C(left target, right state) − C(left target, left state)]`','',
'The first part changes encoded targets at one fixed saved state. The second changes the prior cell state with the reference targets fixed. The algebraic identity is exact; the partition of recorded floating-point costs is checked within 10⁻¹⁸ model heat units. Recomputed actual cell costs match the saved arrays exactly. This separates the immediate write cost; it does not evolve a counterfactual flow, remove encoding effects from the fluid trajectory, or identify an independent field-equation cause. The diagnostic uses the left target as reference and is not a unique symmetric causal attribution.','',
'| Comparison / write | Changed strain words | Changed bits | Checksum equal? | Heat difference | Encoded-target part | Prior-state part |',
'|---|---:|---:|---|---:|---:|---:|']
for label,c in zip(pairs,cs):
 for w in c['writes']:
  b=w['record_bits'];lines.append(f'| {label}, write {w["event_id"]+1} | {b["regions"]["strain"]["changed_words"]} / 2304 | {b["total_changed_bits"]} | {"yes" if b["both_crc"][0]==b["both_crc"][1] else "no"} | {b["heat_difference"]:.8g} | {b["changed_targets_at_right_prestate"]:.8g} | {b["prior_state_at_fixed_left_targets"]:.8g} |')
lines+=['','Raw strain differences, decoded strain differences, regional bit counts and cost partitions against the 16³ reference are retained in analysis.json. Changes in the material encoding and changes in the fluid grid are not interchangeable measurements.','',
'## What Lean checks','']
if proof:
 lines += [f'**PASS: {proof["target_count"]} targets** ({proof["general_rules"]} finite accounting rules and {proof["recorded_claims"]} recorded claims), using pinned Lean 4.34.0-rc2 and the recorded mathlib revision. The full target list, dependency audit and source fingerprint are in [the Lean receipt](../heat-grid-lean/receipt.json).', '']
else:lines += ['Lean verification is pending. No passing result is claimed by this draft.','']
lines += ['Lean checks finite accounting identities; the exact saved decimals for 4,820 global-account rows; coverage of every accepted step and both sides of writes; the recorded comparisons with the declared limits; and complete saved word comparisons and bit counts. Numerical limits that fail are represented as proved exceedances, not turned into successful convergence results. The exact-decimal transcription is independently regenerated in Python.','',
'Lean does not run the fluid solver, derive the grid-array metrics, verify the Python-to-Lean transcription, establish a continuum limit, or prove a physical heat/material inventory. CRC validity is checked in Python; Lean compares the saved CRC integers. No extra axioms, sorry, or native_decide are used. The five general rules use standard mathlib axioms. Of the recorded claims, 346 use no axioms and 63 word-comparison claims use standard propext; the full target-by-target list is retained.','',
'## Verification and remaining scope','',
'The 16³ repeat agrees with all 13 preserved historical checkpoints to '+f'{runs[0]["baseline_max_array_error"]:.3g}'+'. Every saved field and record is bound to a run receipt. Independent recounts check field reconstruction, source totals, global heat budget, decoded targets and write costs. Per-grid tagged/native pilots preserve all 17 native arrays in their tested steps. Native solver files stay unchanged.','',
'The passive Fourier sampler rounds nearly-integer frequency indices instead of truncating them. This avoids an index error on 24³. Passive observers do not feed back into the native fluid or heat fields; the pilot checks that those arrays remain unchanged. This observer readout correction is recorded separately from the grid change.','',
'Spatial shape comparisons cover the 20 saved field instants per run; global accounts cover every accepted step. Unsaved instants, finer-than-40³ fluid grids, refined material quadrature, longer times and other thresholds remain untested. The periodic computational box is not evidence that a followed material path closes into a loop.','',
'This follow-up is local. The earlier published [heat study and 56 Lean targets](https://github.com/NousVolition/hug-sims-lean-proofs/pull/34) remain historical evidence; this report adds finer-grid findings without overwriting them.','']
(OUT/'README.md').write_text('\n'.join(lines),encoding='utf-8')
runpy.run_path(str(Path(__file__).with_name('plot_grid_detail.py')),run_name='__main__')
print(json.dumps({'figures':4,'report':'outputs/heat-grid/README.md','lean_verified':bool(proof),'settled':settled,'time_step_pass':step}))
