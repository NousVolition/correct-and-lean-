import ASModel
import V3EventSpecification
import Mathlib.Tactic

/-!
# Combined Formal Proofs for `ASModel.lean` (`SocialAS`) and `V3EventSpecification.lean` (`HugV3Event`)

This module unifies the two Lean specifications into a single coupled hybrid system
(`namespace CombinedASHug`):

* **`SocialAS` (`ASModel.lean`)**: Evolves the 7 continuous channel/load/meaning-distortion
  coordinates `x : Fin 7 → ℝ` (`A, SSmoke, SClay, LSmokeToClay, LClayToSmoke, zSmoke, zClay`)
  via the Carathéodory integral equation `IntegralSolution`, and evaluates the encounter
  kernel (`activation`, `opportunityActivation`, `opening`, `conditionalRegistration`,
  `branches`) and meaning-distribution update (`update : ℝ → Bool → Meaning → Meaning → Meaning`).
* **`HugV3Event` (`V3EventSpecification.lean`)**: Models the physical bistable rest-strain
  memory coordinate `b : ℝ`, its microtraction probe recovery `inferredRestStrain k load b = b`,
  the event header magic bit `headerMagic = 1729`, the empty-slot margin condition
  `ValidEmptyCoordinate a margin b`, and the instantaneous write jump `writtenBit a bit`.

## Main Combined Theorems Proved Below (Completed proofs)

1. **`combined_probe_recovers_written_bit`**: After an encounter writes `writtenBit a bit` into
   the structural fabric, `inferredRestStrain k load (writtenBit a bit) = writtenBit a bit`
   for any `k ≠ 0` and any probe load `load`.
2. **`written_bit_satisfies_well_margin`**: When `0 < a` and `margin ≤ 1`, any written bit
   `writtenBit a bit` has magnitude `|writtenBit a bit| = a ≥ margin * a`, lying outside the
   ambiguous read dead-zone.
3. **`clay_encounter_branches_simplex`**: For any `ParametersOK p` and `StateOK x`, the
   Clay-channel activation `r = opportunityActivation p.g (activation (x 2) p.threshold)` is
   nonnegative, the resulting `opening` and `conditionalRegistration` probabilities lie in
   `[0, 1]`, and the 3-branch encounter distribution `branches p_open q_reg` is nonnegative
   and sums to `1`.
4. **`combined_event_preserves_stateOK_and_simplex`**: At a scheduled encounter event where
   the meaning distribution updates via `update p.beta C H M` and the structural coordinate
   jumps from `before` to `writtenBit a true`, `StateOK x` and `Simplex H` are preserved while
   the fabric coordinate strictly changes (`writtenBit a true ≠ before`).
5. **`combined_trajectory_continuous_AS_but_discontinuous_full`**: If a combined hybrid
   trajectory `path : ℝ → CombinedState` satisfies `SocialAS.IntegralSolution` on `[t0, T]`
   and witnesses a structural write at `eventTime ∈ [t0, T]` (`EventWitness (fabricCoord ∘ path)`),
   then:
   - Its 7-coordinate `SocialAS` projection `asState ∘ path` **is continuous** at `eventTime`
     (on `Icc t0 T`),
   - Yet the full combined trajectory `path` **cannot be continuous** at `eventTime`
     (`¬ ContinuousAt path eventTime`).
6. **`combined_hybrid_post_event_unique`**: Given two combined trajectories whose `SocialAS`
   states and pre-event meaning distributions agree at `eventTime`, both their post-event
   updated meaning distributions and their post-write structural coordinates coincide
   and are uniquely recovered by the mechanical traction probe.
-/

namespace CombinedASHug
noncomputable section
open Filter Set MeasureTheory
open scoped Topology
open SocialAS HugV3Event

/-! ## 1. Product State Space of the Combined Hybrid System -/

