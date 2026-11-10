import Mathlib.Analysis.ODE.PicardLindelof
import Mathlib.Tactic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.DerivHyp
import Mathlib.Analysis.Calculus.MeanValue

/-! The two Gaussian weights, their odds and positive-scaling transport. Coordinate zero is the cue in the flat four-coordinate extension. -/

namespace TwoMemory

noncomputable section

/-- A normalized readout of two unit-duration records at +1 and -1, with width 1. -/
def memoryField (s : ℝ) : ℝ :=
  let p := Real.exp (-((s - 1)^2) / 2)
  let n := Real.exp (-((s + 1)^2) / 2)
  (p - n) / (p + n)

end

end TwoMemory

namespace TwoMemoryTransport

noncomputable section

def plusWeight (s : ℝ) : ℝ := Real.exp (-((s - 1)^2) / 2)

def minusWeight (s : ℝ) : ℝ := Real.exp (-((s + 1)^2) / 2)

def odds (s : ℝ) : ℝ := plusWeight s / minusWeight s

def transport (a b : ℝ) : ℝ := Real.exp (2 * (b - a))

def along (a : ℝ) (stops : List ℝ) (b : ℝ) : ℝ :=
  match stops with
  | [] => transport a b
  | next :: rest => along next rest b * transport a next

/-- We use the convention D = d + A for parallel transport. -/
def cueCoefficient : ℝ := -2

abbrev Point := Fin 4 → ℝ

abbrev Potential := Fin 4 → Point → ℝ

def partialDerivative (i : Fin 4) (f : Point → ℝ) (p : Point) : ℝ :=
  deriv (fun u : ℝ => f (Function.update p i u)) (p i)

/-- Coordinate 0 is the cue. This is the pullback of the cue-line connection
    by projection onto that coordinate. -/
def potential (i : Fin 4) (_ : Point) : ℝ := if i = 0 then cueCoefficient else 0

/-- For positive scalings the Lie bracket vanishes, so F_ij = ∂_i A_j - ∂_j A_i. -/
def curvature (A : Potential) (i j : Fin 4) (p : Point) : ℝ :=
  partialDerivative i (A j) p - partialDerivative j (A i) p

/-- In Cartesian Euclidean coordinates the source-free abelian equation is
    ∑_i ∂_i F_ij = 0 for each j. -/
def yangMillsResidual (A : Potential) (j : Fin 4) (p : Point) : ℝ :=
  ∑ i, partialDerivative i (curvature A i j) p

end

end TwoMemoryTransport

namespace TwoMemoryTransport

noncomputable section

theorem readout_from_odds (s : ℝ) :
    TwoMemory.memoryField s = (odds s - 1) / (odds s + 1) := by sorry

theorem odds_eq_exp (s : ℝ) : odds s = Real.exp (2 * s) := by sorry

theorem update_odds (a b : ℝ) : transport a b * odds a = odds b := by sorry

theorem compose_transport (a b c : ℝ) :
    transport b c * transport a b = transport a c := by sorry

theorem endpoints_determine_transport (a b : ℝ) (stops : List ℝ) :
    along a stops b = transport a b := by sorry

theorem closed_route (a : ℝ) (stops : List ℝ) : along a stops a = 1 := by sorry

theorem odds_parallel (s : ℝ) : deriv odds s + cueCoefficient * odds s = 0 := by sorry

theorem flat_curvature (i j : Fin 4) (p : Point) :
    curvature potential i j p = 0 := by sorry

theorem source_free (j : Fin 4) (p : Point) : yangMillsResidual potential j p = 0 := by sorry

theorem unit_speed_fails_memory_at_zero :
    deriv (fun t : ℝ => t) 0 ≠ TwoMemory.memoryField 0 := by sorry

end

end TwoMemoryTransport

open Function intervalIntegral MeasureTheory Metric Set
open scoped Nat NNReal Topology
namespace Volterra
noncomputable section
section Extension

variable {E : Type*} [TopologicalSpace E] {a b : ℝ} (hab : a ≤ b)

abbrev Curve (a b : ℝ) (E : Type*) [TopologicalSpace E] := C(Icc a b, E)

def extend (x : Curve a b E) : ℝ → E := IccExtend hab x

lemma extend_continuous (x : Curve a b E) : Continuous (extend hab x) := by sorry

@[simp] lemma extend_val (x : Curve a b E) (t : Icc a b) : extend hab x t = x t := by sorry

end Extension

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
variable {a b : ℝ} (hab : a ≤ b) (F : ℝ → E → E) (x₀ : E)
variable (hint : ∀ x : ℝ → E, ContinuousOn x (Icc a b) →
  IntervalIntegrable (fun t => F t (x t)) volume a b)

def step (x : Curve a b E) : Curve a b E where
  toFun t := x₀ + ∫ s in a..t, F s (extend hab x s)
  continuous_toFun := by
    have h := continuousOn_primitive_interval' (hint _ (extend_continuous hab x).continuousOn)
      (show a ∈ uIcc a b by exact left_mem_uIcc)
    have hc : ContinuousOn (fun t : ℝ => x₀ + ∫ s in a..t, F s (extend hab x s)) (Icc a b) := by
      rw [uIcc_of_le hab] at h
      exact continuousOn_const.add h
    exact continuousOn_iff_continuous_domRestrict.mp hc

@[simp] lemma step_apply (x : Curve a b E) (t : Icc a b) :
    step hab F x₀ hint x t = x₀ + ∫ s in a..t, F s (extend hab x s) := by sorry

omit [NormedSpace ℝ E] in
include hint in
lemma path_integrable (x : Curve a b E) (t : Icc a b) :
    IntervalIntegrable (fun s => F s (extend hab x s)) volume a t := by sorry

variable {K : ℝ≥0} (hlip : ∀ t ∈ Icc a b, LipschitzWith K (F t))
include hlip

lemma iterate_apply_bound (x y : Curve a b E) (n : ℕ) (t : Icc a b) :
    dist ((step hab F x₀ hint)^[n] x t) ((step hab F x₀ hint)^[n] y t) ≤
      (K * |t.1-a|)^n / n ! * dist x y := by sorry

lemma iterate_bound (x y : Curve a b E) (n : ℕ) :
    dist ((step hab F x₀ hint)^[n] x) ((step hab F x₀ hint)^[n] y) ≤
      (K*(b-a))^n/n !*dist x y := by sorry

end
end Volterra
