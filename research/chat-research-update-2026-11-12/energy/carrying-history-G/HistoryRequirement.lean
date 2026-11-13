import Mathlib

/-! Necessary trace of a balancing configuration/history energy on a trajectory.
No constitutive energy, physical reservoir, or PDE solution is assumed to have
been identified by this result. R is the residual AFTER existing transfers and
the activation-height candidate have been included. P is an optional added
context potential, with conversion scale. -/
set_option autoImplicit false
noncomputable section
namespace HistoryRequirement

def accumulated (R : ℝ → ℝ) (t : ℝ) : ℝ := ∫ s in (0 : ℝ)..t, R s

theorem accumulated_rate (R : ℝ → ℝ) (hR : Continuous R) (t : ℝ) :
    HasDerivAt (accumulated R) (R t) t := by
  exact intervalIntegral.integral_hasDerivAt_right (hR.intervalIntegrable 0 t)
    hR.aestronglyMeasurable.stronglyMeasurableAtFilter hR.continuousAt

/- Any balancing G has this trace. Finding the trace is not finding an
independently specified constitutive functional of all reachable states. -/
theorem any_balancing_G_has_required_trace (G P Pdot R : ℝ → ℝ)
    (scale t : ℝ) (hR : Continuous R)
    (hP : ∀ s, HasDerivAt P (Pdot s) s)
    (hG : ∀ s, HasDerivAt G (-R s-scale*Pdot s) s) :
    G t-G 0 = -accumulated R t-scale*(P t-P 0) := by
  have hd : ∀ s, HasDerivAt
      (fun r => G r+accumulated R r+scale*P r) 0 s := by
    intro s
    convert ((hG s).fun_add (accumulated_rate R hR s)).fun_add
      ((hP s).const_mul scale) using 1 <;> first | rfl | ring
  have hc := is_const_of_deriv_eq_zero (fun s => (hd s).differentiableAt)
    (fun s => (hd s).deriv) t 0
  simp only [accumulated, intervalIntegral.integral_same] at hc
  dsimp [accumulated]
  linarith

/- Keeping a nonnegative-rise context potential cannot reduce the required
debit from the as-yet-unidentified G. The units conversion is explicit. -/
theorem adding_increasing_potential_increases_debit
    (change demand scale P0 P1 : ℝ) (hs : 0 ≤ scale) (hP : P0 ≤ P1)
    (hbalance : change = -demand-scale*(P1-P0)) : change ≤ -demand := by
  have hn := mul_nonneg hs (sub_nonneg.mpr hP)
  linarith

end HistoryRequirement
