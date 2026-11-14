import FrozenEuclidean

namespace FrozenPeriodicDistance
open FrozenField FrozenEuclidean Set

noncomputable def integerPoint (k : Fin 3 → ℤ) : Point := fun i => (k i : ℝ)

/-- Euclidean distance on the unit three-torus, with no floating-point wrap. -/
noncomputable def distance (x b : Point) : ℝ :=
  sInf {r : ℝ | ∃ k : Fin 3 → ℤ, r = radius (x-b+integerPoint k)}

theorem abs_le_integer_translate {a : ℝ} (ha : |a| ≤ 1/2) (k : ℤ) :
    |a| ≤ |a+(k : ℝ)| := by
  by_cases hk : k = 0
  · simp [hk]
  · have hki : (1 : ℤ) ≤ |k| := Int.one_le_abs hk
    have hkr : (1 : ℝ) ≤ |(k : ℝ)| := by exact_mod_cast hki
    have ht : |(k : ℝ)| ≤ |a+(k : ℝ)| + |a| := by
      simpa only [add_sub_cancel_left, sub_zero, zero_sub, abs_neg] using
        abs_sub_le (a+(k : ℝ)) 0 a
    linarith

theorem radius_le_integer_translate (v : Point) (hv : ∀ i, |v i| ≤ 1/2)
    (k : Fin 3 → ℤ) : radius v ≤ radius (v+integerPoint k) := by
  have hsq (i : Fin 3) : (v i)^2 ≤ ((v+integerPoint k) i)^2 := by
    have h := abs_le_integer_translate (hv i) (k i)
    simpa only [sq_abs, Pi.add_apply, integerPoint] using
      pow_le_pow_left₀ (abs_nonneg (v i)) h 2
  nlinarith [radius_sq v, radius_sq (v+integerPoint k), hsq 0, hsq 1, hsq 2,
    radius_nonneg v, radius_nonneg (v+integerPoint k)]

theorem distance_eq_radius (x b : Point) (h : ∀ i, |x i-b i| ≤ 1/2) :
    distance x b = radius (x-b) := by
  let S := {r : ℝ | ∃ k : Fin 3 → ℤ, r = radius (x-b+integerPoint k)}
  have hzero : radius (x-b) ∈ S := by
    refine ⟨fun _ => 0, ?_⟩
    change radius (x-b) = radius (x-b+integerPoint (fun _ => 0))
    have hz : integerPoint (fun _ => 0) = 0 := by
      ext i
      simp [integerPoint]
    rw [hz, add_zero]
  have hb : BddBelow S := by
    refine ⟨0, ?_⟩
    rintro r ⟨k, rfl⟩
    exact radius_nonneg _
  apply le_antisymm (csInf_le hb hzero)
  apply le_csInf ⟨_, hzero⟩
  rintro r ⟨k, rfl⟩
  exact radius_le_integer_translate (x-b) h k

theorem distance_error {x q b : Point}
    (hx : ∀ i, |x i-b i| ≤ 1/2) (hq : ∀ i, |q i-b i| ≤ 1/2) :
    |distance x b - distance q b| ≤ 2 * ‖x-q‖ := by
  rw [distance_eq_radius x b hx, distance_eq_radius q b hq]
  simpa only [sub_sub_sub_cancel_right] using radius_difference (x-b) (q-b)

theorem tube_stays_in_central_box {x q b : Point} {r : ℝ}
    (htube : ‖x-q‖ ≤ r) (hbox : ∀ i, |q i-b i| + r ≤ 1/2) :
    ∀ i, |x i-b i| ≤ 1/2 := by
  intro i
  have hc : |x i-q i| ≤ r := by
    apply le_trans _ htube
    simpa only [Pi.sub_apply, Real.norm_eq_abs] using norm_le_pi_norm (x-q) i
  have h := abs_sub_le (x i) (q i) (b i)
  linarith [hbox i]

theorem radius_lipschitz : LipschitzWith 2 radius := by
  apply LipschitzWith.of_dist_le_mul
  intro v w
  simpa only [dist_eq_norm, Real.norm_eq_abs, NNReal.coe_ofNat] using radius_difference v w

/-- A continuous window minimum from an already proved tube, a universal
candidate lower bound, and an upper witness. These obligations are not samples. -/
theorem window_minimum_from_tube
    {a b L U r : ℝ} {y q : ℝ → Point} {target : Point}
    (hab : a ≤ b) (hy : ContinuousOn y (Icc a b))
    (htube : ∀ t ∈ Icc a b, ‖y t-q t‖ ≤ r)
    (hbox : ∀ t ∈ Icc a b, ∀ i, |q t i-target i| + r ≤ 1/2)
    (hlower : ∀ t ∈ Icc a b, L + 2*r ≤ radius (q t-target))
    (hwitness : ∃ t ∈ Icc a b, radius (q t-target) + 2*r ≤ U) :
    ∃ t ∈ Icc a b,
      (∀ s ∈ Icc a b, distance (y t) target ≤ distance (y s) target) ∧
      L ≤ distance (y t) target ∧ distance (y t) target ≤ U := by
  have hcentral (t : ℝ) (ht : t ∈ Icc a b) :
      ∀ i, |y t i-target i| ≤ 1/2 :=
    tube_stays_in_central_box (htube t ht) (hbox t ht)
  have heq (t : ℝ) (ht : t ∈ Icc a b) :
      distance (y t) target = radius (y t-target) :=
    distance_eq_radius _ _ (hcentral t ht)
  have hcont : ContinuousOn (fun t => distance (y t) target) (Icc a b) := by
    have hc : ContinuousOn (fun t => radius (y t-target)) (Icc a b) :=
      radius_lipschitz.continuous.comp_continuousOn (hy.sub continuousOn_const)
    apply hc.congr
    intro t ht
    exact heq t ht
  have herr (t : ℝ) (ht : t ∈ Icc a b) :
      |distance (y t) target - radius (q t-target)| ≤ 2*r := by
    rw [heq t ht]
    have h := radius_difference (y t-target) (q t-target)
    simp only [sub_sub_sub_cancel_right] at h
    exact le_trans h (mul_le_mul_of_nonneg_left (htube t ht) (by norm_num))
  apply FrozenODE.attained_minimum_enclosure hab hcont
  · intro t ht
    have h := (abs_le.mp (herr t ht)).1
    linarith [hlower t ht]
  · obtain ⟨t, ht, hU⟩ := hwitness
    refine ⟨t, ht, ?_⟩
    have h := (abs_le.mp (herr t ht)).2
    linarith

end FrozenPeriodicDistance
