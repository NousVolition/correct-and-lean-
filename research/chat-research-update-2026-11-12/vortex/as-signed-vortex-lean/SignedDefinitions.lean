import Mathlib.Analysis.SpecialFunctions.Trigonometric.DerivHyp
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Deriv
import Mathlib.Analysis.Calculus.Deriv.Prod
import Mathlib.Analysis.ODE.Gronwall
import Mathlib.MeasureTheory.Integral.IntervalIntegral.FundThmCalculus
import Mathlib.MeasureTheory.Integral.DominatedConvergence
import Mathlib.Tactic

noncomputable section
namespace SignedVortex
open MeasureTheory intervalIntegral

/-- Corpus paragraphs 230 and 262. The coefficient of the vector force is -σ/ρ. -/
def signed (ε q : ℝ) : ℝ := q * (1 + Real.tanh (q / ε)) / 2

/-- One smooth scalar on the unit box, independent of its second and third coordinates. -/
def scalar (l x : ℝ) : ℝ := (l / (2 * Real.pi)) * Real.sin (2 * Real.pi * x)

def gradientShape (x : ℝ) : ℝ := |Real.cos (2 * Real.pi * x)|

def density (ε Γ l x : ℝ) : ℝ := signed ε (l * gradientShape x - Γ)

def mean (ε Γ l : ℝ) : ℝ := ∫ x in (0:ℝ)..1, density ε Γ l x

def boxPush (c ε Γ l : ℝ) : ℝ :=
  ∫ x in (0:ℝ)..1, ∫ _y in (0:ℝ)..1, ∫ _z in (0:ℝ)..1, -c * density ε Γ l x

end SignedVortex
