import V3OccupiedSpaceDefinitions
import Mathlib.Analysis.SpecialFunctions.ExpDeriv

namespace HugV3.Source.OccupiedSpaceVerified
noncomputable section
attribute [local instance] Classical.propDecidable
open OccupiedSpace Set
open scoped BigOperators
set_option maxRecDepth 4096

theorem margin_is_original (s : State) (owner visitor : Actor) :
    guardMarginAt s owner visitor (s.expression visitor) = margin s owner visitor := by
  rfl

private theorem half_sigmoid_iff (x : ℝ) : (1/2 : ℝ) < sigmoid x ↔ 0 < x := by
  unfold sigmoid
  rw [lt_div_iff₀ (by positivity : (0 : ℝ) < 1 + Real.exp (-x))]
  constructor
  · intro h
    have he : Real.exp (-x) < 1 := by linarith
    have hx : -x < 0 := Real.exp_lt_one_iff.mp he
    linarith
  · intro h
    have he : Real.exp (-x) < 1 := Real.exp_lt_one_iff.mpr (by linarith)
    linarith

theorem region_matches_half_permission (s : State) (owner visitor : Actor) (z : Action) :
    z ∈ guardRegion s owner visitor ↔ (1/2 : ℝ) < sigmoid (guardMarginAt s owner visitor z/0.18) := by
  change 0 < guardMarginAt s owner visitor z ↔ _
  rw [half_sigmoid_iff]
  norm_num [div_eq_mul_inv]

theorem soft_permission_positive (s : State) (owner visitor : Actor) (z : Action) :
    0 < sigmoid (guardMarginAt s owner visitor z/0.18) := by
  unfold sigmoid
  positivity

theorem region_contains_owners_center (s : State) (owner visitor : Actor) :
    s.normCenter owner ∈ guardRegion s owner visitor := by
  simpa [guardRegion, guardMarginAt] using Real.exp_pos (s.logRadius owner visitor)

theorem same_audience_regions_overlap (s : State) (owner i j : Actor) :
    (guardRegion s owner i ∩ guardRegion s owner j).Nonempty := by
  exact ⟨s.normCenter owner, region_contains_owners_center s owner i,
    region_contains_owners_center s owner j⟩

theorem initial_zero_in_every_guard (G : Geometry) (owner visitor : Actor) :
    zeroAction ∈ guardRegion (initial G) owner visitor := by
  change 0 < Real.exp (Real.log (0.72 : ℝ)) -
    Real.sqrt (∑ k, (0 - 0.65 * intent owner k)^2)
  rw [Real.exp_log (by norm_num : (0 : ℝ) < 0.72)]
  have hnon : 0 ≤ ∑ k : Fin 2, (0 - 0.65 * intent owner k)^2 :=
    Finset.sum_nonneg fun _ _ => sq_nonneg _
  have hs := Real.sq_sqrt hnon
  have hn := Real.sqrt_nonneg (∑ k : Fin 2, (0 - 0.65 * intent owner k)^2)
  have hsmall : (∑ k : Fin 2, (0 - 0.65 * intent owner k)^2) < (0.72 : ℝ)^2 := by
    fin_cases owner <;> norm_num [intent, Fin.sum_univ_succ]
  nlinarith

theorem initial_zero_in_every_whole_region (G : Geometry) (audience : Audience) (i : Actor) :
    zeroAction ∈ occupiedRegion (initial G) audience i := by
  intro owner _ _
  exact initial_zero_in_every_guard G owner i

theorem initial_exclusion_refuted (G : Geometry) (audience : Audience) :
    ¬ Exclusion (initial G) audience := by
  intro h
  exact Set.disjoint_left.mp (h 1 2 (by decide))
    (initial_zero_in_every_whole_region G audience 1)
    (initial_zero_in_every_whole_region G audience 2)

theorem full_hybrid_exclusion_refuted (tr : Trace) (hsol : Solves tr) (audience : Audience) :
    ¬ ExclusionThroughout tr audience := by
  intro h
  have hzero := h.1 0 (by norm_num)
  rw [hsol.1] at hzero
  exact initial_exclusion_refuted sourceGeometry audience hzero

theorem write_preserves_personal_pulley (G : Geometry) (s w : State) (record : Record)
    (hw : writeEvent G s record = some w) (i : Actor) : pulleyView w i = pulleyView s i := by
  have hs := BridgeReturnVerified.write_preserves_person_group_state G s w record hw
  simp only [pulleyView, hs]

