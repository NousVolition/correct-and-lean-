"""Generate the measured energy comparison and standalone scientific figures."""
from pathlib import Path
import json,csv,math,os,hashlib
ROOT=Path(__file__).resolve().parent
os.environ.setdefault('MPLCONFIGDIR',str(ROOT/'.mplconfig'))
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.ticker import MaxNLocator

SCALE=1e6
reports={};rows={};curves={}
for arm in ('journal','control'):
    for resolution in (1,2):
        key=f'{arm}-{resolution}';folder=ROOT/'runs'/key
        reports[key]=json.loads((folder/'summary.json').read_text())
        raw=json.loads((folder/'energy.json').read_text())
        rows[key]=[raw[0]]+[r for r in raw if r['phase']=='after_all']

reference=next(iter(reports.values()))['source_fingerprint']
for report in reports.values():
    assert report['source_fingerprint']==reference
    assert report['audit_code_sha256']==hashlib.sha256((ROOT/'energy_audit.py').read_bytes()).hexdigest()
    assert report['declaration_sha256']==hashlib.sha256((ROOT/'DECLARATION.json').read_bytes()).hexdigest()
for name,digest in reference.items():
    candidate=ROOT.parent/'material-trust-v3'/name
    if not candidate.is_file():candidate=ROOT.parent/'material-trust-v3/upstream'/name
    assert hashlib.sha256(candidate.read_bytes()).hexdigest()==digest,name

for resolution in (1,2):
    on=rows[f'journal-{resolution}'];off=rows[f'control-{resolution}']
    assert len(on)==len(off)==652
    i_on=reports[f'journal-{resolution}']['initial_before_any_write'];i_off=reports[f'control-{resolution}']['initial_before_any_write']
    out=[]
    for a,b in zip(on,off):
        assert a['time']==b['time'] and a['phase']==b['phase']
        r=dict(time=a['time'],phase=a['phase'])
        for k in ('work','drive_work','journal_write_work','event_write_work','threshold_work','breathing_work',
                  'net_heat','viscous_heat','fabric_heat','stroke_heat','diverted_to_directional_storage',
                  'total_residual','mechanical_residual','thermal_residual','mechanical_change','thermal_change','total_change'):
            r[k]=a[k]-b[k]
        for k in ('kinetic','continuum_elastic','event_fabric','journal_fabric'):
            r[k+'_gain']=(a[k]-i_on[k])-(b[k]-i_off[k])
        r['absolute_energy_difference']=a['total']-b['total']
        r['initial_energy_difference']=i_on['total']-i_off['total']
        r['gross_dissipation']=r['viscous_heat']+r['fabric_heat']+r['stroke_heat']
        assert abs(r['work']-r['net_heat']-r['mechanical_change']-r['mechanical_residual'])<1e-16
        assert abs(r['absolute_energy_difference']-r['initial_energy_difference']-r['total_change'])<1e-16
        out.append(r)
    curves[resolution]=out
    with (ROOT/f'comparison-dt-{.002/resolution:.3f}.csv').open('w',newline='',encoding='utf-8') as f:
        writer=csv.DictWriter(f,fieldnames=list(out[0]));writer.writeheader();writer.writerows(out)

fine=curves[2];last=fine[-1]
peak_extra_work=max(abs(r['work']) for r in fine)
diff_error=max(abs(r['mechanical_residual']) for r in fine)
fraction=diff_error/peak_extra_work
ratios={arm:reports[f'{arm}-2']['max_total_residual']/reports[f'{arm}-1']['max_total_residual'] for arm in ('journal','control')}
passed=all(v['status']=='PASS' for v in reports.values()) and fraction<.01 and all(v<1 for v in ratios.values())
summary=dict(status='PASS' if passed else 'PARTIAL',case='Initial trust A toward B = 1, B toward A = 0; time 0 through 1.3',
    control='No material journal; identical quantized prefix recall provided in software',
    initial_difference_before_any_write=last['initial_energy_difference'],refined_final_extra=last,
    max_differential_allocation_residual=diff_error,residual_fraction_of_peak_extra_work=fraction,
    time_halving_residual_ratios=ratios,per_arm={k:{q:v[q] for q in ('integration_dt','status','max_total_residual','max_stage_energy_error','max_write_energy_error','published_journal_state_exact')} for k,v in reports.items()},
    heat_meaning='Net heat retained = viscous + fabric relaxation + stroke heat - diversion into directional material storage; thermal energy remains inside the periodic system',
    limit='Finite numerical verification of the declared matched comparison, not a universal theorem or a physically cost-free software device')
