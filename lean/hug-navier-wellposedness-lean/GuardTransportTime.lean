import GuardTransport
import GuardTransportTimeDefs
import Mathlib.Algebra.Field.Periodic
import Mathlib.Analysis.Calculus.Deriv.Shift
import Mathlib.Topology.Order.Compact

namespace HugNavierSingle.GuardTransport
noncomputable section
open Set MeasureTheory

private theorem periodic_partialX {g : ScalarField} (hp : Periodic g) :
    Periodic (partialX g) := by
  intro r
  constructor
  · change deriv (fun x => g (x, r.2)) (r.1 + 2 * Real.pi) =
      deriv (fun x => g (x, r.2)) r.1
    rw [← deriv_comp_add_const]
    congr 1
    funext x
    exact (hp (x, r.2)).1
  · change deriv (fun x => g (x, r.2 + 2 * Real.pi)) r.1 =
      deriv (fun x => g (x, r.2)) r.1
    congr 1
    funext x
    exact (hp (x, r.2)).2

private theorem periodic_partialY {g : ScalarField} (hp : Periodic g) :
    Periodic (partialY g) := by
  intro r
  constructor
  · change deriv (fun y => g (r.1 + 2 * Real.pi, y)) r.2 =
      deriv (fun y => g (r.1, y)) r.2
    congr 1
    funext y
    exact (hp (r.1, y)).1
  · change deriv (fun y => g (r.1, y)) (r.2 + 2 * Real.pi) =
      deriv (fun y => g (r.1, y)) r.2
    rw [← deriv_comp_add_const]
    congr 1
    funext y
    exact (hp (r.1, y)).2

private theorem periodic_representative {f : ScalarField} (hp : Periodic f) (r : Point) :
    ∃ q ∈ closedCell, f r = f q := by
  have hx : Function.Periodic (fun x => f (x, r.2)) (2 * Real.pi) :=
    fun x => (hp (x, r.2)).1
  obtain ⟨x, hxmem, heqx⟩ := hx.exists_mem_Ico₀ (by positivity) r.1
  have hy : Function.Periodic (fun y => f (x, y)) (2 * Real.pi) :=
    fun y => (hp (x, y)).2
  obtain ⟨y, hymem, heqy⟩ := hy.exists_mem_Ico₀ (by positivity) r.2
  exact ⟨(x, y), ⟨⟨hxmem.1, hxmem.2.le⟩, ⟨hymem.1, hymem.2.le⟩⟩, heqx.trans heqy⟩

/-- Joint continuity of both spatial derivatives on the compact time-cell,
plus spatial periodicity, produces ONE gradient bound for the full interval.
The constant is concluded, not assumed. No solution existence is asserted. -/
theorem uniform_gradient_bound (g : ℝ → ScalarField) (a b : ℝ)
    (gx : ContinuousOn (fun p : ℝ × Point => partialX (g p.1) p.2) (timeCell a b))
    (gy : ContinuousOn (fun p : ℝ × Point => partialY (g p.1) p.2) (timeCell a b))
    (gp : ∀ t ∈ Icc a b, Periodic (g t)) :
    ∃ M : ℝ, 0 ≤ M ∧ ∀ t ∈ Icc a b, ∀ r,
      (partialX (g t) r)^2 + (partialY (g t) r)^2 ≤ M^2 := by
  let F : (ℝ × Point) → ℝ := fun p =>
    (partialX (g p.1) p.2)^2 + (partialY (g p.1) p.2)^2
  have hc : IsCompact (timeCell a b) :=
    isCompact_Icc.prod (isCompact_Icc.prod isCompact_Icc)
  obtain ⟨B, hB⟩ := hc.bddAbove_image ((gx.pow 2).add (gy.pow 2))
  refine ⟨|B| + 1, by positivity, ?_⟩
  intro t ht r
  have hp : Periodic (fun r => (partialX (g t) r)^2 + (partialY (g t) r)^2) := by
    intro q
    obtain ⟨hx1, hx2⟩ := periodic_partialX (gp t ht) q
    obtain ⟨hy1, hy2⟩ := periodic_partialY (gp t ht) q
    constructor <;> simp only [hx1, hx2, hy1, hy2]
  obtain ⟨q, hq, heq⟩ := periodic_representative hp r
  have bound : F (t, q) ≤ B := hB (mem_image_of_mem F ⟨ht, hq⟩)
  change (partialX (g t) q)^2 + (partialY (g t) q)^2 ≤ B at bound
  rw [heq]
  nlinarith [le_abs_self B, abs_nonneg B, sq_nonneg (|B|)]

