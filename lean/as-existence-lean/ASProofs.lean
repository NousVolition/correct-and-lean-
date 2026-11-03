import ASModel
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.FinCases

/- Proofs of the frozen targets; no import of ASChallenge. -/
namespace SocialAS.Verified
open SocialAS

theorem saturation_bounds (L s : ℝ) (hL : 0 ≤ L) (hs : 0 < s) :
    0 ≤ saturation L s ∧ saturation L s < 1 := by
  unfold saturation
  constructor
  · exact div_nonneg hL (by linarith)
  · exact (div_lt_one (by linarith : 0 < L+s)).2 (by linarith)
theorem effect_bounds (g L s : ℝ) (hg : UnitInterval g) (hL : 0 ≤ L) (hs : 0 < s) :
    UnitInterval (effect g L s) := by
  have h := saturation_bounds L s hL hs
  unfold UnitInterval effect
  constructor
  · exact mul_nonneg hg.1 h.1
  · calc
      g * saturation L s ≤ g * 1 := mul_le_mul_of_nonneg_left (le_of_lt h.2) hg.1
      _ ≤ 1 := by simpa using hg.2
theorem exchange_no_increase (w chi gap : ℝ) (hw : 0 ≤ w) (hc : 0 ≤ chi) :
    exchange w chi gap ≤ w * gap := by
  have hpos : 0 ≤ pos gap := le_max_right _ _
  have hprod := mul_nonneg hw (mul_nonneg hc hpos)
  unfold exchange
  nlinarith
theorem exchange_negative_unchanged (w chi gap : ℝ) (hgap : gap ≤ 0) :
    exchange w chi gap = w * gap := by
  simp [exchange, pos, max_eq_right hgap]
theorem exchange_monotone (w chi a b : ℝ) (hw : 0 ≤ w) (hc : UnitInterval chi)
    (hab : a ≤ b) : exchange w chi a ≤ exchange w chi b := by
  by_cases ha : a ≤ 0
  · rw [exchange_negative_unchanged w chi a ha]
    by_cases hb : b ≤ 0
    · rw [exchange_negative_unchanged w chi b hb]
      exact mul_le_mul_of_nonneg_left hab hw
    · have hb0 : 0 ≤ b := le_of_not_ge hb
      have hnon : 0 ≤ exchange w chi b := by
        unfold exchange pos
        rw [max_eq_left hb0]
        apply mul_nonneg hw
        nlinarith [mul_nonneg (sub_nonneg.mpr hc.2) hb0]
      exact le_trans (mul_nonpos_of_nonneg_of_nonpos hw ha) hnon
  · have ha0 : 0 ≤ a := le_of_not_ge ha
    have hb0 : 0 ≤ b := le_trans ha0 hab
    simp only [exchange, pos, max_eq_left ha0, max_eq_left hb0]
    calc
      w * (a-chi*a) = (w*(1-chi))*a := by ring
      _ ≤ (w*(1-chi))*b := mul_le_mul_of_nonneg_left hab (mul_nonneg hw (sub_nonneg.mpr hc.2))
      _ = w * (b-chi*b) := by ring
theorem general_smoke_agrees (p : Parameters) (x : State) :
    generalSDrift p x 0 = smokeDrift p x := by
  simp [generalSDrift, Fin.sum_univ_two, roleW, incomingChi, roleS, roleK, smokeDrift]
theorem general_clay_agrees (p : Parameters) (x : State) :
    generalSDrift p x 1 = clayDrift p x := by
  simp [generalSDrift, Fin.sum_univ_two, roleW, incomingChi, roleS, roleK, clayDrift]
