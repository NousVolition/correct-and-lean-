from pathlib import Path
import json
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

HERE=Path(__file__).resolve()
OUT=HERE.parents[1] if HERE.parent.name=='scripts' else HERE.parents[1]/'outputs/Same particle history'
d=np.load(OUT/'illustration-48.npz')
r=json.loads((OUT/'Numerical checks.json').read_text())
plt.rcParams.update({'font.family':'DejaVu Sans','font.size':11,
                     'axes.spines.top':False,'axes.spines.right':False})
navy,orange='#215775','#c36b1f'
fig,ax=plt.subplots(2,2,figsize=(12,8.1))
fig.subplots_adjust(top=.87,bottom=.14,left=.09,right=.96,wspace=.3,hspace=.62)
fig.suptitle('Same history at A; different vortex-line closure',fontsize=20,y=.97,x=.09,ha='left')
fig.text(.09,.92,'New periodic fluid pair · tagging 1.178 → tick 41 at 1.2',color='#52616b',fontsize=12)

def both(axis,x,y):
    axis.plot(x,y,color=navy,lw=3.5,label='Closed-line flow')
    axis.plot(x,y,color=orange,lw=1.8,ls='--',label='Winding-line flow')
    axis.grid(alpha=.15)

both(ax[0,0],d['times'],d['particle_y'])
ax[0,0].set(title="A follows the same moving path",xlabel='Fluid time',ylabel="A's Y coordinate")
ax[0,0].set_xticks([1.178,1.189,1.2])
ax[0,0].legend(frameon=False,fontsize=9)
both(ax[0,1],d['times'],d['swirl_history'])
ax[0,1].set(title='The paddle-wheel histories coincide',xlabel='Fluid time',ylabel='Swirl strength at A')
ax[0,1].set_xticks([1.178,1.189,1.2])
ax[0,1].text(.04,.1,'Axle: +Y in both flows',transform=ax[0,1].transAxes,fontsize=10,color='#52616b')

y=np.r_[d['y'],1.]
z=np.r_[d['x'],0.]
ax[1,0].plot(y,np.zeros_like(y),color=navy,lw=2.5)
ax[1,0].plot(y,z,color=orange,lw=2.3)
ax[1,0].plot([0,0],[0,.25],':',color='#777777',lw=1.5)
ax[1,0].scatter([0],[.25],color='#687881',s=40,zorder=5)
ax[1,0].scatter([0],[0],color='#173b4d',s=40,zorder=5)
ax[1,0].annotate('B',xy=(0,.25),xytext=(8,-4),textcoords='offset points')
ax[1,0].annotate('A',xy=(0,0),xytext=(8,7),textcoords='offset points')
ax[1,0].text(.035,.12,'1/4',color='#555555',fontsize=10)
ax[1,0].set(title='Same closest point and distance at tick 41',xlabel='Y along one turn of the vortex line',ylabel='Z coordinate (transverse view)',ylim=(-.065,.28),xlim=(-.04,1.04))
ax[1,0].grid(alpha=.15)

turns=np.arange(17)
ax[1,1].plot(turns,np.zeros_like(turns),color=navy,lw=2,label='Closed: returns to A')
ax[1,1].plot(turns,-turns*float(d['drift']),color=orange,marker='o',markersize=3,lw=1.7,label='Winding: shifted each turn')
ax[1,1].set(title='The other coordinate reveals nonreturn',xlabel='Completed turns (Y increases by 1)',ylabel='X coordinate at each crossing')
ax[1,1].ticklabel_format(axis='y',style='sci',scilimits=(0,0))
ax[1,1].set_xticks([0,4,8,12,16])
ax[1,1].grid(alpha=.15)
ax[1,1].legend(frameon=False,fontsize=9,loc='lower left')
fig.text(.09,.065,'Numerical illustration; the analytical proof selects an exactly irrational shift after each turn.',fontsize=10,color='#52616b')
fig.text(.09,.038,'Finite samples cannot prove nonreturn. The new PDE existence and parameter-selection steps are not yet Lean-formalized.',fontsize=9,color='#52616b')
fig.savefig(OUT/'Same history, different lines.png',dpi=180)
fig.savefig(OUT/'Same history, different lines.svg')
print('Saved the comparison figure.')
