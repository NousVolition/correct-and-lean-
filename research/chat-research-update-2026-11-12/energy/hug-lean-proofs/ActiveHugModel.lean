import HugModel
import Mathlib.Analysis.ODE.PicardLindelof
import Mathlib.Analysis.SpecialFunctions.Trigonometric.DerivHyp

/- Exact-real physical-unit equations from hug-active-guard/METHODS.md and
physical_rhs at commit b4ae2c54cd85bfef282c501ecfca83de274e2070.
These source files explicitly call this a reduced, synthetic realization.
F denotes the prescribed force at the instant considered. -/
namespace ActiveHug
noncomputable section
open Set MeasureTheory intervalIntegral

structure Parameters where
  mass : ℝ
  stiffness : ℝ
  volume : ℝ
  length : ℝ
  gm : ℝ
  gk : ℝ
  etaM : ℝ
  etaK : ℝ
  gain : ℝ
  saturation : ℝ
  damping : ℝ
  scale : ℝ
  rateReference : ℝ
  lambda : ℝ
  baselineA : ℝ
  baselineB : ℝ
  weightAB : ℝ
  weightBA : ℝ
  tau : ℝ
  theta : ℝ
  beta : ℝ
  chi : ℝ

def Physical (p : Parameters) : Prop :=
  0 < p.mass ∧ 0 ≤ p.stiffness ∧ 0 ≤ p.volume ∧ 0 < p.length ∧
  0 < p.gm ∧ 0 ≤ p.gk ∧ 0 < p.etaM ∧ 0 < p.etaK ∧ 0 ≤ p.damping ∧
  0 < p.scale ∧ 0 < p.tau

structure State where
  q : ℝ
  v : ℝ
  u : ℝ
  w : ℝ
  xA : ℝ
  xB : ℝ
  gAB : ℝ
  gBA : ℝ

def sigmoid (z : ℝ) : ℝ := 1/(1+Real.exp (-z))
def guardRate (tau z g : ℝ) : ℝ := (sigmoid z-g)/tau
def strainSignal (p : Parameters) (s : State) : ℝ := (1/2)*(s.v/p.scale*p.rateReference)^2
def stress (p : Parameters) (s : State) : ℝ := p.gm*(s.q/p.length-s.u-s.w)
def targetAB (p : Parameters) (s : State) : ℝ := p.theta+p.beta*(s.xB-s.xA)+p.chi*strainSignal p s
def targetBA (p : Parameters) (s : State) : ℝ := p.theta+p.beta*(s.xA-s.xB)+p.chi*strainSignal p s

def rhs (p : Parameters) (F : ℝ) (s : State) : State :=
  ⟨s.v,
   (F+(p.gain-p.saturation*s.q^2)*s.v-p.damping*(s.gAB+s.gBA)*s.v
      -p.stiffness*s.q-p.volume/p.length*stress p s)/p.mass,
   (stress p s-p.gk*s.u)/p.etaK, stress p s/p.etaM,
   p.lambda*(p.baselineA-s.xA)+p.weightAB*s.gAB*(s.xB-s.xA),
   p.lambda*(p.baselineB-s.xB)+p.weightBA*s.gBA*(s.xA-s.xB),
   guardRate p.tau (targetAB p s) s.gAB,
   guardRate p.tau (targetBA p s) s.gBA⟩

def energy (p : Parameters) (s : State) : ℝ :=
  p.mass*s.v^2/2+p.stiffness*s.q^2/2+
  p.volume*(stress p s)^2/(2*p.gm)+p.volume*p.gk*s.u^2/2
def energyChain (p : Parameters) (s ds : State) : ℝ :=
  p.mass*s.v*ds.v+p.stiffness*s.q*ds.q+
  p.volume/p.gm*stress p s*(p.gm*(ds.q/p.length-ds.u-ds.w))+
  p.volume*p.gk*s.u*ds.u
def materialLoss (p : Parameters) (s : State) : ℝ :=
  p.volume*((stress p s-p.gk*s.u)^2/p.etaK+(stress p s)^2/p.etaM)
def guardLoss (p : Parameters) (s : State) : ℝ := p.damping*(s.gAB+s.gBA)*s.v^2
def energyBalance (p : Parameters) (F : ℝ) (s : State) : ℝ :=
  (p.gain-p.saturation*s.q^2)*s.v^2+F*s.v-materialLoss p s-guardLoss p s

-- The primary directional protocol, unchanged exact decimal values.
def protocol : Parameters :=
  ⟨1/5,7/10,1/10000000,1/10,28000,19000,5200000,900000,
   3/100,3000000,1/100,1/10000,1,1,-11/20,7/20,1,1,3/5,-2/5,2,1/2⟩

def IntegralSolution (F : ℝ → ℝ → ℝ) (a b x0 : ℝ) (x : ℝ → ℝ) : Prop :=
  ContinuousOn x (Icc a b) ∧ x a = x0 ∧
  IntervalIntegrable (fun t => F t (x t)) volume a b ∧
  ∀ t ∈ Icc a b, x t = x0+∫ s in a..t, F s (x s)

-- Shared-control guard sum and participant difference, at unit weights.
def differenceRate (p : Parameters) (d G : ℝ) : ℝ := p.lambda*((p.baselineB-p.baselineA)-d)-G*d
def sharedGuardRate (p : Parameters) (s : State) (g : ℝ) : ℝ :=
  ((sigmoid (targetAB p s)+sigmoid (targetBA p s))/2-g)/p.tau
def displayShear (q length x y : ℝ) : ℝ × ℝ := (x+150*(q/length)*y,y)

-- Separate memory-continuity extension from memory-METHODS.md. It is NOT
-- added to rhs above: that source explicitly excludes the guard damper.
def cappedSource (cap k A : ℝ) : ℝ := cap*Real.tanh (k*A/cap)
def pairExchange (k sign height amplitude own partner : ℝ) : ℝ :=
  k*sign*(max height 0)^2*amplitude*Real.tanh ((partner-own)/amplitude)
def exactOff (excess epsilon : ℝ) : ℝ :=
  if excess ≤ 0 then 0 else excess*Real.exp (-((epsilon/excess)^2))
def gradientForce (coefficient gradient threshold epsilon : ℝ) : ℝ :=
  -coefficient*exactOff (|gradient|-threshold) epsilon

end
end ActiveHug
