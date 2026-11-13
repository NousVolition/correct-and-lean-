import EdgeControlStatements

noncomputable section
namespace SignedVortex.Rescaled.EdgeControl
open Set Filter MeasureTheory intervalIntegral NavierStokes HLine
open scoped Topology ContDiff

private abbrev nativeProfile := radial nativeC nativeH
private abbrev trace (t d : ℝ) := shellTrace nativeC nativeH t (1/4-d)
private abbrev timePart (t d : ℝ) := shellTime nativeC nativeH t (1/4-d)
private def defect (t d : ℝ) := timePart t d - deriv (deriv (trace t)) d
private abbrev collar := Iio (1/8:ℝ)

private theorem profile_smooth : ContDiff ℝ ∞ nativeProfile :=
  radial_smooth _ _ CorrectionInitialization.ActualPrimary.outgoing.data.h_pos

private theorem moment_smooth_on {F : Profile} (hf : ContDiff ℝ ∞ F) (t : ℝ) :
    ContDiffOn ℝ ∞ (moment F t) collar := by
  apply ParametricRephase.intervalIntegral_contDiffOn_of_joint
    (fun p : ℝ × ℝ => sample F t p.1 p.2) _ isOpen_Iio _ _ _ (by norm_num)
  exact (sample_smooth hf t).contDiffOn

private theorem trace_smooth (t : ℝ) : ContDiffOn ℝ ∞ (trace t) collar := by
  apply (moment_smooth_on profile_smooth t).congr
  intro d hd
  exact (moment_native _ _ t d hd).symm

private theorem time_smooth (t : ℝ) : ContDiffOn ℝ ∞ (timePart t) collar := by
  apply (moment_smooth_on (dt_smooth profile_smooth) t).congr
  intro d hd
  have hx : 0 < 1/4-d := by change d < 1/8 at hd; linarith
  have he : (fun u : ℝ => moment nativeProfile u d) = fun u => trace u d :=
    funext fun u => moment_native _ _ u d hd
  have hm := (moment_t profile_smooth t d).deriv
  rw [he] at hm
  exact (shell_time_is_derivative nativeC nativeH t (1/4-d)
    CorrectionInitialization.ActualPrimary.outgoing.data.h_pos hx).deriv.symm.trans hm

private theorem defect_smooth (t : ℝ) : ContDiffOn ℝ ∞ (defect t) collar :=
  (time_smooth t).sub (((trace_smooth t).deriv_of_isOpen isOpen_Iio (by simp : ∞+1 ≤ ∞)).deriv_of_isOpen
    isOpen_Iio (by simp : ∞+1 ≤ ∞))

private theorem signal_cont (t : ℝ) : ContinuousOn (signal t) collar :=
  ((defect_smooth t).deriv_of_isOpen isOpen_Iio (by simp : ∞+1 ≤ ∞)).continuousOn

private theorem deriv_zero_on_left {f : ℝ → ℝ} (hz : ∀ u ≤ 0, f u = 0)
    {d : ℝ} (hd : d ≤ 0) (hf : DifferentiableAt ℝ f d) : deriv f d = 0 := by
  apply (uniqueDiffWithinAt_Iic d).eq_deriv (Iic d) hf.hasDerivAt.hasDerivWithinAt
  apply (hasDerivAt_const d (0:ℝ)).hasDerivWithinAt.congr_of_mem _ (by simp)
  intro u hu
  exact hz u ((show u ≤ d from hu).trans hd)

private theorem diff_at {f : ℝ → ℝ} (hf : ContDiffOn ℝ ∞ f collar) {d : ℝ}
    (hd : d < 1/8) : DifferentiableAt ℝ f d :=
  (hf.contDiffAt (isOpen_Iio.mem_nhds hd)).differentiableAt (by simp)

private theorem trace_zero (t : ℝ) {d : ℝ} (hd : d ≤ 0) : trace t d = 0 :=
  shell_trace_zero_outside _ _ _ (by linarith)

private theorem trace_deriv_zero (t : ℝ) {d : ℝ} (hd : d ≤ 0) : deriv (trace t) d = 0 :=
  deriv_zero_on_left (fun _ h => trace_zero t h) hd (diff_at (trace_smooth t) (by linarith))

private theorem defect_zero (t : ℝ) {d : ℝ} (hd : d ≤ 0) : defect t d = 0 := by
  have hd2 := deriv_zero_on_left (fun _ h => trace_deriv_zero t h) hd
    (diff_at ((trace_smooth t).deriv_of_isOpen isOpen_Iio (by simp : ∞+1 ≤ ∞)) (by linarith))
  have hw (y : ℝ) : shellWeight (1/4-d) y = 0 := by
    apply SmoothCutoffs.cutoff_zero_of_one_le
    nlinarith [sq_nonneg d,sq_nonneg y]
  unfold defect timePart shellTime
  rw [hd2]
  simp only [hw,zero_mul,intervalIntegral.integral_zero,sub_zero]