/-- The combined state packages:
1. `asState : SocialAS.State` (`Fin 7 → ℝ`: `A, SSmoke, SClay, L_fwd, L_rev, zSmoke, zClay`),
2. `meaningDist : SocialAS.Meaning` (`Fin 2 → ℝ`: 2-state meaning simplex `H`),
3. `fabricCoord : ℝ` (structural rest-strain bit cell `b` from `HugV3Event`). -/
structure CombinedState where
  asState : SocialAS.State
  meaningDist : SocialAS.Meaning
  fabricCoord : ℝ

/-- Topological structure induced via embedding into `(Fin 7 → ℝ) × (Fin 2 → ℝ) × ℝ`. -/
def CombinedState.toProd (s : CombinedState) :
    SocialAS.State × SocialAS.Meaning × ℝ :=
  (s.asState, s.meaningDist, s.fabricCoord)

instance : TopologicalSpace CombinedState :=
  TopologicalSpace.induced CombinedState.toProd inferInstance

theorem continuous_toProd : Continuous CombinedState.toProd :=
  continuous_induced_dom

theorem continuous_asState : Continuous CombinedState.asState :=
  continuous_fst.comp continuous_toProd

theorem continuous_meaningDist : Continuous CombinedState.meaningDist :=
  (continuous_fst.comp continuous_snd).comp continuous_toProd

theorem continuous_fabricCoord : Continuous CombinedState.fabricCoord :=
  (continuous_snd.comp continuous_snd).comp continuous_toProd

/-- Combined validity invariant: `StateOK` on the 7 `SocialAS` coordinates,
`Simplex` on the meaning distribution `H`, and unambiguous well margin `|b| ≥ margin * a`. -/
def CombinedValid (a margin : ℝ) (s : CombinedState) : Prop :=
  SocialAS.StateOK s.asState ∧
  SocialAS.Simplex s.meaningDist ∧
  0 < a ∧ 0 < margin ∧ margin * a ≤ |s.fabricCoord|

/-- Deterministic hybrid jump map at an encounter event:
* The 7 integral coordinates `asState` remain continuous across the instant (`x⁺ = x⁻`),
* The meaning distribution `H` updates via `SocialAS.update beta C H M`,
* The structural memory slot coordinate jumps to `HugV3Event.writtenBit a bit`. -/
def applyEncounterEvent (beta : ℝ) (C : Bool) (M : SocialAS.Meaning)
    (a : ℝ) (bit : Bool) (s : CombinedState) : CombinedState where
  asState := s.asState
  meaningDist := SocialAS.update beta C s.meaningDist M
  fabricCoord := HugV3Event.writtenBit a bit

/-! ## 2. Exact Probe Recovery and Well-Margin Preservation for Written Bits -/

theorem combined_probe_recovers_rest_strain (k load b : ℝ) (hk : k ≠ 0) :
    inferredRestStrain k load b = b := by
  unfold inferredRestStrain traction
  field_simp
  ring

theorem combined_probe_recovers_written_bit (k load a : ℝ) (bit : Bool) (hk : k ≠ 0) :
    inferredRestStrain k load (writtenBit a bit) = writtenBit a bit :=
  combined_probe_recovers_rest_strain k load (writtenBit a bit) hk

theorem abs_writtenBit_eq {a : ℝ} (ha : 0 < a) (bit : Bool) :
    |writtenBit a bit| = a := by
  cases bit
  · unfold writtenBit
    simp only [Bool.false_eq_true, ite_false, mul_neg, mul_one, abs_neg, abs_of_pos ha]
  · unfold writtenBit
    simp only [ite_true, mul_one, abs_of_pos ha]

theorem written_bit_satisfies_well_margin {a margin : ℝ}
    (ha : 0 < a) (hmargin : margin ≤ 1) (bit : Bool) :
    margin * a ≤ |writtenBit a bit| := by
  rw [abs_writtenBit_eq ha bit]
  nlinarith

/-! ## 3. Clay-Channel Encounter Kernel (`SocialAS` E6–E8) Bridge Lemmas -/

theorem pos_nonneg (x : ℝ) : 0 ≤ pos x :=
  le_max_right x 0

