import SIMSLatentReadout
import YangMillsCueTest
import Tick41SavedWrite
import Tick41SavedReturns

/-!
Two applications of the same ambiguity theorem, with their observations explicit.
The tick-41 instance is about imported finite records. The Yang–Mills instance is
about smooth candidate abelian potentials in the saved Euclidean convention.
Neither instance identifies the physical mechanisms of the two systems.
-/
set_option autoImplicit false
set_option maxRecDepth 8192
set_option maxHeartbeats 2000000

namespace AmbiguityInstances

namespace Tick41Write
open Tick41SavedWrite

theorem same_water_observation : observe .before = observe .after := by rfl

theorem different_record_presence :
    eventTwoPresent .before = false ∧ eventTwoPresent .after = true := by decide

theorem no_exact_water_reader :
    ¬ ∃ reader : (String × String) → Bool,
      ∀ s : Side, reader (observe s) = eventTwoPresent s := by
  apply SIMSLatentReadout.no_exact_reader_of_ambiguous_observation
    observe eventTwoPresent .before .after same_water_observation
  rw [different_record_presence.1, different_record_presence.2]
  decide

def withRecord (s : Side) : (String × String) × List Nat :=
  (observe s, (snapshot s).eventIds)

/-- An observation which also reads the decoded records can answer this question. -/
theorem exact_reader_with_record :
    ∃ reader : ((String × String) × List Nat) → Bool,
      ∀ s : Side, reader (withRecord s) = eventTwoPresent s := by
  exact ⟨fun o => o.2.contains 2, fun _ => rfl⟩

end Tick41Write

namespace YangMills
open TwoMemoryTransport YangMillsCueTest
noncomputable section