/-- Connect the uniform gradient bound directly to the existing whole-cell
transport estimate, at EVERY time in the same interval with the SAME constant. -/
theorem integrated_residual_bound_uniform (z w : ℝ → Fields)
    (g h : ℝ → ScalarField) (a b : ℝ)
    (gx : ContinuousOn (fun p : ℝ × Point => partialX (g p.1) p.2) (timeCell a b))
    (gy : ContinuousOn (fun p : ℝ × Point => partialY (g p.1) p.2) (timeCell a b))
    (gp : ∀ t ∈ Icc a b, Periodic (g t))
    (zX : ∀ t ∈ Icc a b, Continuous (z t).ux)
    (zY : ∀ t ∈ Icc a b, Continuous (z t).uy)
    (wX : ∀ t ∈ Icc a b, Continuous (w t).ux)
    (wY : ∀ t ∈ Icc a b, Continuous (w t).uy)
    (hg : ∀ t ∈ Icc a b, ContDiff ℝ 1 (g t))
    (hh : ∀ t ∈ Icc a b, Continuous (h t)) :
    ∃ M : ℝ, 0 ≤ M ∧ ∀ t ∈ Icc a b,
      |∫ r, h t r * residual (velocityAt (z t) r) (w t) (g t) r ∂cellMeasure| ≤
        ((∫ r, ((z t).ux r-(w t).ux r)^2 + ((z t).uy r-(w t).uy r)^2 ∂cellMeasure) +
          M^2 * ∫ r, (h t r)^2 ∂cellMeasure) / 2 := by
  obtain ⟨M, hM, bound⟩ := uniform_gradient_bound g a b gx gy gp
  refine ⟨M, hM, ?_⟩
  intro t ht
  exact integrated_residual_bound (z t) (w t) (g t) (h t) M
    (zX t ht) (zY t ht) (wX t ht) (wY t ht) (hg t ht) (hh t ht) (bound t ht)

/-- The two actual Hug-Navier guard residuals have a common constant valid
throughout the interval. This is conditional on two existing FieldProblem
solutions and the stated extra joint regularity of the comparison guards. -/
theorem fieldproblem_guard_transport_bounds (input : FieldInputs) (a b : ℝ)
    (initial : Fields) (z w : ℝ → Fields) (pz pw : ℝ → ScalarField)
    (hz : FieldProblem input a b initial z pz)
    (hw : FieldProblem input a b initial w pw)
    (joint : JointGuardGradientRegularity w a b) :
    ∃ M : ℝ, 0 ≤ M ∧ ∀ t ∈ Icc a b,
      (|∫ r, ((z t).gAB r-(w t).gAB r) *
          residual (velocityAt (z t) r) (w t) (w t).gAB r ∂cellMeasure| ≤
        ((∫ r, ((z t).ux r-(w t).ux r)^2 + ((z t).uy r-(w t).uy r)^2 ∂cellMeasure) +
          M^2 * ∫ r, ((z t).gAB r-(w t).gAB r)^2 ∂cellMeasure) / 2) ∧
      (|∫ r, ((z t).gBA r-(w t).gBA r) *
          residual (velocityAt (z t) r) (w t) (w t).gBA r ∂cellMeasure| ≤
        ((∫ r, ((z t).ux r-(w t).ux r)^2 + ((z t).uy r-(w t).uy r)^2 ∂cellMeasure) +
          M^2 * ∫ r, ((z t).gBA r-(w t).gBA r)^2 ∂cellMeasure) / 2) := by
  rcases joint with ⟨abx, aby, bax, bay⟩
  have periodicAB : ∀ t ∈ Icc a b, Periodic (w t).gAB :=
    fun t ht => (hw.2.2.1 t ht).2.1.2.2.2.2.1
  have periodicBA : ∀ t ∈ Icc a b, Periodic (w t).gBA :=
    fun t ht => (hw.2.2.1 t ht).2.1.2.2.2.2.2.1
  obtain ⟨Mab, hab, boundAB⟩ := uniform_gradient_bound (fun t => (w t).gAB) a b abx aby periodicAB
  obtain ⟨Mba, hba, boundBA⟩ := uniform_gradient_bound (fun t => (w t).gBA) a b bax bay periodicBA
  refine ⟨Mab + Mba, add_nonneg hab hba, ?_⟩
  intro t ht
  rcases (hz.2.2.1 t ht).1 with ⟨zu, zv, za, zb, zab, zba, zp⟩
  rcases (hw.2.2.1 t ht).1 with ⟨wu, wv, wa, wb, wab, wba, wp⟩
  have boundAB' (r : Point) :
      (partialX (w t).gAB r)^2 + (partialY (w t).gAB r)^2 ≤ (Mab + Mba)^2 := by
    have h := boundAB t ht r
    nlinarith [mul_nonneg hab hba, sq_nonneg Mba]
  have boundBA' (r : Point) :
      (partialX (w t).gBA r)^2 + (partialY (w t).gBA r)^2 ≤ (Mab + Mba)^2 := by
    have h := boundBA t ht r
    nlinarith [mul_nonneg hab hba, sq_nonneg Mab]
  constructor
  · exact integrated_residual_bound (z t) (w t) (w t).gAB
      (fun r => (z t).gAB r-(w t).gAB r) (Mab+Mba)
      zu.continuous zv.continuous wu.continuous wv.continuous
      (wab.of_le (by norm_num)) (zab.continuous.sub wab.continuous) boundAB'
  · exact integrated_residual_bound (z t) (w t) (w t).gBA
      (fun r => (z t).gBA r-(w t).gBA r) (Mab+Mba)
      zu.continuous zv.continuous wu.continuous wv.continuous
      (wba.of_le (by norm_num)) (zba.continuous.sub wba.continuous) boundBA'

end
end HugNavierSingle.GuardTransport