theorem total_influence_balance (p : Parameters) (x : State)
    (hK : p.KSmoke + p.KClay = 1) :
    smokeDrift p x + clayDrift p x = source p x - p.decay * (x 1 + x 2) +
      (p.wClaySmoke - p.wSmokeClay) * (x 1 - x 2) -
      p.wClaySmoke * chiForward p x * pos (x 1 - x 2) -
      p.wSmokeClay * chiReverse p x * pos (x 2 - x 1) := by
  have hK' : p.KSmoke * source p x + p.KClay * source p x = source p x := by
    calc
      _ = (p.KSmoke+p.KClay)*source p x := by ring
      _ = source p x := by rw [hK]; ring
  unfold smokeDrift clayDrift exchange
  nlinarith [hK']
theorem received_meaning_bounds (theta z imposed : ℝ)
    (ht : UnitInterval theta) (hz : UnitInterval z) (hi : UnitInterval imposed) :
    UnitInterval (receivedMeaning theta z imposed) := by
  unfold UnitInterval receivedMeaning
  constructor
  · exact add_nonneg (mul_nonneg (sub_nonneg.mpr ht.2) hz.1) (mul_nonneg ht.1 hi.1)
  · calc
      (1-theta)*z + theta*imposed ≤ (1-theta)*1 + theta*1 :=
        add_le_add (mul_le_mul_of_nonneg_left hz.2 (sub_nonneg.mpr ht.2))
          (mul_le_mul_of_nonneg_left hi.2 ht.1)
      _ = 1 := by ring
theorem meaning_rate_bounds (w chi S s : ℝ) (hw : 0 ≤ w)
    (hc : UnitInterval chi) (hs : 0 < s) :
    0 ≤ meaningRate w chi S s ∧ meaningRate w chi S s ≤ w := by
  have hp : 0 ≤ pos S := le_max_right _ _
  have hd : 0 < s + pos S := by linarith
  unfold meaningRate
  constructor
  · exact div_nonneg (mul_nonneg (mul_nonneg (sub_nonneg.mpr hc.2) hw) hp) (le_of_lt hd)
  · apply (div_le_iff₀ hd).2
    have h1 := mul_nonneg (mul_nonneg hc.1 hw) hp
    have h2 := mul_nonneg hw (le_of_lt hs)
    nlinarith
theorem meaning_lower_boundary (k received clear ref : ℝ)
    (hk : 0 ≤ k) (hr : 0 ≤ received) (hc : 0 ≤ clear) (hf : 0 ≤ ref) :
    0 ≤ meaningDrift k received 0 clear ref := by
  simp only [meaningDrift, sub_zero]
  exact add_nonneg (mul_nonneg hk hr) (mul_nonneg hc hf)
theorem meaning_upper_boundary (k received clear ref : ℝ)
    (hk : 0 ≤ k) (hr : received ≤ 1) (hc : 0 ≤ clear) (hf : ref ≤ 1) :
    meaningDrift k received 1 clear ref ≤ 0 := by
  unfold meaningDrift
  exact add_nonpos (mul_nonpos_of_nonneg_of_nonpos hk (sub_nonpos.mpr hr))
    (mul_nonpos_of_nonneg_of_nonpos hc (sub_nonpos.mpr hf))
theorem load_lower_boundary (alpha exposure clear : ℝ) (h : Bool)
    (ha : 0 ≤ alpha) (he : 0 ≤ exposure) :
    0 ≤ loadDrift alpha h exposure clear 0 := by
  cases h
  · simp [loadDrift, indicator]
  · simpa [loadDrift, indicator] using mul_nonneg ha he
theorem activation_nonnegative (clay threshold : ℝ) :
    0 ≤ activation clay threshold := by
  exact le_max_right _ _
theorem opening_bounds (g p0 r s : ℝ) (hg : UnitInterval g)
    (hp : UnitInterval p0) (hr : 0 ≤ r) (hs : 0 < s) :
    0 ≤ opening g p0 r s ∧ opening g p0 r s ≤ g := by
  have hd : 0 < s+r := by linarith
  have hratio0 : 0 ≤ r/(s+r) := div_nonneg hr (le_of_lt hd)
  have hratio1 : r/(s+r) ≤ 1 := (div_le_one hd).2 (by linarith)
  have hinner0 : 0 ≤ p0+(1-p0)*(r/(s+r)) :=
    add_nonneg hp.1 (mul_nonneg (sub_nonneg.mpr hp.2) hratio0)
  have hinner1 : p0+(1-p0)*(r/(s+r)) ≤ 1 := by
    calc
      _ ≤ p0+(1-p0)*1 := add_le_add_right (mul_le_mul_of_nonneg_left hratio1 (sub_nonneg.mpr hp.2)) _
      _ = 1 := by ring
  have heq : opening g p0 r s = g*(p0+(1-p0)*(r/(s+r))) := by unfold opening; ring
  rw [heq]
  constructor
  · exact mul_nonneg hg.1 hinner0
  · simpa using mul_le_mul_of_nonneg_left hinner1 hg.1
theorem registration_bounds (eta z v : ℝ) (he : UnitInterval eta)
    (hz : UnitInterval z) (hv : UnitInterval v) :
    0 ≤ registration eta z v ∧ registration eta z v ≤ eta := by
  have hprod0 := mul_nonneg hz.1 hv.1
  have hprod1 : z*v ≤ 1 := calc
    z*v ≤ 1*v := mul_le_mul_of_nonneg_right hz.2 hv.1
    _ ≤ 1 := by simpa using hv.2
  unfold registration
  constructor
  · exact mul_nonneg he.1 (sub_nonneg.mpr hprod1)
  · have hh : 1-z*v ≤ 1 := by linarith
    simpa using mul_le_mul_of_nonneg_left hh he.1
theorem no_opening_no_registration (eta z v : ℝ) :
    conditionalRegistration eta z v false = 0 := by
  simp [conditionalRegistration, indicator]
theorem fully_qualified_blocks_challenge (eta : ℝ) :
    registration eta 1 1 = 0 := by
  simp [registration]
theorem confirmation_unchanged (eta z : ℝ) :
    registration eta z 0 = eta := by
  simp [registration]
theorem branch_distribution (p q : ℝ) (hp : UnitInterval p) (hq : UnitInterval q) :
    (∀ j, 0 ≤ branches p q j) ∧ (∑ j, branches p q j) = 1 := by
  constructor
  · intro j
    fin_cases j
    · simpa [branches] using sub_nonneg.mpr hp.2
    · simpa [branches] using mul_nonneg hp.1 (sub_nonneg.mpr hq.2)
    · simpa [branches] using mul_nonneg hp.1 hq.1
  · simp [branches, Fin.sum_univ_succ]
    ring
theorem update_no_contribution (beta : ℝ) (H M : Meaning) :
    update beta false H M = H := by
  funext j
  simp [update, information, indicator]
theorem update_same_meaning (beta : ℝ) (C : Bool) (H : Meaning) :
    update beta C H H = H := by
  funext j
  simp [update, information]
theorem update_is_convex (beta : ℝ) (H M : Meaning) :
    update beta true H M = fun j => (1-beta) * H j + beta * M j := by
  funext j
  simp only [update, information, indicator, ite_true, one_mul]
  ring
theorem update_preserves_simplex (beta : ℝ) (C : Bool) (H M : Meaning)
    (hb : UnitInterval beta) (hH : Simplex H) (hM : Simplex M) :
    Simplex (update beta C H M) := by
  cases C
  · simpa [update_no_contribution] using hH
  · rw [update_is_convex]
    constructor
    · intro j
      exact add_nonneg (mul_nonneg (sub_nonneg.mpr hb.2) (hH.1 j)) (mul_nonneg hb.1 (hM.1 j))
    · calc
        (∑ j : Fin 2, ((1-beta)*H j + beta*M j)) = (1-beta)*(∑ j : Fin 2, H j)+beta*(∑ j : Fin 2, M j) := by
          simp only [Fin.sum_univ_two]
          ring
        _ = 1 := by rw [hH.2, hM.2]; ring
theorem constant_accumulation_solves (A0 gamma utility baseline t : ℝ) :
    HasDerivAt (fun s : ℝ => A0 + gamma * (utility-baseline) * s)
      (accumulatedDrift gamma utility baseline) t := by
  simpa [accumulatedDrift] using
    (((hasDerivAt_id t).const_mul (gamma*(utility-baseline))).const_add A0)
theorem constant_exposure_solves (L0 alpha exposure t : ℝ) (h : Bool) :
    HasDerivAt (fun s : ℝ => L0 + alpha * indicator h * exposure * s)
      (loadDrift alpha h exposure 0 (L0 + alpha * indicator h * exposure * t)) t := by
  simpa [loadDrift] using
    (((hasDerivAt_id t).const_mul (alpha*indicator h*exposure)).const_add L0)
theorem constant_exposure_nonnegative (L0 alpha exposure t : ℝ) (h : Bool)
    (hL : 0 ≤ L0) (ha : 0 ≤ alpha) (he : 0 ≤ exposure) (ht : 0 ≤ t) :
    0 ≤ L0 + alpha * indicator h * exposure * t := by
  have hi : 0 ≤ indicator h := by cases h <;> norm_num [indicator]
  exact add_nonneg hL (mul_nonneg (mul_nonneg (mul_nonneg ha hi) he) ht)
theorem clearing_solves (L0 clear t : ℝ) :
    HasDerivAt (fun s : ℝ => L0 * Real.exp (-clear*s))
      (-clear * (L0 * Real.exp (-clear*t))) t := by
  have h := (((hasDerivAt_id t).const_mul (-clear)).exp).const_mul L0
  simpa only [id_eq, mul_one, mul_comm, mul_left_comm, mul_assoc] using h
theorem clearing_preserves_nonnegative (L0 clear t : ℝ) (hL : 0 ≤ L0) :
    0 ≤ L0 * Real.exp (-clear*t) := by
  exact mul_nonneg hL (le_of_lt (Real.exp_pos _))
theorem cleared_equal_meaning_has_zero_drift (k z : ℝ) :
    meaningDrift k (receivedMeaning 0 z 1) z 0 0 = 0 := by
  simp [meaningDrift, receivedMeaning]

end SocialAS.Verified

#print axioms SocialAS.Verified.saturation_bounds
#print axioms SocialAS.Verified.effect_bounds
#print axioms SocialAS.Verified.exchange_no_increase
#print axioms SocialAS.Verified.exchange_negative_unchanged
#print axioms SocialAS.Verified.exchange_monotone
#print axioms SocialAS.Verified.general_smoke_agrees
#print axioms SocialAS.Verified.general_clay_agrees
#print axioms SocialAS.Verified.total_influence_balance
#print axioms SocialAS.Verified.received_meaning_bounds
#print axioms SocialAS.Verified.meaning_rate_bounds
#print axioms SocialAS.Verified.meaning_lower_boundary
#print axioms SocialAS.Verified.meaning_upper_boundary
#print axioms SocialAS.Verified.load_lower_boundary
#print axioms SocialAS.Verified.activation_nonnegative
#print axioms SocialAS.Verified.opening_bounds
#print axioms SocialAS.Verified.registration_bounds
#print axioms SocialAS.Verified.no_opening_no_registration
#print axioms SocialAS.Verified.fully_qualified_blocks_challenge
#print axioms SocialAS.Verified.confirmation_unchanged
#print axioms SocialAS.Verified.branch_distribution
#print axioms SocialAS.Verified.update_no_contribution
#print axioms SocialAS.Verified.update_same_meaning
#print axioms SocialAS.Verified.update_is_convex
#print axioms SocialAS.Verified.update_preserves_simplex
#print axioms SocialAS.Verified.constant_accumulation_solves
#print axioms SocialAS.Verified.constant_exposure_solves
#print axioms SocialAS.Verified.constant_exposure_nonnegative
#print axioms SocialAS.Verified.clearing_solves
#print axioms SocialAS.Verified.clearing_preserves_nonnegative
#print axioms SocialAS.Verified.cleared_equal_meaning_has_zero_drift
