"""Plot the saved signed heat account; no illustrative trajectories are substituted."""
import csv,json
from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import TwoSlopeNorm
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'outputs/heat-follow'
A=json.loads((OUT/'analysis.json').read_text());run=A['runs'][0];COLORS=['#ad650f','#b23c43','#694aab']
plt.rcParams.update({'font.family':'DejaVu Sans','font.size':11,'axes.spines.top':False,'axes.spines.right':False,'axes.titleweight':'bold','axes.titlepad':12,'savefig.facecolor':'#fffdfa','figure.facecolor':'#fffdfa','axes.facecolor':'#fffdfa'})
def rows(tag):
    with (OUT/tag/'history.csv').open(newline='') as f:return list(csv.DictReader(f))
r=rows(run['run']);f=rows(A['runs'][1]['run']);t=np.array([float(v['time']) for v in r]);ft=np.array([float(v['time']) for v in f])
def val(rs,key):return np.array([float(v[key]) for v in rs])
def timeaxis(ax):
    ax.axvspan(1.2,1.6,color='#cdd5dc',alpha=.22,zorder=0)
    for w in [.4,.8,1.2]:ax.axvline(w,color='#8c8c8c',lw=.8,ls=':',zorder=0)
    ax.set_xlim(0,1.6);ax.set_xlabel('Model time');ax.grid(axis='y',alpha=.18)
fig,axs=plt.subplots(2,2,figsize=(12.7,10.3));fig.subplots_adjust(top=.81,bottom=.19,hspace=.52,wspace=.27)
fig.suptitle('Heat spreads; the write total accumulates',fontsize=22,x=.065,ha='left',y=.98)
fig.text(.065,.924,'Threshold 1 · breathing on · 16³ grid · periodic unit box\nSolid: original step 0.002. Dotted: half step 0.001. Shaded time 1.2–1.6 is the new continuation.',fontsize=11,color='#4a4a4a',va='top')
ax=axs[0,0];series=[val(r,f'write_{i}_mean')*1e5 for i in range(3)]
ax.stackplot(t,*series,colors=COLORS,labels=[f'Write at {x:.1f}' for x in [.4,.8,1.2]],alpha=.83)
ax.plot(ft,sum(val(f,f'write_{i}_mean') for i in range(3))*1e5,'k:',lw=1.3)
ax.set_title('A. Earlier pulses remain when the next arrives',loc='left',fontsize=12);ax.set_ylabel('Total write contribution (10⁻⁵ units)');timeaxis(ax)
ax.legend(frameon=False,fontsize=9,loc='upper left');ax.text(1.58,4.18336+.11,'4.183',ha='right',fontsize=11);ax.set_ylim(0,4.9)
ax=axs[0,1]
for i,c in enumerate(COLORS):
    active=val(r,f'write_{i}_expected_mean')>0;fa=val(f,f'write_{i}_expected_mean')>0
    ax.plot(t[active],100*val(r,f'write_{i}_outside025_share')[active],color=c,lw=2.2)
    ax.plot(ft[fa],100*val(f,f'write_{i}_outside025_share')[fa],color='black',ls=':',lw=.8)
    end=100*run['writes'][i]['final_outside025_share'];ax.text(1.58,end+1.1,f'{end:.1f}%',color=c,ha='right',fontsize=11)
