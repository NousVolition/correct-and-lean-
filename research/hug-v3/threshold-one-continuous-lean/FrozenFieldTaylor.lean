import FrozenField

namespace FrozenFieldTaylor
open FrozenField

theorem cos_first_order (a d : ℝ) :
    |Real.cos (a+d) - Real.cos a + Real.sin a * d| ≤ d^2 := by
  by_cases hd : |d| ≤ 3
  · have hc : |Real.cos d - 1| ≤ d^2/2 := by
      rw [abs_of_nonpos (sub_nonpos.mpr (Real.cos_le_one d))]
      linarith [Real.one_sub_sq_div_two_le_cos (x := d)]
    have hs : |Real.sin d - d| ≤ |d|^3/6 := by
      simpa only [abs_sub_comm] using Real.abs_sub_sin_le d
    have heq : Real.cos (a+d) - Real.cos a + Real.sin a * d =
        Real.cos a * (Real.cos d - 1) - Real.sin a * (Real.sin d - d) := by
      rw [Real.cos_add]; ring
    rw [heq]
    have hpow : |d|^3 ≤ 3*d^2 := by
      calc
        _ = d^2 * |d| := by rw [pow_succ, sq_abs]
        _ ≤ d^2 * 3 := mul_le_mul_of_nonneg_left hd (sq_nonneg d)
        _ = _ := by ring
    calc
      _ ≤ |Real.cos a * (Real.cos d - 1)| + |Real.sin a * (Real.sin d - d)| := by
        simpa only [sub_eq_add_neg, abs_neg] using abs_add_le
          (Real.cos a * (Real.cos d - 1)) (-(Real.sin a * (Real.sin d - d)))
      _ ≤ 1 * (d^2/2) + 1 * (|d|^3/6) := by
        simp only [abs_mul]
        gcongr
        · exact Real.abs_cos_le_one _
        · exact Real.abs_sin_le_one _
      _ ≤ d^2 := by nlinarith
  · have hd' : 3 < |d| := lt_of_not_ge hd
    calc
      _ ≤ |Real.cos (a+d)| + |Real.cos a| + |Real.sin a * d| := by
        simpa only [sub_eq_add_neg, abs_neg] using
          abs_add_three (Real.cos (a+d)) (-Real.cos a) (Real.sin a * d)
      _ ≤ 1 + 1 + 1 * |d| := by
        rw [abs_mul]
        gcongr
        · exact Real.abs_cos_le_one _
        · exact Real.abs_cos_le_one _
        · exact Real.abs_sin_le_one _
      _ ≤ d^2 := by nlinarith [sq_abs d]

theorem sin_first_order (a d : ℝ) :
    |Real.sin (a+d) - Real.sin a - Real.cos a * d| ≤ d^2 := by
  have h := cos_first_order (Real.pi/2-a) (-d)
  rw [show Real.pi/2-a + -d = Real.pi/2-(a+d) by ring,
    Real.cos_pi_div_two_sub, Real.cos_pi_div_two_sub, Real.sin_pi_div_two_sub,
    mul_neg, neg_sq] at h
  simpa only [sub_eq_add_neg] using h

noncomputable def shift (w : Wave) (δ : Point) : ℝ :=
  2 * Real.pi * ((w.k₀ : ℝ)*δ 0 + (w.k₁ : ℝ)*δ 1 + (w.k₂ : ℝ)*δ 2)

noncomputable def linearPart (w : Wave) (D : ℕ) (x δ : Point) : ℝ :=
  (-(w.re : ℝ)/D * Real.sin (w.phase x) - (w.im : ℝ)/D * Real.cos (w.phase x)) * shift w δ

theorem phase_add (w : Wave) (x δ : Point) : w.phase (x+δ) = w.phase x + shift w δ := by
  simp only [Wave.phase, shift, Pi.add_apply]
  ring

theorem shift_bound (w : Wave) (x δ : Point) : |shift w δ| ≤ 8*w.frequency*‖δ‖ := by
  have h := phase_difference_bound w (x+δ) x
  simpa only [phase_add, add_sub_cancel_left, add_sub_cancel_left] using h

