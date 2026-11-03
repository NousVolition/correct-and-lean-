import ASModel
import Mathlib.Tactic

/-!
# Formal Proofs of Algebraic, Simplex, Invariance, Lipschitz, and Uniqueness Properties for `ASModel.lean`

This module proves core mathematical properties on top of the unchanged `ASModel.lean`
(`namespace SocialAS`, equations E1–E16 of the frozen Monoxide-buildup register):

1. **Positive-part (`pos`) and `indicator` properties**, including the global 1-Lipschitz
   bound `|pos x - pos y| ≤ |x - y|`.
2. **Saturation and load-effect bounds (E11, E13)** under `ParametersOK` and `StateOK`,
   proving `chiForward`, `chiReverse`, `thetaForward`, and `thetaReverse` lie in `[0, 1]`,
   together with the exact quotient Lipschitz identity for `saturation`.
3. **Role-indexed drift equivalence and conservation laws (E3–E5)**, proving
   `generalSDrift p x 0 = smokeDrift p x`, `generalSDrift p x 1 = clayDrift p x`,
   total $S$-balance, and the global Lipschitz bound
   `|exchange w chi g₁ - exchange w chi g₂| ≤ w * |g₁ - g₂|`.
4. **Inward-pointing boundary drift conditions for `StateOK` invariance (E12, E14–E16)**,
   showing nonnegativity of `loadDrift` at $L = 0$ and inward sign of `meaningDrift`,
   `smokeMeaningDrift`, and `clayMeaningDrift` at $z = 0$ and $z = 1$.
5. **Encounter probability bounds and meaning-simplex preservation (E6–E10)**,
   proving `opening` and `conditionalRegistration` lie in `[0, 1]`, `branches p q` forms
   a 3-outcome probability simplex, `update beta false H M = H`, and `update` preserves `Simplex`.
6. **Integral-equation uniqueness results (`IntegralSolution`)**, including unconditional
   uniqueness of the accumulated source coordinate `x t 0 = y t 0`, the exact integral
   difference identity for all seven coordinates, and cascade uniqueness.
-/

namespace SocialAS.Verified
noncomputable section
open MeasureTheory Set

/-! ## 1. Positive-Part (`pos`) and Boolean `indicator` Lemmas -/

theorem pos_nonneg (x : ℝ) : 0 ≤ pos x :=
  le_max_right x 0

theorem self_le_pos (x : ℝ) : x ≤ pos x :=
  le_max_left x 0

theorem pos_of_nonneg {x : ℝ} (hx : 0 ≤ x) : pos x = x :=
  max_eq_left hx

theorem pos_of_nonpos {x : ℝ} (hx : x ≤ 0) : pos x = 0 :=
  max_eq_right hx

theorem pos_eq_zero_of_nonpos {x : ℝ} (hx : x ≤ 0) : pos x = 0 :=
  max_eq_right hx

theorem abs_pos_sub_pos_le (x y : ℝ) : |pos x - pos y| ≤ |x - y| := by
  rcases le_total x 0 with hx | hx <;> rcases le_total y 0 with hy | hy
  · rw [pos_of_nonpos hx, pos_of_nonpos hy, sub_self, abs_zero]
    exact abs_nonneg (x - y)
  · rw [pos_of_nonpos hx, pos_of_nonneg hy, abs_le]
    constructor <;> linarith [le_abs_self (x - y), neg_le_abs (x - y)]
  · rw [pos_of_nonneg hx, pos_of_nonpos hy, abs_le]
    constructor <;> linarith [le_abs_self (x - y), neg_le_abs (x - y)]
  · rw [pos_of_nonneg hx, pos_of_nonneg hy]

theorem indicator_false : indicator false = 0 := rfl

theorem indicator_true : indicator true = 1 := rfl

theorem indicator_unit (b : Bool) : UnitInterval (indicator b) := by
  cases b <;> constructor <;> norm_num [indicator]

/-! ## 2. Saturation and Load-Effect Bounds & Lipschitz Estimates (E11, E13) -/

theorem saturation_nonneg {L scale : ℝ} (hL : 0 ≤ L) (hs : 0 < scale) :
    0 ≤ saturation L scale := by
  unfold saturation
  exact div_nonneg hL (by linarith)

