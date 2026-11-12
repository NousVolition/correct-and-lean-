"""Quantitative plot from the completed same-pair comparisons."""
import os,sys,json,csv
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
os.environ.setdefault('MPLCONFIGDIR',str(HERE/'mpl-config'))
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm
import numpy as np
from public_data import ROOT as OUT,load_gaps,rows

def main():
    summary=json.loads((OUT/'analysis-summary.json').read_text())
    comparisons={r['comparison']:r for r in rows(OUT/'gap-comparisons.csv')}
    tags=['n32_dt0p0005','n40_dt0p0005','n48_dt0p0005']
    arrays=[load_gaps(tag)[1] for tag in tags]
    colors=['#547995','#e08d2b','#247c68']
    plt.rcParams.update({'font.family':'DejaVu Sans','font.size':10,
        'axes.spines.top':False,'axes.spines.right':False,'figure.facecolor':'white',
        'axes.labelcolor':'#263238','text.color':'#263238','axes.titleweight':'bold'})
    fig,axes=plt.subplots(2,2,figsize=(13,9),gridspec_kw={'hspace':.48,'wspace':.30})
    fig.suptitle('Do the same pairs settle on finer fluid grids?',x=.075,y=.985,ha='left',fontsize=19,weight='bold')
    fig.text(.075,.942,'25 material pairs · tick 37 to tick 41 (time 1.1–1.2) · threshold 0.015 · breathing-on experiment',fontsize=10.5)
    decision='Declared gap criteria met at 48³' if summary['same_pair_gaps_settled_within_declared_tests'] else 'The declared checks do not yet establish settled pair gaps'
    fig.text(.075,.909,decision+' — numerical study, separate from Lean',fontsize=11,weight='bold')
    ax=axes[0,0]
    keys=['space24_32','space32_40','space40_48','time48_half']
    for field,color,marker,label in [('max_pair_gap_change','#2864a3','o','Largest pair change'),
        ('max_time_median_abs_pair_change','#8a5aa8','s','Largest median pair change')]:
        values=[float(comparisons[k][field]) for k in keys]
        ax.plot(range(3),values[:3],marker=marker,color=color,lw=1.8,label=label)
        ax.plot(3,values[3],marker=marker,color=color)
        for i,v in enumerate(values):
            ax.annotate(f'{v:.3g}',(i,v),xytext=(4,6 if marker=='o' else -13),textcoords='offset points',fontsize=8,color=color)
    ax.axhline(.001,color='#2864a3',ls=':',lw=1,label='Maximum target: 0.001')
    ax.axhline(.0005,color='#8a5aa8',ls=':',lw=1,label='Median target: 0.0005')
    ax.axvline(2.5,color='#d5dadd',lw=1)
    ax.set_yscale('log');ax.set_xticks(range(4),['24³→32³','32³→40³','40³→48³','48³: halve dt'])
    ax.tick_params(axis='x',labelsize=9)
    ax.set_ylabel('Gap change (cube side lengths, log scale)')
    ax.set_title('A  All 51 saved times and both windows',loc='left',pad=12)
    ax.legend(fontsize=8,loc='best',framealpha=.95)
    ax.grid(axis='y',color='#e5e8ea',lw=.6)
    ax=axes[0,1]
    changes=np.max(abs(arrays[2][:,:,:2]-arrays[1][:,:,:2]),axis=2).T
    floor=max(float(changes.max())*1e-5,1e-9)
    im=ax.imshow(np.maximum(changes,floor),origin='lower',aspect='auto',extent=[1.1,1.2,-.5,24.5],
        cmap='magma',norm=LogNorm(vmin=floor,vmax=max(float(changes.max()),floor*10)))
    ax.set_title('B  40³→48³: each pair through the window',loc='left',pad=12)
    ax.set_xlabel('Model time (right edge: tick 41)');ax.set_ylabel('Pair ID')
    bar=fig.colorbar(im,ax=ax,pad=.02)
    bar.set_label('Largest gap change across the two windows')
    for ax,k,letter,label in [(axes[1,0],0,'C','Short window: first 0.375 of the line'),
                              (axes[1,1],1,'D','Extended window: first 0.75 of the line')]:
        for i,(data,color,n) in enumerate(zip(arrays,colors,[32,40,48])):
            ax.plot(np.arange(25)+(i-1)*.17,data[-1,:,k],linestyle='none',marker=['o','s','^'][i],
                    color=color,ms=4.8,label=f'{n}³ fluid grid',alpha=.9)
        ax.set_title(letter+'  '+label,loc='left',pad=12)
        ax.set_xlabel('Same material pair ID at tick 41');ax.set_ylabel('Gap (cube side lengths)')
        ax.set_xticks(range(0,25,2));ax.grid(axis='y',color='#e5e8ea',lw=.6)
        ax.legend(fontsize=8,loc='best')
    fig.subplots_adjust(top=.85,bottom=.12,left=.075,right=.96)
    fig.text(.075,.048,'Fluid integrations start at time zero. Material quadrature stays at 384 points. A small final median can hide a moving pair.',fontsize=9,color='#5d6870')
    fig.text(.075,.022,'AI-generated; dictated and directed by NousVolition. These numerical checks do not extend the Lean proof scope.',fontsize=9,color='#5d6870')
    fig.savefig(OUT/'finer-grids.png',dpi=180)
    fig.savefig(OUT/'finer-grids.svg')
    plt.close(fig)
    print('Saved finer-grids.png and finer-grids.svg',flush=True)
    # Follow the specific pair whose last spatial comparison differs most.
    focus=summary['last_spatial'];pair=focus['worst_seed'];window=focus['worst_window']
    meter=rows(OUT/'same-pair-local-meter.csv')
    fig,axs=plt.subplots(2,2,figsize=(12.5,8),sharex=True,gridspec_kw={'hspace':.34,'wspace':.28})
    focus_time=1.1+.002*focus['worst_frame_index']
    fig.suptitle(f'Following pair {pair} where 40³ and 48³ disagree most',x=.075,y=.98,ha='left',fontsize=17,weight='bold')
    fig.text(.075,.932,f'{window.capitalize()} viewing window · same material A and B · tick 37 (1.1) through tick 41 (1.2)',fontsize=10.5)
    panels=[(axs[0,0],window+'_gap','A  Gap for this pair','Gap (cube side lengths)'),
        (axs[0,1],window+'_closest_arclength','B  Location selected along the line','Arclength from A (cube side lengths)'),
        (axs[1,0],'A_local_spin','C  Local spin at A','Local spin (1 / model time)'),
        (axs[1,1],'A_strain_norm','D  Local strain at A','Strain-rate norm (1 / model time)')]
    for ax,key,title,ylabel in panels:
        for tag,color,n in zip(tags,colors,[32,40,48]):
            rs=sorted([r for r in meter if r['run']==tag and int(r['pair'])==pair],key=lambda r:float(r['model_time']))
            ax.plot([float(r['model_time']) for r in rs],[float(r[key]) for r in rs],color=color,lw=1.6,label=f'{n}³')
        ax.axvline(focus_time,color='#59636a',ls=':',lw=1)
        ax.set_title(title,loc='left');ax.set_ylabel(ylabel);ax.grid(axis='y',color='#e5e8ea',lw=.6)
    axs[0,0].legend(ncol=3,fontsize=9)
    for ax in axs[1]:ax.set_xlabel('Model time; dotted line marks largest gap disagreement')
    fig.subplots_adjust(top=.87,bottom=.13,left=.075,right=.96)
    fig.text(.075,.051,'Read from saved fields at 51 times. Intermediate samples are not extra prime labels. The meter does not establish causation.',fontsize=9,color='#5d6870')
    fig.text(.075,.025,'AI-generated; dictated and directed by NousVolition. Numerical readouts, separate from Lean.',fontsize=9,color='#5d6870')
    fig.savefig(OUT/'same-pair-meter.png',dpi=180)
    fig.savefig(OUT/'same-pair-meter.svg')
    plt.close(fig)
    print('Saved same-pair-meter.png and same-pair-meter.svg',flush=True)

if __name__=='__main__':main()