theorem indicator_unit (b : Bool) : UnitInterval (indicator b) := by
  cases b <;> constructor <;> norm_num [SocialAS.indicator]

theorem clay_opportunity_nonneg {p : Parameters} (hp : ParametersOK p) (x : SocialAS.State) :
    0 ≤ opportunityActivation p.g (activation (x 2) p.threshold) := by
  rcases hp with ⟨_, _, _, _, _, _, _, _, _, _, hg, _, _, _, _, _, _, _, _, _, _, _, _⟩
  unfold opportunityActivation activation
  exact mul_nonneg hg.1 (pos_nonneg (x 2 - p.threshold))

theorem clay_opening_unit {p : Parameters} (hp : ParametersOK p) (x : SocialAS.State) :
    UnitInterval (opening p.g p.p0
      (opportunityActivation p.g (activation (x 2) p.threshold)) p.rStar) := by
  have hr : 0 ≤ opportunityActivation p.g (activation (x 2) p.threshold) :=
    clay_opportunity_nonneg hp x
  rcases hp with ⟨_, _, _, _, _, _, _, _, _, hrStar, hg, hp0, _, _, _, _, _, _, _, _, _, _, _⟩
  rcases hg with ⟨hg0, hg1⟩
  rcases hp0 with ⟨hp00, hp01⟩
  set r := opportunityActivation p.g (activation (x 2) p.threshold)
  have hden : 0 < p.rStar + r := by linarith
  have hne : p.rStar + r ≠ 0 := ne_of_gt hden
  have hfrac0 : 0 ≤ r / (p.rStar + r) := div_nonneg hr (le_of_lt hden)
  have hfrac1 : r / (p.rStar + r) ≤ 1 := by
    have hdiff : 1 - r / (p.rStar + r) = p.rStar / (p.rStar + r) := by
      field_simp
      ring
    have hpos : 0 ≤ p.rStar / (p.rStar + r) := div_nonneg (le_of_lt hrStar) (le_of_lt hden)
    linarith
  unfold opening
  rw [mul_div_assoc]
  have hb0 : 0 ≤ p.p0 + (1 - p.p0) * (r / (p.rStar + r)) :=
    add_nonneg hp00 (mul_nonneg (sub_nonneg.mpr hp01) hfrac0)
  have hb1 : p.p0 + (1 - p.p0) * (r / (p.rStar + r)) ≤ 1 := by
    have := mul_le_mul_of_nonneg_left hfrac1 (sub_nonneg.mpr hp01)
    nlinarith
  constructor
  · exact mul_nonneg hg0 hb0
  · nlinarith [mul_le_mul_of_nonneg_left hb1 hg0]

theorem smoke_conditionalRegistration_unit {p : Parameters} {x : SocialAS.State}
    {challenge : ℝ} (B : Bool)
    (hp : ParametersOK p) (hx : StateOK x) (hch : UnitInterval challenge) :
    UnitInterval (conditionalRegistration p.eta (x 5) challenge B) := by
  rcases hp with ⟨_, _, _, _, _, _, _, _, _, _, _, _, heta, _, _, _, _, _, _, _, _, _, _⟩
  rcases hx with ⟨_, _, hx5, _⟩
  rcases heta with ⟨he0, he1⟩
  rcases hx5 with ⟨hz0, hz1⟩
  rcases hch with ⟨hc0, hc1⟩
  rcases indicator_unit B with ⟨hi0, hi1⟩
  have hzch0 : 0 ≤ x 5 * challenge := mul_nonneg hz0 hc0
  have hzch1 : x 5 * challenge ≤ 1 := by nlinarith
  have hreg0 : 0 ≤ p.eta * (1 - x 5 * challenge) :=
    mul_nonneg he0 (sub_nonneg.mpr hzch1)
  have hreg1 : p.eta * (1 - x 5 * challenge) ≤ 1 := by
    nlinarith [mul_nonneg he0 hzch0]
  unfold conditionalRegistration registration
  constructor
  · exact mul_nonneg hreg0 hi0
  · nlinarith [mul_le_mul_of_nonneg_left hi1 hreg0]

