"""Read-only evaluation of existing checkpoints. No evolution or source edits."""
import os
for key in ("OPENBLAS_NUM_THREADS", "OMP_NUM_THREADS", "MKL_NUM_THREADS"):
    os.environ[key] = "1"
import sys, json, hashlib, csv
from pathlib import Path
from datetime import datetime, timezone
sys.dont_write_bytecode = True
ROOT = Path(r"$USER_HOME\Documents\Codex\2026-11-11\new-chat-13\tick41-readonly-check")
OUT = Path(__file__).resolve().parent
OUT.mkdir(parents=True, exist_ok=True)
runtime = Path(r"$USER_HOME\Documents\Codex\2026-10-28\new-chat-4\hug-v3-coexistence-lean\.runtime")
sys.path[:0] = [str(runtime), str(ROOT/"inputs/declared-source"), str(ROOT/"inputs/study")]
import numpy as np
import scipy
import preflight
from breathing import ComparisonSolver, Trail
from structural_hug import Config
files = list((ROOT/"inputs/declared-source").rglob("*.py")) + [ROOT/"inputs/study/breathing.py", ROOT/"inputs/study/marker-seeds.csv", ROOT/"inputs/declared-source/protocol.json", ROOT/"inputs/declared-source/source_seal.json", ROOT/"inputs/declared-source/declarations/threshold_1.json"]
files += [ROOT/"inputs/snapshots"/n for n in ("state-0000.npz", "state-0600.npz")]
digest = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
before = {str(p): digest(p) for p in files}
case = preflight.approve("threshold_1")
with (ROOT/"inputs/study/marker-seeds.csv").open() as f:
    trail = Trail(list(csv.DictReader(f)))
solver = ComparisonSolver(Config(**case["config"]), .5, .6, trail)
solver.initial()  # Establish the original utility baseline; no files written.
def load(n):
    with np.load(ROOT/"inputs/snapshots"/n, allow_pickle=False) as z:
        return {k: z[k].copy() for k in z.files}
s0, s1 = load("state-0000.npz"), load("state-0600.npz")
_, stat0, _ = solver.rhs(0., s0, True)
rates, stat1, _ = solver.rhs(1.2, s1, True)
dE = stat1["energy"] - stat0["energy"]
work = {"breathing": float(s1["breathing_work"]-s0["breathing_work"]), "write": float(s1["write_work"]-s0["write_work"]), "AS": float(s1["ledger"][1]-s0["ledger"][1])}
residual = dE - sum(work.values())
u, C = s1["g"][...,:3], s1["g"][...,3]
c = solver.c
gradC = np.stack([(np.roll(C,-1,axis=j)-np.roll(C,1,axis=j))/(2*solver.dx) for j in range(3)],-1)
q = np.sqrt(np.sum(gradC**2,-1)+c.delta**2)-np.sqrt(c.threshold**2+c.delta**2)
assert c.branch not in ("sharp", "tanh"), c.branch
activation = np.zeros_like(q)
on = q>0
activation[on] = q[on]*np.exp(-(c.epsilon/q[on])**2)
force = np.zeros_like(u); force[...,0] = -c.sigma*activation
mean = lambda a: a.mean(axis=(0,1,2))
rms = lambda a: float(np.sqrt(np.mean(np.sum(a*a,axis=-1))))
projected = solver.project(force)
fmean, umean = mean(force), mean(u)
power = float(np.mean(np.sum(force*u,-1)))
meanpower = float(np.dot(fmean, umean))
fluctpower = float(np.mean(np.sum((force-fmean)*(u-umean),-1)))
changed = {k:v.copy() for k,v in s1.items()}
changed["ledger"][1] += 1.
changed_rates = solver.rhs(1.2, changed)
ledger_rate_effect = {k:float(np.max(np.abs(changed_rates[k]-v))) for k,v in rates.items()}
assert max(ledger_rate_effect.values()) == 0.
assert abs(power-float(rates["ledger"][1])) < 1e-15
assert abs(power-meanpower-fluctpower) < 1e-15
assert abs(residual) < 2e-9
after = {str(p):digest(p) for p in files}
assert before == after
result = dict(checked_utc=datetime.now(timezone.utc).isoformat(), method="Fresh read-only evaluations of saved frame 0 and frame 600, time 1.2, after third write; no new trajectory simulated", numpy=np.__version__, scipy=scipy.__version__, config=dict(n=c.n, branch=c.branch, threshold=c.threshold, sigma=c.sigma, breathing_peak=.5, breathing_period=.6), initial={k:stat0[k] for k in ("energy","kinetic","elastic","thermal")}, tick41={k:stat1[k] for k in ("energy","kinetic","elastic","thermal")}, energy_change=dE, work=work, work_shares_percent={k:100*v/dE for k,v in work.items()}, residual=residual, residual_ppm=1e6*abs(residual/dE), drift_kinetic=float(.5*np.dot(umean,umean)), elastic_over_coupling=stat1["elastic"]/work["AS"], drift_kinetic_over_coupling=float(.5*np.dot(umean,umean)/work["AS"]), instantaneous=dict(mean_force=fmean.tolist(), mean_velocity=umean.tolist(), power=power, mean_power=meanpower, fluctuation_power=fluctpower, projected_force_rms=rms(projected), projected_force_fluctuation_rms=rms(projected-mean(projected)), gradient_component_power=float(np.mean(np.sum((force-projected)*u,-1))), force_projection_note="Native periodic Fourier projection; a periodic gradient has zero projected force. Mean and nonconstant projected components are retained."), ledger_perturbation=dict(amount=1., max_rate_change=max(ledger_rate_effect.values()), all_rate_arrays_identical=True, interpretation="ledger[1] is passive in this RHS; this test does not identify its physical reservoir or the user's mentor concept"), inputs_unchanged=True, inputs_sha256=before)
(OUT/"saved-frame-check.json").write_text(json.dumps(result,indent=2)+"\n", encoding="utf-8")
print(json.dumps({k:v for k,v in result.items() if k!="inputs_sha256"},indent=2))
