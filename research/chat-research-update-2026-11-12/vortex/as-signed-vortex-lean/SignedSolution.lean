import SignedDefinitions

noncomputable section
namespace SignedVortex
open Set MeasureTheory intervalIntegral

private theorem tanh_cont : Continuous Real.tanh := by
  simp only [funext Real.tanh_eq_sinh_div_cosh]
  exact Real.continuous_sinh.div Real.continuous_cosh (fun x => (Real.cosh_pos x).ne')

private theorem factor_pos (v : ℝ) : 0 < 1 + Real.tanh v := by
  linarith [Real.neg_one_lt_tanh v]

theorem signed_flat_negative {ε Γ : ℝ} (hΓ : 0 < Γ) : signed ε (-Γ) < 0 := by
  exact div_neg_of_neg_of_pos (mul_neg_of_neg_of_pos (neg_lt_zero.mpr hΓ) (factor_pos _)) (by norm_num)

private theorem half_le_signed {ε : ℝ} (he : 0 < ε) (q : ℝ) : q / 2 ≤ signed ε q := by
  have h : 0 ≤ q * Real.tanh (q / ε) := by
    rw [Real.tanh_eq_sinh_div_cosh]
    rcases le_total 0 q with hq | hq
    · exact mul_nonneg hq (div_nonneg (Real.sinh_nonneg_iff.mpr (div_nonneg hq he.le)) (Real.cosh_pos _).le)
    · exact mul_nonneg_of_nonpos_of_nonpos hq
        (div_nonpos_of_nonpos_of_nonneg (Real.sinh_nonpos_iff.mpr (div_nonpos_of_nonpos_of_nonneg hq he.le)) (Real.cosh_pos _).le)
  unfold signed
  nlinarith

theorem scalar_periodic (l : ℝ) : Function.Periodic (scalar l) 1 := by
  intro x
  simp only [scalar, mul_add, mul_one, Real.sin_add_two_pi]

theorem scalar_gradient {l : ℝ} (hl : 0 ≤ l) (x : ℝ) :
    |deriv (scalar l) x| = l * gradientShape x := by
  have hp : 2 * Real.pi ≠ 0 := by positivity
  have hd := (((Real.hasDerivAt_sin (2*Real.pi*x)).comp x
    ((hasDerivAt_id x).const_mul (2*Real.pi))).const_mul (l/(2*Real.pi))).deriv
  change deriv (scalar l) x = l/(2*Real.pi) * (Real.cos (2*Real.pi*x) * (2*Real.pi*1)) at hd
  rw [hd]
  simp only [mul_one, gradientShape]
  have h : l / (2 * Real.pi) * (Real.cos (2 * Real.pi * x) * (2 * Real.pi)) =
      l * Real.cos (2 * Real.pi * x) := by field_simp
  rw [h, abs_mul, abs_of_nonneg hl]

private theorem shape_cont : Continuous gradientShape :=
  (Real.continuous_cos.comp (continuous_const.mul continuous_id)).abs

private theorem density_cont (ε Γ : ℝ) : Continuous (Function.uncurry (density ε Γ)) := by
  have h : Continuous (fun p : ℝ × ℝ => p.1 * gradientShape p.2 - Γ) :=
    (continuous_fst.mul (shape_cont.comp continuous_snd)).sub continuous_const
  exact (h.mul (continuous_const.add (tanh_cont.comp (h.div_const ε)))).div_const 2

private theorem at_quarter (ε Γ l : ℝ) :
    density ε Γ l (1 / 4) = signed ε (-Γ) := by
  have h : 2 * Real.pi * (1 / 4) = Real.pi / 2 := by ring
  unfold density gradientShape
  rw [h, Real.cos_pi_div_two]
  simp

private theorem at_zero (ε Γ l : ℝ) :
    density ε Γ l 0 = signed ε (l - Γ) := by simp [density, gradientShape]

theorem balanced_snapshot {ε Γ c : ℝ} (he : 0 < ε) (hg : 0 < Γ) (hc : 0 < c) :
    ∃ l : ℝ, Γ < l ∧ boxPush c ε Γ l = 0 ∧
      0 < -c * signed ε (|deriv (scalar l) (1/4)| - Γ) ∧
      -c * signed ε (|deriv (scalar l) 0| - Γ) < 0 := by
  let H := ∫ x in (0:ℝ)..1, gradientShape x
  have hH : 0 < H := by
    apply intervalIntegral.integral_pos (by norm_num) shape_cont.continuousOn
      (fun x _ => abs_nonneg _)
    exact ⟨0, by norm_num, by simp [gradientShape]⟩
  have hf := density_cont ε Γ
  have hslice (l : ℝ) : Continuous (density ε Γ l) :=
    hf.comp (continuous_const.prodMk continuous_id)
  have hmean : Continuous (mean ε Γ) :=
    intervalIntegral.continuous_parametric_intervalIntegral_of_continuous' hf 0 1
  have hlo : mean ε Γ Γ < 0 := by
    have ht := intervalIntegral.integral_lt_integral_of_continuousOn_of_le_of_exists_lt
      (f := density ε Γ Γ) (g := fun _ => (0:ℝ)) (a := 0) (b := 1) (by norm_num)
      (hslice Γ).continuousOn continuousOn_const
    apply lt_of_lt_of_eq (ht ?_ ?_)
    · simp
    · intro x hx
      have hx1 : gradientShape x ≤ 1 := abs_le.mpr ⟨Real.neg_one_le_cos _, Real.cos_le_one _⟩
      exact div_nonpos_of_nonpos_of_nonneg
        (mul_nonpos_of_nonpos_of_nonneg (by nlinarith) (factor_pos _).le) (by norm_num)
    · exact ⟨1/4, by norm_num, by rw [at_quarter]; exact signed_flat_negative hg⟩
  let L := Γ + (Γ+1)/H
  have hL : Γ < L := by dsimp [L]; linarith [div_pos (by linarith : 0 < Γ+1) hH]
  have hhi : 0 < mean ε Γ L := by
    have lower := intervalIntegral.integral_mono_on (a := (0:ℝ)) (b := 1) (μ := volume)
      (by norm_num) (((continuous_const.mul shape_cont).sub continuous_const).div_const 2
        |>.intervalIntegrable 0 1) ((hslice L).intervalIntegrable 0 1)
      (fun x _ => half_le_signed he (L * gradientShape x - Γ))
    change (∫ x in (0:ℝ)..1, (L * gradientShape x - Γ)/2) ≤ mean ε Γ L at lower
    have hi : (∫ x in (0:ℝ)..1, (L * gradientShape x - Γ)/2) = (L*H-Γ)/2 := by
      rw [intervalIntegral.integral_div, intervalIntegral.integral_sub (f := fun x => L * gradientShape x) (g := fun _ => Γ)
        ((continuous_const.mul shape_cont).intervalIntegrable _ _) (continuous_const.intervalIntegrable _ _),
        intervalIntegral.integral_const_mul, intervalIntegral.integral_const]
      simp [H]
    rw [hi] at lower
    have hprod : L*H = Γ*H+(Γ+1) := by dsimp [L]; field_simp
    nlinarith [mul_pos hg hH]
  obtain ⟨l, hmem, hl⟩ := intermediate_value_Icc hL.le hmean.continuousOn ⟨hlo.le,hhi.le⟩
  have hl' : Γ < l := lt_of_le_of_ne hmem.1 (fun h => by subst l; linarith)
  have hpos : 0 ≤ l := (hg.trans hl').le
  refine ⟨l,hl',?_,?_,?_⟩
  · simpa [boxPush, mean, intervalIntegral.integral_const_mul, hl] using
      (show -c * mean ε Γ l = 0 by rw [hl, mul_zero])
  · rw [scalar_gradient hpos]
    change 0 < -c * density ε Γ l (1/4)
    rw [at_quarter]
    exact mul_pos_of_neg_of_neg (neg_lt_zero.mpr hc) (signed_flat_negative hg)
  · rw [scalar_gradient hpos]
    change -c * density ε Γ l 0 < 0
    rw [at_zero]
    exact mul_neg_of_neg_of_pos (neg_lt_zero.mpr hc)
      (div_pos (mul_pos (sub_pos.mpr hl') (factor_pos _)) (by norm_num))

/-- Pressure differences cannot supply net work around a periodic coordinate loop.
The A/S force has zero component along any distinct coordinate axis. -/
theorem transverse_period (R P : ℝ → ℝ) (hP : ∀ y, HasDerivAt P (R y) y)
    (hR : Continuous R) (hperiod : P 1 = P 0) : (∫ y in (0:ℝ)..1, R y) = 0 := by
  rw [intervalIntegral.integral_eq_sub_of_hasDerivAt (fun y _ => hP y) (hR.intervalIntegrable _ _), hperiod, sub_self]

/-- s measures distance inward from the outer edge. Q is the true time derivative
of the transverse line integral at the test time when applying this lemma. -/
theorem cutoff_line_obstruction (I I₁ I₂ Q : ℝ → ℝ) {L ν B : ℝ}
    (hν : 0 < ν) (_hB : 0 ≤ B)
    (hI : ContinuousOn I (Icc 0 L)) (hI₁ : ContinuousOn I₁ (Icc 0 L))
    (hd : ∀ s ∈ Ico 0 L, HasDerivAt I (I₁ s) s)
    (hdd : ∀ s ∈ Ico 0 L, HasDerivAt I₁ (I₂ s) s)
    (h0 : I 0 = 0) (h10 : I₁ 0 = 0)
    (hbound : ∀ s ∈ Ico 0 L, |Q s| ≤ B * |I s|)
    (hw : ∃ s ∈ Icc 0 L, I s ≠ 0) :
    ¬ ∀ s ∈ Ico 0 L, Q s = ν * I₂ s := by
  intro hheat
  let J : ℝ → ℝ × ℝ := fun s => (I s,I₁ s)
  let J' : ℝ → ℝ × ℝ := fun s => (I₁ s,I₂ s)
  have hG := eq_zero_of_abs_deriv_le_mul_abs_self_of_eq_zero_right
    (f := J) (f' := J') (K := max 1 (B/ν)) (a := 0) (b := L)
    (hI.prodMk hI₁) (fun s hs => ((hd s hs).prodMk (hdd s hs)).hasDerivWithinAt)
    (show J 0 = 0 by simp [J,h0,h10])
  have bound : ∀ s ∈ Ico 0 L, ‖J' s‖ ≤ max 1 (B/ν) * ‖J s‖ := by
    intro s hs
    change max ‖I₁ s‖ ‖I₂ s‖ ≤ max 1 (B/ν) * max ‖I s‖ ‖I₁ s‖
    simp only [Real.norm_eq_abs]
    apply max_le
    · exact (le_max_right _ _).trans (le_mul_of_one_le_left (by positivity : 0 ≤ max |I s| |I₁ s|) (le_max_left _ _))
    · have hb := hbound s hs
      rw [hheat s hs,abs_mul,abs_of_pos hν] at hb
      calc |I₂ s| ≤ B/ν * |I s| := by
              rw [div_mul_eq_mul_div]
              apply (le_div_iff₀ hν).2
              linarith
            _ ≤ max 1 (B/ν) * max |I s| |I₁ s| :=
              mul_le_mul (le_max_right _ _) (le_max_left _ _) (abs_nonneg _) (by positivity)
  obtain ⟨s,hs,hn⟩ := hw
  exact hn (congrArg Prod.fst (hG bound s hs))

/-- A periodic pressure cannot remove the nonzero y-component on this x-slice. -/
theorem balanced_active_shear {ε Γ c : ℝ} (he : 0 < ε) (hg : 0 < Γ) (hc : 0 < c) :
    ∃ l > Γ, boxPush c ε Γ l = 0 ∧
    ¬ ∃ P : ℝ → ℝ, P 1 = P 0 ∧
      ∀ y, HasDerivAt P (-c * signed ε (|deriv (scalar l) 0| - Γ)) y := by
  obtain ⟨l,hl,hm,_,hn⟩ := balanced_snapshot he hg hc
  refine ⟨l,hl,hm,?_⟩
  rintro ⟨P,hP,hD⟩
  have hz := transverse_period _ P hD continuous_const hP
  simp at hz
  rcases hz with h | h
  · exact hc.ne' h
  · exact hn.ne (by rw [h,mul_zero])

/-- Integral of the transverse momentum equation over one closed coordinate line.
N is the odd transverse advection, Y the second y derivative, and P' the pressure
derivative. There is no transverse forcing from a fixed distinct coordinate axis. -/
theorem transverse_line_balance (T N X Y dP P V : ℝ → ℝ) (ν : ℝ)
    (hT : Continuous T) (hN : Continuous N) (hX : Continuous X)
    (hY : Continuous Y) (hp : Continuous dP)
    (hOdd : ∀ y : ℝ, N (-y) = -N y)
    (hD : ∀ y, HasDerivAt P (dP y) y) (hV : ∀ y, HasDerivAt V (Y y) y)
    (hPper : P (1/2) = P (-1/2)) (hVper : V (1/2) = V (-1/2))
    (hmom : ∀ y, T y + N y = ν * (X y + Y y) - dP y) :
    (∫ y in (-(1/2):ℝ)..1/2, T y) = ν * ∫ y in (-(1/2):ℝ)..1/2, X y := by
  have hi := congrArg (fun f : ℝ → ℝ => ∫ y in (-(1/2):ℝ)..1/2, f y) (funext hmom)
  have hy : (∫ y in (-(1/2):ℝ)..1/2, Y y) = 0 := by
    rw [intervalIntegral.integral_eq_sub_of_hasDerivAt (fun y _ => hV y)
      (hY.intervalIntegrable _ _)]
    linarith
  have hpr : (∫ y in (-(1/2):ℝ)..1/2, dP y) = 0 := by
    rw [intervalIntegral.integral_eq_sub_of_hasDerivAt (fun y _ => hD y)
      (hp.intervalIntegrable _ _)]
    linarith
  have hodd := intervalIntegral.integral_comp_neg (f := N) (a := (-(1/2):ℝ)) (b := 1/2)
  simp only [hOdd, intervalIntegral.integral_neg, neg_neg] at hodd
  change (∫ y in (-(1/2):ℝ)..1/2, T y + N y) =
    ∫ y in (-(1/2):ℝ)..1/2, ν*(X y+Y y)-dP y at hi
  rw [intervalIntegral.integral_add (hT.intervalIntegrable _ _) (hN.intervalIntegrable _ _),
    intervalIntegral.integral_sub (f := fun y => ν*(X y+Y y)) (g := dP)
      ((continuous_const.mul (hX.add hY)).intervalIntegrable _ _) (hp.intervalIntegrable _ _),
    intervalIntegral.integral_const_mul,
    intervalIntegral.integral_add (hX.intervalIntegrable _ _) (hY.intervalIntegrable _ _),
    hy,hpr,add_zero,sub_zero] at hi
  linarith

end SignedVortex