summary['endpoint_time_refinement']={k:dict(step_002=curves[1][-1][k],step_001=last[k],
    signed_difference=last[k]-curves[1][-1][k],difference_as_fraction_of_extra_work=abs(last[k]-curves[1][-1][k])/abs(last['work']))
    for k in ('work','net_heat','mechanical_change')}
(ROOT/'verification.json').write_text(json.dumps(summary,indent=2),encoding='utf-8')

plt.rcParams.update({'font.family':'DejaVu Sans','font.size':11,'axes.spines.top':False,'axes.spines.right':False,
    'axes.labelcolor':'#263746','text.color':'#263746','xtick.color':'#526574','ytick.color':'#526574',
    'axes.edgecolor':'#acb8c1','grid.color':'#e1e7eb','figure.facecolor':'white','savefig.facecolor':'white'})
colors={'work':'#275f98','heat':'#bd5b1b','stored':'#10846f','coarse':'#8965a3'}
t=np.array([r['time'] for r in fine])
series=lambda key,res=2:np.array([r[key] for r in curves[res]])*SCALE
fig=plt.figure(figsize=(14,9.4))
fig.suptitle('Where the material journal’s extra work goes',x=.08,y=.97,ha='left',fontsize=23,fontweight='bold')
fig.text(.08,.917,'Journal − matched no-material-journal control  |  A→B starts 1; B→A starts 0  |  refined step 0.001',fontsize=11.5,color='#526574')
ax=fig.add_axes([.08,.43,.65,.43]);ax.set_axisbelow(True);ax.grid(axis='y')
ax.plot(t,series('work'),color=colors['work'],lw=2.8,label='Extra supplied work')
ax.plot(t,series('net_heat'),color=colors['heat'],lw=2.5,ls='--',label='Extra net heat retained')
ax.plot(t,series('mechanical_change'),color=colors['stored'],lw=2.3,ls='-.',label='Extra mechanical stored-energy gain')
ax.fill_between(t,series('net_heat'),series('work'),color=colors['stored'],alpha=.13)
ax.set_xlim(0,1.3);ax.set_ylabel('Energy  (10⁻⁶ model units)');ax.set_xlabel('Model time')
ax.legend(loc='upper left',frameon=False,fontsize=10.5)
for key,color in [('work','work'),('net_heat','heat'),('mechanical_change','stored')]:ax.scatter([t[-1]],[series(key)[-1]],color=colors[color],s=25,zorder=5)
box=fig.add_axes([.775,.43,.205,.43]);box.axis('off')
box.text(0,.99,'At time 1.3',fontsize=13,fontweight='bold',va='top')
entries=[('Extra supplied work',last['work']),('Extra net heat',last['net_heat']),('Stored-energy gain',last['mechanical_change']),('Allocation residual',last['mechanical_residual'])]
for n,(label,value) in enumerate(entries):
    y=.86-n*.15;box.text(0,y,label,fontsize=10.7)
    number=f'{value*SCALE:+.3e}' if label=='Allocation residual' else f'{value*SCALE:+.6f}'
    box.text(0,y-.063,number,fontsize=14,fontweight='bold')
