import FullModel

/- Original corrected-corpus field branch, retained separately and in arbitrary
   finite spatial dimension. No extra guard, Monoxide, mechanical oscillator,
   or replacement force is silently inserted. Source paragraphs 229-265,
   517-519 and 545-550. The sharp, tanh, and exact-off laws are alternatives. -/
namespace OriginalAS
noncomputable section
open MeasureTheory Set
open scoped BigOperators

abbrev Point (n : ℕ) := Fin n → ℝ
abbrev Scalar (n : ℕ) := Point n → ℝ
abbrev Vector (n : ℕ) := Point n → Fin n → ℝ

def coordinatePartial {n : ℕ} (f : Scalar n) (i : Fin n) (x : Point n) : ℝ :=
  deriv (fun a => f (Function.update x i a)) (x i)
def laplacian {n : ℕ} (f : Scalar n) (x : Point n) : ℝ :=
  ∑ i, coordinatePartial (coordinatePartial f i) i x
def advect {n : ℕ} (u : Vector n) (f : Scalar n) (x : Point n) : ℝ :=
  ∑ i, u x i * coordinatePartial f i x
def divergence {n : ℕ} (u : Vector n) (x : Point n) : ℝ :=
  ∑ i, coordinatePartial (fun y => u y i) i x
def gradMagnitude {n : ℕ} (S : Scalar n) (x : Point n) : ℝ :=
  Real.sqrt (∑ i, (coordinatePartial S i x)^2)

structure Parameters where
  rho : ℝ
  mu : ℝ
  mu0 : ℝ
  sigma : ℝ
  diffusion : ℝ
  gamma : ℝ
  kappa : ℝ
  baseline : ℝ
  threshold : ℝ

def Admissible (p : Parameters) : Prop :=
  0 < p.rho ∧ 0 < p.mu ∧ 0 < p.mu0 ∧ 0 ≤ p.sigma ∧
    0 ≤ p.diffusion ∧ 0 ≤ p.threshold

def memory (p : Parameters) (U : ℝ → ℝ) (t : ℝ) : ℝ :=
  ∫ s in (0 : ℝ)..t, p.gamma * (U s-p.baseline)
def sourceRate (p : Parameters) (U : ℝ → ℝ) (t : ℝ) : ℝ :=
  p.kappa * memory p U t

def sharp (q : ℝ) : ℝ := max q 0
def tanhResponse (epsilon q : ℝ) : ℝ := q*(1+Real.tanh (q/epsilon))/2
def exactOffResponse (epsilon q : ℝ) : ℝ :=
  if q ≤ 0 then 0 else q*Real.exp (-((epsilon/q)^2))

-- The original, unregularized magnitude is used. The optional g_delta law
-- has NOT been substituted to make a smoothness argument easier.
def excess {n : ℕ} (p : Parameters) (S : Scalar n) (x : Point n) : ℝ :=
  gradMagnitude S x-p.threshold
def force {n : ℕ} (p : Parameters) (response : ℝ → ℝ)
    (direction : Fin n) (S : Scalar n) (x : Point n) (i : Fin n) : ℝ :=
  -(p.sigma/p.rho)*response (excess p S x)*(if i=direction then 1 else 0)
def stress {n : ℕ} (p : Parameters) (u : Vector n)
    (x : Point n) (i j : Fin n) : ℝ :=
  p.mu0*(coordinatePartial (fun y => u y i) j x+coordinatePartial (fun y => u y j) i x)

structure Fields (n : ℕ) where
  u : Vector n
  S : Scalar n

def rates {n : ℕ} (p : Parameters) (response : ℝ → ℝ)
    (direction : Fin n) (U : ℝ → ℝ) (K : Scalar n) (x0 : Point n)
    (t : ℝ) (z : Fields n) (pressure : Scalar n) : Fields n :=
  ⟨(fun x i => -advect z.u (fun y => z.u y i) x - coordinatePartial pressure i x +
       (p.mu/p.rho)*laplacian (fun y => z.u y i) x+force p response direction z.S x i),
   (fun x => -advect z.u z.S x+p.diffusion*laplacian z.S x+
       K (x-x0)*sourceRate p U t)⟩

def FullDifferentialAt {n : ℕ} (p : Parameters) (response : ℝ → ℝ)
    (direction : Fin n) (U : ℝ → ℝ) (K : Scalar n) (x0 : Point n)
    (domain : Set (Point n)) (z : ℝ → Fields n) (pressure : ℝ → Scalar n)
    (t : ℝ) : Prop :=
  ∀ x ∈ domain,
    divergence (z t).u x=0 ∧
    HasDerivAt (fun s => (z s).S x)
      ((rates p response direction U K x0 t (z t) (pressure t)).S x) t ∧
    ∀ i, HasDerivAt (fun s => (z s).u x i)
      ((rates p response direction U K x0 t (z t) (pressure t)).u x i) t

-- Initial/boundary data and the domain have to be supplied, not guessed.
-- Kernel normalization, smoothness and positive width are analytic input
-- obligations; the singular Dirac alternative needs a weak formulation.
def FullProblem {n : ℕ} (p : Parameters) (response : ℝ → ℝ)
    (direction : Fin n) (U : ℝ → ℝ) (K : Scalar n) (x0 : Point n)
    (domain : Set (Point n)) (initial : Fields n) (T : ℝ)
    (boundaryCondition : (ℝ → Fields n) → (ℝ → Scalar n) → Prop)
    (z : ℝ → Fields n) (pressure : ℝ → Scalar n) : Prop :=
  Admissible p ∧ z 0=initial ∧ boundaryCondition z pressure ∧
    ∀ t ∈ Ioo 0 T, FullDifferentialAt p response direction U K x0 domain z pressure t

end
end OriginalAS