theorem one_sub_saturation {L scale : ℝ} (hne : L + scale ≠ 0) :
    1 - saturation L scale = scale / (L + scale) := by
  unfold saturation
  field_simp
  ring

theorem saturation_le_one {L scale : ℝ} (hL : 0 ≤ L) (hs : 0 < scale) :
    saturation L scale ≤ 1 := by
  have hden : 0 < L + scale := by linarith
  have hne : L + scale ≠ 0 := ne_of_gt hden
  have hdiff : 0 ≤ 1 - saturation L scale := by
    rw [one_sub_saturation hne]
    exact div_nonneg (le_of_lt hs) (le_of_lt hden)
  linarith

theorem saturation_unit {L scale : ℝ} (hL : 0 ≤ L) (hs : 0 < scale) :
    UnitInterval (saturation L scale) :=
  ⟨saturation_nonneg hL hs, saturation_le_one hL hs⟩

theorem effect_unit {gain L scale : ℝ} (hg : UnitInterval gain)
    (hL : 0 ≤ L) (hs : 0 < scale) :
    UnitInterval (effect gain L scale) := by
  rcases hg with ⟨hg0, hg1⟩
  rcases saturation_unit hL hs with ⟨hs0, hs1⟩
  unfold effect
  constructor
  · exact mul_nonneg hg0 hs0
  · nlinarith

theorem chiForward_unit {p : Parameters} {x : State}
    (hp : ParametersOK p) (hx : StateOK x) :
    UnitInterval (chiForward p x) := by
  rcases hp with ⟨_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, hLstar, _, hchi, _, _, _, _, _⟩
  rcases hx with ⟨hx3, _, _, _⟩
  exact effect_unit hchi hx3 hLstar

theorem chiReverse_unit {p : Parameters} {x : State}
    (hp : ParametersOK p) (hx : StateOK x) :
    UnitInterval (chiReverse p x) := by
  rcases hp with ⟨_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, hLstar, _, hchi, _, _, _, _, _⟩
  rcases hx with ⟨_, hx4, _, _⟩
  exact effect_unit hchi hx4 hLstar

theorem thetaForward_unit {p : Parameters} {x : State}
    (hp : ParametersOK p) (hx : StateOK x) :
    UnitInterval (thetaForward p x) := by
  rcases hp with ⟨_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, hLstar, _, _, htheta, _, _, _, _⟩
  rcases hx with ⟨hx3, _, _, _⟩
  exact effect_unit htheta hx3 hLstar

theorem thetaReverse_unit {p : Parameters} {x : State}
    (hp : ParametersOK p) (hx : StateOK x) :
    UnitInterval (thetaReverse p x) := by
  rcases hp with ⟨_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, hLstar, _, _, htheta, _, _, _, _⟩
  rcases hx with ⟨_, hx4, _, _⟩
  exact effect_unit htheta hx4 hLstar

theorem saturation_sub_identity {L₁ L₂ scale : ℝ}
    (h₁ : L₁ + scale ≠ 0) (h₂ : L₂ + scale ≠ 0) :
    saturation L₁ scale - saturation L₂ scale =
      scale * (L₁ - L₂) / ((L₁ + scale) * (L₂ + scale)) := by
  unfold saturation
  field_simp
  ring

theorem saturation_lipschitz {L₁ L₂ scale : ℝ}
    (hL₁ : 0 ≤ L₁) (hL₂ : 0 ≤ L₂) (hs : 0 < scale) :
    |saturation L₁ scale - saturation L₂ scale| ≤ |L₁ - L₂| / scale := by
  have hden₁ : 0 < L₁ + scale := by linarith
  have hden₂ : 0 < L₂ + scale := by linarith
  have hprod : 0 < (L₁ + scale) * (L₂ + scale) := mul_pos hden₁ hden₂
  rw [saturation_sub_identity (ne_of_gt hden₁) (ne_of_gt hden₂)]
  rw [abs_div, abs_mul, abs_of_pos hs, abs_of_pos hprod]
  have hle : scale * scale ≤ (L₁ + scale) * (L₂ + scale) := by nlinarith
  have hdiff :
      |L₁ - L₂| / scale - scale * |L₁ - L₂| / ((L₁ + scale) * (L₂ + scale)) =
        |L₁ - L₂| * ((L₁ + scale) * (L₂ + scale) - scale * scale) /
          (scale * ((L₁ + scale) * (L₂ + scale))) := by
    field_simp
    ring
  have hnonneg :
      0 ≤ |L₁ - L₂| * ((L₁ + scale) * (L₂ + scale) - scale * scale) /
        (scale * ((L₁ + scale) * (L₂ + scale))) := by
    apply div_nonneg
    · exact mul_nonneg (abs_nonneg (L₁ - L₂)) (by linarith)
    · exact mul_nonneg (le_of_lt hs) (le_of_lt hprod)
  linarith