box.text(0,.20,'Initial energy difference\n(before any write)',fontsize=10.7)
box.text(0,.085,f'{last["initial_energy_difference"]*SCALE:+.6f}',fontsize=14,fontweight='bold')
box.text(0,.008,'All values: 10⁻⁶ model units',fontsize=9,color='#526574')
zoom=fig.add_axes([.08,.13,.38,.20]);zoom.grid(axis='y');zoom.set_axisbelow(True)
zoom.plot(t,series('mechanical_change'),color=colors['stored'],lw=2)
zoom.axhline(0,color='#acb8c1',lw=.8);zoom.set_xlim(0,1.3)
zoom.set_title('Mechanical stored-energy gain, enlarged',fontsize=11,loc='left')
zoom.set_xlabel('Model time');zoom.set_ylabel('10⁻⁶ model units');zoom.yaxis.set_major_locator(MaxNLocator(5))
err=fig.add_axes([.56,.13,.38,.20]);err.grid(axis='y');err.set_axisbelow(True)
err.plot(t,series('mechanical_residual',1)/SCALE,color=colors['coarse'],lw=1.5,label='Step 0.002')
err.plot(t,series('mechanical_residual',2)/SCALE,color=colors['work'],lw=1.8,label='Step 0.001')
err.axhline(0,color='#acb8c1',lw=.8);err.set_xlim(0,1.3)
err.set_title('Unassigned numerical balance error',fontsize=11,loc='left')
err.set_xlabel('Model time');err.set_ylabel('Model units');err.legend(frameon=False,fontsize=9)
fig.text(.08,.035,'Extra work = extra net heat + extra mechanical-energy gain + numerical residual. Each gain subtracts its own initial energy.',fontsize=10)
for ext in ('png','svg','pdf'):fig.savefig(ROOT/f'extra-work.{ext}',dpi=180)
plt.close(fig)

fig,axes=plt.subplots(2,2,figsize=(13,8.5));fig.subplots_adjust(top=.86,bottom=.09,hspace=.36,wspace=.30)
fig.suptitle('Full-flow energy verification',x=.10,y=.975,ha='left',fontsize=22,fontweight='bold')
fig.text(.10,.92,'Total energy includes retained heat. No residual is removed, reassigned to heat, or forced to zero.',fontsize=11,color='#526574')
for ax,arm in zip(axes[0],('journal','control')):
    rr=rows[f'{arm}-2'];tt=[r['time'] for r in rr]
    ax.plot(tt,[SCALE*r['work'] for r in rr],lw=2.4,color=colors['work'],label='Supplied work')
    ax.plot(tt,[SCALE*r['total_change'] for r in rr],lw=1.8,ls='--',color=colors['heat'],label='Total energy − own initial energy')
    ax.set_title('Material journal' if arm=='journal' else 'Matched control',loc='left',fontsize=12)
    ax.set_ylabel('10⁻⁶ model units');ax.set_xlabel('Model time');ax.grid(axis='y');ax.legend(frameon=False,fontsize=9)
ax=axes[1,0]
for arm,color in [('journal',colors['work']),('control',colors['heat'])]:
    for resolution,style in [(1,'--'),(2,'-')]:
        rr=rows[f'{arm}-{resolution}'];ax.plot([r['time'] for r in rr],[SCALE*r['total_residual'] for r in rr],color=color,ls=style,lw=1.6,label=f'{arm}, step {.002/resolution:.3f}')
ax.set_title('Per-run residuals: work − total-energy change',loc='left',fontsize=11);ax.set_xlabel('Model time');ax.set_ylabel('10⁻⁶ model units');ax.grid(axis='y');ax.legend(frameon=False,fontsize=8)
ax=axes[1,1]
names=['Viscous heating','Fabric relaxation','Write-stroke heat','− diversion\nto storage','Net heat retained']
values=np.array([last['viscous_heat'],last['fabric_heat'],last['stroke_heat'],-last['diverted_to_directional_storage'],last['net_heat']])*SCALE
ax.barh(np.arange(5),values,color=[colors['heat'],colors['heat'],colors['heat'],colors['stored'],colors['work']],alpha=.85)
ax.set_yticks(np.arange(5),names,fontsize=9);ax.invert_yaxis();ax.axvline(0,color='#526574',lw=.8)
ax.set_title('Extra thermal budget at time 1.3',loc='left',fontsize=11);ax.set_xlabel('10⁻⁶ model units');ax.grid(axis='x');ax.set_axisbelow(True)
ax.set_xlim(-2,max(values)*1.23)
for k,value in enumerate(values):ax.text(max(value,0)+2,k,f'{value:+.6f}',va='center',fontsize=8.5)
for ext in ('png','svg','pdf'):fig.savefig(ROOT/f'energy-verification.{ext}',dpi=180)
plt.close(fig)