theorem wave_remainder (w : Wave) {D : ℕ} (hD : 0 < D) (x δ : Point) :
    |w.value D (x+δ) - w.value D x - linearPart w D x δ| ≤
      64 * (w.mass * w.frequency^2 : ℕ) / D * ‖δ‖^2 := by
  have hd : (0 : ℝ) < D := by exact_mod_cast hD
  have hc := cos_first_order (w.phase x) (shift w δ)
  have hs := sin_first_order (w.phase x) (shift w δ)
  have hshift := shift_bound w x δ
  have hsq : (shift w δ)^2 ≤ (8*(w.frequency : ℝ)*‖δ‖)^2 := by
    simpa only [sq_abs] using pow_le_pow_left₀ (abs_nonneg (shift w δ)) hshift 2
  have heq : w.value D (x+δ) - w.value D x - linearPart w D x δ =
      (w.re : ℝ)/D * (Real.cos (w.phase x + shift w δ) - Real.cos (w.phase x) + Real.sin (w.phase x)*shift w δ) -
      (w.im : ℝ)/D * (Real.sin (w.phase x + shift w δ) - Real.sin (w.phase x) - Real.cos (w.phase x)*shift w δ) := by
    simp only [Wave.value, linearPart, phase_add]
    ring
  rw [heq]
  calc
    _ ≤ |(w.re : ℝ)/D * (Real.cos (w.phase x + shift w δ) - Real.cos (w.phase x) + Real.sin (w.phase x)*shift w δ)| +
        |(w.im : ℝ)/D * (Real.sin (w.phase x + shift w δ) - Real.sin (w.phase x) - Real.cos (w.phase x)*shift w δ)| := by
      simpa only [sub_eq_add_neg, abs_neg] using abs_add_le
        ((w.re : ℝ)/D * (Real.cos (w.phase x + shift w δ) - Real.cos (w.phase x) + Real.sin (w.phase x)*shift w δ))
        (-((w.im : ℝ)/D * (Real.sin (w.phase x + shift w δ) - Real.sin (w.phase x) - Real.cos (w.phase x)*shift w δ)))
    _ ≤ |(w.re : ℝ)|/D * (shift w δ)^2 + |(w.im : ℝ)|/D * (shift w δ)^2 := by
      simp only [abs_mul, abs_div, abs_of_pos hd]
      gcongr
    _ ≤ |(w.re : ℝ)|/D * (8*(w.frequency : ℝ)*‖δ‖)^2 +
        |(w.im : ℝ)|/D * (8*(w.frequency : ℝ)*‖δ‖)^2 := by gcongr
    _ = _ := by
      simp only [Wave.mass, Nat.cast_mul, Nat.cast_pow, Nat.cast_add, Nat.cast_natAbs, Int.cast_abs]
      ring

def secondMass (ws : List Wave) : ℕ := (ws.map (fun w => w.mass * w.frequency^2)).sum

noncomputable def fieldLinear (ws : List Wave) (D : ℕ) (x δ : Point) : ℝ :=
  (ws.map (fun w => linearPart w D x δ)).sum

theorem field_remainder (ws : List Wave) {D : ℕ} (hD : 0 < D) (x δ : Point) :
    |value ws D (x+δ) - value ws D x - fieldLinear ws D x δ| ≤
      64 * (secondMass ws : ℝ) / D * ‖δ‖^2 := by
  induction ws with
  | nil => simp [value, fieldLinear, secondMass]
  | cons w ws ih =>
    simp only [value, fieldLinear, secondMass, List.map_cons, List.sum_cons, Nat.cast_add] at *
    calc
      _ = |(w.value D (x+δ) - w.value D x - linearPart w D x δ) +
        ((ws.map (fun w => w.value D (x+δ))).sum -
          (ws.map (fun w => w.value D x)).sum - (ws.map (fun w => linearPart w D x δ)).sum)| := by congr 1; ring
      _ ≤ |w.value D (x+δ) - w.value D x - linearPart w D x δ| +
        |(ws.map (fun w => w.value D (x+δ))).sum -
          (ws.map (fun w => w.value D x)).sum - (ws.map (fun w => linearPart w D x δ)).sum| := abs_add_le _ _
      _ ≤ 64 * (w.mass * w.frequency^2 : ℕ) / D * ‖δ‖^2 +
        64 * (((ws.map (fun w => w.mass * w.frequency^2)).sum : ℕ) : ℝ) / D * ‖δ‖^2 :=
        add_le_add (wave_remainder w hD x δ) ih
      _ = _ := by ring

end FrozenFieldTaylor
