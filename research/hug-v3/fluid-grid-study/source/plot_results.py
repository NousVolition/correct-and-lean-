"""Standalone, reproducible numerical convergence figure with explicit units."""
import os,sys,json,csv
from pathlib import Path
HERE=Path(__file__).resolve().parent
os.environ.setdefault('MPLCONFIGDIR',str(HERE/'mpl-config'))
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
OUT=HERE.parent
TAGS=['n16_dt0p002', 'n16_dt0p001', 'n16_dt0p0005', 'n24_dt0p0005', 'n32_dt0p0005', 'n32_dt0p00025']
def readcsv(p):
    with p.open(encoding='utf-8-sig',newline='') as f:return list(csv.DictReader(f))

BLUE='#2864a3';ORANGE='#c46b25';INK='#263238';GRAY='#697780'
COLORS={'fixed':BLUE,'reselected':ORANGE}
NAMES={'fixed':'Same material pairs','reselected':'Pairs selected on each run'}
plt.rcParams.update({'font.family':'DejaVu Sans','font.size':10,'axes.titlesize':12,
    'axes.labelsize':10,'axes.spines.top':False,'axes.spines.right':False,
    'axes.edgecolor':GRAY,'axes.labelcolor':INK,'text.color':INK,'xtick.color':INK,'ytick.color':INK,
    'figure.facecolor':'white','axes.facecolor':'white','savefig.facecolor':'white'})

comparisons=readcsv(OUT/'gap-comparisons.csv')
by={(r['comparison'],r['convention']):r for r in comparisons}
stats=readcsv(OUT/'gap-summaries.csv')
fields=readcsv(OUT/'field-comparisons.csv')
fig,axes=plt.subplots(2,2,figsize=(12.5,8.5),gridspec_kw={'hspace':.45,'wspace':.30})
fig.suptitle('Hug v3: actual fluid-grid and time-step checks',x=.075,y=.98,ha='left',fontsize=18,weight='bold')
fig.text(.075,.925,'Threshold 0.015 · breathing on · periodic unit cube · 384 material points held fixed',fontsize=10.5,color=GRAY)
for ax in axes.flat:
    ax.set_axisbelow(True);ax.grid(axis='y',color='#e4e8eb',lw=.7)

ax=axes[0,0]
timekeys=['time16_2_1','time16_1_half','time32_half_quarter']
for c in ['fixed','reselected']:
    y=[float(by[k,c]['max_pair_gap_change']) for k in timekeys]
    offset=-.035 if c=='fixed' else .035
    ax.plot(np.array([0,1])+offset,y[:2],marker='o' if c=='fixed' else 's',linestyle='-' if c=='fixed' else '--',color=COLORS[c],lw=1.8,ms=6,label=NAMES[c])
    ax.plot([2+offset],[y[2]],marker='o' if c=='fixed' else 's',linestyle='none',color=COLORS[c],ms=6)
ax.axvline(1.5,color='#d8dde1',lw=.8)
ax.axhline(.001,color=INK,ls=':',lw=1.2)
ax.text(2.05,.001,'0.001 target',va='center',fontsize=8.5,color=INK,bbox=dict(facecolor='white',edgecolor='none',pad=1))
ax.set_yscale('log');ax.set_ylim(1e-6,.2);ax.set_xlim(-.2,2.65)
ax.set_xticks([0,1,2],['16³: .002→.001','16³: .001→.0005','32³: .0005→.00025'])
ax.tick_params(axis='x',labelsize=8.5)
ax.set_ylabel('Largest pair-gap change\n(cube side lengths; log scale)')
ax.set_title('A  Smaller simulation time steps',loc='left',weight='bold')

ax=axes[0,1]
for c in ['fixed','reselected']:
    y=[float(by[k,c]['max_pair_gap_change']) for k in ['space16_24','space24_32']]
    xs=np.array([0,1])+(-.035 if c=='fixed' else .035)
    ax.plot(xs,y,marker='o' if c=='fixed' else 's',linestyle='-' if c=='fixed' else '--',color=COLORS[c],lw=1.8,ms=6,label=NAMES[c])
    for x,v in zip(xs,y):ax.annotate(f'{v:.4g}',(x,v),xytext=(6,8 if c=='fixed' else -16),textcoords='offset points',fontsize=9,color=COLORS[c])
