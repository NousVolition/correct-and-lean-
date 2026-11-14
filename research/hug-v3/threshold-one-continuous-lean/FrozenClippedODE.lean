import FrozenODE
import Mathlib.Topology.MetricSpace.Lipschitz

namespace FrozenClippedODE
open Set Metric
open scoped NNReal

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]

/-- A globally defined auxiliary field. It agrees with normalized vorticity
where the norm is at least `μ`; that agreement must be proved on the trace. -/
noncomputable def clip (μ : ℝ) (v : E) : E := (max μ ‖v‖)⁻¹ • v

theorem clip_norm_le_one {μ : ℝ} (hμ : 0 < μ) (v : E) : ‖clip μ v‖ ≤ 1 := by
  have hm : 0 < max μ ‖v‖ := lt_of_lt_of_le hμ (le_max_left _ _)
  rw [clip, norm_smul, Real.norm_eq_abs, abs_inv, abs_of_pos hm]
  have h := (div_le_one hm).mpr (le_max_right μ ‖v‖)
  simpa only [div_eq_mul_inv, mul_comm] using h

theorem clip_eq_normalized {μ : ℝ} {v : E} (h : μ ≤ ‖v‖) :
    clip μ v = ‖v‖⁻¹ • v := by rw [clip, max_eq_right h]

theorem clip_difference {μ : ℝ} (hμ : 0 < μ) (v w : E) :
    ‖clip μ v - clip μ w‖ ≤ (2 / μ) * ‖v-w‖ := by
  let r := max μ ‖v‖
  let s := max μ ‖w‖
  have hr : 0 < r := lt_of_lt_of_le hμ (le_max_left _ _)
  have hs : 0 < s := lt_of_lt_of_le hμ (le_max_left _ _)
  have hgap : |s-r| ≤ ‖v-w‖ := by
    have h := abs_max_sub_max_le_abs ‖w‖ ‖v‖ μ
    simp only [max_comm] at h
    exact le_trans h (by simpa only [norm_sub_rev] using abs_norm_sub_norm_le w v)
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
    _ ≤ r⁻¹ * ‖v-w‖ + (‖v-w‖ / r) * 1 := by gcongr
    _ = (2 * ‖v-w‖) / r := by ring
    _ ≤ (2 * ‖v-w‖) / μ :=
      div_le_div_of_nonneg_left (by positivity) hμ (le_max_left _ _)
    _ = _ := by ring

theorem clip_lipschitz {μ : ℝ≥0} (hμ : 0 < μ) :
    LipschitzWith (2 / μ) (clip (μ : ℝ) : E → E) := by
  apply LipschitzWith.of_dist_le_mul
  intro v w
  simpa only [dist_eq_norm, NNReal.coe_div, NNReal.coe_ofNat] using
    clip_difference (by exact_mod_cast hμ) v w

/-- Existence for the clipped auxiliary field on a full finite interval. This
does not establish agreement with the requested normalized field. -/
theorem exists_clipped_trace [CompleteSpace E] {a b : ℝ} (hab : a ≤ b) (v : E → E)
    (μ K : ℝ≥0) (hμ : 0 < μ) (hv : LipschitzWith K v) (x : E) :
    ∃ y : ℝ → E, y a = x ∧ Continuous y ∧
      (∀ t, dist (y t) x ≤ b-a) ∧
      ∀ t ∈ Icc a b, HasDerivWithinAt y (clip (μ : ℝ) (v (y t))) (Icc a b) t := by
  let R : ℝ≥0 := ⟨b-a, sub_nonneg.mpr hab⟩
  have hlip : LipschitzWith ((2/μ)*K) (fun y => clip (μ : ℝ) (v y)) :=
    (clip_lipschitz hμ).comp hv
  have hf : IsPicardLindelof (fun _ y => clip (μ : ℝ) (v y))
      ⟨a, left_mem_Icc.mpr hab⟩ x R 0 1 ((2/μ)*K) := by
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

end FrozenClippedODE