fmt=lambda x:f'{x:.12g}'
lines=['# Full-flow energy result','',f'**{summary["status"]}** for the declared A=1, B=0 comparison through time 1.3.','',
    'The control has no material-journal cells or writes, but retains the same quantized feature-prefix information in software. This isolates the physical journal addition; it is not a claim that software memory has no real-world cost.','',
    'All values below are dimensionless model units. Initial energies are measured before any time-zero write.','',
    '| Quantity at time 1.3, refined step 0.001 | Journal minus control |','|---|---:|']
for label,k in [('Extra total supplied work','work'),('Extra continuous driving work','drive_work'),('Journal write work','journal_write_work'),('Change in event-write work','event_write_work'),('Extra net heat retained','net_heat'),('Extra mechanical stored-energy gain','mechanical_change'),('Extra kinetic-energy gain','kinetic_gain'),('Extra continuum-elastic gain','continuum_elastic_gain'),('Extra event-fabric gain','event_fabric_gain'),('Extra journal-fabric gain','journal_fabric_gain'),('Initial total-energy difference','initial_energy_difference'),('Final absolute total-energy difference','absolute_energy_difference'),('Differential allocation residual','mechanical_residual')]:lines.append(f'| {label} | {fmt(last[k])} |')
lines+=['','The absolute final energy difference equals the initial difference plus the difference in energy gains. The work allocation uses gains, so the initial stored energy is not counted as new work.','',
    '| Arm | Step | Maximum absolute total-energy residual | Original criterion |','|---|---:|---:|---:|']
for k,r in reports.items():lines.append(f'| {r["arm"]} | {r["integration_dt"]} | {fmt(r["max_total_residual"])} | {r["source_energy_tolerance"]} |')
lines+=['',f'Time halving reduced maximum residuals by factors {fmt(ratios["journal"])} (journal) and {fmt(ratios["control"])} (control). The maximum refined differential allocation residual is {fmt(diff_error)}, or {100*fraction:.6g}% of peak extra work.',
    '', 'Endpoint sensitivity to time refinement is reported separately from balance closure:','',
    '| Extra quantity | Step 0.002 | Step 0.001 | Signed change |','|---|---:|---:|---:|']
for k,r in summary['endpoint_time_refinement'].items():lines.append(f'| {k} | {fmt(r["step_002"])} | {fmt(r["step_001"])} | {fmt(r["signed_difference"])} |')
lines+=['','Discrete quantized sample/CRC changes can change write costs between refined trajectories. A tiny energy residual does not establish that every allocation value is equally insensitive to integration step.',
    '',f'The standard-step journal trajectory matched every array of the previously published final state: **{reports["journal-1"]["published_journal_state_exact"]}**. Instrumentation did not substitute new dynamics.',
    '',f'The largest sampled instantaneous energy-rate defect across all runs was {fmt(max(r["max_stage_energy_error"] for r in reports.values()))}. The largest write-jump energy error was {fmt(max(r["max_write_energy_error"] for r in reports.values()))}.',
    '', 'This is a numerical energy-accounting verification for the declared finite comparison, not a universal continuation theorem. Refinement keeps journal sampling/writing at 0.002 and changes only integration substeps.',
    '', '[Extra-work plot](extra-work.png) · [Energy verification plot](energy-verification.png) · [Equations and source review](README.md) · [Machine-readable verification](verification.json)','']
(ROOT/'RESULTS.md').write_text('\n'.join(lines),encoding='utf-8')
print(json.dumps(summary,indent=2))
