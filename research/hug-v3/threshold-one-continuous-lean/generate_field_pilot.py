"""Propose a whole-segment archived Fourier-field certificate for Lean.

SciPy and Arb propose the position and trigonometric polynomials. All analytic
errors, truncations and arithmetic bounds are independently checked by Lean.
This alone is not a certificate that the candidate solves the normalized ODE.
"""
import os
os.environ['OPENBLAS_NUM_THREADS'] = '1'
import sys, json, hashlib, re
from fractions import Fraction as Q
from math import factorial
from pathlib import Path
from dataclasses import dataclass
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent/'threshold-one-window-study'))
import numpy as np
from scipy.integrate import solve_ivp
from flint import arb, arb_series, ctx
from measure import field_at
ctx.prec = 256
ctx.cap = 21
ROOT = HERE
import argparse
parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,required=True)
args=parser.parse_args();OUT=args.output;OUT.mkdir(parents=True,exist_ok=True)
D = 2**200
F = 2**80
A = D//F
DEGREE = 12
constants = (ROOT/'FrozenDyadicConstants.lean').read_text(encoding='utf-8')
PINUM = int(re.search(r'def piNumerator : ℤ := (\d+)', constants).group(1))
PIERR = int(re.search(r'def piError : ℤ := (\d+)', constants).group(1))

def add(p, q):
    return [(p[i] if i < len(p) else 0)+(q[i] if i < len(q) else 0)
            for i in range(max(len(p), len(q)))]

def scale(a, p):
    return [a*x for x in p]

def sub(p, q):
    return add(p, scale(-1, q))

def mul(p, q):
    if not p:
        return []
    if not q:
        return [0]*len(p)
    out = [0]*(len(p)+len(q)-1)
    for i, a in enumerate(p):
        for j, b in enumerate(q):
            out[i+j] += a*b
    return out

def deriv(p):
    return [i*p[i] for i in range(1, len(p))]+([0] if p else [])

def ev(p, x):
    out = 0
    for a in p[::-1]:
        out = a+x*out
    return out

def mass(p):
    return sum(map(abs, p))

