import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic

/- Real-number transcription of the two prescribed Hug prototypes at source
commit 7fbc7f28f685c86f824d7587aff91feedf20d3da. Decimal constants are exact
decimal reals here; this does not certify Python floating-point execution.
The later active-Hug/SIMS and Navier--Stokes models are separate. -/
namespace Hug
noncomputable section

def UnitInterval (x : ℝ) : Prop := 0 ≤ x ∧ x ≤ 1
def clip (x : ℝ) : ℝ := min 1 (max 0 x)
def quintic (x : ℝ) : ℝ := x*x*x*(10+x*(-15+6*x))
def smoothstep (x : ℝ) : ℝ := quintic (clip x)

def pressureRatio (difference limit : ℝ) : ℝ := difference / limit
def memoryTau (m p : ℝ) : ℝ := if m < p then 4/5 else 6
def memoryUpdate (m p dt tau : ℝ) : ℝ := p+(m-p)*Real.exp (-dt/tau)
def imprintStep (m p dt : ℝ) : ℝ := memoryUpdate m p dt (memoryTau m p)
def memoryPath (m p tau t : ℝ) : ℝ := memoryUpdate m p t tau

def breathingCoefficient (t : ℝ) : ℝ := 1/25 + 1/50 * Real.sin (2*Real.pi*t/3)
def pressureScale (m t : ℝ) : ℝ := 1+m*breathingCoefficient t
def timedPulse (u : ℝ) : ℝ := 64*u^3*(1-u)^3
def timedScale (u : ℝ) : ℝ := 1+(2/25)*timedPulse u
def squeeze (s : ℝ) : ℝ := 1/s
def stretchPoint (s : ℝ) (x y : ℝ) : ℝ × ℝ := (s*x,squeeze s*y)
def horizontal (bend sx cosine : ℝ) : ℝ := sx*(1-bend+bend*cosine)
def leftArm (bend sx sy cosine sine : ℝ) : ℝ × ℝ :=
  (-horizontal bend sx cosine,sy*sine)
def rightArm (bend sx sy cosine sine : ℝ) : ℝ × ℝ :=
  (horizontal bend sx cosine,sy*sine)
-- The implementation assigns endpoint cosine exactly zero.
def endpointGap (bend sx : ℝ) : ℝ :=
  (rightArm bend sx 1 0 1).1 - (leftArm bend sx 1 0 1).1
def reportedConnected (bend sx : ℝ) : Prop := endpointGap bend sx ≤ 1/(10^12)

def nextOpeningAge (age : Option ℝ) (p dt : ℝ) : Option ℝ :=
  match age with
  | some a => some (a+dt)
  | none => if 1 ≤ p then some dt else none
def openingBend (age : Option ℝ) : ℝ :=
  match age with
  | none => 1
  | some a => 1-smoothstep (a/(4/5))

structure State where
  imprint : ℝ
  elapsed : ℝ
  openingAge : Option ℝ

def step (x : State) (p dt : ℝ) : State :=
  ⟨imprintStep x.imprint p dt, x.elapsed+dt, nextOpeningAge x.openingAge p dt⟩
def StateOK (x : State) : Prop :=
  0 ≤ x.imprint ∧ 0 ≤ x.elapsed ∧ ∀ a, x.openingAge = some a → 0 ≤ a
def initial : State := ⟨0,0,none⟩

end
end Hug
