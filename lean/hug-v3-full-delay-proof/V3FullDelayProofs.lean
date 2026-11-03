import V3FullCoordinates

/-! No source equation is edited. The analytic hypotheses below remain obligations
for the actual full dynamics; a passing check is not the full hybrid theorem. -/
namespace HugV3.Source.FullDelayVerified
noncomputable section
open Set Metric FullDelay
open scoped NNReal

theorem full_state_round_trip (s : State) : decode (encode s) = s := decode_encode s

theorem full_vector_round_trip (z : FullVector) : encode (decode z) = z := encode_decode z

theorem full_state_equality (a b : State) (h : encode a = encode b) : a = b :=
  encode_injective h

private theorem picard_with_ball
    {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E] [CompleteSpace E]
    {f : ℝ → E → E} {a b : ℝ} {t₀ : Icc a b} {x₀ : E}
    {radius L K : ℝ≥0} (hp : IsPicardLindelof f t₀ x₀ radius 0 L K) :
    ∃ z : ℝ → E, z t₀ = x₀ ∧ ContinuousOn z (Icc a b) ∧
      (∀ t ∈ Icc a b, z t ∈ closedBall x₀ radius) ∧
      ∀ t ∈ Icc a b, HasDerivWithinAt z (f t (z t)) (Icc a b) t := by
  obtain ⟨z, hz⟩ := ODE.FunSpace.exists_isFixedPt_next hp (mem_closedBall_self le_rfl)
  refine ⟨z.compProj, ?_, z.continuous_compProj.continuousOn,
    fun _ _ => z.compProj_mem_closedBall hp.mul_max_le, ?_⟩
  · rw [ODE.FunSpace.compProj_val, ← hz, ODE.FunSpace.next_apply₀]
  · intro t ht
    apply ODE.hasDerivWithinAt_picard_Icc t₀.2 hp.continuousOn_uncurry
      z.continuous_compProj.continuousOn
      (fun _ _ => z.compProj_mem_closedBall hp.mul_max_le) x₀ ht |>.congr_of_mem _ ht
    intro t' ht'
    nth_rw 1 [← hz]
    rw [ODE.FunSpace.compProj_of_mem ht', ODE.FunSpace.next_apply]

theorem full_segment_exists_unique
    (G : Geometry) (records : List (Fin 4 × Record)) (history : ℝ → State)
    (τ a b : ℝ) (hab : a ≤ b) (start : State) (radius L K : ℝ≥0)
    (hp : IsPicardLindelof (frozenRate G records history τ)
      ⟨a, le_rfl, hab⟩ (encode start) radius 0 L K)
    (hc : Compatible G records history τ a b (encode start) radius) :
    ∃ z : ℝ → FullVector,
      Segment G history τ a b start z ∧
      (∀ t ∈ Icc a b, z t ∈ closedBall (encode start) radius) ∧
      ∀ w : ℝ → FullVector, Segment G history τ a b start w →
        (∀ t ∈ Icc a b, w t ∈ closedBall (encode start) radius) →
        EqOn z w (Icc a b) := by
  obtain ⟨z, hz0, hzc, hzb, hzd⟩ := picard_with_ball hp
  refine ⟨z, ⟨hz0, hzc, ?_⟩, hzb, ?_⟩
  · intro t ht
    refine ⟨decode (frozenRate G records history τ t (z t)), hc t ht (z t) (hzb t ht), ?_⟩
    simpa only [encode_decode] using hzd t ht
  · intro w hw hwb
    have hwd : ∀ t ∈ Icc a b,
        HasDerivWithinAt w (frozenRate G records history τ t (w t)) (Icc a b) t := by
      intro t ht
      obtain ⟨d, hd, hder⟩ := hw.2.2 t ht
      have heq : d = decode (frozenRate G records history τ t (w t)) :=
        Option.some.inj (hd.symm.trans (hc t ht (w t) (hwb t ht)))
      simpa only [heq, encode_decode] using hder
    apply ODE_solution_unique_of_mem_Icc_right
      (s := fun _ => closedBall (encode start) radius)
      (fun t ht => hp.lipschitzOnWith t ⟨ht.1, ht.2.le⟩)
      hzc _ (fun t ht => hzb t ⟨ht.1, ht.2.le⟩)
      hw.2.1 _ (fun t ht => hwb t ⟨ht.1, ht.2.le⟩) (hz0.trans hw.1.symm)
    · intro t ht
      exact ((hzd t ⟨ht.1, ht.2.le⟩).mono (Icc_subset_Icc ht.1 le_rfl)).mono_of_mem_nhdsWithin
        (Icc_mem_nhdsGE ht.2)
    · intro t ht
      exact ((hwd t ⟨ht.1, ht.2.le⟩).mono (Icc_subset_Icc ht.1 le_rfl)).mono_of_mem_nhdsWithin
        (Icc_mem_nhdsGE ht.2)

theorem history_preserved (a : ℝ) (past : ℝ → State) (z : ℝ → FullVector)
    (t : ℝ) (ht : t ≤ a) : extendHistory a past z t = past t := by
  simp only [extendHistory, if_pos ht]

theorem first_step_is_actual_delayed_rhs
    (G : Geometry) (history : ℝ → State) (τ a b : ℝ) (start : State)
    (z : ℝ → FullVector) (hτ : 0 < τ) (hstep : b ≤ a+τ)
    (hpast : history a = start) (hz : z a = encode start)
    (t : ℝ) (ht : t ∈ Icc a b) :
    Delay.rhsAlong G τ (extendHistory a history z) t =
      Delay.rhsDelayed G t (decode (z t)) (history (t-τ)) := by
  have hback : t-τ ≤ a := by linarith [ht.2]
  have hcurrent : extendHistory a history z t = decode (z t) := by
    by_cases hta : t ≤ a
    · have heq : t = a := le_antisymm hta ht.1
      subst t
      simp only [extendHistory, le_refl, if_true, hpast, hz, decode_encode]
    · simp only [extendHistory, if_neg hta]
  simp only [Delay.rhsAlong, hcurrent, history_preserved a history z (t-τ) hback]

theorem full_segment_is_delay_solution_on_step
    (G : Geometry) (history : ℝ → State) (τ a b : ℝ) (start : State)
    (z : ℝ → FullVector) (hτ : 0 < τ) (hstep : b ≤ a+τ)
    (hpast : history a = start) (hz : Segment G history τ a b start z) :
    ∀ t ∈ Icc a b, ∃ d : State,
      Delay.rhsAlong G τ (extendHistory a history z) t = some d ∧
      HasDerivWithinAt z (encode d) (Icc a b) t := by
  intro t ht
  rw [first_step_is_actual_delayed_rhs G history τ a b start z hτ hstep hpast hz.1 t ht]
  exact hz.2.2 t ht

set_option maxRecDepth 4096 in
theorem accepted_write_keeps_social (G : Geometry) (s w : State) (r : Record)
    (hw : writeEvent G s r = some w) : Delay.SameSocial w s := by
  classical
  unfold writeEvent at hw
  obtain ⟨records, _, hw⟩ := Option.bind_eq_some_iff.mp hw
  split at hw
  · cases hw
  · obtain ⟨slot, _, hw⟩ := Option.bind_eq_some_iff.mp hw
    obtain ⟨bytes, _, hw⟩ := Option.bind_eq_some_iff.mp hw
    dsimp only at hw
    split at hw
    · cases hw
    · have heq := Option.some.inj hw
      rw [← heq]
      exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

theorem completed_event_keeps_social (id : Fin 3) (s w : FullState)
    (hw : completeEvent id s = some w) : Delay.SameSocial w.state s.state := by
  unfold completeEvent at hw
  obtain ⟨startF, _, hw⟩ := Option.bind_eq_some_iff.mp hw
  obtain ⟨record, _, hw⟩ := Option.bind_eq_some_iff.mp hw
  obtain ⟨state, hwrite, hw⟩ := Option.bind_eq_some_iff.mp hw
  have heq := Option.some.inj hw
  rw [← heq]
  exact accepted_write_keeps_social sourceGeometry s.state state record hwrite

theorem accepted_boundary_keeps_social (k : ℕ) (s w : FullState)
    (hw : Delay.eventBoundary k s = some w) :
    Delay.SameSocial w.state s.state := by
  change boundary k s = some w at hw
  match k with
  | 0 =>
    rw [← Option.some.inj hw]
    exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩
  | 1 =>
    rw [← Option.some.inj hw]
    exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩
  | 2 => exact completed_event_keeps_social 0 s w hw
  | 3 =>
    change (completeEvent 1 s).map (capture 2) = some w at hw
    obtain ⟨v, hv, heq⟩ := Option.map_eq_some_iff.mp hw
    rw [← heq]
    exact completed_event_keeps_social 1 s v hv
  | 4 => exact completed_event_keeps_social 2 s w hw
  | n+5 =>
    rw [← Option.some.inj hw]
    exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

theorem boundary_deterministic (k : ℕ) (s a b : FullState)
    (ha : Delay.eventBoundary k s = some a) (hb : Delay.eventBoundary k s = some b) :
    a = b := Option.some.inj (ha.symm.trans hb)

theorem buffered_social_unchanged_by_write (G : Geometry) (present s w : State)
    (r : Record) (hw : writeEvent G s r = some w) :
    Delay.socialFrom present w = Delay.socialFrom present s := by
  obtain ⟨he, hc, hn, hl, hb, hr, ha⟩ := accepted_write_keeps_social G s w r hw
  simp only [Delay.socialFrom, he, hc, hn, hl, hb, hr, ha]

theorem full_delayed_trace_has_accepted_writes (τ : ℝ) (past : ℝ → State)
    (tr : Trace) (ht : DelayedSolves τ past tr) (k : ℕ) (hk : k < 5) :
    Delay.eventBoundary (k+1) (tr.path k (time (k+1))) ≠ none := by
  rw [(ht.2.2.2 k hk).2.2.2.2]
  exact Option.some_ne_none _

theorem full_segment_satisfies_original_coordinates
    (G : Geometry) (history : ℝ → State) (τ a b : ℝ) (start : State)
    (z : ℝ → FullVector) (hz : Segment G history τ a b start z) :
    ∀ t ∈ Icc a b, ∃ d : State,
      Delay.rhsDelayed G t (decode (z t)) (history (t-τ)) = some d ∧
      StateHasDerivWithinAt (fun s => decode (z s)) d (Icc a b) t := by
  intro t ht
  obtain ⟨d, hr, hd⟩ := hz.2.2 t ht
  exact ⟨d, hr, decoded_derivative hd⟩

#print axioms full_segment_exists_unique
#print axioms full_segment_is_delay_solution_on_step
#print axioms accepted_boundary_keeps_social

end
end HugV3.Source.FullDelayVerified
