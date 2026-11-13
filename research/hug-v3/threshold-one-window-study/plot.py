"""Render the saved measurements. Requires Matplotlib in addition to NumPy."""
import json, os
from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

HERE=Path(__file__).resolve().parent
rows=json.loads((HERE/'measurements.json').read_text())
windows=[('forward_075','Original [0, 0.75]','#cc7621'),
         ('both_075','Extended [−0.75, 0.75]','#147d80'),
         ('both_300','Extended [−3, 3]','#7655a3')]
fig,axes=plt.subplots(2,2,figsize=(12,7.2),gridspec_kw={'height_ratios':[1.5,1]},layout='constrained')
plt.rcParams.update({'font.size':10})
for j,(start,end,events) in enumerate([(1.178,1.184,[1.1809101667,1.1820768690]),(1.198,1.2,[1.1992811937])]):
    data=sorted([r for r in rows if start<=r['time']<=end],key=lambda r:r['time'])
    x=[r['time'] for r in data]
    for name,label,color in windows:
        axes[0,j].scatter(x,[r['windows'][name]['winner']['s'] for r in data],s=24,label=label,color=color,alpha=.9)
        if name!='forward_075':
            improvement=[r['windows']['forward_075']['winner']['d']-r['windows'][name]['winner']['d'] for r in data]
            axes[1,j].plot(x,improvement,'o-',ms=3,lw=1.2,label=label,color=color)
    for ax in axes[:,j]:
        for t in events:ax.axvline(t,color='#708090',lw=.9,ls='--',zorder=0)
        ax.grid(alpha=.18)
        ax.set_xlim(start-.00004,end+.00004)
        ax.ticklabel_format(useOffset=False,axis='x')
    axes[0,j].axhline(0,color='#999999',lw=.6)
    axes[0,j].set_title('First two saved exchanges' if j==0 else 'Third saved exchange',fontsize=12,pad=10)
    axes[1,j].set_xlabel('Model time')
    axes[1,j].ticklabel_format(style='sci',axis='y',scilimits=(0,0))
axes[0,0].set_ylabel('Selected signed arclength from A')
axes[1,0].set_ylabel('Reduction in nearest distance to B')
axes[0,1].set_ylim(-1,.6)
axes[0,0].legend(loc='lower left',fontsize=9)
fig.suptitle('The measured closest point depends on how much of the path is visible',fontsize=15)
fig.supxlabel('Threshold 1 • fixed 16³ history • same A and B • 40 measured times\nDashed lines: saved exchange times. Upper panels show samples, not continuous event tracking.',fontsize=10)
fig.savefig(HERE/'window-comparison.png',dpi=180)
fig.savefig(HERE/'window-comparison.svg')
print(str(HERE/'window-comparison.png'))