theorem edge_signal_zero (t : ℝ) : signal t 0 = 0 :=
  deriv_zero_on_left (fun _ h => defect_zero t h) le_rfl (diff_at (defect_smooth t) (by norm_num))

/-- Positivity just inside the cutoff prevents its transverse signal from
vanishing over any whole inward interval, however short. -/
theorem native_in_every_collar {t L : ℝ} (ht : t < 1) (hL : 0 < L) (hR : L < 1/8) :
    ∃ d ∈ Ioo (0:ℝ) L, signal t d ≠ 0 := by
  have hc := trace_smooth t
  have hc1 := hc.deriv_of_isOpen isOpen_Iio (show ∞+1 ≤ ∞ by simp)
  have hsub : Icc 0 L ⊆ collar := fun _ hs => hs.2.trans_lt hR
  have hC := selected_normalization_positive
  have hh := CorrectionInitialization.ActualPrimary.outgoing.data.h_pos
  obtain ⟨M,hM,hbound⟩ := shell_time_relative_bound hC hh ht
  have fails := cutoff_line_obstruction (trace t) (deriv (trace t)) (deriv (deriv (trace t)))
    (timePart t) (L:=L) (ν:=1) (by norm_num) hM (hc.continuousOn.mono hsub)
    (hc1.continuousOn.mono hsub)
    (fun _ hs => (diff_at hc (hs.2.trans hR)).hasDerivAt)
    (fun _ hs => (diff_at hc1 (hs.2.trans hR)).hasDerivAt)
    (trace_zero t le_rfl) (trace_deriv_zero t le_rfl)
    (fun s hs => hbound (1/4-s) ⟨by linarith [hs.2],by linarith [hs.1]⟩)
    ⟨L,⟨hL.le,le_rfl⟩,(shell_trace_positive hC hh ht
      (show 1/8 ≤ 1/4-L by linarith) (by linarith : 1/4-L < 1/4)).ne'⟩
  by_contra hn
  push Not at hn
  apply fails
  intro s hs
  have hz : defect t s = 0 := by
    rcases eq_or_lt_of_le hs.1 with he | hp
    · exact defect_zero t he.ge
    · have hcD := defect_smooth t
      obtain ⟨z,hz,he⟩ := exists_deriv_eq_slope (defect t) hp
        (hcD.continuousOn.mono (fun u hu => hu.2.trans_lt (hs.2.trans hR)))
        (fun u hu => (diff_at hcD (hu.2.trans (hs.2.trans hR))).differentiableWithinAt)
      have hd : deriv (defect t) z = 0 := hn z ⟨hz.1,hz.2.trans hs.2⟩
      rw [hd,defect_zero t (d:=0) le_rfl,sub_zero,sub_zero] at he
      exact (div_eq_zero_iff.mp he.symm).resolve_right hp.ne'
  simpa only [one_mul] using (sub_eq_zero.mp hz)

theorem inward_small {t m D ε : ℝ} (ht : t < 1) (hm : 0 < m) (hD : 0 < D) (hε : 0 < ε) :
    ∃ d ∈ Ioo (0:ℝ) (1/8), d < D ∧ 0 < |m * signal t d| ∧ |m * signal t d| < ε := by
  have hc : ContinuousAt (fun d => |m * signal t d|) 0 :=
    (continuousAt_const.mul ((signal_cont t).continuousAt
      (isOpen_Iio.mem_nhds (by norm_num : (0:ℝ) < 1/8)))).abs
  have h0 : |m * signal t 0| < ε := by simpa only [edge_signal_zero,mul_zero,abs_zero] using hε
  have near := hc.eventually_lt_const h0
  obtain ⟨r,hr,within⟩ := Metric.mem_nhds_iff.mp near
  let L := min D (min r (1/16))
  have hL : 0 < L := lt_min hD (lt_min hr (by norm_num))
  have hcap : L ≤ 1/16 := (min_le_right _ _).trans (min_le_right _ _)
  have hr' : L ≤ r := (min_le_right _ _).trans (min_le_left _ _)
  obtain ⟨d,hd,hn⟩ := native_in_every_collar ht hL (by linarith)
  have hb : d ∈ Metric.ball (0:ℝ) r := by
    rw [Metric.mem_ball, Real.dist_eq, sub_zero, abs_of_pos hd.1]
    exact hd.2.trans_le hr'
  exact ⟨d,⟨hd.1,by linarith [hd.2]⟩,hd.2.trans_le (min_le_left _ _),
    abs_pos.mpr (mul_ne_zero hm.ne' hn),within hb⟩

end SignedVortex.Rescaled.EdgeControl
