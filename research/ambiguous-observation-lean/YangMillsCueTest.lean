import TwoMemoryTransport

/-!
What can the two-memory cue determine about a four-dimensional connection?
The saved positive-scaling connection has coefficient -2 along the cue. Here a
second abelian potential agrees with it on the cue line, even in every component.
Its transverse Yang–Mills residual is 2. This is an identifiability test for the
same cue data. The added transverse coefficient is an explicit test choice.
-/
namespace YangMillsCueTest
open TwoMemoryTransport
noncomputable section

/-- Coordinate 0 is the original cue. Coordinates 1 and 2 supply a transverse plane. -/
def transversePotential (i : Fin 4) (p : Point) : ℝ :=
  if i = 2 then (p 1)^2 else potential i p

theorem agree_on_slice (p : Point) (h : p 1 = 0) (i : Fin 4) :
    transversePotential i p = potential i p := by
  by_cases hi : i = 2
  · subst i
    simp [transversePotential, potential, h]
  · simp [transversePotential, hi]

theorem transverse_curvature_column (i : Fin 4) (p : Point) :
    curvature transversePotential i 2 p = if i = 1 then 2 * p 1 else 0 := by
  have square (x : ℝ) : deriv (fun z : ℝ => z^2) x = 2 * x := by
    simp
  fin_cases i <;> simp [curvature, partialDerivative, transversePotential, potential,
    Function.update, square]

theorem transverse_residual (p : Point) :
    yangMillsResidual transversePotential 2 p = 2 := by
  have column (i : Fin 4) : curvature transversePotential i 2 =
      fun x => if i = 1 then 2 * x 1 else 0 := by
    funext x
    exact transverse_curvature_column i x
  have linear (x : ℝ) : deriv (fun z : ℝ => 2 * z) x = 2 := by
    simp
  simp [yangMillsResidual, partialDerivative, column, Fin.sum_univ_succ, Function.update, linear]

/-- Paired controls on the same slice using the original definition of the residual. -/
theorem same_data_different_field_equation (p : Point) (h : p 1 = 0) :
    (∀ i, transversePotential i p = potential i p) ∧
    yangMillsResidual potential 2 p = 0 ∧ yangMillsResidual transversePotential 2 p ≠ 0 := by
  exact ⟨agree_on_slice p h, source_free 2 p, by rw [transverse_residual]; norm_num⟩

section Loops
variable {X G : Type*} [Group G]

/-- Ordered traversal is a→b→c→d→a. The rightmost edge acts first. -/
def squareLoop (U : X → X → G) (a b c d : X) : G :=
  U d a * U c d * U b c * U a b

theorem endpoint_frames_cancel (g : X → G) (a b c d : X) :
    squareLoop (fun x y => g y * (g x)⁻¹) a b c d = 1 := by
  unfold squareLoop
  group

theorem local_frames_conjugate_loop (U : X → X → G) (g : X → G) (a b c d : X) :
    squareLoop (fun x y => g y * U x y * (g x)⁻¹) a b c d =
      g a * squareLoop U a b c d * (g a)⁻¹ := by
  unfold squareLoop
  group
end Loops

#print axioms same_data_different_field_equation
#print axioms endpoint_frames_cancel
#print axioms local_frames_conjugate_loop
end
end YangMillsCueTest
