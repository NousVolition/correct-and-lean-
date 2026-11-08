import Mathlib.Tactic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Sqrt

/- Proposed exact-real transcription of the selected main source.
   Definitions are concrete; compiler acceptance is not a proof that this
   transcription is equivalent to every Python/NumPy operation. -/
namespace HugV3.Source
noncomputable section
attribute [local instance] Classical.propDecidable
open scoped BigOperators
open Finset

abbrev Axis := Fin 3
abbrev Actor := Fin 6
abbrev Particle := Fin 384
abbrev Direction := Fin 24
abbrev Cell := Fin 149056
abbrev Grid := Fin 3 → Fin 16
abbrev Vec := Axis → ℝ
abbrev Mat := Axis → Axis → ℝ
abbrev Scalar := Grid → ℝ
abbrev Vector := Grid → Vec

def dot (x y : Vec) : ℝ := ∑ i, x i * y i
def sqnorm (x : Vec) : ℝ := ∑ i, x i ^ 2
def mm (A B : Mat) : Mat := fun i j => ∑ k, A i k * B k j
def eye : Mat := fun i j => if i = j then 1 else 0
def green (F : Mat) : Mat := fun i j => ((∑ k, F k i * F k j) - eye i j) / 2
def strainNorm (F : Mat) : ℝ := Real.sqrt (∑ i, ∑ j, (green F i j)^2)
def symm (L : Mat) : Mat := fun i j => (L i j + L j i) / 2
def cross (u v : Vec) : Vec := ![u 1*v 2-u 2*v 1, u 2*v 0-u 0*v 2, u 0*v 1-u 1*v 0]

structure Geometry where
  X₀ : Particle → Vec
  V : Particle → ℝ
  directions : Direction → Vec
  directionWeights : Direction → ℝ
  attach : Actor → Particle → ℝ

structure State where
  g : Grid → Fin 5 → ℝ
  X : Particle → Vec
  F : Particle → Mat
  m : Particle → Direction → Fin 2 → ℝ
  b : Cell → ℝ
  A : ℝ
  ledger : Fin 4 → ℝ
  writeWork : ℝ
  expression : Actor → Fin 2 → ℝ
  context : Actor → Fin 2 → ℝ
  normCenter : Actor → Fin 2 → ℝ
  logRadius : Actor → Actor → ℝ
  relation : Actor → Actor → Fin 3 → ℝ
  responses : Actor → Actor → Fin 7 → ℝ
  association : Actor → Actor → Fin 3 → ℝ

structure FullState where
  state : State
  starts : Fin 3 → Option (Particle → Mat)

def sameAgent : String := "The same returning student"
def sameIdea : String := "Giving someone space to speak can change what I understand."

def dx : ℝ := 1/16
def dv : ℝ := dx^3
def freq (i : Fin 16) : ℝ := if i.val < 8 then i.val else (i.val : ℝ)-16
def wave (k : Grid) : Vec := fun j => 2*Real.pi*freq (k j)
def phase (k x : Grid) : ℝ := 2*Real.pi*(∑ j, freq (k j)*(x j).val)/16
def cis (x : ℝ) : ℂ := ⟨Real.cos x, Real.sin x⟩
def hat (f : Scalar) (k : Grid) : ℂ := ∑ x, (f x : ℂ)*cis (-phase k x)
def realGrid (f : Grid → ℂ) (x : Grid) : ℝ := ((∑ k, f k*cis (phase k x))/4096).re
def masked (k : Grid) : Prop := ∀ j, |freq (k j)| < (16:ℝ)/3
def filt (f : Scalar) : Scalar := realGrid (fun k => if masked k then hat f k else 0)
def grad (f : Scalar) (x : Grid) (j : Axis) : ℝ :=
  realGrid (fun k => Complex.I * (wave k j : ℂ) * hat f k) x
def divergence (v : Vector) : Scalar := fun x => ∑ j, grad (fun z => v z j) x j
def project (v : Vector) : Vector := fun x j => realGrid (fun k =>
  let h : Axis → ℂ := fun r => if masked k then hat (fun z => v z r) k else 0
  let kd := ∑ r, (wave k r : ℂ)*h r
  let den := if sqnorm (wave k) = 0 then 1 else sqnorm (wave k)
  h j - (wave k j : ℂ)*kd/(den : ℂ)) x

