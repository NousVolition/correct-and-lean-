import TraceDefinitions
import ExteriorSolution
import SignedSolution
import NavierStokes.ParametricRephase

noncomputable section
namespace SignedVortex
open Set MeasureTheory intervalIntegral NavierStokes
open scoped Topology ContDiff

theorem shell_weight_is_native (x : NavierStokes.ProblemStatement.Space) (hz : x 2 = 0) :
    SpatialLocalization.spatialCutoff x = shellWeight (x 0) (x 1) := by
  simp [SpatialLocalization.spatialCutoff, SpatialLocalization.cutoffProfile,
    SpatialLocalization.radialSquare, shellWeight, hz,
    SmoothCutoffs.cutoff_one_of_abs_le (x := 0) (by norm_num)]

theorem shell_trace_zero_outside (C h t : ℝ) {x : ℝ} (hx : 1/4 ≤ x) :
    shellTrace C h t x = 0 := by
  unfold shellTrace
  have hf (y : ℝ) : shellWeight x y = 0 := by
    apply SmoothCutoffs.cutoff_zero_of_one_le
    nlinarith [sq_nonneg (x-1/4), sq_nonneg y]
  simp [hf]

theorem shell_trace_positive {C h t x : ℝ} (hC : 0 < C) (hh : 0 < h)
    (ht : t < 1) (hx : 1/8 ≤ x) (hx' : x < 1/4) : 0 < shellTrace C h t x := by
  have he (y : ℝ) : 0 < shellEnergy x y := by
    unfold shellEnergy; nlinarith [sq_pos_of_pos (by linarith : 0 < x), sq_nonneg y]
  have he1 (y : ℝ) (hy : y ∈ Icc (-(1/2):ℝ) (1/2)) : shellEnergy x y < 1 := by
    unfold shellEnergy
    nlinarith [mul_nonneg (by linarith [hy.1] : 0 ≤ y + 1/2) (by linarith [hy.2] : 0 ≤ 1/2-y),
      mul_nonneg (by linarith : 0 ≤ 1/4-x) (by linarith : 0 ≤ x+1/4)]
  have hweight : Continuous (shellWeight x) := by
    unfold shellWeight
    exact SmoothCutoffs.cutoff_contDiff.continuous.comp (by fun_prop)
  have hprim : Continuous (shellPrimitive C h t x) := by
    apply continuous_iff_continuousAt.mpr
    intro y
    have hpt : ContinuousAt (fun v : ℝ => (t,shellEnergy x v,(0:ℝ))) y := by
      unfold shellEnergy; fun_prop
    exact ContinuousAt.comp (f := fun v : ℝ => (t,shellEnergy x v,(0:ℝ)))
      (TailGaugePotential.heatPrimitive_smoothAt C hh (he y)).continuousAt hpt
  apply intervalIntegral.integral_pos (by norm_num) (hweight.mul hprim).continuousOn
  · intro y hy
    exact mul_nonneg (SmoothCutoffs.cutoff_mem_Icc _).1
      (exterior_primitive_positive hC hh ht (he y) (he1 y ⟨hy.1.le,hy.2⟩)).le
  · refine ⟨0,by norm_num, mul_pos ?_ (exterior_primitive_positive hC hh ht (he 0) (he1 0 (by norm_num)))⟩
    have hm : 16*(x^2+(0:ℝ)^2) ∈ Function.support SmoothCutoffs.cutoff := by
      rw [SmoothCutoffs.cutoff_support]
      constructor <;> nlinarith [sq_nonneg x,
        mul_pos (by linarith : 0 < 1/4-x) (by linarith : 0 < 1/4+x)]
    exact lt_of_le_of_ne (SmoothCutoffs.cutoff_mem_Icc _).1 (Ne.symm hm)

private theorem slope_cont_at (C h t s : ℝ) (hh : 0 < h) (hs : 0 < s) :
    ContinuousAt (timeSlope C h t) s := by
  have h := TailGaugePotential.heatPrimitive_smoothAt C hh (p := (t,s,(0:ℝ))) hs
  have hpt : ContinuousAt (fun v : ℝ => (t,v,(0:ℝ))) s :=
    (continuous_const.prodMk (continuous_id.prodMk continuous_const)).continuousAt
  exact ContinuousAt.comp (f := fun v : ℝ => (t,v,(0:ℝ)))
    (((h.fderiv_right (show ∞ + 1 ≤ ∞ by simp)).clm_apply
      (contDiffAt_const (c := ((1,0,0) : ℝ × ℝ × ℝ)))).continuousAt) hpt

theorem shell_time_relative_bound {C h t : ℝ} (hC : 0 < C) (hh : 0 < h) (ht : t < 1) :
    ∃ B : ℝ, 0 ≤ B ∧ ∀ x ∈ Icc (1/8:ℝ) (1/4),
      |shellTime C h t x| ≤ B * |shellTrace C h t x| := by
  let ψ := fun s : ℝ => TailGaugePotential.heatPrimitive C h (t,s,(0:ℝ))
  let R := fun s : ℝ => |timeSlope C h t s| / ψ s
  let K := Icc (1/128:ℝ) (1/4)
  have hψ (s : ℝ) (hs : s ∈ K) : 0 < ψ s :=
    exterior_primitive_positive hC hh ht (by linarith [hs.1]) (by linarith [hs.2])
  have hpc (s : ℝ) (hs : 0 < s) : ContinuousAt ψ s := by
    exact ContinuousAt.comp (f := fun v : ℝ => (t,v,(0:ℝ)))
      (TailGaugePotential.heatPrimitive_smoothAt C hh (p := (t,s,(0:ℝ))) hs).continuousAt
      (continuous_const.prodMk (continuous_id.prodMk continuous_const)).continuousAt
  have hR : ContinuousOn R K := fun s hs =>
    ((slope_cont_at C h t s hh (by linarith [hs.1])).abs.div
      (hpc s (by linarith [hs.1])) (hψ s hs).ne').continuousWithinAt
  obtain ⟨m,hm,hmax⟩ := isCompact_Icc.exists_isMaxOn
    (show K.Nonempty from ⟨1/8,by constructor <;> norm_num⟩) hR
  refine ⟨R m, div_nonneg (abs_nonneg _) (hψ m hm).le, ?_⟩
  intro x hx
  have he (y : ℝ) : 0 < shellEnergy x y := by
    unfold shellEnergy; nlinarith [sq_pos_of_pos (by linarith [hx.1] : 0 < x),sq_nonneg y]
  have hmem (y : ℝ) (hy : y ∈ Icc (-(1/2):ℝ) (1/2)) : shellEnergy x y ∈ K := by
    change (1/128:ℝ) ≤ (x^2+y^2)/2 ∧ (x^2+y^2)/2 ≤ 1/4
    constructor <;> nlinarith [sq_nonneg y, sq_nonneg (x-1/8),hx.1,
      mul_nonneg (by linarith [hx.2] : 0 ≤ 1/4-x) (by linarith [hx.1] : 0 ≤ 1/4+x),
      mul_nonneg (by linarith [hy.1] : 0 ≤ y+1/2) (by linarith [hy.2] : 0 ≤ 1/2-y)]
  have hweight : Continuous (shellWeight x) := by
    unfold shellWeight
    exact SmoothCutoffs.cutoff_contDiff.continuous.comp (by fun_prop)
  have hen : Continuous (shellEnergy x) := by unfold shellEnergy; fun_prop
  have htime : Continuous (fun y => timeSlope C h t (shellEnergy x y)) :=
    continuous_iff_continuousAt.mpr fun y => (slope_cont_at C h t _ hh (he y)).comp hen.continuousAt
  have hpr : Continuous (shellPrimitive C h t x) :=
    continuous_iff_continuousAt.mpr fun y => (hpc _ (he y)).comp hen.continuousAt
  have hle (y : ℝ) (hy : y ∈ Icc (-(1/2):ℝ) (1/2)) :
      |shellWeight x y * timeSlope C h t (shellEnergy x y)| ≤
      R m * (shellWeight x y * shellPrimitive C h t x y) := by
    have hc := (div_le_iff₀ (hψ _ (hmem y hy))).mp (hmax (hmem y hy))
    have hw : 0 ≤ shellWeight x y := (SmoothCutoffs.cutoff_mem_Icc _).1
    rw [abs_mul,abs_of_nonneg hw]
    calc _ ≤ shellWeight x y * (R m * ψ (shellEnergy x y)) :=
          mul_le_mul_of_nonneg_left hc (SmoothCutoffs.cutoff_mem_Icc _).1
         _ = _ := by dsimp [ψ,shellPrimitive]; ring
  calc |shellTime C h t x| ≤ _ := intervalIntegral.abs_integral_le_integral_abs (by norm_num)
       _ ≤ ∫ y in (-(1/2):ℝ)..1/2, R m * (shellWeight x y * shellPrimitive C h t x y) :=
          intervalIntegral.integral_mono_on (by norm_num)
            ((hweight.mul htime).abs.intervalIntegrable _ _)
            ((continuous_const.mul (hweight.mul hpr)).intervalIntegrable _ _) hle
       _ = R m * shellTrace C h t x := intervalIntegral.integral_const_mul _ _
       _ ≤ R m * |shellTrace C h t x| := mul_le_mul_of_nonneg_left (le_abs_self _)
            (div_nonneg (abs_nonneg _) (hψ m hm).le)

/-- For the actual cutoff and primitive, the averaged heat equation fails at some offset,
given the classical offset derivatives. The explicit time term is the integral of the
native time derivative. Offsets use s = 1/4 - x. -/
theorem actual_trace_heat_fails {C h t ν : ℝ} (hC : 0 < C) (hh : 0 < h)
    (ht : t < 1) (hν : 0 < ν) (D₁ D₂ : ℝ → ℝ)
    (hJ : ContinuousOn (fun s => shellTrace C h t (1/4-s)) (Icc 0 (1/8)))
    (hD : ContinuousOn D₁ (Icc 0 (1/8)))
    (h₁ : ∀ s ∈ Ico 0 (1/8), HasDerivAt (fun z => shellTrace C h t (1/4-z)) (D₁ s) s)
    (h₂ : ∀ s ∈ Ico 0 (1/8), HasDerivAt D₁ (D₂ s) s)
    (hflat : D₁ 0 = 0) :
    ¬ ∀ s ∈ Ico 0 (1/8), shellTime C h t (1/4-s) = ν * D₂ s := by
  obtain ⟨B,hB,hb⟩ := shell_time_relative_bound hC hh ht
  apply cutoff_line_obstruction _ D₁ D₂ _ hν hB hJ hD h₁ h₂ _ hflat
  · intro s hs; exact hb _ ⟨by linarith [hs.2],by linarith [hs.1]⟩
  · refine ⟨1/8,by norm_num,?_⟩
    exact (shell_trace_positive hC hh ht (by norm_num) (by norm_num)).ne'
  · simpa using shell_trace_zero_outside C h t (x := 1/4) (by norm_num)

private theorem offset_smooth (C h t : ℝ) (hh : 0 < h) :
    ContDiffOn ℝ ∞ (fun d => shellTrace C h t (1/4-d)) (Iio (1/4)) := by
  apply ParametricRephase.intervalIntegral_contDiffOn_of_joint
    (fun p : ℝ × ℝ => shellWeight (1/4-p.1) p.2 * shellPrimitive C h t (1/4-p.1) p.2)
    _ isOpen_Iio _ _ _ (by norm_num)
  intro p hp
  have hq : 0 < shellEnergy (1/4-p.1) p.2 := by
    unfold shellEnergy
    have hx : 0 < (1/4:ℝ)-p.1 := sub_pos.mpr hp.1
    nlinarith [sq_pos_of_pos hx,sq_nonneg p.2]
  have h1 : ContDiffAt ℝ ∞ (fun p : ℝ × ℝ => shellWeight (1/4-p.1) p.2) p := by
    unfold shellWeight
    exact SmoothCutoffs.cutoff_contDiff.contDiffAt.comp p (by fun_prop)
  have h2 : ContDiffAt ℝ ∞ (fun p : ℝ × ℝ => shellPrimitive C h t (1/4-p.1) p.2) p := by
    unfold shellPrimitive
    apply (TailGaugePotential.heatPrimitive_smoothAt C hh hq).comp p
    unfold shellEnergy; fun_prop
  exact (h1.mul h2).contDiffWithinAt

/-- No shape, sign, derivative or flatness hypothesis on the trace is supplied here.
The only parameters are positive heat normalization, exponent and viscosity and t < 1. -/
theorem native_trace_residual_nonzero {C h t ν : ℝ} (hC : 0 < C) (hh : 0 < h)
    (ht : t < 1) (hν : 0 < ν) :
    ∃ s ∈ Ico (0:ℝ) (1/8), shellTime C h t (1/4-s) ≠
      ν * deriv (deriv (fun z => shellTrace C h t (1/4-z))) s := by
  let F := fun z : ℝ => shellTrace C h t (1/4-z)
  have hF : ContDiffOn ℝ ∞ F (Iio (1/4)) := offset_smooth C h t hh
  have hF' := hF.deriv_of_isOpen isOpen_Iio (show ∞ + 1 ≤ ∞ by simp)
  have sub : Icc (0:ℝ) (1/8) ⊆ Iio (1/4) := fun s hs => by
    change s < 1/4; linarith [hs.2]
  have hd (s : ℝ) (hs : s ∈ Iio (1/4:ℝ)) : HasDerivAt F (deriv F s) s :=
    ((hF.contDiffAt (isOpen_Iio.mem_nhds hs)).differentiableAt (by simp)).hasDerivAt
  have hflat : deriv F 0 = 0 := by
    apply (uniqueDiffWithinAt_Iic (0:ℝ)).eq_deriv (Iic 0) (hd 0 (by norm_num)).hasDerivWithinAt
    apply (hasDerivAt_const (0:ℝ) (0:ℝ)).hasDerivWithinAt.congr_of_mem _ (by simp)
    intro s hs
    exact shell_trace_zero_outside C h t (by change s ≤ 0 at hs; linarith)
  by_contra hn
  push Not at hn
  apply actual_trace_heat_fails hC hh ht hν (deriv F) (deriv (deriv F))
      (hF.continuousOn.mono sub) (hF'.continuousOn.mono sub)
      (fun s hs => hd s (sub ⟨hs.1,hs.2.le⟩))
      (fun s hs => ((hF'.contDiffAt (isOpen_Iio.mem_nhds (sub ⟨hs.1,hs.2.le⟩))).differentiableAt
        (by simp)).hasDerivAt) hflat
  exact hn

private theorem diff_fixed_interval (F G : ℝ → ℝ → ℝ) (t : ℝ)
    (hF : Continuous F.uncurry) (hG : Continuous G.uncurry)
    (hD : ∀ u y, HasDerivAt (fun z => F z y) (G u y) u) :
    HasDerivAt (fun u => ∫ y in (-(1/2):ℝ)..1/2, F u y)
      (∫ y in (-(1/2):ℝ)..1/2, G t y) t := by
  let K := Icc (t-1) (t+1) ×ˢ Icc (-(1/2):ℝ) (1/2)
  obtain ⟨B,hB⟩ := (show IsCompact K from isCompact_Icc.prod isCompact_Icc).exists_bound_of_continuousOn
    hG.continuousOn
  apply (intervalIntegral.hasDerivAt_integral_of_dominated_loc_of_deriv_le
    (F := F) (F' := G) (bound := fun _ => B) (s := Ioo (t-1) (t+1))
    (Ioo_mem_nhds (by linarith) (by linarith)) _ _ _ _ intervalIntegrable_const _).2
  · exact Filter.Eventually.of_forall fun u =>
      (hF.comp (continuous_const.prodMk continuous_id)).aestronglyMeasurable
  · exact (hF.comp (continuous_const.prodMk continuous_id)).intervalIntegrable _ _
  · exact (hG.comp (continuous_const.prodMk continuous_id)).aestronglyMeasurable
  · apply Filter.Eventually.of_forall
    intro y hy u hu
    apply hB (u,y)
    rw [uIoc_of_le (show (-(1/2):ℝ) ≤ 1/2 by norm_num)] at hy
    exact ⟨⟨hu.1.le,hu.2.le⟩, ⟨hy.1.le,hy.2⟩⟩
  · exact Filter.Eventually.of_forall fun y _ u _ => hD u y

theorem shell_time_is_derivative (C h t x : ℝ) (hh : 0 < h) (hx : 0 < x) :
    HasDerivAt (fun u => shellTrace C h u x) (shellTime C h t x) t := by
  let F := fun u y : ℝ => shellWeight x y * shellPrimitive C h u x y
  let G := fun u y : ℝ => shellWeight x y * timeSlope C h u (shellEnergy x y)
  have he (y : ℝ) : 0 < shellEnergy x y := by
    dsimp [shellEnergy]; nlinarith [sq_pos_of_pos hx,sq_nonneg y]
  have hweight : Continuous (shellWeight x) := SmoothCutoffs.cutoff_contDiff.continuous.comp (by fun_prop)
  have hF : Continuous F.uncurry := by
    apply continuous_iff_continuousAt.mpr
    intro p
    apply (hweight.comp continuous_snd).continuousAt.mul
    apply ContinuousAt.comp (f := fun z : ℝ × ℝ => (z.1,shellEnergy x z.2,(0:ℝ)))
      (TailGaugePotential.heatPrimitive_smoothAt C hh (he p.2)).continuousAt
    unfold shellEnergy; fun_prop
  have hG : Continuous G.uncurry := by
    apply continuous_iff_continuousAt.mpr
    intro p
    apply (hweight.comp continuous_snd).continuousAt.mul
    have hhpt := TailGaugePotential.heatPrimitive_smoothAt C hh (p := (p.1,shellEnergy x p.2,(0:ℝ))) (he p.2)
    apply ContinuousAt.comp (f := fun z : ℝ × ℝ => (z.1,shellEnergy x z.2,(0:ℝ)))
      (((hhpt.fderiv_right (show ∞+1 ≤ ∞ by simp)).clm_apply
        (contDiffAt_const (c := ((1,0,0) : ℝ × ℝ × ℝ)))).continuousAt)
    unfold shellEnergy; fun_prop
  apply diff_fixed_interval F G t hF hG
  intro u y
  apply HasDerivAt.const_mul (shellWeight x y)
  exact ((TailGaugePotential.heatPrimitive_smoothAt C hh (p := (u,shellEnergy x y,(0:ℝ)))
    (he y)).differentiableAt (by simp)).hasFDerivAt.comp_hasDerivAt u
      ((hasDerivAt_id u).prodMk (hasDerivAt_const u (shellEnergy x y,(0:ℝ))))

theorem edge_heat_equation_fails {C h t ν : ℝ} (hC : 0 < C) (hh : 0 < h)
    (ht : t < 1) (hν : 0 < ν) :
    ∃ d ∈ Ico (0:ℝ) (1/8),
      deriv (fun u => shellTrace C h u (1/4-d)) t ≠
        ν * deriv (deriv (fun z => shellTrace C h t (1/4-z))) d := by
  obtain ⟨d,hd,hr⟩ := native_trace_residual_nonzero hC hh ht hν
  exact ⟨d,hd,by rwa [(shell_time_is_derivative C h t (1/4-d) hh (by linarith [hd.2])).deriv]⟩

private theorem offset_time_smooth (C h t : ℝ) (hh : 0 < h) :
    ContDiffOn ℝ ∞ (fun d => shellTime C h t (1/4-d)) (Iio (1/4)) := by
  apply ParametricRephase.intervalIntegral_contDiffOn_of_joint
    (fun p : ℝ × ℝ => shellWeight (1/4-p.1) p.2 * timeSlope C h t (shellEnergy (1/4-p.1) p.2))
    _ isOpen_Iio _ _ _ (by norm_num)
  intro p hp
  have hx : 0 < (1/4:ℝ)-p.1 := sub_pos.mpr hp.1
  have hs : 0 < shellEnergy (1/4-p.1) p.2 := by
    unfold shellEnergy; nlinarith [sq_pos_of_pos hx,sq_nonneg p.2]
  have h1 : ContDiffAt ℝ ∞ (fun p : ℝ × ℝ => shellWeight (1/4-p.1) p.2) p := by
    unfold shellWeight
    exact SmoothCutoffs.cutoff_contDiff.contDiffAt.comp p (by fun_prop)
  have hpjet := (TailGaugePotential.heatPrimitive_smoothAt C hh (p := (t,shellEnergy (1/4-p.1) p.2,(0:ℝ))) hs).fderiv_right
    (show ∞+1 ≤ ∞ by simp)
  have h2 : ContDiffAt ℝ ∞ (fun p : ℝ × ℝ => timeSlope C h t (shellEnergy (1/4-p.1) p.2)) p := by
    have inner : ContDiffAt ℝ ∞ (fun z : ℝ × ℝ => (t,shellEnergy (1/4-z.1) z.2,(0:ℝ))) p := by
      unfold shellEnergy; fun_prop
    exact (hpjet.clm_apply (contDiffAt_const (c := ((1,0,0) : ℝ × ℝ × ℝ)))).comp p inner
  exact (h1.mul h2).contDiffWithinAt

/-- The inward derivative of the heat defect is the candidate transverse line signal.
It is genuinely nonzero at some offset in the native collar. -/
theorem native_transverse_signal {C h t ν : ℝ} (hC : 0 < C) (hh : 0 < h)
    (ht : t < 1) (hν : 0 < ν) :
    ∃ s ∈ Ioo (-(1/16):ℝ) (1/8),
      deriv (fun d => shellTime C h t (1/4-d) -
        ν * deriv (deriv (fun z => shellTrace C h t (1/4-z))) d) s ≠ 0 := by
  let F := fun z : ℝ => shellTrace C h t (1/4-z)
  let G := fun d : ℝ => shellTime C h t (1/4-d) - ν * deriv (deriv F) d
  have hf := offset_smooth C h t hh
  have hg : ContDiffOn ℝ ∞ G (Iio (1/4)) := (offset_time_smooth C h t hh).sub
    (contDiffOn_const.mul ((hf.deriv_of_isOpen isOpen_Iio (by simp : ∞+1 ≤ ∞)).deriv_of_isOpen
      isOpen_Iio (by simp : ∞+1 ≤ ∞)))
  have hzF : F =ᶠ[𝓝 (-(1/16):ℝ)] (fun _ => 0) := by
    filter_upwards [gt_mem_nhds (by norm_num : (-(1/16):ℝ) < 0)] with s hs
    exact shell_trace_zero_outside C h t (by linarith)
  have hzG : G (-(1/16)) = 0 := by
    have hw (y : ℝ) : shellWeight (1/4-(-(1/16):ℝ)) y = 0 := by
      apply SmoothCutoffs.cutoff_zero_of_one_le
      nlinarith [sq_nonneg y]
    have hd := hzF.deriv.deriv_eq
    dsimp only [G,shellTime]
    rw [hd]
    simp only [hw,zero_mul,intervalIntegral.integral_zero]
    simp
  obtain ⟨d,hd,hw⟩ := native_trace_residual_nonzero hC hh ht hν
  have hne : G d ≠ 0 := sub_ne_zero.mpr hw
  have hgsub : Icc (-(1/16):ℝ) d ⊆ Iio (1/4) := fun x hx => by
    change x < 1/4; linarith [hx.2,hd.2]
  have hdlt : (-(1/16):ℝ) < d := by linarith [hd.1]
  obtain ⟨v,hv,he⟩ := exists_deriv_eq_slope G hdlt (hg.continuousOn.mono hgsub)
    (fun z hz => ((hg.contDiffAt (isOpen_Iio.mem_nhds (hgsub ⟨hz.1.le,hz.2.le⟩))).differentiableAt
      (by simp)).differentiableWithinAt)
  refine ⟨v,⟨hv.1,hv.2.trans hd.2⟩,?_⟩
  change deriv G v ≠ 0
  rw [he,hzG,sub_zero]
  exact div_ne_zero hne (sub_ne_zero.mpr hdlt.ne')

/-- The imported periodic velocity identity and the nonzero signal refer to the same
presingular time, the same heat normalization and the same actual cutoff. -/
theorem pinned_vortex_edge_test (a : ℕ → ℕ) :
    let h := CorrectionInitialization.ActualPrimary.h
    let C := BaseExterior.nominalHeatNormalization CorrectionInitialization.ActualPrimary.nominal
    ∃ η : ℝ, 0 < η ∧ ∀ τ : ℝ, 0 < τ → τ < η →
      (∀ x : ProblemStatement.Space, x 2 = 0 → (1/128:ℝ) ≤ AxisymmetricFields.radialEnergy x →
        AxisymmetricFields.radialEnergy x < 1 → x ∈ PeriodicLocalization.innerCube (1/4) →
        R3CompactCandidate.periodicVelocity (LocalAngularGrowth.selectedPotential a)
          (LocalAngularGrowth.selectedDirect a) (1-τ,x) =
          SpatialCurl.spatialCurl (SpatialLocalization.cutPotential (TailGaugePotential.heatPotential C h))
            (1-τ,x)) ∧
      (∃ s ∈ Ioo (-(1/16):ℝ) (1/8), deriv (fun d => shellTime C h (1-τ) (1/4-d) -
        deriv (deriv (fun z => shellTrace C h (1-τ) (1/4-z))) d) s ≠ 0) := by
  obtain ⟨η,hη,H⟩ := actual_midplane_strip a (b := (1/128:ℝ)) (by norm_num)
  refine ⟨η,hη,?_⟩
  intro τ ht hτ
  refine ⟨H _ ht hτ,?_⟩
  simpa only [one_mul] using (native_transverse_signal selected_normalization_positive
    CorrectionInitialization.ActualPrimary.outgoing.data.h_pos (show 1-τ < 1 by linarith) (ν:=1) (by norm_num))

end SignedVortex