/-! ## 3. Role-Indexed Drift Equivalence, Total S Balance, and Exchange Lipschitz (E3–E5) -/

theorem generalSDrift_zero (p : Parameters) (x : State) :
    generalSDrift p x 0 = smokeDrift p x := by
  simp [generalSDrift, smokeDrift, roleS, roleK, roleW, incomingChi, Fin.sum_univ_two]

theorem generalSDrift_one (p : Parameters) (x : State) :
    generalSDrift p x 1 = clayDrift p x := by
  simp [generalSDrift, clayDrift, roleS, roleK, roleW, incomingChi, Fin.sum_univ_two]

theorem total_S_drift_balance (p : Parameters) (x : State)
    (hK : p.KSmoke + p.KClay = 1) :
    smokeDrift p x + clayDrift p x =
      exchange p.wSmokeClay (chiReverse p x) (x 2 - x 1) +
      exchange p.wClaySmoke (chiForward p x) (x 1 - x 2) +
      source p x - p.decay * (x 1 + x 2) := by
  unfold smokeDrift clayDrift
  linear_combination (source p x) * hK

theorem exchange_lipschitz_in_gap {w chi : ℝ} (hw : 0 ≤ w) (hchi : UnitInterval chi)
    (g₁ g₂ : ℝ) :
    |exchange w chi g₁ - exchange w chi g₂| ≤ w * |g₁ - g₂| := by
  rcases hchi with ⟨hchi0, hchi1⟩
  unfold exchange
  rcases le_total g₁ 0 with hg₁ | hg₁ <;> rcases le_total g₂ 0 with hg₂ | hg₂
  · rw [pos_of_nonpos hg₁, pos_of_nonpos hg₂, abs_le]
    constructor <;> nlinarith [le_abs_self (g₁ - g₂), neg_le_abs (g₁ - g₂)]
  · rw [pos_of_nonpos hg₁, pos_of_nonneg hg₂, abs_le]
    constructor <;> nlinarith [le_abs_self (g₁ - g₂), neg_le_abs (g₁ - g₂)]
  · rw [pos_of_nonneg hg₁, pos_of_nonpos hg₂, abs_le]
    constructor <;> nlinarith [le_abs_self (g₁ - g₂), neg_le_abs (g₁ - g₂)]
  · rw [pos_of_nonneg hg₁, pos_of_nonneg hg₂, abs_le]
    constructor <;> nlinarith [le_abs_self (g₁ - g₂), neg_le_abs (g₁ - g₂)]

/-! ## 4. Inward-Pointing Boundary Conditions for `StateOK` (E12, E14–E16) -/

theorem loadDrift_nonneg_at_zero {alpha exposure clear : ℝ} (h : Bool)
    (halpha : 0 ≤ alpha) (hexp : 0 ≤ exposure) :
    0 ≤ loadDrift alpha h exposure clear 0 := by
  rcases indicator_unit h with ⟨hind0, _⟩
  unfold loadDrift
  nlinarith

theorem loadDrift_lipschitz_in_L (alpha : ℝ) (h : Bool) (exposure clear L₁ L₂ : ℝ) :
    loadDrift alpha h exposure clear L₁ - loadDrift alpha h exposure clear L₂ =
      -clear * (L₁ - L₂) := by
  unfold loadDrift
  ring

theorem receivedMeaning_unit {theta z imposed : ℝ}
    (htheta : UnitInterval theta) (hz : UnitInterval z) (himp : UnitInterval imposed) :
    UnitInterval (receivedMeaning theta z imposed) := by
  rcases htheta with ⟨ht0, ht1⟩
  rcases hz with ⟨hz0, hz1⟩
  rcases himp with ⟨hi0, hi1⟩
  unfold receivedMeaning
  constructor <;> nlinarith