def shifted (x : Grid) (j : Axis) (offset : ℕ) : Grid :=
  fun k => if k = j then ⟨((x k).val+offset)%16, Nat.mod_lt _ (by decide)⟩ else x k
def sincπ (x : ℝ) : ℝ := if x = 0 then 1 else Real.sin (Real.pi*x)/(Real.pi*x)
def faceVelocity (u : Vector) (j : Axis) : Scalar :=
  realGrid (fun k => hat (fun x => u x j) k * cis (wave k j*dx/2) *
    (∏ r, if r = j then (1:ℂ) else (sincπ (wave k r*dx/(2*Real.pi)) : ℂ)))
def contextTransport (C : Scalar) (u : Vector) : Scalar :=
  let flux := fun j x => faceVelocity u j x*(C x+C (shifted x j 1))/2 -
    (1/125:ℝ)*(C (shifted x j 1)-C x)/dx
  fun x => -(∑ j, (flux j x-flux j (shifted x j 15))/dx)

def wrap (z : ℝ) : ℝ := z+1/2-(⌊z+1/2⌋ : ℤ)-1/2
def gaussianImages (z : ℝ) : ℝ :=
  ∑ q : Fin 3, Real.exp (-((wrap z + (q.val:ℝ)-1)/(9/200))^2/2)
def thermal1D (z : ℝ) (i : Fin 16) : ℝ :=
  gaussianImages (z-((i.val:ℝ)/16-1/2)) /
    ∑ r : Fin 16, gaussianImages (z-((r.val:ℝ)/16-1/2))
def mechanical1D (z : ℝ) (i : Fin 16) : ℝ :=
  (∑ f : Fin 16, if |freq f| < (16:ℝ)/3 then
    Real.cos (2*Real.pi*(z-((i.val:ℝ)/16-1/2))*freq f) *
      Real.exp (-(2*Real.pi*freq f*(7/200))^2/2) else 0)/16
def M (X : Particle → Vec) (p : Particle) (x : Grid) : ℝ :=
  ∏ j, mechanical1D (X p j) (x j)
def R (X : Particle → Vec) (p : Particle) (x : Grid) : ℝ :=
  ∏ j, thermal1D (X p j) (x j)

def point (l : Cell) : Particle := ⟨l.val%384, Nat.mod_lt _ (by decide)⟩
def axis (l : Cell) : Axis := ⟨(l.val/384)%3, Nat.mod_lt _ (by decide)⟩
def localWeight (l : Cell) : ℝ :=
  1 / (((149055-(point l).val)/384+1 : ℕ) : ℝ)
def fabricStrain (F : Particle → Mat) (l : Cell) : ℝ :=
  ((∑ i, (F (point l) i (axis l))^2)-1)/2
def fabricEnergy (e b : ℝ) : ℝ :=
  (1/2)*(1/25)*(e-b)^2 + (1/500)/4*((b/(1/50))^2-1)^2
def fabricGradient (e b : ℝ) : ℝ :=
  (1/25)*(b-e)+(1/500)*b/(1/50)^2*((b/(1/50))^2-1)
def fabricRate (e b : ℝ) : ℝ := -(1/20)*fabricGradient e b
def fabricHeat (s : State) (p : Particle) : ℝ :=
  ∑ l : Cell, if point l = p then
    localWeight l*(1/20)*(fabricGradient (fabricStrain s.F l) (s.b l))^2 else 0
def fabricStress (s : State) (p : Particle) : Mat := fun i j =>
  ∑ l : Cell, if point l = p then localWeight l*(1/25)*
    (fabricStrain s.F l-s.b l)*s.F p i (axis l)*s.F p j (axis l) else 0

def sigmoid (x : ℝ) : ℝ := 1/(1+Real.exp (-x))
def tanh (x : ℝ) : ℝ := (Real.exp x-Real.exp (-x))/(Real.exp x+Real.exp (-x))
def pulse (t : ℝ) : ℝ :=
  if 0<t ∧ t<1/2 then (Real.sin (2*Real.pi*t))^2
  else if 1/2≤t ∧ t<1 then -(Real.sin (2*Real.pi*(t-1/2)))^2 else 0
def activation (q : ℝ) : ℝ := if 0<q then q*Real.exp (-((3/250)/q)^2) else 0
def mask (i j : Actor) : ℝ := if i=j then 0 else 1

end
end HugV3.Source
