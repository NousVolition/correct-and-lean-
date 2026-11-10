import TwoMemory

/-!
Compare the two original Gaussian weights at different cue values. The comparison
acts by positive real rescalings on their ratio. The last section tests the
resulting abelian connection in flat Euclidean coordinates. The optional extra
coordinates are passive and do not occur in the memory model.

To repeat the check in the original SIMS suite, put this file beside
`TwoMemory.lean` in the prepared `lean` directory and run these commands.

    lake build Volterra
    lake env lean -o .lake/build/lib/lean/TwoMemory.olean TwoMemory.lean
    lake env lean TwoMemoryTransport.lean
-/

namespace TwoMemoryTransport
noncomputable section

def plusWeight (s : ℝ) : ℝ := Real.exp (-((s - 1)^2) / 2)
def minusWeight (s : ℝ) : ℝ := Real.exp (-((s + 1)^2) / 2)
def odds (s : ℝ) : ℝ := plusWeight s / minusWeight s

/-- The ratio retains all the information used by the original memory drift. -/
theorem readout_from_odds (s : ℝ) :
    TwoMemory.memoryField s = (odds s - 1) / (odds s + 1) := by
  have hn : minusWeight s ≠ 0 := Real.exp_ne_zero _
  change (plusWeight s - minusWeight s) / (plusWeight s + minusWeight s) = _
  rw [show odds s - 1 = (plusWeight s - minusWeight s) / minusWeight s by
        rw [odds, sub_div, div_self hn],
      show odds s + 1 = (plusWeight s + minusWeight s) / minusWeight s by
        rw [odds, add_div, div_self hn], div_div_div_cancel_right₀ hn]

theorem odds_eq_exp (s : ℝ) : odds s = Real.exp (2 * s) := by
  unfold odds plusWeight minusWeight
  rw [← Real.exp_sub]
  congr 1
  ring

def transport (a b : ℝ) : ℝ := Real.exp (2 * (b - a))

theorem update_odds (a b : ℝ) : transport a b * odds a = odds b := by
  simp only [transport, odds_eq_exp, ← Real.exp_add]
  congr 1
  ring

theorem compose_transport (a b c : ℝ) :
    transport b c * transport a b = transport a c := by
  unfold transport
  rw [← Real.exp_add]
  congr 1
  ring

def along (a : ℝ) (stops : List ℝ) (b : ℝ) : ℝ :=
  match stops with
  | [] => transport a b
  | next :: rest => along next rest b * transport a next

theorem endpoints_determine_transport (a b : ℝ) (stops : List ℝ) :
    along a stops b = transport a b := by
  induction stops generalizing a with
  | nil => rfl
  | cons next rest ih => rw [along, ih, compose_transport]

theorem closed_route (a : ℝ) (stops : List ℝ) : along a stops a = 1 := by
  rw [endpoints_determine_transport]
  simp [transport]

/-- We use the convention D = d + A for parallel transport. -/
def cueCoefficient : ℝ := -2

theorem odds_parallel (s : ℝ) : deriv odds s + cueCoefficient * odds s = 0 := by
  have hlin : HasDerivAt (fun u : ℝ => 2 * u) 2 s := by
    simpa using (hasDerivAt_id s).const_mul 2
  have he : HasDerivAt odds (Real.exp (2 * s) * 2) s := by
    rw [show odds = (fun u : ℝ => Real.exp (2 * u)) from funext odds_eq_exp]
    exact (Real.hasDerivAt_exp _).comp s hlin
  rw [he.deriv, odds_eq_exp, cueCoefficient]
  ring

section EuclideanExtension

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

theorem flat_curvature (i j : Fin 4) (p : Point) :
    curvature potential i j p = 0 := by
  simp [curvature, partialDerivative, potential]

theorem source_free (j : Fin 4) (p : Point) : yangMillsResidual potential j p = 0 := by
  simp [yangMillsResidual, partialDerivative, flat_curvature]

end EuclideanExtension

/-- Transport works along any cue path. Unit-speed motion already disagrees
    with the original memory drift at 0. -/
theorem unit_speed_fails_memory_at_zero :
    deriv (fun t : ℝ => t) 0 ≠ TwoMemory.memoryField 0 := by
  simp [TwoMemory.recall_eq_tanh]

#print axioms readout_from_odds
#print axioms odds_eq_exp
#print axioms update_odds
#print axioms compose_transport
#print axioms endpoints_determine_transport
#print axioms closed_route
#print axioms odds_parallel
#print axioms flat_curvature
#print axioms source_free
#print axioms unit_speed_fails_memory_at_zero

end
end TwoMemoryTransport
