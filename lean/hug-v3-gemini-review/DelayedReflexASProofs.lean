import ASModel
import V3EventSpecification
import Mathlib.Tactic

/-!
# Delayed Conscious Buffer $x(t - \tau)$ Coupled to Fast Physical Reflex $F(t)$

This module extends `ASModel.lean` (`SocialAS`) and `V3EventSpecification.lean` (`HugV3Event`)
into a two-timescale delay-hybrid system (`namespace DelayedReflexAS`):

1. **Fast Physical / Reflex Coordinate $F(t)$ (Instantaneous Present Time $t$)**:
   Reacts directly at time $t$ to local mechanical strain `e(t)`, spinal reflex avoidance
   at `t_haz + τ_spinal`, and effective tissue/fabric stiffness
   `effectiveStiffness k0 kBrace brace = k0 + kBrace * brace`.
2. **Slow / Buffered Conscious & Social Coordinate $x(t)$ (Delayed Past Time $t - \tau$)**:
   Evolves the two-channel (`Smoke` and `Clay`) 7-coordinate system from `ASModel.lean`,
   driven by the buffered past state `x(t - τ)` with perceptual lag `τ > 0`
   (`DelayedIntegralSolution`).

## Main Theorems Proved Below (Zero `sorry`)

* **`delayedSolution_unique_on_step` (Method of Steps Uniqueness)**:
  Because the conscious drift at time `s ∈ [t0, t0 + τ]` evaluates `evolution p (i s) (x (s - τ))`
  inside the known history window `[t0 - τ, t0]`, any two solutions of `DelayedIntegralSolution`
  that agree on the history buffer `[t0 - τ, t0]` are **identically equal on `[t0, t0 + τ]`**
  for all 7 coordinates (`j : Fin 7`) without even requiring Grönwall's inequality on that step!
* **`reflex_acts_before_conscious_registration` (Fast Spinal Reflex vs. Conscious Lag)**:
  When `0 < τ_spinal < τ_lag`, a hazard at `t_haz` triggers the physical reflex at
  `t_reflex = t_haz + τ_spinal < t_conscious = t_haz + τ_lag`. At any time
  `t ∈ [t_reflex, t_conscious)`, the physical reflex is already active (`t_reflex ≤ t`),
  while the buffered conscious time `t - τ_lag < t_haz` still precedes the hazard!
* **`unbraced_peak_stress_lt_braced` & `unbraced_survives_crash_window` (Viscoelastic Crash Survival)**:
  When conscious bracing `brace ∈ (0, 1]` has not yet engaged (so `brace = 0` due to the
  perceptual lag `τ_lag` or sedation), the effective stiffness `k0` is strictly less than the
  braced stiffness `k0 + kBrace * brace`, strictly reducing peak impact traction below a fracture
  threshold `τ_crit` that a braced state exceeds.
* **`mirror_write_is_many_to_one` (One-Way Mirror at a Memory Stamp)**:
  Distinct pre-event rest-strain states `b₁ ≠ b₂` in the valid empty well both map to the
  exact same post-write state `writtenBit a true`, proving that while forward hybrid evolution
  is unique, the reverse ("mirror") map at a memory stamp is strictly many-to-one.
-/

namespace DelayedReflexAS
noncomputable section
open Set MeasureTheory
open SocialAS HugV3Event

/-! ## 1. Two-Timescale Delayed-Conscious + Fast-Physical Definitions -/

/-- Effective viscoelastic stiffness of the physical body/fabric:
`k0 > 0` is the baseline relaxed (limp) stiffness, `kBrace > 0` is the additional
muscular/structural stiffness added when conscious bracing `brace ∈ [0, 1]` engages. -/
def effectiveStiffness (k0 kBrace brace : ℝ) : ℝ :=
  k0 + kBrace * brace

/-- Peak impact traction/stress for a given strain excursion `deltaStrain > 0`
at rest strain `b` and bracing level `brace`. -/
def impactTraction (k0 kBrace brace load b : ℝ) : ℝ :=
  effectiveStiffness k0 kBrace brace * (load - b)

/-- Instantaneous physical/reflex drift at present time `t`, coupled to the
buffered conscious Clay signal `x (t - τ) 2` and Smoke distortion `x (t - τ) 5`. -/
def fastPhysicalDrift (k0 kBrace damping : ℝ)
    (hazardAtPresent : ℝ) (braceFromPast : ℝ) (F_now b_now : ℝ) : ℝ :=
  -effectiveStiffness k0 kBrace braceFromPast * (F_now - b_now)
  - damping * F_now + hazardAtPresent