theorem clay_encounter_branches_simplex {p : Parameters} {x : SocialAS.State}
    {challenge : ℝ} (B : Bool)
    (hp : ParametersOK p) (hx : StateOK x) (hch : UnitInterval challenge) :
    let p_open := opening p.g p.p0
      (opportunityActivation p.g (activation (x 2) p.threshold)) p.rStar
    let q_reg := conditionalRegistration p.eta (x 5) challenge B
    (∀ k : Fin 3, 0 ≤ branches p_open q_reg k) ∧
    (∑ k : Fin 3, branches p_open q_reg k) = 1 := by
  intro p_open q_reg
  rcases clay_opening_unit hp x with ⟨hp0, hp1⟩
  rcases smoke_conditionalRegistration_unit B hp hx hch with ⟨hq0, hq1⟩
  constructor
  · intro k
    fin_cases k <;> simp [branches] <;> nlinarith
  · simp [branches, Fin.sum_univ_three]
    ring

/-! ## 4. Preservation of `CombinedValid` and Non-Trivial Jump Across an Encounter Write -/

theorem update_preserves_simplex {beta : ℝ} (C : Bool) {H M : SocialAS.Meaning}
    (hbeta : UnitInterval beta) (hH : Simplex H) (hM : Simplex M) :
    Simplex (update beta C H M) := by
  rcases hbeta with ⟨hb0, hb1⟩
  rcases hH with ⟨hH0, hHsum⟩
  rcases hM with ⟨hM0, hMsum⟩
  rcases indicator_unit C with ⟨hi0, hi1⟩
  have hw0 : 0 ≤ beta * SocialAS.indicator C := mul_nonneg hb0 hi0
  have hw1 : beta * SocialAS.indicator C ≤ 1 := by nlinarith
  constructor
  · intro j
    have heq : update beta C H M j =
        (1 - beta * SocialAS.indicator C) * H j + (beta * SocialAS.indicator C) * M j := by
      unfold update information
      ring
    rw [heq]
    exact add_nonneg (mul_nonneg (sub_nonneg.mpr hw1) (hH0 j)) (mul_nonneg hw0 (hM0 j))
  · simp only [update, information, Fin.sum_univ_two] at hHsum hMsum ⊢
    linear_combination (1 - beta * indicator C) * hHsum + (beta * indicator C) * hMsum

theorem combined_event_preserves_valid_and_jumps
    {p : Parameters} {s : CombinedState} {M : SocialAS.Meaning}
    {a margin : ℝ} (C : Bool)
    (hp : ParametersOK p)
    (hstate : StateOK s.asState)
    (hH : Simplex s.meaningDist)
    (hM : Simplex M)
    (hempty : ValidEmptyCoordinate a margin s.fabricCoord)
    (hmargin_le : margin ≤ 1) :
    let s_post := applyEncounterEvent p.beta C M a true s
    CombinedValid a margin s_post ∧ s_post.fabricCoord ≠ s.fabricCoord := by
  intro s_post
  rcases hp with ⟨_, _, _, _, _, _, _, _, _, _, _, _, _, hbeta, _, _, _, _, _, _, _, _, _⟩
  rcases hempty with ⟨ha, hmargin_pos, hbefore⟩
  constructor
  · refine ⟨hstate, update_preserves_simplex C hbeta hH hM, ha, hmargin_pos, ?_⟩
    exact written_bit_satisfies_well_margin ha hmargin_le true
  · have hp_prod : 0 < margin * a := mul_pos hmargin_pos ha
    change writtenBit a true ≠ s.fabricCoord
    unfold writtenBit
    simp only [ite_true, mul_one]
    linarith

/-! ## 5. Continuity of the `SocialAS` Projection vs. Discontinuity of the Combined State -/