ax.set_title('B. More of each pulse lies farther from its start',loc='left',fontsize=12);ax.set_ylabel('Signed share outside radius 0.25 (%)');timeaxis(ax);ax.set_ylim(0,62)
ax=axs[1,0];write=sum(val(r,f'write_{i}_mean') for i in range(3));net=val(r,'net_viscous_heat_mean');release=val(r,'structural_release_mean')
ax.stackplot(t,write*1e4,net*1e4,release*1e4,colors=['#b9674b','#4f8891','#c8b077'],labels=['Three writes','Net viscous heating','Structural release'],alpha=.85)
ax.plot(ft,(val(f,'thermal_mean')-float(f[0]['thermal_mean']))*1e4,'k:',lw=1.2)
ax.set_title('C. Writes supply 20.7% of the new warmth',loc='left',fontsize=12);ax.set_ylabel('Increase above initial warmth (10⁻⁴ units)');timeaxis(ax);ax.legend(frameon=False,fontsize=9,loc='upper left')
ax=axs[1,1];x=np.arange(3);width=.32;birth=[w['birth_negative_to_net_ratio']*100 for w in run['writes']];end=[w['final_negative_to_net_ratio']*100 for w in run['writes']]
b1=ax.bar(x-width/2,birth,width,color=COLORS,alpha=.85,label='Just after write');b2=ax.bar(x+width/2,end,width,color=COLORS,alpha=.28,edgecolor=COLORS,label='At time 1.6')
for b,v in zip(b1,birth):ax.text(b.get_x()+b.get_width()/2,v+.05,f'{v:.2f}%',ha='center',fontsize=10)
for b,v in zip(b2,end):ax.text(b.get_x()+b.get_width()/2,v+.05,f'{v:.4f}%',ha='center',fontsize=9)
ax.set_title('D. The filter’s negative ripples are retained',loc='left',fontsize=12);ax.set_ylabel('Negative magnitude / net pulse (%)');ax.set_xticks(x,[f'Write {v}' for v in ['0.4','0.8','1.2']]);ax.set_ylim(0,2.7);ax.grid(axis='y',alpha=.18);ax.legend(frameon=False,fontsize=9,loc='upper right')
fig.text(.065,.055,'The curves account for signed numerical heat contributions. They are not positive heat-particle inventories.\nNo wall cooling or fourth write was added. Half-step heat checks pass; grid convergence is untested.\nSimulation findings only. Lean checks the recorded accounts separately. AI-generated; dictated and directed by NousVolition.',fontsize=10,color='#4a4a4a')
fig.savefig(OUT/'heat-account.png',dpi=180);fig.savefig(OUT/'heat-account.svg');plt.close(fig)
with np.load(OUT/run['run']/'fields.npz') as z:
    data=[]
    for side in ['birth','end']:
        for i,w in enumerate(run['writes']):
            j=next(j for j,(t,s) in enumerate(zip(z['time'],z['side'])) if (t==w['write_time'] and s=='after_write') if side=='birth') if side=='birth' else len(z['time'])-1
            data.append(z['components'][j,...,3+i].mean(axis=1).T/w['deposited_heat'])
limit=max(float(abs(d).max()) for d in data)
norm=TwoSlopeNorm(vmin=-limit,vcenter=0,vmax=limit)
fig,axs=plt.subplots(2,3,figsize=(12.7,8.6),layout='constrained');fig.suptitle('Follow each write’s heat through the same box',fontsize=21)
for j,ax in enumerate(axs.flat):
    i=j%3;coords=np.arange(17)/16-.5
    im=ax.pcolormesh(coords,coords,np.pad(data[j],((0,1),(0,1)),mode='wrap'),cmap='RdBu_r',norm=norm,shading='nearest')
    ax.set_xlim(-.5,.5);ax.set_ylim(-.5,.5);ax.set_aspect('equal')
    ax.set_title(f'Write at {run["writes"][i]["write_time"]:.1f} — '+('just added' if j<3 else 'at time 1.6'),fontsize=12)
    ax.set_xlabel('x');ax.set_ylabel('z');ax.set_xticks([-.5,0,.5]);ax.set_yticks([-.5,0,.5])
fig.colorbar(im,ax=axs,shrink=.82,label='Signed pulse field / its deposited total (y average)')
fig.supxlabel('One shared linear signed colour scale. Negative ripples are retained and measured in the account diagram.\nOpposite faces join. Threshold 1 · breathing on · 16³ · step 0.002. Simulation fields, not Lean output.\nAI-generated; dictated and directed by NousVolition.',fontsize=10)
fig.savefig(OUT/'heat-spread.png',dpi=180);fig.savefig(OUT/'heat-spread.svg');plt.close(fig)
print(json.dumps({'figures':['heat-account.png','heat-spread.png'],'source_run':run['run'],'snapshots':20,'clip_negative_values':False}))
