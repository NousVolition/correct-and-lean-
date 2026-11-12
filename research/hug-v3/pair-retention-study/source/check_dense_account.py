import json
from types import SimpleNamespace
import numpy as np
from run_retention_cellaware import dense_account, sample
rng=np.random.default_rng(9025)
n=10
g0=rng.normal(size=(n,n,n,5))
k1=rng.normal(size=g0.shape);k2=rng.normal(size=g0.shape)
p=np.array([[-.005,-.135,.045],[.095,.155,-.255]])
v1=np.array([[1.,.02,.01],[1.,-.03,.04]])
v2=v1+np.array([[.05,.001,0],[-.02,0,.002]])
dt=.02
c1=np.zeros((n,n,n,6));c2=c1.copy()
c1[...,1]=k1[...,3];c2[...,1]=k2[...,3]
c1[...,4]=k1[...,4];c2[...,4]=k2[...,4]
audit=SimpleNamespace(stage_velocities=[v1,v2],stage_grid_rates=[k1,k2],stage_components=[c1,c2])
account,splits=dense_account(g0,p,dt,audit)
endg=g0+dt*(k1+k2)/2
endp=p+dt*(v1+v2)/2
actual=sample(endg,endp)[0][:,3:5]-sample(g0,p)[0][:,3:5]
recount=np.stack([account[:,:3].sum(axis=1),account[:,3:].sum(axis=1)],axis=-1)
error=float(abs(actual-recount).max())
assert splits>=2
assert error<1e-12
print(json.dumps(dict(crossing_test_passed=True,cell_splits=splits,max_chain_error=error)))