/-- Delay Integral Equation (`DelayedIntegralSolution`) for the 7-coordinate `SocialAS` state
with perceptual buffer lag `τ > 0` on a step `[t0, t0 + τ]`:
The rate at time `s ∈ [t0, t0 + τ]` evaluates `evolution p (i s) (trajectory (s - τ))`. -/
def DelayedIntegralSolution (p : Parameters) (i : ℝ → Inputs) (t0 tau : ℝ)
    (history : ℝ → State) (trajectory : ℝ → State) : Prop :=
  0 < tau ∧
  ContinuousOn trajectory (Icc t0 (t0 + tau)) ∧
  (∀ s ∈ Icc (t0 - tau) t0, trajectory s = history s) ∧
  (∀ j t, t ∈ Icc t0 (t0 + tau) →
    IntervalIntegrable (fun s => evolution p (i s) (trajectory (s - tau)) j) volume t0 t) ∧
  (∀ j t, t ∈ Icc t0 (t0 + tau) →
    trajectory t j = history t0 j +
      ∫ s in t0..t, evolution p (i s) (trajectory (s - tau)) j)

/-! ## 2. Method of Steps Uniqueness for the $\tau$-Delayed System -/

/-- Helper lemma: If `s` lies in `[t0, t]` where `t ∈ [t0, t0 + τ]`, then the delayed time
`s - τ` lies in the known past buffer `[t0 - τ, t0]`. -/
theorem sub_tau_mem_history_window {t0 tau t s : ℝ}
    (ht : t ∈ Icc t0 (t0 + tau)) (hs : s ∈ uIcc t0 t) :
    s - tau ∈ Icc (t0 - tau) t0 := by
  rcases ht with ⟨ht0, ht1⟩
  rw [uIcc_of_le ht0] at hs
  rcases hs with ⟨hs0, hs1⟩
  constructor <;> linarith

/-- **Method of Steps Uniqueness Theorem**:
Because the conscious/social rate at time `s ∈ [t0, t0 + τ]` depends on the buffered past
state `x(s - τ)` inside `[t0 - τ, t0]`, any two `DelayedIntegralSolution` trajectories sharing
the same history buffer on `[t0 - τ, t0]` are **identically equal across `[t0, t0 + τ]`**
for all 7 coordinates (`Smoke`, `Clay`, loads, meaning distortions, and source `A`). -/
theorem delayedSolution_unique_on_step
    {p : Parameters} {i : ℝ → Inputs} {t0 tau : ℝ}
    {history : ℝ → State} {x y : ℝ → State}
    (hx : DelayedIntegralSolution p i t0 tau history x)
    (hy : DelayedIntegralSolution p i t0 tau history y)
    (j : Fin 7) {t : ℝ} (ht : t ∈ Icc t0 (t0 + tau)) :
    x t j = y t j := by
  rcases hx with ⟨_, _, hx_hist, _, hx_eq⟩
  rcases hy with ⟨_, _, hy_hist, _, hy_eq⟩
  rw [hx_eq j t ht, hy_eq j t ht]
  congr 1
  apply intervalIntegral.integral_congr
  intro s hs
  have hmem : s - tau ∈ Icc (t0 - tau) t0 := sub_tau_mem_history_window ht hs
  change evolution p (i s) (x (s - tau)) j = evolution p (i s) (y (s - tau)) j
  rw [hx_hist (s - tau) hmem, hy_hist (s - tau) hmem]

/-! ## 3. Fast Spinal Reflex vs. Conscious Perceptual Lag ("Knife Dodge") -/

/-- **Fast Reflex Precedes Conscious Registration**:
Suppose a physical hazard (e.g. a knife slip) begins at `t_haz`, the spinal reflex arc
initiates avoidance after `τ_spinal > 0`, and conscious perceptual registration lags by
`τ_lag` with `τ_spinal < τ_lag` (e.g., 50 ms vs. 500 ms or a 15 s situation buffer).
Then for every time `t` in the non-empty window `[t_haz + τ_spinal, t_haz + τ_lag)`:
1. The physical reflex has already engaged (`t_haz + τ_spinal ≤ t`),
2. Yet the buffered conscious clock `t - τ_lag` is still strictly prior to `t_haz`
   (`t - τ_lag < t_haz`), so conscious awareness has not yet registered the event! -/
theorem reflex_acts_before_conscious_registration
    {t_haz tau_spinal tau_lag t : ℝ}
    (h_spinal_pos : 0 < tau_spinal)
    (h_faster : tau_spinal < tau_lag)
    (ht : t ∈ Ico (t_haz + tau_spinal) (t_haz + tau_lag)) :
    t_haz < t_haz + tau_spinal ∧
    t_haz + tau_spinal ≤ t ∧
    t - tau_lag < t_haz := by
  rcases ht with ⟨ht_lo, ht_hi⟩
  refine ⟨by linarith, ht_lo, by linarith⟩

