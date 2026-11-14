import FrozenField
import FrozenODE
import Mathlib.Analysis.InnerProductSpace.PiL2

namespace FrozenEuclidean
open FrozenField Set Metric
open scoped NNReal

/-- The simulation normalizes vorticity with the Euclidean norm. The ambient
`Point` uses the maximum norm for polynomial and matrix error bounds. -/
noncomputable def radius (v : Point) : ℝ := ‖WithLp.toLp 2 v‖

theorem radius_nonneg (v : Point) : 0 ≤ radius v := norm_nonneg _

theorem radius_sq (v : Point) :
    radius v ^ 2 = v 0 ^ 2 + v 1 ^ 2 + v 2 ^ 2 := by
  simpa only [radius, Fin.sum_univ_three,
    PiLp.toLp_apply] using (EuclideanSpace.real_norm_sq_eq (WithLp.toLp 2 v))

theorem coordinate_le_radius (v : Point) (i : Fin 3) : |v i| ≤ radius v := by
  simpa only [Real.norm_eq_abs, radius, PiLp.toLp_apply] using
    PiLp.norm_apply_le (WithLp.toLp 2 v) i

theorem norm_le_radius (v : Point) : ‖v‖ ≤ radius v := by
  apply (pi_norm_le_iff_of_nonneg (radius_nonneg v)).mpr
  intro i
  simpa only [Real.norm_eq_abs] using coordinate_le_radius v i

theorem radius_le_two_norm (v : Point) : radius v ≤ 2 * ‖v‖ := by
  have hc (i : Fin 3) : (v i)^2 ≤ ‖v‖^2 := by
    have h : |v i| ≤ ‖v‖ := by simpa only [Real.norm_eq_abs] using norm_le_pi_norm v i
    simpa only [sq_abs] using pow_le_pow_left₀ (abs_nonneg (v i)) h 2
  nlinarith [radius_sq v, hc 0, hc 1, hc 2, radius_nonneg v, norm_nonneg v]

theorem radius_difference (v w : Point) : |radius v - radius w| ≤ 2 * ‖v-w‖ := by
  apply le_trans (abs_norm_sub_norm_le (WithLp.toLp 2 v) (WithLp.toLp 2 w))
  simpa only [radius, WithLp.toLp_sub] using radius_le_two_norm (v-w)

noncomputable def clip (μ : ℝ) (v : Point) : Point := (max μ (radius v))⁻¹ • v

theorem clip_norm_le_one {μ : ℝ} (hμ : 0 < μ) (v : Point) : ‖clip μ v‖ ≤ 1 := by
  have hm : 0 < max μ (radius v) := lt_of_lt_of_le hμ (le_max_left _ _)
  rw [clip, norm_smul, Real.norm_eq_abs, abs_inv, abs_of_pos hm]
  have h := (div_le_one hm).mpr (le_trans (norm_le_radius v) (le_max_right _ _))
  simpa only [div_eq_mul_inv, mul_comm] using h

theorem clip_eq_normalized {μ : ℝ} {v : Point} (h : μ ≤ radius v) :
    clip μ v = (radius v)⁻¹ • v := by rw [clip, max_eq_right h]

theorem clip_difference {μ : ℝ} (hμ : 0 < μ) (v w : Point) :
    ‖clip μ v - clip μ w‖ ≤ (3 / μ) * ‖v-w‖ := by
  let r := max μ (radius v)
  let s := max μ (radius w)
  have hr : 0 < r := lt_of_lt_of_le hμ (le_max_left _ _)
  have hs : 0 < s := lt_of_lt_of_le hμ (le_max_left _ _)
  have hgap : |s-r| ≤ 2 * ‖v-w‖ := by
    have h := abs_max_sub_max_le_abs (radius w) (radius v) μ
    simp only [max_comm] at h
    exact le_trans h (by simpa only [norm_sub_rev] using radius_difference w v)
  have hw := clip_norm_le_one hμ w
  have heq : clip μ v - clip μ w = r⁻¹ • (v-w) + ((s-r)/r) • clip μ w := by
    change r⁻¹ • v - s⁻¹ • w = r⁻¹ • (v-w) + ((s-r)/r) • (s⁻¹ • w)
    have hc : (s-r)/r * s⁻¹ = r⁻¹ - s⁻¹ := by field_simp
    rw [smul_smul, hc, smul_sub, sub_smul]
    abel
  rw [heq]
  calc
    _ ≤ ‖r⁻¹ • (v-w)‖ + ‖((s-r)/r) • clip μ w‖ := norm_add_le _ _
    _ = r⁻¹ * ‖v-w‖ + (|s-r| / r) * ‖clip μ w‖ := by
      rw [norm_smul, norm_smul, Real.norm_eq_abs, Real.norm_eq_abs,
        abs_inv, abs_of_pos hr, abs_div, abs_of_pos hr]
    _ ≤ r⁻¹ * ‖v-w‖ + ((2 * ‖v-w‖) / r) * 1 := by gcongr
    _ = (3 * ‖v-w‖) / r := by ring
    _ ≤ (3 * ‖v-w‖) / μ :=
      div_le_div_of_nonneg_left (by positivity) hμ (le_max_left _ _)
    _ = _ := by ring

theorem clip_lipschitz {μ : ℝ≥0} (hμ : 0 < μ) :
    LipschitzWith (3 / μ) (clip (μ : ℝ)) := by
  apply LipschitzWith.of_dist_le_mul
  intro v w
  simpa only [dist_eq_norm, NNReal.coe_div, NNReal.coe_ofNat] using
    clip_difference (by exact_mod_cast hμ) v w

/-- Global existence of an auxiliary trace with Euclidean normalization.
Agreement with normalized vorticity still needs a nonvanishing certificate. -/
theorem exists_clipped_trace {a b : ℝ} (hab : a ≤ b) (v : Point → Point)
    (μ K : ℝ≥0) (hμ : 0 < μ) (hv : LipschitzWith K v) (x : Point) :
    ∃ y : ℝ → Point, y a = x ∧ Continuous y ∧
      (∀ t, dist (y t) x ≤ b-a) ∧
      ∀ t ∈ Icc a b, HasDerivWithinAt y (clip (μ : ℝ) (v (y t))) (Icc a b) t := by
  let R : ℝ≥0 := ⟨b-a, sub_nonneg.mpr hab⟩
  have hlip : LipschitzWith ((3/μ)*K) (fun y => clip (μ : ℝ) (v y)) :=
    (clip_lipschitz hμ).comp hv
  have hf : IsPicardLindelof (fun _ y => clip (μ : ℝ) (v y))
      ⟨a, left_mem_Icc.mpr hab⟩ x R 0 1 ((3/μ)*K) := by
    constructor
    · intro t ht
      exact hlip.lipschitzOnWith
    · intro e he
      exact continuousOn_const
    · intro t ht y hy
      simpa only [NNReal.coe_one] using clip_norm_le_one (by exact_mod_cast hμ) (v y)
    · simp only [sub_self, NNReal.coe_one, one_mul,
        max_eq_left (sub_nonneg.mpr hab), NNReal.coe_zero, sub_zero, R]
      exact le_refl _
  obtain ⟨y, hy0, hyc, hyb, hyd⟩ := FrozenODE.exists_solution_in_ball hf (mem_closedBall_self (by simp))
  exact ⟨y, hy0, hyc, hyb, hyd⟩

end FrozenEuclidean