theorem write_preserves_whole_regions (G : Geometry) (s w : State) (record : Record)
    (hw : writeEvent G s record = some w) (audience : Audience) (i : Actor) :
    occupiedRegion w audience i = occupiedRegion s audience i := by
  have hs := BridgeReturnVerified.write_preserves_person_group_state G s w record hw
  have hn : w.normCenter = s.normCenter := congrArg BridgeReturn.SocialSnapshot.normCenter hs
  have hl : w.logRadius = s.logRadius := congrArg BridgeReturn.SocialSnapshot.logRadius hs
  simp only [occupiedRegion, guardRegion, guardMarginAt, hn, hl]

private theorem complete_preserves_regions (id : Fin 3) (s w : FullState)
    (hw : completeEvent id s = some w) (audience : Audience) (i : Actor) :
    occupiedRegion w.state audience i = occupiedRegion s.state audience i := by
  unfold completeEvent at hw
  obtain ⟨start, _, hw⟩ := Option.bind_eq_some_iff.mp hw
  obtain ⟨record, _, hw⟩ := Option.bind_eq_some_iff.mp hw
  obtain ⟨state, hwrite, hw⟩ := Option.bind_eq_some_iff.mp hw
  rw [← Option.some.inj hw]
  exact write_preserves_whole_regions sourceGeometry s.state state record hwrite audience i

theorem boundary_preserves_whole_regions (q : ℕ) (s w : FullState)
    (hw : boundary q s = some w) (audience : Audience) (i : Actor) :
    occupiedRegion w.state audience i = occupiedRegion s.state audience i := by
  match q with
  | 0 => rw [← Option.some.inj hw]; rfl
  | 1 => rw [← Option.some.inj hw]; rfl
  | 2 => exact complete_preserves_regions 0 s w hw audience i
  | 3 =>
    change (completeEvent 1 s).map (capture 2) = some w at hw
    obtain ⟨y, hy, heq⟩ := Option.map_eq_some_iff.mp hw
    rw [← heq]
    exact complete_preserves_regions 1 s y hy audience i
  | 4 => exact complete_preserves_regions 2 s w hw audience i
  | n+5 => rw [← Option.some.inj hw]

theorem boundary_preserves_exclusion_status (q : ℕ) (s w : FullState)
    (hw : boundary q s = some w) (audience : Audience) :
    Exclusion w.state audience ↔ Exclusion s.state audience := by
  simp only [Exclusion, boundary_preserves_whole_regions q s w hw audience]

theorem delay_uses_buffered_regions (present past : State) (audience : Audience) (i : Actor) :
    occupiedRegion (Delay.socialFrom present past) audience i = occupiedRegion past audience i := by
  rfl

private theorem region_score_derivative (s : ℝ → State) (rate : State)
    (I : Set ℝ) (t : ℝ) (hd : StateHasDerivWithinAt s rate I t)
    (owner visitor : Actor) (z : Action) :
    HasDerivWithinAt (fun τ => regionScore (s τ) owner visitor z)
      (regionScoreRate (s t) rate owner visitor z) I t := by
  rcases hd with ⟨_, _, _, _, _, _, _, _, _, _, hn, hl, _, _, _⟩
  have hexp := ((hl owner visitor).exp).pow 2
  have hsum := HasDerivWithinAt.sum (u := Finset.univ)
    (fun k _ => ((hn owner k).const_sub (z k)).pow 2)
  convert! hexp.sub hsum using 1 <;>
    simp [regionScore, regionScoreRate, Finset.mul_sum, pow_two, mul_assoc] <;> ring

theorem full_region_motion (tr : Trace) (hsol : Solves tr) (q : ℕ) (hq : q < 5)
    (t : ℝ) (ht : t ∈ Icc (time q) (time (q+1))) (owner visitor : Actor) (z : Action) :
    ∃ rate, rhs sourceGeometry t (tr.path q t).state = some rate ∧
      HasDerivWithinAt (fun τ => regionScore (tr.path q τ).state owner visitor z)
        (regionScoreRate (tr.path q t).state rate owner visitor z)
        (Icc (time q) (time (q+1))) t := by
  obtain ⟨rate, hr, hd⟩ := (hsol.2 q hq).2.2.2.1 t ht
  exact ⟨rate, hr, region_score_derivative (fun τ => (tr.path q τ).state)
    rate (Icc (time q) (time (q+1))) t hd owner visitor z⟩

end
end HugV3.Source.OccupiedSpaceVerified