/-- Generation-to-generation evolutionary reflex speed-up:
If adaptation reduces reflex latency from `tau_old` to `tau_new < tau_old` under a constant
hazard rate `v_hazard > 0`, the physical tissue excursion before withdrawal
`v_hazard * tau_new` is strictly smaller than `v_hazard * tau_old`, preventing a cut
when `v_hazard * tau_new < d_cut ≤ v_hazard * tau_old`. -/
theorem faster_reflex_prevents_cut
    {v_hazard tau_new tau_old d_cut : ℝ}
    (hv : 0 < v_hazard)
    (h_speedup : tau_new < tau_old)
    (h_safe : v_hazard * tau_new < d_cut)
    (h_old_cut : d_cut ≤ v_hazard * tau_old) :
    v_hazard * tau_new < d_cut ∧ v_hazard * tau_new < v_hazard * tau_old := by
  exact ⟨h_safe, mul_lt_mul_of_pos_left h_speedup hv⟩

/-! ## 4. Viscoelastic Crash Survival: Unbraced (Limp) vs. Braced Peak Stress -/

/-- When conscious bracing `brace > 0` has not engaged at impact (so `brace = 0` because the
impact occurs faster than the perceptual lag `τ_lag` or under sedation), the unbraced
impact traction for any positive strain excursion `load - b > 0` is strictly lower than
the braced impact traction. -/
theorem unbraced_peak_stress_lt_braced
    {k0 kBrace brace load b : ℝ}
    (hkBrace : 0 < kBrace) (hbrace : 0 < brace) (hstrain : b < load) :
    impactTraction k0 kBrace 0 load b < impactTraction k0 kBrace brace load b := by
  unfold impactTraction effectiveStiffness
  have hdiff :
      (k0 + kBrace * brace) * (load - b) - (k0 + kBrace * 0) * (load - b) =
        kBrace * brace * (load - b) := by ring
  have hpos : 0 < kBrace * brace * (load - b) :=
    mul_pos (mul_pos hkBrace hbrace) (by linarith)
  linarith

/-- **Crash Survival Window Theorem**:
For any critical fracture stress `stress_crit` lying between the unbraced impact stress
`k0 * (load - b)` and the braced impact stress `(k0 + kBrace * brace) * (load - b)`,
the unbraced (limp/lagged) state survives (`impactTraction < stress_crit`) whereas the
consciously braced state exceeds the failure threshold (`stress_crit ≤ impactTraction`). -/
theorem unbraced_survives_crash_window
    {k0 kBrace brace load b stress_crit : ℝ}
    (h_unbraced : k0 * (load - b) < stress_crit)
    (h_braced : stress_crit ≤ (k0 + kBrace * brace) * (load - b)) :
    impactTraction k0 kBrace 0 load b < stress_crit ∧
    stress_crit ≤ impactTraction k0 kBrace brace load b := by
  unfold impactTraction effectiveStiffness
  constructor <;> linarith

/-! ## 5. The "One-Way Mirror": Forward Uniqueness vs. Reverse Many-to-One Collapse -/

/-- **Why the Mirror Is One-Way at a Memory Stamp**:
There exist distinct valid empty pre-event coordinates `b₁ ≠ b₂` (for instance,
`b₁ = -(margin * a)` and `b₂ = -(2 * margin * a)`) that both satisfy `ValidEmptyCoordinate a margin`
and both jump to the exact same post-event value `writtenBit a true = a`.
Hence, looking backward in time ("in the mirror") after a write event, a single post-event
state has multiple distinct valid pre-event histories, even though forward evolution is unique. -/
theorem mirror_write_is_many_to_one {a margin : ℝ} (ha : 0 < a) (hm : 0 < margin) :
    let b₁ := -(margin * a)
    let b₂ := -(2 * margin * a)
    ValidEmptyCoordinate a margin b₁ ∧
    ValidEmptyCoordinate a margin b₂ ∧
    b₁ ≠ b₂ ∧
    writtenBit a true = a := by
  intro b₁ b₂
  have hprod : 0 < margin * a := mul_pos hm ha
  refine ⟨⟨ha, hm, by linarith⟩, ⟨ha, hm, by linarith⟩, by linarith, ?_⟩
  unfold writtenBit
  simp only [ite_true, mul_one]

#print axioms delayedSolution_unique_on_step
#print axioms reflex_acts_before_conscious_registration
#print axioms faster_reflex_prevents_cut
#print axioms unbraced_peak_stress_lt_braced
#print axioms unbraced_survives_crash_window
#print axioms mirror_write_is_many_to_one

end
end DelayedReflexAS
