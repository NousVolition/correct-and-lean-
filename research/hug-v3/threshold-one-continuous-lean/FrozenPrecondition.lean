import FrozenODE
import Mathlib.Analysis.Calculus.Deriv.Mul

namespace FrozenPrecondition
open Set

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]

/-- An approximate left inverse is enough to recover a physical error bound.
No exact inverse or externally asserted matrix condition number is used. -/
theorem recover_error (Y Z : E →L[ℝ] E) {η κ : ℝ}
    (hY : ‖Y‖ ≤ η) (hYZ : ‖Y.comp Z - ContinuousLinearMap.id ℝ E‖ ≤ κ)
    (hκ : κ < 1) (d : E) : ‖d‖ ≤ (η / (1-κ)) * ‖Z d‖ := by
  have h1 : ‖Y (Z d)‖ ≤ η * ‖Z d‖ :=
    le_trans (Y.le_opNorm _) (mul_le_mul_of_nonneg_right hY (norm_nonneg _))
  have h2 : ‖Y (Z d) - d‖ ≤ κ * ‖d‖ := by
    have h := (Y.comp Z - ContinuousLinearMap.id ℝ E).le_opNorm d
    exact le_trans h (mul_le_mul_of_nonneg_right hYZ (norm_nonneg _))
  have h3 : ‖d‖ ≤ ‖Y (Z d)‖ + ‖Y (Z d)-d‖ := by
    simpa only [sub_sub_cancel, norm_sub_rev] using norm_sub_le (Y (Z d)) (Y (Z d)-d)
  have h4 : ‖d‖ * (1-κ) ≤ η * ‖Z d‖ := by linarith
  have h := (le_div_iff₀ (sub_pos.mpr hκ)).mpr h4
  simpa only [div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm] using h

/-- A continuous piecewise differentiable candidate and coordinate matrix can
be certified by right derivatives. The boundary inequality is required over
the whole physical tube, so the conclusion does not assume tube membership. -/
theorem tube_from_boundary
    {a b : ℝ} {f : ℝ → E → E} {y q q' : ℝ → E}
    {Y Z Z' : ℝ → E →L[ℝ] E} {η κ R R' : ℝ → ℝ}
    (hy : ContinuousOn y (Icc a b))
    (hy' : ∀ t ∈ Icc a b, HasDerivWithinAt y (f t (y t)) (Icc a b) t)
    (hq : ContinuousOn q (Icc a b))
    (hq' : ∀ t ∈ Ico a b, HasDerivWithinAt q (q' t) (Ici t) t)
    (hZ : ContinuousOn Z (Icc a b))
    (hZ' : ∀ t ∈ Ico a b, HasDerivWithinAt Z (Z' t) (Ici t) t)
    (hY : ∀ t ∈ Icc a b, ‖Y t‖ ≤ η t)
    (hYZ : ∀ t ∈ Icc a b, ‖(Y t).comp (Z t) - ContinuousLinearMap.id ℝ E‖ ≤ κ t)
    (hκ : ∀ t ∈ Icc a b, κ t < 1)
    (hR : ContinuousOn R (Icc a b))
    (hR' : ∀ t ∈ Ico a b, HasDerivWithinAt R (R' t) (Ici t) t)
    (hstart : ‖Z a (y a-q a)‖ ≤ R a)
    (hbound : ∀ t ∈ Ico a b, ∀ v : E,
      ‖v-q t‖ ≤ (η t / (1-κ t)) * R t →
      ‖Z' t (v-q t) + Z t (f t v-q' t)‖ < R' t) :
    ∀ t ∈ Icc a b,
      ‖Z t (y t-q t)‖ ≤ R t ∧ ‖y t-q t‖ ≤ (η t / (1-κ t)) * R t := by
  let e : ℝ → E := fun t => Z t (y t-q t)
  let e' : ℝ → E := fun t => Z' t (y t-q t) + Z t (f t (y t)-q' t)
  have he : ContinuousOn e (Icc a b) := hZ.clm_apply (hy.sub hq)
  have he' : ∀ t ∈ Ico a b, HasDerivWithinAt e (e' t) (Ici t) t := by
    intro t ht
    have hyd := (hy' t (Ico_subset_Icc_self ht)).mono_of_mem_nhdsWithin (Icc_mem_nhdsGE_of_mem ht)
    exact (hZ' t ht).clm_apply (hyd.sub (hq' t ht))
  have hboundary : ∀ t ∈ Ico a b, ‖e t‖ = R t → ‖e' t‖ < R' t := by
    intro t ht hEq
    have hcc := Ico_subset_Icc_self ht
    apply hbound t ht (y t)
    have h := recover_error (Y t) (Z t) (hY t hcc) (hYZ t hcc) (hκ t hcc) (y t-q t)
    simpa only [← hEq, e] using h
  have hglobal := image_norm_le_of_norm_deriv_right_lt_deriv_boundary'
    he he' hstart hR hR' hboundary
  intro t ht
  have h := hglobal ht
  refine ⟨h, ?_⟩
  have hc := recover_error (Y t) (Z t) (hY t ht) (hYZ t ht) (hκ t ht) (y t-q t)
  have hη : 0 ≤ η t := le_trans (norm_nonneg _) (hY t ht)
  exact le_trans hc (mul_le_mul_of_nonneg_left h (div_nonneg hη (sub_pos.mpr (hκ t ht)).le))

end FrozenPrecondition
