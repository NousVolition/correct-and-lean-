from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

out=Path('$USER_HOME/Documents/Codex/2026-11-10/lo/outputs/Closest point and paddle wheel')
plt.rcParams.update({'font.family':'DejaVu Sans','font.size':11,'axes.spines.top':False,
                     'axes.spines.right':False,'axes.labelcolor':'#253343','text.color':'#253343'})
fig,ax=plt.subplots(figsize=(10,4.8),dpi=170)
fig.patch.set_facecolor('#fafaf7')
ax.set_facecolor('#fafaf7')
ax.axvspan(0,.75,color='#e9edf1',zorder=0)
ax.plot([0,1],[1,1],color='#bd6723',lw=2.4,label='Closed line')
s=np.linspace(0,5/6-1e-5,900)
g=2*(1-np.cos(2*np.pi*s+np.pi/3))
ax.plot(s,g,color='#176c96',lw=2.7,label='Open line')
ax.scatter([0],[1],s=50,c='#253343',zorder=6)
ax.scatter([5/6],[0],s=60,facecolors='#fafaf7',edgecolors='#176c96',linewidths=2,zorder=6)
ax.axvline(.75,color='#748292',lw=1,ls='--')
ax.annotate('A: same axle and strength',xy=(0,1),xytext=(.035,1.55),fontsize=10,
            arrowprops={'arrowstyle':'-','color':'#253343'})
ax.annotate('Zero swirl at the limit\n(the line never reaches it\nin finite vortex parameter)',
            xy=(5/6,.04),xytext=(.59,2.15),fontsize=10,
            arrowprops={'arrowstyle':'->','color':'#176c96'},ha='left')
ax.text(.375,4.18,'Shared ¾-length trace',ha='center',fontsize=10,color='#5b6877')
ax.text(.995,1.15,'Returns to A',ha='right',fontsize=10,color='#99501a')
ax.set(xlim=(-.025,1.025),ylim=(-.15,4.5),xlabel='Arclength from A (cube lengths)',
       ylabel='Swirl strength / strength at A')
ax.set_xticks([0,1/3,.75,5/6,1],['0','⅓','¾','⅚','1'])
ax.legend(loc='upper right',frameon=False)
ax.grid(axis='y',color='#dce1e5',linewidth=.6)
fig.suptitle('Same reading at A; different swirl farther along the line',x=.08,ha='left',fontsize=14,weight='bold')
fig.text(.08,.015,'Fluid time is fixed at 1.2. These are exact constructed Navier–Stokes solutions, not saved Hug data.',fontsize=9,color='#5b6877')
fig.subplots_adjust(left=.08,right=.98,bottom=.18,top=.86)
fig.savefig(out/'Swirl along the two lines.png',facecolor=fig.get_facecolor())
fig.savefig(out/'Swirl along the two lines.svg',facecolor=fig.get_facecolor())
print(str(out/'Swirl along the two lines.png'))
