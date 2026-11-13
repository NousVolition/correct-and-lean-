"""Show where the completed finest-grid comparison exceeds its declared limit."""
from pathlib import Path
import json,hashlib
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'outputs/heat-grid'
final=(ROOT/'outputs/heat-grid-lean/receipt.json').exists()
source=OUT/'comparison-n32_dt0p002--n40_dt0p002.json';c=json.loads(source.read_text())['comparison']
fig,ax=plt.subplots(figsize=(11,5.8),facecolor='#fbfaf7');ax.set_facecolor('#fbfaf7')
colors=['#215a99','#c77728','#238776']
for w,col in zip(c['writes'],colors):
 rows=w['history'];x=[r['time'] for r in rows];y=[100*r['normalized_field_L1'] for r in rows]
 ax.plot(x,y,'o-',color=col,lw=2,ms=4,label=f'Write {w["event_id"]+1}')
 first=rows[0];ax.annotate(f'{y[0]:.3f}%',(x[0],y[0]),xytext=(10,8),textcoords='offset points',color=col,fontsize=11,weight='bold')
 ax.annotate(f'{y[-1]:.3f}%',(x[-1],y[-1]),xytext=(9,0),textcoords='offset points',color=col,va='center',fontsize=10)
ax.axhline(1,ls=':',color='#a03545',lw=1.6,label='Preset 1% limit')
ax.set(xlabel='Model time',ylabel='Difference in normalized spatial pattern (%)',xlim=(.36,1.75),ylim=(0,1.26))
ax.spines[['top','right']].set_visible(False);ax.grid(alpha=.15);ax.legend(loc='upper left',fontsize=10)
fig.suptitle('The largest difference is at the new write',x=.1,ha='left',fontsize=19,weight='bold',y=.97)
fig.text(.1,.89,'Completed fluid runs: 32³ versus 40³, both at time step 0.002 · threshold 1',fontsize=11)
fig.subplots_adjust(left=.1,right=.96,top=.82,bottom=.22)
scope='Only saved instants are shown. Lean separately checks recorded numbers and finite rules; it does not check the fluid simulation.' if final else 'Only saved instants are shown; the 40³ smaller-step control and final recorded-result Lean checks are pending.'
fig.text(.1,.09,'Each pulse is divided by its own deposited heat. Comparisons use the same 96³ observation grid.\n'+scope,fontsize=9,color='#4b5661')
fig.text(.1,.025,'AI-generated; dictated and directed by NousVolition.',fontsize=8,color='#4b5661')
name='heat-grid-detail' if final else 'heat-grid-detail-progress'
fig.savefig(OUT/(name+'.png'),dpi=150,facecolor=fig.get_facecolor());fig.savefig(OUT/(name+'.svg'),facecolor=fig.get_facecolor());plt.close(fig)
(OUT/(name+'-source.json')).write_text(json.dumps({'source':source.name,'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'comparison':c,'scope':scope},indent=2)+'\n')
print(json.dumps({'figure':name,'final':final}))
