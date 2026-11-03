import HugModel
namespace Hug.Verified
open Hug

theorem pressure_nonnegative (d limit : ℝ) (hd : 0 ≤ d) (hl : 0 < limit) :
    0 ≤ pressureRatio d limit := div_nonneg hd hl.le

theorem pressure_threshold (d limit : ℝ) (hl : 0 < limit) :
    1 ≤ pressureRatio d limit ↔ limit ≤ d := by
  simpa [pressureRatio] using (le_div_iff₀ hl : 1 ≤ d / limit ↔ 1 * limit ≤ d)

theorem pressure_above_one_allowed : pressureRatio 2 1 = 2 := by norm_num [pressureRatio]

theorem tau_positive (m p : ℝ) : 0 < memoryTau m p := by
  unfold memoryTau
  split_ifs <;> norm_num

theorem memory_update_bounds (m p dt tau : ℝ) (hd : 0 ≤ dt) (ht : 0 < tau) :
    min m p ≤ memoryUpdate m p dt tau ∧ memoryUpdate m p dt tau ≤ max m p := by
  have he := (Real.exp_pos (-dt/tau)).le
  have he1 : Real.exp (-dt/tau) ≤ 1 := Real.exp_le_one_iff.mpr (div_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr hd) ht.le)
  unfold memoryUpdate
  rcases le_total m p with h | h
  · rw [min_eq_left h, max_eq_right h]
    constructor <;> nlinarith [mul_nonneg (sub_nonneg.mpr h) he, mul_nonneg (sub_nonneg.mpr h) (sub_nonneg.mpr he1)]
  · rw [min_eq_right h, max_eq_left h]
    constructor <;> nlinarith [mul_nonneg (sub_nonneg.mpr h) he, mul_nonneg (sub_nonneg.mpr h) (sub_nonneg.mpr he1)]

theorem imprint_nonnegative (m p dt : ℝ) (hm : 0 ≤ m) (hp : 0 ≤ p) (hd : 0 ≤ dt) :
    0 ≤ imprintStep m p dt :=
  le_trans (le_min hm hp) (memory_update_bounds m p dt (memoryTau m p) hd (tau_positive m p)).1

theorem no_time_no_change (m p : ℝ) : imprintStep m p 0 = m := by
  simp [imprintStep, memoryUpdate]

theorem constant_pressure_ode (m p tau t : ℝ) (ht : 0 < tau) :
    HasDerivAt (memoryPath m p tau) ((p-memoryPath m p tau t)/tau) t := by
  have h : HasDerivAt (fun x : ℝ => p+(m-p)*Real.exp (-x/tau))
      ((m-p)*(Real.exp (-t/tau)*(-1/tau))) t :=
    ((((hasDerivAt_id t).neg.div_const tau).exp).const_mul (m-p)).const_add p
  have he : (p-memoryPath m p tau t)/tau = (m-p)*(Real.exp (-t/tau)*(-1/tau)) := by
    unfold memoryPath memoryUpdate
    ring
  rw [he]
  exact h

theorem memory_above_one_reachable : imprintStep 0 2 ((4/5)*Real.log 4) = 3/2 := by
  norm_num [imprintStep, memoryTau, memoryUpdate]
  rw [show -(4 / 5 * Real.log 4) / (4 / 5 : ℝ) = -Real.log 4 by ring]
  rw [Real.exp_neg, Real.exp_log (by norm_num : (0:ℝ) < 4)]
  norm_num

theorem zero_pressure_retains_imprint (m dt : ℝ) (hm : 0 < m) (hd : 0 ≤ dt) :
    0 < imprintStep m 0 dt ∧ imprintStep m 0 dt ≤ m := by
  constructor
  · simpa [imprintStep, memoryUpdate] using mul_pos hm (Real.exp_pos (-dt/memoryTau m 0))
  · simpa [imprintStep, max_eq_left hm.le] using (memory_update_bounds m 0 dt (memoryTau m 0) hd (tau_positive m 0)).2

theorem breathing_bounds (t : ℝ) :
    1/50 ≤ breathingCoefficient t ∧ breathingCoefficient t ≤ 3/50 := by
  have h₁ := Real.neg_one_le_sin (2*Real.pi*t/3)
  have h₂ := Real.sin_le_one (2*Real.pi*t/3)
  unfold breathingCoefficient
  constructor <;> linarith

theorem pressure_scale_bounds (m t : ℝ) (hm : 0 ≤ m) :
    1+m/50 ≤ pressureScale m t ∧ pressureScale m t ≤ 1+3*m/50 := by
  obtain ⟨h₁,h₂⟩ := breathing_bounds t
  have a := mul_le_mul_of_nonneg_left h₁ hm
  have b := mul_le_mul_of_nonneg_left h₂ hm
  unfold pressureScale
  constructor <;> nlinarith

theorem reciprocal_squeeze_bounds (m t : ℝ) (hm : 0 ≤ m) :
    0 < squeeze (pressureScale m t) ∧ squeeze (pressureScale m t) ≤ 1 := by
  have hs : 1 ≤ pressureScale m t := by linarith [(pressure_scale_bounds m t hm).1]
  have hp : 0 < pressureScale m t := lt_of_lt_of_le zero_lt_one hs
  exact ⟨one_div_pos.mpr hp, (div_le_iff₀ hp).mpr (by simpa using hs)⟩