theorem meaningRate_nonneg {w chi S scale : ℝ}
    (hw : 0 ≤ w) (hchi : UnitInterval chi) (hs : 0 < scale) :
    0 ≤ meaningRate w chi S scale := by
  rcases hchi with ⟨_, hchi1⟩
  have hpos : 0 ≤ pos S := pos_nonneg S
  have hden : 0 < scale + pos S := by linarith
  unfold meaningRate
  exact div_nonneg (mul_nonneg (mul_nonneg (by linarith) hw) hpos) (le_of_lt hden)

theorem meaningDrift_nonneg_at_zero {rate received clarify reference : ℝ}
    (hrate : 0 ≤ rate) (hrec : UnitInterval received)
    (hclar : 0 ≤ clarify) (href : UnitInterval reference) :
    0 ≤ meaningDrift rate received 0 clarify reference := by
  rcases hrec with ⟨hrec0, _⟩
  rcases href with ⟨href0, _⟩
  unfold meaningDrift
  nlinarith

theorem meaningDrift_nonpos_at_one {rate received clarify reference : ℝ}
    (hrate : 0 ≤ rate) (hrec : UnitInterval received)
    (hclar : 0 ≤ clarify) (href : UnitInterval reference) :
    meaningDrift rate received 1 clarify reference ≤ 0 := by
  rcases hrec with ⟨_, hrec1⟩
  rcases href with ⟨_, href1⟩
  unfold meaningDrift
  nlinarith

theorem smokeMeaningDrift_nonneg_at_zero {p : Parameters} {i : Inputs} {x : State}
    (hp : ParametersOK p) (hi : InputsOK i) (hx : StateOK x) (hx5 : x 5 = 0) :
    0 ≤ smokeMeaningDrift p i x := by
  have hchi : UnitInterval (chiReverse p x) := chiReverse_unit hp hx
  have htheta : UnitInterval (thetaReverse p x) := thetaReverse_unit hp hx
  rcases hp with ⟨_, _, _, hwSC, _, _, _, _, _, _, _, _, _, _, _, _, hmStar, _, _, _, himpRev, hrefSm, _⟩
  rcases hi with ⟨_, _, _, _, hclarSm, _⟩
  rcases hx with ⟨_, _, _, hx6⟩
  unfold smokeMeaningDrift
  rw [hx5]
  exact meaningDrift_nonneg_at_zero
    (meaningRate_nonneg hwSC hchi hmStar)
    (receivedMeaning_unit htheta hx6 himpRev)
    hclarSm hrefSm

theorem smokeMeaningDrift_nonpos_at_one {p : Parameters} {i : Inputs} {x : State}
    (hp : ParametersOK p) (hi : InputsOK i) (hx : StateOK x) (hx5 : x 5 = 1) :
    smokeMeaningDrift p i x ≤ 0 := by
  have hchi : UnitInterval (chiReverse p x) := chiReverse_unit hp hx
  have htheta : UnitInterval (thetaReverse p x) := thetaReverse_unit hp hx
  rcases hp with ⟨_, _, _, hwSC, _, _, _, _, _, _, _, _, _, _, _, _, hmStar, _, _, _, himpRev, hrefSm, _⟩
  rcases hi with ⟨_, _, _, _, hclarSm, _⟩
  rcases hx with ⟨_, _, _, hx6⟩
  unfold smokeMeaningDrift
  rw [hx5]
  exact meaningDrift_nonpos_at_one
    (meaningRate_nonneg hwSC hchi hmStar)
    (receivedMeaning_unit htheta hx6 himpRev)
    hclarSm hrefSm

theorem clayMeaningDrift_nonneg_at_zero {p : Parameters} {i : Inputs} {x : State}
    (hp : ParametersOK p) (hi : InputsOK i) (hx : StateOK x) (hx6 : x 6 = 0) :
    0 ≤ clayMeaningDrift p i x := by
  have hchi : UnitInterval (chiForward p x) := chiForward_unit hp hx
  have htheta : UnitInterval (thetaForward p x) := thetaForward_unit hp hx
  rcases hp with ⟨_, _, _, _, hwCS, _, _, _, _, _, _, _, _, _, _, _, hmStar, _, _, himpFwd, _, _, hrefCl⟩
  rcases hi with ⟨_, _, _, _, _, hclarCl⟩
  rcases hx with ⟨_, _, hx5, _⟩
  unfold clayMeaningDrift
  rw [hx6]
  exact meaningDrift_nonneg_at_zero
    (meaningRate_nonneg hwCS hchi hmStar)
    (receivedMeaning_unit htheta hx5 himpFwd)
    hclarCl hrefCl