ax.axhline(.001,color=INK,ls=':',lw=1.2)
ax.text(1.10,.001,'0.001 target',va='center',fontsize=8.5,bbox=dict(facecolor='white',edgecolor='none',pad=1))
ax.set_yscale('log');ax.set_ylim(1e-6,.2);ax.set_xlim(-.2,1.65);ax.set_xticks([0,1],['16³ → 24³','24³ → 32³'])
ax.set_ylabel('Largest pair-gap change\n(cube side lengths; log scale)')
ax.set_title('B  Finer fluid grids, Δt = 0.0005',loc='left',weight='bold')

ax=axes[1,0]
for c in ['fixed','reselected']:
    series=[]
    for tag in TAGS[2:5]:
        r=next(r for r in stats if r['run']==tag and r['convention']==c and r['window']=='extended' and abs(float(r['time'])-1.2)<1e-12)
        series.append([float(r[k]) for k in ['min_gap','median_gap','max_gap']])
    a=np.asarray(series);x=np.array([16,24,32])+(0 if c=='fixed' else .65)
    ax.errorbar(x,a[:,1],yerr=np.vstack([a[:,1]-a[:,0],a[:,2]-a[:,1]]),color=COLORS[c],marker='o' if c=='fixed' else 's',
                linestyle='-' if c=='fixed' else '--',lw=1.8,ms=6,capsize=4,label=NAMES[c])
ax.set_ylim(bottom=0);ax.set_xlim(14,35);ax.set_xticks([16,24,32],['16³','24³','32³'])
ax.set_ylabel('Gap on the 0.75 forward arc\n(cube side lengths)')
ax.set_title('C  Final gaps at t = 1.2',loc='left',weight='bold')
ax.text(0,-.23,'Markers: median of 25 pairs. Whiskers: minimum–maximum,\nnot a confidence interval. Δt = 0.0005.',transform=ax.transAxes,fontsize=9,color=GRAY)

ax=axes[1,1]
for quantity,color,marker,name,target in [('velocity','#596c3a','o','Velocity',1),('vorticity','#976081','s','Vorticity',5)]:
    y=[]
    for k in ['space16_24','space24_32']:
        r=next(r for r in fields if r['comparison']==k and r['quantity']==quantity and abs(float(r['time'])-1.2)<1e-12)
        y.append(100*float(r['relative_l2']))
    ax.plot([0,1],y,color=color,marker=marker,lw=1.8,ms=6,label=name)
    ax.axhline(target,color=color,ls=':',lw=1)
    ax.text(1.10,target,f'{name} target {target}%',fontsize=8.5,va='center',color=color,bbox=dict(facecolor='white',edgecolor='none',pad=1))
ax.set_yscale('log');ax.set_xlim(-.2,1.9);ax.set_xticks([0,1],['16³ → 24³','24³ → 32³'])
ax.set_yticks([1,2,3,5,8],labels=['1','2','3','5','8'])
ax.yaxis.set_minor_formatter(matplotlib.ticker.NullFormatter())
ax.set_ylabel('Relative L2 difference (%)\n(finer field is the reference; log scale)')
ax.set_title('D  Final fluid-field agreement',loc='left',weight='bold')
ax.legend(loc='upper right',frameon=False,fontsize=9)

handles,labels=axes[0,0].get_legend_handles_labels()
fig.legend(handles,labels,loc='lower left',bbox_to_anchor=(.07,.005),ncol=2,frameon=False,fontsize=10)
fig.text(.075,.075,'A–B use the maximum over 25 pairs, 51 times (1.1–1.2), and both finite trace windows.\nLine readout: 192³ with arc step 1/1024. D uses a shared 64³ field-reading grid.\nThose reading grids are separate from the actual 16³, 24³ and 32³ fluid integrations.',fontsize=9,color=GRAY)
fig.subplots_adjust(top=.88,bottom=.20,left=.09,right=.96)
fig.savefig(OUT/'convergence.png',dpi=180)
fig.savefig(OUT/'convergence.svg')
plt.close(fig)
print('Saved convergence.png and convergence.svg')
