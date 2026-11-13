"""Propose a certificate for one archived-field candidate segment's phase.
The candidate is not claimed to solve the field ODE. Lean checks the entire
trigonometric enclosure along the supplied polynomial, independently of Arb.
"""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
import sys,json,hashlib
from fractions import Fraction as Q
from math import factorial
from pathlib import Path
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'threshold-one-window-study'))
import numpy as np
from scipy.integrate import solve_ivp
from flint import arb,arb_series,ctx
from measure import field_at
ctx.prec=256;ctx.cap=21
import argparse
parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,required=True)
args=parser.parse_args();ROOT=args.output;ROOT.mkdir(parents=True,exist_ok=True)
D=2**200;PILO=Q(314159265358979323846,10**20)

def add(p,q):return [(p[i] if i<len(p) else 0)+(q[i] if i<len(q) else 0) for i in range(max(len(p),len(q)))]
def scale(a,p):return [a*x for x in p]
def mul(p,q):
    out=[Q(0)]*(len(p)+len(q)-1)
    for i,a in enumerate(p):
        for j,b in enumerate(q):out[i+j]+=a*b
    return out
def deriv(p):return [i*p[i] for i in range(1,len(p))]
def ev(p,x):
    out=Q(0)
    for a in p[::-1]:out=a+x*out
    return out
def mass(p):return sum(map(abs,p))
def residual(p,c,s):return mass(add(deriv(c),mul(deriv(p),s)))+mass(add(deriv(s),scale(-1,mul(deriv(p),c))))
def rounded(x):return Q(round(x*D),D)
def lean(x):return str(x.numerator) if x.denominator==1 else f'({x.numerator} / {x.denominator})'
def point_candidate(q):
    return ([rounded((-1)**(n//2)*q**n/factorial(n)) if n%2==0 else Q(0) for n in range(65)],
        [rounded((-1)**((n-1)//2)*q**n/factorial(n)) if n%2 else Q(0) for n in range(65)])
def dyadic_mid(x):
    n=(x.mid()*arb(D)).floor().unique_fmpz()
    assert n is not None
    return Q(int(n),D)

study=HERE.parent/'threshold-one-window-study'
rows=json.loads((study/'snapshots.json').read_text(encoding='utf-8'))
index=next(r['index'] for r in rows if r['label']=='event-1-left')
with np.load(study/'snapshots.npz',allow_pickle=False) as z:omega=z['omega'][index];A=z['pairs'][index,0]
def rhs(t,x):
    w=field_at(omega,x);return w/np.linalg.norm(w)
sol=solve_ivp(rhs,(0,.001),A,method='DOP853',rtol=2e-12,atol=2e-14,
    first_step=.001,max_step=.001,dense_output=True)
assert sol.success
interp=sol.sol.interpolants[0]
position=[Q(0)]
for i,f in enumerate(reversed(interp.F)):
    position=add(position,[Q(float(f[0]))])
    position=mul(position,[Q(1,2),Q(1,2) if i%2==0 else Q(-1,2)])
position=add(position,[Q(float(interp.y_old[0]))])
assert ev(position,-1)==Q(float(A[0]))
p=scale(2*PILO,add(position,[Q(1,2)]))
pa=ev(p,-1);cp,sp=point_candidate(pa)
series=arb_series([arb(a.numerator)/a.denominator for a in p],prec=21)
c=[dyadic_mid(series.cos()[i]) for i in range(21)]
s=[dyadic_mid(series.sin()[i]) for i in range(21)]
error=2*residual([Q(0),pa],cp,sp)+abs(ev(c,-1)-ev(cp,1))+abs(ev(s,-1)-ev(sp,1))+2*residual(p,c,s)
phaseerror=2*Q(1,10**20)*mass(add(position,[Q(1,2)]))
assert error<Q(1,10**30) and error+phaseerror<Q(1,10**18)
lines=['import FrozenTrigModel','import FrozenConstants','set_option maxRecDepth 100000',
    'set_option maxHeartbeats 10000000','set_option profiler true','set_option profiler.threshold 100',
    'namespace PhasePilot','open FrozenPolynomial FrozenTrig FrozenTrigModel FrozenConstants FrozenRational']
for name,poly in [('position',position),('p',p),('c',c),('s',s),('cp',cp),('sp',sp)]:
    lines.append('def '+name+' : Poly := ['+',\n'.join(map(lean,poly))+']')
lines += ['''def input : Model := (phaseModel position).round p
def cm : Model := withInputError (cosineModel p c s cp sp) input
def sm : Model := withInputError (sineModel p c s cp sp) input
theorem cosine_candidate_sound : Models cm
    (fun u => Real.cos (2 * Real.pi * (eval position u + 1/2))) := by
  apply cosine_input_sound (round_models (phaseModel_sound position) p)
  exact cosineModel_sound p c s cp sp (by norm_num [cp, eval]) (by norm_num [sp, eval])
theorem sine_candidate_sound : Models sm
    (fun u => Real.sin (2 * Real.pi * (eval position u + 1/2))) := by
  apply sine_input_sound (round_models (phaseModel_sound position) p)
  exact sineModel_sound p c s cp sp (by norm_num [cp, eval]) (by norm_num [sp, eval])
theorem cosine_error_small : cm.error ≤ (1 / 10^18 : ℚ) := by decide +kernel
theorem sine_error_small : sm.error ≤ (1 / 10^18 : ℚ) := by decide +kernel
theorem whole_interval_cosine (u : ℝ) (hu : |u| ≤ 1) :
    |Real.cos (2 * Real.pi * (eval position u + 1/2)) - eval c u| ≤ (1 / 10^18 : ℝ) := by
  apply le_trans (cosine_candidate_sound u hu)
  have hr := (Rat.cast_le (K := ℝ)).mpr cosine_error_small
  simpa only [Rat.cast_div, Rat.cast_one, Rat.cast_pow, Rat.cast_ofNat] using hr
theorem whole_interval_sine (u : ℝ) (hu : |u| ≤ 1) :
    |Real.sin (2 * Real.pi * (eval position u + 1/2)) - eval s u| ≤ (1 / 10^18 : ℝ) := by
  apply le_trans (sine_candidate_sound u hu)
  have hr := (Rat.cast_le (K := ℝ)).mpr sine_error_small
  simpa only [Rat.cast_div, Rat.cast_one, Rat.cast_pow, Rat.cast_ofNat] using hr
#print axioms whole_interval_cosine
#print axioms whole_interval_sine
end PhasePilot''']
(ROOT/'PhasePilot.lean').write_text('\n'.join(lines)+'\n',encoding='utf-8',newline='\n')
record={'status':'CANDIDATE_NOT_YET_CHECKED','archived_label':'event-1-left','coordinate':0,
    'physical_interval':[float(interp.t_old),float(interp.t)],
    'source_npz_sha256':hashlib.sha256((study/'snapshots.npz').read_bytes()).hexdigest(),
    'candidate_trigonometric_error':float(error),'candidate_phase_error':float(phaseerror),
    'claim_scope':'Trigonometric approximation on a candidate polynomial segment, not an ODE trajectory.'}
(ROOT/'PhasePilot.json').write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(record))