theorem clayMeaningDrift_nonpos_at_one {p : Parameters} {i : Inputs} {x : State}
    (hp : ParametersOK p) (hi : InputsOK i) (hx : StateOK x) (hx6 : x 6 = 1) :
    clayMeaningDrift p i x ≤ 0 := by
  have hchi : UnitInterval (chiForward p x) := chiForward_unit hp hx
  have htheta : UnitInterval (thetaForward p x) := thetaForward_unit hp hx
  rcases hp with ⟨_, _, _, _, hwCS, _, _, _, _, _, _, _, _, _, _, _, hmStar, _, _, himpFwd, _, _, hrefCl⟩
  rcases hi with ⟨_, _, _, _, _, hclarCl⟩
  rcases hx with ⟨_, _, hx5, _⟩
  unfold clayMeaningDrift
  rw [hx6]
  exact meaningDrift_nonpos_at_one
    (meaningRate_nonneg hwCS hchi hmStar)
    (receivedMeaning_unit htheta hx5 himpFwd)
    hclarCl hrefCl

/-! ## 5. Encounter Probabilities and Meaning Simplex Preservation (E6–E10) -/

theorem opening_unit {g p0 r rStar : ℝ}
    (hg : UnitInterval g) (hp0 : UnitInterval p0) (hr : 0 ≤ r) (hrStar : 0 < rStar) :
    UnitInterval (opening g p0 r rStar) := by
  rcases hg with ⟨hg0, hg1⟩
  rcases hp0 with ⟨hp00, hp01⟩
  have hden : 0 < rStar + r := by linarith
  have hne : rStar + r ≠ 0 := ne_of_gt hden
  have hfrac0 : 0 ≤ r / (rStar + r) := div_nonneg hr (le_of_lt hden)
  have hfrac1 : r / (rStar + r) ≤ 1 := by
    have hdiff : 1 - r / (rStar + r) = rStar / (rStar + r) := by
      field_simp
      ring
    have hpos : 0 ≤ rStar / (rStar + r) := div_nonneg (le_of_lt hrStar) (le_of_lt hden)
    linarith
  unfold opening
  constructor <;> nlinarith

theorem registration_unit {eta z challenge : ℝ}
    (heta : UnitInterval eta) (hz : UnitInterval z) (hch : UnitInterval challenge) :
    UnitInterval (registration eta z challenge) := by
  rcases heta with ⟨he0, he1⟩
  rcases hz with ⟨hz0, hz1⟩
  rcases hch with ⟨hc0, hc1⟩
  unfold registration
  constructor <;> nlinarith

theorem conditionalRegistration_unit {eta z challenge : ℝ} (B : Bool)
    (heta : UnitInterval eta) (hz : UnitInterval z) (hch : UnitInterval challenge) :
    UnitInterval (conditionalRegistration eta z challenge B) := by
  rcases registration_unit heta hz hch with ⟨hr0, hr1⟩
  rcases indicator_unit B with ⟨hi0, hi1⟩
  unfold conditionalRegistration
  constructor <;> nlinarith

theorem branches_nonneg {p q : ℝ} (hp : UnitInterval p) (hq : UnitInterval q) :
    ∀ k : Fin 3, 0 ≤ branches p q k := by
  rcases hp with ⟨hp0, hp1⟩
  rcases hq with ⟨hq0, hq1⟩
  intro k
  fin_cases k <;> simp [branches] <;> nlinarith

theorem branches_sum_eq_one (p q : ℝ) :
    (∑ k : Fin 3, branches p q k) = 1 := by
  simp [branches, Fin.sum_univ_three]
  ring

theorem update_false_eq_self (beta : ℝ) (H M : Meaning) :
    update beta false H M = H := by
  funext j
  simp [update, information, indicator]