/-- Candidate fields are smooth, but are not assumed to satisfy the field equation. -/
abbrev SmoothField := {A : Potential // ∀ i, ContDiff ℝ ⊤ (A i)}
abbrev Slice := {p : Point // p 1 = 0}

def original : SmoothField := ⟨potential, by
  intro i
  unfold potential
  fun_prop⟩

def modified : SmoothField := ⟨transversePotential, by
  intro i
  by_cases h : i = 2
  · subst i
    change ContDiff ℝ ⊤ (fun p : Point => (p 1)^2)
    fun_prop
  · have same : transversePotential i = potential i := by
      funext p
      simp [transversePotential, h]
    rw [same]
    exact original.2 i⟩

abbrev Observation := (Fin 4 → Slice → ℝ) × (Fin 4 → Fin 4 → Slice → ℝ)

/-- All potential and curvature components on the whole x₁=0 slice. -/
def observe (A : SmoothField) : Observation :=
  (fun i p => A.1 i p.1, fun i j p => curvature A.1 i j p.1)

def origin : Point := fun _ => 0

/-- The four source-free abelian residual components vanish at the cue. -/
def sourceFreeAtCue (A : SmoothField) : Bool := by
  classical
  exact decide (∀ j, yangMillsResidual A.1 j origin = 0)

theorem same_slice_observation : observe original = observe modified := by
  apply Prod.ext
  · funext i p
    exact (agree_on_slice p.1 p.2 i).symm
  · funext i j p
    change curvature potential i j p.1 = curvature transversePotential i j p.1
    rw [flat_curvature]
    have square (x : ℝ) : deriv (fun z : ℝ => z^2) x = 2*x := by simp
    have hp : p.1 1 = 0 := p.2
    fin_cases i <;> fin_cases j <;>
      simp [curvature, partialDerivative, transversePotential, potential,
        Function.update, square, hp]

theorem original_satisfies : sourceFreeAtCue original = true := by
  simp [sourceFreeAtCue, original, source_free]

theorem modified_does_not_satisfy : sourceFreeAtCue modified = false := by
  have h : ¬ (∀ j, yangMillsResidual transversePotential j origin = 0) := by
    intro all
    have bad := all 2
    rw [transverse_residual] at bad
    norm_num at bad
  simp [sourceFreeAtCue, modified, h]

theorem residuals_are_zero_and_two :
    yangMillsResidual original.1 2 origin = 0 ∧
      yangMillsResidual modified.1 2 origin = 2 := by
  exact ⟨source_free _ _, transverse_residual _⟩

theorem no_exact_slice_reader :
    ¬ ∃ reader : Observation → Bool,
      ∀ A : SmoothField, reader (observe A) = sourceFreeAtCue A := by
  apply SIMSLatentReadout.no_exact_reader_of_ambiguous_observation
    observe sourceFreeAtCue original modified same_slice_observation
  rw [original_satisfies, modified_does_not_satisfy]
  decide

def offSlice : Point := fun i => if i = 1 then 1 else 0

/-- The witnesses become distinguishable when this transverse reading is added. -/
theorem off_slice_curvature_distinguishes :
    curvature original.1 1 2 offSlice = 0 ∧
      curvature modified.1 1 2 offSlice = 2 := by
  constructor
  · exact flat_curvature _ _ _
  · change curvature transversePotential 1 2 offSlice = 2
    rw [transverse_curvature_column]
    norm_num [offSlice]

end
end YangMills

namespace Tick41Geometry
open Tick41SavedReturns

theorem all_scales_positive : saved.all (fun r => decide (0 < r.scale)) = true := by
  decide +kernel

theorem all_saved_x_returns_open : saved.all (fun r => !xCloses r) = true := by
  decide +kernel

theorem saved_x_does_not_close (r : SavedReturn) : xCloses r.1 = false := by
  have h := (List.all_eq_true.mp all_saved_x_returns_open) r.1 r.2
  simpa using h

theorem integer_return_would_close (r : Return) (n : Int)
    (h : r.endX = r.startX + n * r.scale) : xCloses r = true := by
  simp [xCloses, h]

theorem no_saved_integer_periodic_return (r : SavedReturn) (n : Int) :
    r.1.endX ≠ r.1.startX + n * r.1.scale := by
  intro h
  have closed := integer_return_would_close r.1 n h
  rw [saved_x_does_not_close r] at closed
  contradiction

/-- This finite collection cannot supply the opposite-property witnesses. -/
theorem no_opposite_saved_closure_properties :
    ¬ ∃ a b : SavedReturn, xCloses a.1 ≠ xCloses b.1 := by
  rintro ⟨a, b, h⟩
  exact h ((saved_x_does_not_close a).trans (saved_x_does_not_close b).symm)

/-- On this finite collection, constant 'open' is correct for any observation. -/
theorem exact_reader_on_saved_returns {O : Type} (observe : SavedReturn → O) :
    ∃ reader : O → Bool, ∀ r : SavedReturn, reader (observe r) = xCloses r.1 := by
  exact ⟨fun _ => false, fun r => (saved_x_does_not_close r).symm⟩

end Tick41Geometry

#print axioms Tick41Write.same_water_observation
#print axioms Tick41Write.different_record_presence
#print axioms Tick41Write.no_exact_water_reader
#print axioms Tick41Write.exact_reader_with_record
#print axioms YangMills.same_slice_observation
#print axioms YangMills.original_satisfies
#print axioms YangMills.modified_does_not_satisfy
#print axioms YangMills.residuals_are_zero_and_two
#print axioms YangMills.no_exact_slice_reader
#print axioms YangMills.off_slice_curvature_distinguishes
#print axioms Tick41Geometry.all_scales_positive
#print axioms Tick41Geometry.all_saved_x_returns_open
#print axioms Tick41Geometry.saved_x_does_not_close
#print axioms Tick41Geometry.integer_return_would_close
#print axioms Tick41Geometry.no_saved_integer_periodic_return
#print axioms Tick41Geometry.no_opposite_saved_closure_properties
#print axioms Tick41Geometry.exact_reader_on_saved_returns

end AmbiguityInstances