@dataclass
class Model:
    p: list
    e: int = 0

    def add(self, other):
        return Model(add(self.p, other.p), self.e+other.e)

    def neg(self):
        return Model(scale(-1, self.p), self.e)

    def sub(self, other):
        return self.add(other.neg())

    def mul(self, other):
        raw = mul(self.p, other.p)
        p = [a//D for a in raw[:DEGREE+1]]
        s = (mass(self.p)*other.e+mass(other.p)*self.e+self.e*other.e+
             mass(sub(raw, scale(D, p))))
        return Model(p, s//D+1)

@dataclass
class ComplexModel:
    re: Model
    im: Model

    def add(self, other):
        return ComplexModel(self.re.add(other.re), self.im.add(other.im))

    def mul(self, other):
        return ComplexModel(self.re.mul(other.re).sub(self.im.mul(other.im)),
                            self.re.mul(other.im).add(self.im.mul(other.re)))

    def conj(self):
        return ComplexModel(self.re, self.im.neg())

    def power(self, k):
        r = ComplexModel(Model([D]), Model([0]))
        for _ in range(abs(k)):
            r = r.mul(self)
        return r.conj() if k < 0 else r

def complex_sum(ms):
    out = ComplexModel(Model([0]), Model([0]))
    for m in reversed(ms):
        out = m.add(out)
    return out

def residual(p, c, s):
    return (mass(add(scale(D, deriv(c)), mul(deriv(p), s)))+
            mass(sub(scale(D, deriv(s)), mul(deriv(p), c))))

def trig_model(input_model):
    p = input_model.p
    a = ev(p, -1)
    q = Q(a, D)
    cp = [round((-1)**(n//2)*q**n/factorial(n)*D) if n%2 == 0 else 0 for n in range(65)]
    sp = [round((-1)**((n-1)//2)*q**n/factorial(n)*D) if n%2 else 0 for n in range(65)]
    series = arb_series([arb(x)/D for x in p], prec=21)
    ac, ass = series.cos(), series.sin()
    def midint(x):
        z = (x.mid()*arb(D)).floor().unique_fmpz()
        assert z is not None
        return int(z)
    c = [midint(ac[i]) for i in range(21)]
    s = [midint(ass[i]) for i in range(21)]
    N = (residual([0, a], cp, sp)+D*(abs(ev(c, -1)-ev(cp, 1))+
         abs(ev(s, -1)-ev(sp, 1)))+2*residual(p, c, s))
    E = N//D+1+input_model.e
    return ComplexModel(Model(c, E), Model(s, E)), (c, s, cp, sp)

study = HERE.parent/'threshold-one-window-study'
rows = json.loads((study/'snapshots.json').read_text(encoding='utf-8'))
index = next(r['index'] for r in rows if r['label'] == 'event-1-left')
with np.load(study/'snapshots.npz', allow_pickle=False) as z:
    omega = z['omega'][index]
    seed = z['pairs'][index, 0]

def rhs(t, x):
    w = field_at(omega, x)
    return w/np.linalg.norm(w)

sol = solve_ivp(rhs, (0, .001), seed, method='DOP853', rtol=2e-12, atol=2e-14,
                first_step=.001, max_step=.001, dense_output=True)
assert sol.success
interp = sol.sol.interpolants[0]
positions = []
inputs = []
bases = []
trig_data = []
for axis in range(3):
    q = [Q(0)]
    for i, ff in enumerate(reversed(interp.F)):
        q = add(q, [Q(float(ff[axis]))])
        q = mul(q, [Q(1, 2), Q(1, 2) if i%2 == 0 else Q(-1, 2)])
    q = add(q, [Q(float(interp.y_old[axis]))])
    assert ev(q, -1) == Q(float(seed[axis]))
    assert all((v*D).denominator == 1 for v in q)
    p = [int(v*D) for v in q]
    positions.append(p)
    pm = Model([2*D]).mul(Model([PINUM], PIERR).mul(Model(p).add(Model([D//2]))))
    base, data = trig_model(pm)
    inputs.append(pm)
    bases.append(base)
    trig_data.append(data)

archive_source = (ROOT/'FrozenArchive.lean').read_text(encoding='utf-8')
source_block = re.search(r'def event_1_left_c0 : List Wave := \[(.*?)\]\n', archive_source, re.S).group(1)
# A Wave has five fields; keep a strict arity check on the actual transcription.
waves = [tuple(map(int, m)) for m in re.findall(r'⟨(-?\d+), (-?\d+), (-?\d+), (-?\d+), (-?\d+)⟩', source_block)]
assert len(waves) == 1331
powers = [[base.power(k) for k in range(-5, 6)] for base in bases]
blocks = []
for k0 in range(-5, 6):
    row_models = []
    for k1 in range(-5, 6):
        leaves = [w for w in waves if w[:2] == (k0, k1)]
        lm = [ComplexModel(Model([re*A]), Model([im*A])).mul(powers[2][k2+5])
              for _, _, k2, re, im in leaves]
        row_models.append(complex_sum(lm).mul(powers[1][k1+5]))
    blocks.append(complex_sum(row_models).mul(powers[0][k0+5]))
field = complex_sum(blocks)
assert field.re.e*10**18 <= D

def lp(p):
    return '['+',\n'.join(map(str, p))+']'

lines = ['import FrozenFourierModel', 'import FrozenIntTrigModel', 'import FrozenDyadicConstants',
         'import FrozenIntEnclosure',
         'import FrozenArchive', 'set_option maxRecDepth 100000',
         'set_option maxHeartbeats 100000000', 'set_option profiler true',
         'set_option profiler.threshold 100', 'namespace FieldPilot',
         'open FrozenIntPolynomial FrozenDyadicConstants FrozenFourierModel',
         'abbrev D := denominator', 'abbrev hD := denominator_positive',
         f'def A : ℤ := {A}', f'def degree : ℕ := {DEGREE}']
lines.append('def positions : Fin 3 → Poly := !['+',\n'.join(lp(p) for p in positions)+']')
for j, name in enumerate(['c', 's', 'cp', 'sp']):
    lines.append(f'def {name} : Fin 3 → Poly := !['+',\n'.join(lp(v[j]) for v in trig_data)+']')
lines.append('def baseError : Fin 3 → ℤ := !['+','.join(str(b.re.e) for b in bases)+']')
for part in ['re','im']:
    lines.append(f'def power{part.upper()} : Fin 3 → Fin 11 → Poly := !['+
        ',\n'.join('!['+',\n'.join(lp(getattr(m,part).p) for m in row)+']' for row in powers)+']')
    lines.append(f'def error{part.upper()} : Fin 3 → Fin 11 → ℤ := !['+
        ',\n'.join('!['+','.join(str(getattr(m,part).e) for m in row)+']' for row in powers)+']')
lines += ['''noncomputable def q (x : ℝ) : FrozenField.Point := fun i => eval (positions i) x / D
def input (i : Fin 3) : FrozenIntModel.Model := phaseModel degree (positions i)
theorem baseError_nonneg (i : Fin 3) : 0 ≤ baseError i := by fin_cases i <;> decide
def base (i : Fin 3) : FrozenComplexModel.Model :=
  ⟨⟨c i, baseError i, baseError_nonneg i⟩, ⟨s i, baseError i, baseError_nonneg i⟩⟩
theorem starts_cos (i : Fin 3) : evalInt (cp i) 0 = D := by fin_cases i <;> decide
theorem starts_sin (i : Fin 3) : evalInt (sp i) 0 = 0 := by fin_cases i <;> decide
theorem base_error_checked (i : Fin 3) :
    FrozenIntTrigModel.errorNumerator D (input i) (c i) (s i) (cp i) (sp i) = baseError i := by
  fin_cases i <;> decide +kernel
theorem base_sound (i : Fin 3) : FrozenComplexModel.Models D (base i)
    (fun x => phasor (spatialPhase (q x) i)) := by
  constructor
  · have hc := FrozenIntTrigModel.cosine_models hD (phase_models degree (positions i))
      (c i) (s i) (cp i) (sp i) (starts_cos i) (starts_sin i)
    simpa only [phasor, Complex.exp_ofReal_mul_I_re, base, input, q, spatialPhase, D] using
      FrozenIntEnclosure.enclose hD hc (c i) (baseError i) (baseError_nonneg i) rfl (base_error_checked i).le
  · have hs := FrozenIntTrigModel.sine_models hD (phase_models degree (positions i))
      (c i) (s i) (cp i) (sp i) (starts_cos i) (starts_sin i)
    simpa only [phasor, Complex.exp_ofReal_mul_I_im, base, input, q, spatialPhase, D] using
      FrozenIntEnclosure.enclose hD hs (s i) (baseError i) (baseError_nonneg i) rfl (base_error_checked i).le
def computedPower (i : Fin 3) (k : Fin 11) : FrozenComplexModel.Model :=
  FrozenComplexModel.Model.intPhase D hD degree (base i) (frequency k)
theorem powerRE_nonneg (i : Fin 3) (k : Fin 11) : 0 ≤ errorRE i k := by
  fin_cases i <;> fin_cases k <;> decide
theorem powerIM_nonneg (i : Fin 3) (k : Fin 11) : 0 ≤ errorIM i k := by
  fin_cases i <;> fin_cases k <;> decide
def powers (i : Fin 3) (k : Fin 11) : FrozenComplexModel.Model :=
  ⟨⟨powerRE i k, errorRE i k, powerRE_nonneg i k⟩,
   ⟨powerIM i k, errorIM i k, powerIM_nonneg i k⟩⟩
theorem powers_checked (i : Fin 3) (k : Fin 11) :
    (computedPower i k).re.polynomial = powerRE i k ∧ (computedPower i k).re.error = errorRE i k ∧
    (computedPower i k).im.polynomial = powerIM i k ∧ (computedPower i k).im.error = errorIM i k := by
  fin_cases i <;> fin_cases k <;> decide +kernel
theorem powers_sound (i : Fin 3) (k : Fin 11) : FrozenComplexModel.Models D (powers i k)
    (fun x => phasor ((frequency k : ℝ) * spatialPhase (q x) i)) := by
  have h := FrozenComplexModel.intPhase_models hD degree (base_sound i) (frequency k)
  have hc := powers_checked i k
  exact ⟨FrozenIntEnclosure.enclose hD h.1 _ _ (powerRE_nonneg i k) hc.1 hc.2.1.le,
    FrozenIntEnclosure.enclose hD h.2 _ _ (powerIM_nonneg i k) hc.2.2.1 hc.2.2.2.le⟩
''']
tree = []
for k0 in range(-5, 6):
    rtext = []
    for k1 in range(-5, 6):
        leaves = [w for w in waves if w[:2] == (k0, k1)]
        ls = ',\n'.join(f'⟨{k2+5}, {re}, {im}⟩' for _, _, k2, re, im in leaves)
        rtext.append(f'⟨{k1+5}, [{ls}]⟩')
    tree.append(f'⟨{k0+5}, ['+',\n'.join(rtext)+']⟩')
lines.append('def tree : List Block := ['+',\n'.join(tree)+']')
lines += ['''theorem archive_identity : flatten tree = FrozenArchive.event_1_left_c0 := by decide +kernel
def fieldModel : FrozenComplexModel.Model := treeModel D hD degree A powers tree
theorem field_sound : FrozenIntModel.Models D fieldModel.re
    (fun x => FrozenField.value FrozenArchive.event_1_left_c0 FrozenArchive.denominator (q x)) := by
  rw [← archive_identity]
  exact tree_models hD degree (by decide) FrozenArchive.denominator_positive (by decide) powers_sound tree
''']
lines.append('def proposedPolynomial : Poly := '+lp(field.re.p))
lines.append('def proposedError : ℤ := '+str(field.re.e))
lines += ['''theorem checked_field : fieldModel.re.polynomial = proposedPolynomial ∧
    fieldModel.re.error = proposedError := by decide +kernel
theorem checked_error : proposedError * 10^18 ≤ D := by decide
theorem continuous_field_enclosure (x : ℝ) (hx : |x| ≤ 1) :
    |FrozenField.value FrozenArchive.event_1_left_c0 FrozenArchive.denominator (q x) -
      eval proposedPolynomial x / D| ≤ (1 / 10^18 : ℝ) := by
  have h := field_sound x hx
  rw [checked_field.1, checked_field.2] at h
  apply le_trans h
  have hd : (0 : ℝ) < D := by exact_mod_cast hD
  apply (div_le_div_iff₀ hd (by positivity : (0 : ℝ) < 10^18)).mpr
  have he : (proposedError : ℝ) * 10^18 ≤ (D : ℝ) := by exact_mod_cast checked_error
  simpa only [one_mul] using he
#print axioms archive_identity
#print axioms checked_field
#print axioms continuous_field_enclosure
end FieldPilot''']
(OUT/'FieldPilot.lean').write_text('\n'.join(lines)+'\n', encoding='utf-8', newline='\n')
record = {'status': 'PROPOSED_NOT_YET_CHECKED', 'scope': 'One archived Fourier component along a candidate segment; not an ODE trajectory',
          'archived_label': 'event-1-left', 'component': 0, 'physical_interval': [float(interp.t_old), float(interp.t)],
          'source_npz_sha256': hashlib.sha256((study/'snapshots.npz').read_bytes()).hexdigest(),
          'field_model_error_proposal': float(Q(field.re.e, D)),
          'field_model_center': float(Q(field.re.p[0], D)),
          'field_model_tail_mass': float(Q(mass(field.re.p[1:]), D)),
          'phase_model_error_proposals': [float(Q(b.re.e, D)) for b in bases]}
(OUT/'FieldPilot.json').write_text(json.dumps(record, indent=2)+'\n', encoding='utf-8', newline='\n')
print(json.dumps(record), flush=True)
