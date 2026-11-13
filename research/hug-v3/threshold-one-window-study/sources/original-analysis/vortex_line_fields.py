"""Reconstruct the 50 native clean-Hug 801 integration steps between prime 37 and 41."""
import csv
import json
from pathlib import Path
from unittest.mock import patch

import numpy as np
from scipy.fft import fftn

HERE=Path(__file__).resolve().parent
DEST=HERE/"vortex-lines"
DEST.mkdir(exist_ok=True)
FREQ=np.arange(-5,6)
WN=2j*np.pi*np.stack(np.meshgrid(FREQ,FREQ,FREQ,indexing="ij"),-1)
DT=.002
FIRST,LAST=550,600

def coefficients(velocity):
    return fftn(velocity,axes=(0,1,2))[np.ix_(FREQ%16,FREQ%16,FREQ%16)]/16**3

def field_at(hat,points):
    p=np.asarray(points).reshape(-1,3)
    exp=np.exp(2j*np.pi*((p+.5)%1.)[:,:,None]*FREQ)
    xsum=np.tensordot(exp[:,0],hat,axes=(1,0))
    xysum=np.einsum("pj,pjkc->pkc",exp[:,1],xsum)
    return np.einsum("pk,pkc->pc",exp[:,2],xysum).real.reshape(np.asarray(points).shape)

def forward(points, pair):
    """Actual discrete native Heun material map for the stored velocity stages."""
    k1=field_at(pair[0],points)
    k2=field_at(pair[1],points+DT*k1)
    return points+.5*DT*(k1+k2)

def replay():
    from hug_vortex_replay import SOURCE, approved_arm, ComparisonSolver, Config, Trail, read_state
    case,extra=approved_arm("breathing_on")
    old=SOURCE/"results/breathing_on"
    with (SOURCE/"marker-seeds.csv").open() as f:trail=Trail(list(csv.DictReader(f)))
    solver=ComparisonSolver(Config(**case["config"]),extra["peak"],extra["period"],trail)
    solver.initial()
    s=read_state(old/"prime-37-at.npz")
    stages=[];accepted=[]
    saved={}
    with (old/"prime-markers.csv").open() as f:
        for r in csv.DictReader(f):
            pair=(int(r["coincidence_prime"]),r["side"])
            if pair in ((37,"at"),(41,"before_write")):
                saved.setdefault(pair,[]).append([float(r[k]) for k in ("x_unwrapped","y_unwrapped","z_unwrapped")])
    s["observer_X"]=np.array(saved[(37,"at")]); check=s["observer_X"][[0,100,300,500,800]].copy()
    native=solver.rhs
    def capture(t,state,details=False):
        assert not details
        stages.append(coefficients(state["g"][...,:3]))
        return native(t,state)
    with patch.object(solver,"rhs",capture):
        for i in range(FIRST,LAST+1):
            if i>FIRST:
                s=solver.step((i-1)*DT,s,DT)
                check=forward(check,stages[-2:])
                np.testing.assert_allclose(check,s["observer_X"][[0,100,300,500,800]],atol=5e-15,rtol=0)
            accepted.append(coefficients(s["g"][...,:3]))
    expected=read_state(old/"prime-41-before_write.npz")
    for k,v in expected.items(): np.testing.assert_array_equal(s[k],v)
    np.testing.assert_array_equal(s["observer_X"],np.array(saved[(41,"before_write")]))
    accepted=np.asarray(accepted);stages=np.asarray(stages).reshape(50,2,11,11,11,3)
    np.testing.assert_array_equal(stages[:,0],accepted[:-1])
    w=np.cross(WN,accepted)
    assert np.max(abs(np.sum(WN*w,axis=-1)))<2e-14
    np.savez(DEST/"fields.npz",velocity=accepted,stages=stages,omega=w)
    print("Verified all native final fields, 801 marker positions, both stages and spectral curl.",flush=True)

if __name__=="__main__":replay()
