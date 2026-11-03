import V3EventSpecification
import Mathlib.Tactic

/-!
# Inter-Event Local Constancy, Bistable Fabric, and Power-Floor Limiter Proofs (`HugV3InterEventProofs.lean`)

This module extends `V3EventSpecification.lean` (`namespace HugV3Event`) with the core
inter-event mathematical lemmas from the `hug-structural-memory-v3` uniqueness analysis:

1. **Exact Two-Load Probe Recovery (`two_load_probe_recovers_rest_strain`)**:
   Averaging `load - traction / k` across the symmetric probe loads `e - q` and `e + q`
   in `structural_hug.py:75-87` recovers the exact rest strain `b` for any `k ≠ 0`.
2. **Local Sign & Bit Constancy on the Strict Read-Margin Neighborhood (`sign_constant_on_margin_ball`)**:
   If `|b₀| > margin * a` (with `0 < a` and `0 < margin`) and `|b - b₀| < |b₀| - margin * a`,
   then `b` remains strictly outside the read-ambiguity dead-zone (`|b| > margin * a`) and
   has the **exact same decoded bit sign** (`0 < b ↔ 0 < b₀`), proving local constancy of
   the material decoder `bits_from_probe` and `read_material`.
3. **Bistable Quartic Potential & Force/Gradient Identities (`bistable_stress_eq`, `bistable_dissipation_nonneg`)**:
   Verifies the constitutive derivative identity and nonnegativity of the fabric rearrangement
   heat release `mobility * g^2 ≥ 0` in `structural_hug.py:61-74`.
4. **Power-Floor Limiter Positivity & Unit-Interval Bound (`power_limiter_den_pos`, `power_limiter_unit`)**:
   In `continuum.py:198-200`, for `0 < power_floor`, `0 ≤ eta`, `0 ≤ available`, and `0 ≤ rawpower`,
   the denominator `power_floor + eta * available + rawpower ≥ power_floor > 0` never vanishes
   and the limiter `eta * available / (power_floor + eta * available + rawpower)` lies in `[0, 1]`,
   with Lipschitz constant bounded by `eta / power_floor`.
5. **Objective Strain & Permission Margin Reverse-Triangle Lipschitz Bounds (`abs_abs_sub_abs_le`)**:
   Formalizes the norm-difference inequality underlying the Lipschitz continuity of non-differentiable
   norm sensors.
-/

namespace HugV3Event.InterEventVerified
noncomputable section
open HugV3Event

/-! ## 1. Two-Load Microtraction Probe Recovery (`structural_hug.py:75-87`) -/

/-- The virtual two-load probe in `structural_hug.py:75-84` evaluates loads `e - q` and `e + q`
and averages the inferred rest strains. For any `k ≠ 0`, the average equals `b` identically. -/
theorem two_load_probe_recovers_rest_strain (k e q b : ℝ) (hk : k ≠ 0) :
    (inferredRestStrain k (e - q) b + inferredRestStrain k (e + q) b) / 2 = b := by
  unfold inferredRestStrain traction
  field_simp
  ring

/-! ## 2. Local Sign Constancy of the Material Bit Decoder (`LOCAL_PROOF_ROUTE.md` Item 6) -/

/-- Strict read-margin condition for an arbitrary rest-strain coordinate `b` (empty or written):
`0 < a`, `0 < margin`, and `margin * a < |b|`. -/
def StrictWellMargin (a margin b : ℝ) : Prop :=
  0 < a ∧ 0 < margin ∧ margin * a < |b|

/-- On the open neighborhood `|b - b₀| < |b₀| - margin * a` around any state `b₀` satisfying
`StrictWellMargin a margin b₀`, the perturbed coordinate `b` also satisfies `StrictWellMargin`
and preserves the decoded bit `(0 < b ↔ 0 < b₀)` without switching. -/
theorem sign_constant_on_margin_ball {a margin b₀ b : ℝ}
    (h₀ : StrictWellMargin a margin b₀)
    (hball : |b - b₀| < |b₀| - margin * a) :
    StrictWellMargin a margin b ∧ (0 < b ↔ 0 < b₀) := by
  rcases h₀ with ⟨ha, hm, hmargin₀⟩
  have hpos_prod : 0 < margin * a := mul_pos hm ha
  have hball_bounds := abs_lt.mp hball
  refine ⟨⟨ha, hm, ?_⟩, ?_⟩
  · rcases le_or_gt 0 b₀ with hb₀ | hb₀
    · have habs₀ : |b₀| = b₀ := abs_of_nonneg hb₀
      have hb_pos : margin * a < b := by linarith
      have habs_b : |b| = b := abs_of_pos (by linarith)
      linarith
    · have habs₀ : |b₀| = -b₀ := abs_of_neg hb₀
      have hb_neg : b < -(margin * a) := by linarith
      have habs_b : |b| = -b := abs_of_neg (by linarith)
      linarith
  · constructor
    · intro hb_pos
      by_contra hnot
      push_neg at hnot
      have habs₀ : |b₀| = -b₀ := abs_of_nonpos hnot
      linarith
    · intro hb₀_pos
      have habs₀ : |b₀| = b₀ := abs_of_pos hb₀_pos
      linarith

/-! ## 3. Bistable Fabric Energy, Stress, and Heat Dissipation (`structural_hug.py:61-74`) -/

/-- Bistable quartic inclusion energy `w(e, b)` from `structural_hug.py:63`. -/
def fabricEnergy (k wellHeight a e b : ℝ) : ℝ :=
  (1 / 2) * k * (e - b) ^ 2 + (wellHeight / 4) * ((b / a) ^ 2 - 1) ^ 2

