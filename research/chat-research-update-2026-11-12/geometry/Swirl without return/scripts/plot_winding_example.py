from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

out=Path('$USER_HOME/Documents/Codex/2026-11-10/lo/outputs/Swirl without return')
mu=np.sqrt(2.)
rho=(mu-1)/(mu+1)
r=np.linspace(0,7,16000)
q=mu*(r-np.arctan(rho*np.sin(4*np.pi*r)/(1+rho*np.cos(4*np.pi*r)))/(2*np.pi))
x=(r-q)/2
y=(r+q)/2
xw=(x+.5)%1-.5
yw=(y+.5)%1-.5
jump=np.r_[False,(np.abs(np.diff(xw))>.5)|(np.abs(np.diff(yw))>.5)]
xw[jump]=np.nan
yw[jump]=np.nan

plt.rcParams.update({'font.family':'DejaVu Sans','font.size':10,'axes.spines.top':False,
                     'axes.spines.right':False,'axes.labelcolor':'#243447','text.color':'#243447'})
fig,(ax,bx)=plt.subplots(1,2,figsize=(11,4.9),dpi=170,gridspec_kw={'width_ratios':[1,1.45]})
fig.patch.set_facecolor('#fafaf7')
for a in [ax,bx]: a.set_facecolor('#fafaf7')
ax.plot(xw,yw,color='#187198',lw=1.4,alpha=.86,label='Open line: keeps winding')
ax.plot([0,0],[-.5,.5],color='#bd6723',lw=2.3,ls='--',label='Closed line')
ax.scatter([0],[0],s=44,c='#243447',zorder=6)
ax.annotate('A',xy=(0,0),xytext=(.04,.04),weight='bold')
ax.set(xlim=(-.5,.5),ylim=(-.5,.5),aspect='equal',xlabel='x (periodic box)',ylabel='y (periodic box)',
       title='Same plane; different return behavior')
ax.set_xticks([-.5,0,.5]); ax.set_yticks([-.5,0,.5])
ax.grid(color='#dbe1e6',lw=.65)
ax.legend(loc='upper left',fontsize=8,frameon=True,facecolor='#fafaf7',framealpha=.95)

s=np.linspace(0,2,1800)
v=(np.cos(4*np.pi*s)-1)/8
strength=np.sqrt(v*v+(1+v)**2)
bx.plot(s,np.ones_like(s),color='#bd6723',lw=2.2,ls='--',label='Closed line')
bx.plot(s,strength,color='#187198',lw=2.5,label='Open line')
bx.axhline(1/np.sqrt(2),color='#6b7885',ls=':',lw=1.5)
bx.text(1.97,1/np.sqrt(2)-.035,'Proved lower bound: 1/√2',ha='right',fontsize=9,color='#5a6774')
bx.axhline(0,color='#c1c8cf',lw=.8)
bx.scatter([0],[1],s=44,c='#243447',zorder=6)
bx.annotate('At A: identical swirl',xy=(0,1),xytext=(.18,1.115),fontsize=10,
            arrowprops={'arrowstyle':'-','color':'#243447'})
bx.set(xlim=(-.025,2.025),ylim=(-.03,1.22),xlabel='Position along the line: r = x + y (unwrapped)',
       ylabel='Swirl strength / strength at A',title='Swirl stays above zero everywhere on the line')
bx.grid(axis='y',color='#dbe1e6',lw=.65)
fig.suptitle('Matching A while the open line keeps swirling',x=.065,ha='left',fontsize=15,weight='bold')
fig.text(.065,.02,'Time is fixed at 1.2. Curves are exact analytic examples; a finite drawing illustrates the separate proof of nonreturn.',fontsize=9,color='#5a6774')
fig.subplots_adjust(left=.065,right=.98,bottom=.19,top=.80,wspace=.28)
fig.savefig(out/'Nonzero winding comparison.png',facecolor=fig.get_facecolor())
fig.savefig(out/'Nonzero winding comparison.svg',facecolor=fig.get_facecolor())
print(str(out/'Nonzero winding comparison.png'))
