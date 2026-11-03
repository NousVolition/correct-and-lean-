import ASOpenClaims
import Mathlib.MeasureTheory.Measure.Typeclasses.NullSingletonClass
import Mathlib.Tactic

open Set MeasureTheory
open scoped NNReal
namespace SocialAS.Open

theorem PiecewiseContinuousBounded.integrableOn {f : ℝ → ℝ} {a b : ℝ}
    (h : PiecewiseContinuousBounded f a b) : IntegrableOn f (Icc a b) := by
  obtain ⟨cuts,hcont,M,hbound⟩ := h
  have heq : (Icc a b \ (cuts : Set ℝ)) =ᵐ[volume] Icc a b :=
    sdiff_null_ae_eq_self (cuts.measure_zero volume)
  have hm := hcont.aestronglyMeasurable (μ := volume) (measurableSet_Icc.diff cuts.measurableSet)
  have hmeasure : volume.restrict (Icc a b \ (cuts : Set ℝ)) = volume.restrict (Icc a b) :=
    Measure.restrict_congr_set heq
  have hm' : AEStronglyMeasurable f (volume.restrict (Icc a b)) := hmeasure ▸ hm
  refine ⟨hm', HasFiniteIntegral.of_bounded (C := M) ?_⟩
  filter_upwards [ae_restrict_mem measurableSet_Icc] with t ht
  simpa only [Real.norm_eq_abs] using hbound t ht

theorem PiecewiseContinuousBounded.intervalIntegrable {f : ℝ → ℝ} {a b : ℝ}
    (hab : a ≤ b) (h : PiecewiseContinuousBounded f a b) :
    IntervalIntegrable f volume a b := by
  apply IntegrableOn.intervalIntegrable
  simpa only [uIcc_of_le hab] using h.integrableOn

theorem PiecewiseContinuousBounded.bound {f : ℝ → ℝ} {a b : ℝ}
    (h : PiecewiseContinuousBounded f a b) :
    ∃ M : ℝ≥0, ∀ t ∈ Icc a b, |f t| ≤ M := by
  obtain ⟨cuts,hcont,M,hbound⟩ := h
  exact ⟨⟨max M 0,le_max_right _ _⟩,fun t ht => (hbound t ht).trans (le_max_left _ _)⟩

end SocialAS.Open