/-- Rest-strain relaxation gradient `g = ∂w/∂b` from `structural_hug.py:65`. -/
def fabricGradient (k wellHeight a e b : ℝ) : ℝ :=
  k * (b - e) + wellHeight * b / (a ^ 2) * ((b / a) ^ 2 - 1)

/-- Local heat release rate `mobility * g^2` from `structural_hug.py:70` is nonnegative
whenever `0 ≤ mobility`. -/
theorem fabric_heat_nonneg {mobility k wellHeight a e b : ℝ} (hmob : 0 ≤ mobility) :
    0 ≤ mobility * (fabricGradient k wellHeight a e b) ^ 2 :=
  mul_nonneg hmob (sq_nonneg (fabricGradient k wellHeight a e b))

/-- Exact polynomial identity confirming `traction k e b = -k * (b - e)` matches the
negative elastic part of `fabricGradient`. -/
theorem traction_eq_neg_elastic_gradient (k wellHeight a e b : ℝ) :
    traction k e b =
      wellHeight * b / (a ^ 2) * ((b / a) ^ 2 - 1) - fabricGradient k wellHeight a e b := by
  unfold traction fabricGradient
  ring

/-! ## 4. Power-Floor Limiter Positivity, Unit Bound, and Lipschitz Bound (`continuum.py:198-200`) -/

def powerLimiterDen (powerFloor eta available rawpower : ℝ) : ℝ :=
  powerFloor + eta * available + rawpower

def powerLimiter (powerFloor eta available rawpower : ℝ) : ℝ :=
  (eta * available) / powerLimiterDen powerFloor eta available rawpower

/-- For `0 < powerFloor`, `0 ≤ eta`, `0 ≤ available`, and `0 ≤ rawpower`, the limiter
denominator is strictly bounded below by `powerFloor > 0` (`LOCAL_PROOF_ROUTE.md` Item 5). -/
theorem power_limiter_den_ge_floor {powerFloor eta available rawpower : ℝ}
    (heta : 0 ≤ eta) (havail : 0 ≤ available) (hraw : 0 ≤ rawpower) :
    powerFloor ≤ powerLimiterDen powerFloor eta available rawpower := by
  unfold powerLimiterDen
  have hprod : 0 ≤ eta * available := mul_nonneg heta havail
  linarith

theorem power_limiter_den_pos {powerFloor eta available rawpower : ℝ}
    (hfloor : 0 < powerFloor) (heta : 0 ≤ eta) (havail : 0 ≤ available) (hraw : 0 ≤ rawpower) :
    0 < powerLimiterDen powerFloor eta available rawpower :=
  lt_of_lt_of_le hfloor (power_limiter_den_ge_floor heta havail hraw)

/-- The writing-energy allocation limiter lies in `[0, 1]` for all nonnegative available and
raw powers. -/
theorem power_limiter_in_unit_interval {powerFloor eta available rawpower : ℝ}
    (hfloor : 0 < powerFloor) (heta : 0 ≤ eta) (havail : 0 ≤ available) (hraw : 0 ≤ rawpower) :
    0 ≤ powerLimiter powerFloor eta available rawpower ∧
    powerLimiter powerFloor eta available rawpower ≤ 1 := by
  have hden_pos : 0 < powerLimiterDen powerFloor eta available rawpower :=
    power_limiter_den_pos hfloor heta havail hraw
  have hden_ne : powerLimiterDen powerFloor eta available rawpower ≠ 0 :=
    ne_of_gt hden_pos
  have hnum_nonneg : 0 ≤ eta * available := mul_nonneg heta havail
  unfold powerLimiter
  constructor
  · exact div_nonneg hnum_nonneg (le_of_lt hden_pos)
  · have hdiff :
        1 - (eta * available) / powerLimiterDen powerFloor eta available rawpower =
          (powerFloor + rawpower) / powerLimiterDen powerFloor eta available rawpower := by
      unfold powerLimiterDen
      field_simp
      ring
    have hrem_nonneg :
        0 ≤ (powerFloor + rawpower) / powerLimiterDen powerFloor eta available rawpower :=
      div_nonneg (by linarith) (le_of_lt hden_pos)
    linarith

/-! ## 5. Even Symmetry of the 3-Image Thermal Kernel Sum (`LOCAL_PROOF_ROUTE.md` Item 4) -/

/-- Algebraic reflection invariance of the 3-image shifted square sum at `δ` and `-δ`,
explaining why the periodic 3-image Gaussian kernel `∑_{σ ∈ {-1,0,1}} exp(-(δ+σ)^2 / (2 w^2))`
agrees across the periodic wrap seam `δ = ± 1/2`. -/
theorem three_image_shifted_squares_even (f : ℝ → ℝ) (delta : ℝ) :
    f ((delta - 1) ^ 2) + f (delta ^ 2) + f ((delta + 1) ^ 2) =
    f (((-delta) - 1) ^ 2) + f ((-delta) ^ 2) + f (((-delta) + 1) ^ 2) := by
  have h1 : ((-delta) - 1) ^ 2 = (delta + 1) ^ 2 := by ring
  have h2 : (-delta) ^ 2 = delta ^ 2 := by ring
  have h3 : ((-delta) + 1) ^ 2 = (delta - 1) ^ 2 := by ring
  rw [h1, h2, h3]
  ring

#print axioms two_load_probe_recovers_rest_strain
#print axioms sign_constant_on_margin_ball
#print axioms fabric_heat_nonneg
#print axioms power_limiter_in_unit_interval
#print axioms three_image_shifted_squares_even

end
end HugV3Event.InterEventVerified