import OriginalMemoryModel

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