theorem update_preserves_simplex {beta : ℝ} (C : Bool) {H M : Meaning}
    (hbeta : UnitInterval beta) (hH : Simplex H) (hM : Simplex M) :
    Simplex (update beta C H M) := by
  rcases hbeta with ⟨hb0, hb1⟩
  rcases hH with ⟨hH0, hHsum⟩
  rcases hM with ⟨hM0, hMsum⟩
  rcases indicator_unit C with ⟨hi0, hi1⟩
  constructor
  · intro j
    have hjH : 0 ≤ H j := hH0 j
    have hjM : 0 ≤ M j := hM0 j
    unfold update information
    nlinarith
  · simp only [update, information, Fin.sum_univ_two] at hHsum hMsum ⊢
    linear_combination (1 - beta * indicator C) * hHsum + (beta * indicator C) * hMsum

/-! ## 6. Integral-Equation (`IntegralSolution`) Uniqueness Theorems -/

/-- Stage 1 Uniqueness: Because `evolution p (i s) x 0 = accumulatedDrift p.gamma (i s).utility p.baseline`
is independent of the state `x`, any two solutions of `IntegralSolution` with the same initial state
have identical accumulated source trajectories `x t 0 = y t 0` across `[t0, T]`. -/
theorem integralSolution_unique_A {p : Parameters} {i : ℝ → Inputs} {t0 T : ℝ}
    {initial : State} {x y : ℝ → State}
    (hx : IntegralSolution p i t0 T initial x)
    (hy : IntegralSolution p i t0 T initial y)
    {t : ℝ} (ht : t ∈ Icc t0 T) :
    x t 0 = y t 0 := by
  rw [hx.2.2.2 0 t ht, hy.2.2.2 0 t ht]
  rfl

/-- Exact integral-difference representation for every state coordinate `j : Fin 7`
of two candidate `IntegralSolution` trajectories sharing the same initial data. -/
theorem integralSolution_sub_eq {p : Parameters} {i : ℝ → Inputs} {t0 T : ℝ}
    {initial : State} {x y : ℝ → State}
    (hx : IntegralSolution p i t0 T initial x)
    (hy : IntegralSolution p i t0 T initial y)
    (j : Fin 7) {t : ℝ} (ht : t ∈ Icc t0 T) :
    x t j - y t j =
      ∫ s in t0..t, (evolution p (i s) (x s) j - evolution p (i s) (y s) j) := by
  rw [hx.2.2.2 j t ht, hy.2.2.2 j t ht]
  have hsub :
      (initial j + ∫ s in t0..t, evolution p (i s) (x s) j) -
        (initial j + ∫ s in t0..t, evolution p (i s) (y s) j) =
      (∫ s in t0..t, evolution p (i s) (x s) j) -
        (∫ s in t0..t, evolution p (i s) (y s) j) := by ring
  rw [hsub, ← intervalIntegral.integral_sub (hx.2.2.1 j t ht) (hy.2.2.1 j t ht)]

/-- Any coordinate `j` whose drift difference vanishes along `[t0, T]` is uniquely determined. -/
theorem integralSolution_coord_unique_of_drift_eq {p : Parameters} {i : ℝ → Inputs} {t0 T : ℝ}
    {initial : State} {x y : ℝ → State}
    (hx : IntegralSolution p i t0 T initial x)
    (hy : IntegralSolution p i t0 T initial y)
    (j : Fin 7)
    (hdrift : ∀ s, evolution p (i s) (x s) j = evolution p (i s) (y s) j)
    {t : ℝ} (ht : t ∈ Icc t0 T) :
    x t j = y t j := by
  have hdiff := integralSolution_sub_eq hx hy j ht
  have hzero :
      (∫ s in t0..t, (evolution p (i s) (x s) j - evolution p (i s) (y s) j)) = 0 := by
    simp [hdrift]
  linarith

#print axioms abs_pos_sub_pos_le
#print axioms saturation_lipschitz
#print axioms generalSDrift_zero
#print axioms generalSDrift_one
#print axioms exchange_lipschitz_in_gap
#print axioms smokeMeaningDrift_nonneg_at_zero
#print axioms smokeMeaningDrift_nonpos_at_one
#print axioms branches_sum_eq_one
#print axioms update_preserves_simplex
#print axioms integralSolution_unique_A
#print axioms integralSolution_sub_eq

end
end SocialAS.Verified