/-- In the combined hybrid model, any trajectory whose `SocialAS` component satisfies
`IntegralSolution` on `[t0, T]` and whose fabric coordinate experiences a scheduled
write witness at `eventTime ∈ [t0, T]` has a **continuous** `SocialAS` state projection
on `[t0, T]`, yet the **combined trajectory cannot be continuous** at `eventTime`. -/
theorem combined_trajectory_continuous_AS_but_discontinuous_full
    (p : Parameters) (i : ℝ → Inputs) (t0 T : ℝ) (initial : SocialAS.State)
    (path : ℝ → CombinedState)
    (hint : IntegralSolution p i t0 T initial (CombinedState.asState ∘ path))
    (eventTime before a : ℝ)
    (hwitness : EventWitness (CombinedState.fabricCoord ∘ path) eventTime before a) :
    ContinuousOn (CombinedState.asState ∘ path) (Icc t0 T) ∧
    ¬ ContinuousAt path eventTime := by
  refine ⟨hint.1, ?_⟩
  intro hcont
  have hcoord : ContinuousAt (CombinedState.fabricCoord ∘ path) eventTime :=
    continuous_fabricCoord.continuousAt.comp hcont
  rcases hwitness with ⟨hleft, hval, hbefore, ha⟩
  have hs : Tendsto (CombinedState.fabricCoord ∘ path) (𝓝[<] eventTime)
      (𝓝 ((CombinedState.fabricCoord ∘ path) eventTime)) :=
    hcoord.tendsto.mono_left nhdsWithin_le_nhds
  have heq : (CombinedState.fabricCoord ∘ path) eventTime = before :=
    tendsto_nhds_unique hs hleft
  unfold writtenBit at hval
  simp only [ite_true, mul_one] at hval
  linarith

/-! ## 6. Hybrid Uniqueness Across Continuous Evolution and Deterministic Event Jumps -/

/-- Two combined hybrid trajectories whose `SocialAS` components satisfy `IntegralSolution`
with the same initial data agree unconditionally on the accumulated source coordinate `A`
across `[t0, T]`, and if their pre-event states agree at `eventTime`, their post-event
states after `applyEncounterEvent` and their mechanical probe readouts are identical. -/
theorem combined_hybrid_uniqueness_transfer
    {p : Parameters} {i : ℝ → Inputs} {t0 T : ℝ} {initial : SocialAS.State}
    {path₁ path₂ : ℝ → CombinedState}
    (h₁ : IntegralSolution p i t0 T initial (CombinedState.asState ∘ path₁))
    (h₂ : IntegralSolution p i t0 T initial (CombinedState.asState ∘ path₂))
    {eventTime : ℝ} (ht : eventTime ∈ Icc t0 T)
    (hpre_eq : path₁ eventTime = path₂ eventTime)
    (C : Bool) (M : SocialAS.Meaning) (a k load : ℝ) (bit : Bool) (hk : k ≠ 0) :
    (path₁ eventTime).asState 0 = (path₂ eventTime).asState 0 ∧
    applyEncounterEvent p.beta C M a bit (path₁ eventTime) =
      applyEncounterEvent p.beta C M a bit (path₂ eventTime) ∧
    inferredRestStrain k load
      (applyEncounterEvent p.beta C M a bit (path₁ eventTime)).fabricCoord =
      writtenBit a bit := by
  refine ⟨?_, ?_, ?_⟩
  · change (CombinedState.asState ∘ path₁) eventTime 0 =
      (CombinedState.asState ∘ path₂) eventTime 0
    rw [h₁.2.2.2 0 eventTime ht, h₂.2.2.2 0 eventTime ht]
    rfl
  · rw [hpre_eq]
  · exact combined_probe_recovers_written_bit k load a bit hk

#print axioms combined_probe_recovers_written_bit
#print axioms clay_encounter_branches_simplex
#print axioms combined_event_preserves_valid_and_jumps
#print axioms combined_trajectory_continuous_AS_but_discontinuous_full
#print axioms combined_hybrid_uniqueness_transfer

end
end CombinedASHug