theorem reciprocal_area_factor (s : ℝ) (hs : 0 < s) : s*squeeze s = 1 := by
  simp [squeeze, ne_of_gt hs]

theorem inverse_stretch (s x y : ℝ) (hs : 0 < s) :
    stretchPoint (1/s) (stretchPoint s x y).1 (stretchPoint s x y).2 = (x,y) := by
  ext <;> dsimp [stretchPoint, squeeze] <;> field_simp

theorem mirror_arms (b sx sy c v : ℝ) :
    rightArm b sx sy c v = (-(leftArm b sx sy c v).1,(leftArm b sx sy c v).2) := by
  simp [rightArm, leftArm]

theorem exact_tip_closure (b sx : ℝ) (hs : 0 < sx) : endpointGap b sx = 0 ↔ b = 1 := by
  simp only [endpointGap, rightArm, leftArm, horizontal, mul_zero, add_zero, sub_neg_eq_add]
  constructor
  · intro h
    have : sx*(1-b)=0 := by linarith
    rcases mul_eq_zero.mp this with h | h
    · exact False.elim (ne_of_gt hs h)
    · linarith
  · intro h
    simp [h]

theorem tolerance_is_not_exact_closure :
    let b : ℝ := 1-1/(4*10^12)
    UnitInterval b ∧ reportedConnected b 1 ∧ endpointGap b 1 ≠ 0 := by
  norm_num [UnitInterval, reportedConnected, endpointGap, rightArm, leftArm, horizontal]

theorem timed_stretch_bounds (u : ℝ) (hu : UnitInterval u) :
    1 ≤ timedScale u ∧ timedScale u ≤ 27/25 := by
  obtain ⟨hu0,hu1⟩ := hu
  have hq0 : 0 ≤ u*(1-u) := mul_nonneg hu0 (sub_nonneg.mpr hu1)
  have hq1 : u*(1-u) ≤ (1/4:ℝ) := by nlinarith [sq_nonneg (2*u-1)]
  have hc : (u*(1-u))^3 ≤ (1/4:ℝ)^3 := by gcongr
  have hc0 := pow_nonneg hq0 3
  have heq : timedScale u = 1+(2/25)*64*(u*(1-u))^3 := by unfold timedScale timedPulse; ring
  rw [heq]
  constructor <;> nlinarith

theorem timed_maximum : timedScale (1/2) = 27/25 := by norm_num [timedScale, timedPulse]

theorem smoothstep_bounds (x : ℝ) : UnitInterval (smoothstep x) := by
  have hc0 : 0 ≤ clip x := le_min (by norm_num) (le_max_left _ _)
  have hc1 : clip x ≤ 1 := min_le_left _ _
  have hp : 0 ≤ 1-clip x := sub_nonneg.mpr hc1
  have hq : 0 ≤ 9-6*clip x := by linarith
  have h₁ := mul_nonneg (pow_nonneg hc0 3) (show 0 ≤ 1+(1-clip x)*(9-6*clip x) by positivity)
  have h₂ := mul_nonneg (pow_nonneg hp 3) (show 0 ≤ 1+3*clip x+6*(clip x)^2 by positivity)
  change 0 ≤ quintic (clip x) ∧ quintic (clip x) ≤ 1
  unfold quintic
  constructor <;> nlinarith

theorem opening_threshold (p dt : ℝ) :
    nextOpeningAge none p dt ≠ none ↔ 1 ≤ p := by
  unfold nextOpeningAge
  split_ifs <;> simp_all

theorem opening_latched (age p dt : ℝ) :
    nextOpeningAge (some age) p dt = some (age+dt) := rfl

theorem lower_pressure_does_not_reclose (age dt : ℝ) :
    nextOpeningAge (some age) 0 dt ≠ none := by simp [nextOpeningAge]

theorem full_open_after_duration (age : ℝ) (ha : 4/5 ≤ age) :
    openingBend (some age) = 0 := by
  have h : 1 ≤ age/(4/5:ℝ) := (le_div_iff₀ (by norm_num)).mpr (by simpa using ha)
  have hm : 1 ≤ max 0 (age/(4/5:ℝ)) := le_trans h (le_max_right _ _)
  norm_num [openingBend, smoothstep, clip, min_eq_left hm, quintic]

theorem step_preserves_state (x : State) (p dt : ℝ) (hx : StateOK x)
    (hp : 0 ≤ p) (hd : 0 ≤ dt) : StateOK (step x p dt) := by
  obtain ⟨hm,ht,ha⟩ := hx
  refine ⟨imprint_nonnegative _ _ _ hm hp hd, add_nonneg ht hd, ?_⟩
  intro a he
  change nextOpeningAge x.openingAge p dt = some a at he
  cases hage : x.openingAge with
  | none =>
    simp only [hage, nextOpeningAge] at he
    split_ifs at he with h
    · cases he; exact hd
  | some old =>
    simp only [hage, nextOpeningAge, Option.some.injEq] at he
    rw [← he]
    exact add_nonneg (ha old hage) hd

theorem repeated_steps_nonnegative (ps ds : ℕ → ℝ)
    (hp : ∀ n, 0 ≤ ps n) (hd : ∀ n, 0 ≤ ds n) :
    ∀ n, StateOK (Nat.rec initial (fun n x => step x (ps n) (ds n)) n) := by
  intro n
  induction n with
  | zero => simp [StateOK, initial]
  | succ n ih => exact step_preserves_state _ _ _ ih (hp n) (hd n)

end Hug.Verified
