import Volterra
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
