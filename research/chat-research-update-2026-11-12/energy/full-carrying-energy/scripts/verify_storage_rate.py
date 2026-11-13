"""Independent directional derivative of the full implemented material energy."""
import sys,json,csv,hashlib
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
import diagnose_stages as d
np=d.np
def main():
    case=d.old.preflight.approve('threshold_1')
    with (d.old.INPUT/'study/marker-seeds.csv').open() as f:trail=d.Trail(list(csv.DictReader(f)))
    solver=d.ComparisonSolver(d.Config(**case['config']),.5,.6,trail);solver.initial()
    path=d.old.SAVED/'state-0600.npz';before=d.old.sha(path);s=d.old.load(path)
    rates,stats,extra=solver.rhs(1.2,s,details=True)
    _,expected=d.diagnostic(solver,1.2,s,rates,stats,extra)
    def energy(F,m,b):
        base=solver.material(F,m,np.zeros_like(F))[0]
        fabric=solver.fabric.constitutive(F,b)[0]
        return float(solver.V@(base+fabric))
    checks=[]
    for eps in [1e-3,1e-4,1e-5]:
        plus=energy(*(s[k]+eps*rates[k] for k in ['F','m','b']))
        minus=energy(*(s[k]-eps*rates[k] for k in ['F','m','b']))
        derivative=(plus-minus)/(2*eps)
        checks.append(dict(epsilon=eps,energy_directional_derivative=derivative,
            stress_write_release_rate=expected['stored_rate'],difference=derivative-expected['stored_rate']))
    assert abs(checks[-1]['difference'])<1e-12
    assert d.old.sha(path)==before
    result=dict(status='PASS',state_frame=600,checks=checks,source_state_sha256=before,
        script_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),state_unchanged=True,
        scope='One directional derivative of W(F,m,b), independent finite differences of energy versus the stress/write/release expression. Not a continuum theorem.')
    (d.OUT/'storage-rate-check.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))
if __name__=='__main__':main()
