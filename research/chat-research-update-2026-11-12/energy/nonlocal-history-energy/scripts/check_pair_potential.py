"""Finite algebra check of a potential derived from the older, inactive pair law.
This is not a Hug trajectory or an insertion of that law into the saved run.
"""
from pathlib import Path
import json,hashlib
import numpy as np
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'outputs/nonlocal-history-energy'
source=Path(r'$USER_HOME\Documents\Codex\2026-10-08\referenced-chatgpt-conversation-this-is-an-2\outputs\hug-field-specification\coupled_hug.py')
before=hashlib.sha256(source.read_bytes()).hexdigest()
partner=np.array([1,0,3,2]);V=np.array([.1,.1,.2,.2]);w=np.array([.4,.7,.2,.6]);k=1.2;B=.03
R=np.array([[1,2,3,4,5,6,7],[2,4,1,7,3,6,5],[4,1,7,3,2,5,6],[7,6,5,4,3,2,1]],float);R/=R.sum(axis=1,keepdims=True)
C=np.array([.2,-.1,.5,.4,-.3,.1,.6]);direction=np.array([.3,.1,-.2,.5,.7,-.4,.2]);dv=1/len(C)
def energy(C):
    cp=R@C;z=(cp[partner]-cp)/B
    logcosh=np.logaddexp(z,-z)-np.log(2.)
    return .5*k*B*B*np.sum(V*w*w[partner]*logcosh)
cp=R@C;d=k*w*w[partner]*B*np.tanh((cp[partner]-cp)/B)
D=R.T@(V*d)/dv
gradient=-D;analytic=dv*np.dot(gradient,direction)
checks=[]
for eps in [1e-3,1e-4,1e-5]:
    fd=(energy(C+eps*direction)-energy(C-eps*direction))/(2*eps)
    checks.append(dict(epsilon=eps,directional_finite_difference=float(fd),analytic=float(analytic),difference=float(fd-analytic)))
assert abs(checks[-1]['difference'])<1e-12
eps=1e-4;pair_rate=(energy(C+eps*D)-energy(C-eps*D))/(2*eps);expected=-dv*np.dot(D,D)
assert abs(pair_rate-expected)<1e-12
assert abs(float(np.dot(V,d)))<1e-16
assert energy(np.zeros_like(C))==0 and energy(C)>0
assert hashlib.sha256(source.read_bytes()).hexdigest()==before
result=dict(status='PASS',scope='Small frozen-geometry algebra check of a derived potential for the older mirrored pair law; not a simulation, calibration, physical energy identification, or Lean theorem.',
    checks=checks,pair_only_potential_rate=float(pair_rate),negative_grid_norm_squared=float(expected),
    potential_at_zero=energy(np.zeros_like(C)),potential_at_test_state=energy(C),
    relation_to_saved_run='The old direct paired-context term is identically zero in the actual threshold-1 solver; this law is not activated.',
    source=str(source),source_sha256=before,source_unchanged=True,script_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
(OUT/'pair-potential-check.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
