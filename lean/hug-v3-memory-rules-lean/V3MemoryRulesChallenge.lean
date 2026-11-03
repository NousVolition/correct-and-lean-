import V3MemoryRulesDefinitions

/-! Frozen reference statements. `sorry` occurs only in this reference challenge;
the independently compiled solution must not import this module or depend on sorryAx. -/
namespace HugV3.Source.MemoryRulesVerified
noncomputable section
open MemoryRules Delay

theorem report_without_observation (r : Record) (y : ℝ) :
    score {r with observed := none, report := some y}=some y := by sorry

theorem both_missing_ignored (G : Geometry) (s : State) (rs : List (Fin 4 × Record))
    (slot : Fin 4) (r : Record) (i j : Actor) (k : Fin 4)
    (ho : r.observed=none) (hr : r.report=none) :
    memory G s ((slot,r)::rs) i j k=memory G s rs i j k := by sorry

theorem opposing_reports_zero (r : Record) (y : ℝ) :
    score {r with observed := some y, report := some (-y)}=some 0 := by sorry

theorem different_reports_same_score (r : Record) (x y δ : ℝ) :
    score {r with observed := some (x+δ), report := some (y-δ)}=
    score {r with observed := some x, report := some y} := by sorry

theorem time_translation_weight (G : Geometry) (s : State) (r : Record) (δ : ℝ) :
    recordWeight G s {r with startTime := r.startTime+δ, endTime := r.endTime+δ}=
    recordWeight G s r := by sorry

theorem closer_cue_increases_weight (G : Geometry) (s z : State) (r : Record)
    (ht : r.startTime<r.endTime)
    (hc : cueDistanceSquared G s r<cueDistanceSquared G z r) :
    recordWeight G z r<recordWeight G s r := by sorry

theorem association_changes_cue (G : Geometry) (s : State) (r : Record)
    (a : Actor → Actor → Fin 3 → ℝ) (k : Fin 3) :
    cueDifference G {s with association := a} r k-cueDifference G s r k=
    -0.15*(tanh (a r.recipient r.origin k)-tanh (s.association r.recipient r.origin k)) := by sorry

theorem changed_context_and_association_keep_record_bytes (s : State)
    (c : Actor → Fin 2 → ℝ) (a : Actor → Actor → Fin 3 → ℝ) :
    readRecords {s with context := c, association := a}=readRecords s := by sorry

theorem exposure_adds_across_records (G : Geometry) (s : State)
    (rs zs : List (Fin 4 × Record)) (i j : Actor) :
    exposure G s (rs++zs) i j=exposure G s rs i j+exposure G s zs i j := by sorry

theorem weighted_memory_merge (G : Geometry) (s : State)
    (rs zs : List (Fin 4 × Record)) (i j : Actor) (k : Fin 4)
    (hr : 0.12+exposure G s rs i j≠0) (hz : 0.12+exposure G s zs i j≠0) :
    memory G s (rs++zs) i j k=
    ((0.12+exposure G s rs i j)*memory G s rs i j k+
     (0.12+exposure G s zs i j)*memory G s zs i j k)/
    (0.12+exposure G s rs i j+exposure G s zs i j) := by sorry

theorem opposite_events_both_influence (G : Geometry) (s : State) (r z : Record)
    (hr : r.startTime<r.endTime) (hz : z.startTime<z.endTime)
    (hi : z.recipient=r.recipient) (hj : z.origin=r.origin)
    (y v : ℝ) (hy : 0<y) (hv : v<0)
    (hry : score r=some y) (hzv : score z=some v) :
    0<memory G s [(0,r),(1,z)] r.recipient r.origin 0 ∧
    0<memory G s [(0,r),(1,z)] r.recipient r.origin 1 := by sorry

theorem source_partner_remains_identified (G : Geometry) (s : State)
    (rs : List (Fin 4 × Record)) (slot : Fin 4) (r : Record) (i j : Actor)
    (hne : r.origin≠j) (k : Fin 4) :
    memory G s ((slot,r)::rs) i j k=memory G s rs i j k := by sorry

theorem self_record_rejected (r : Record) (h : r.origin=r.recipient) :
    payload r=none := by sorry

theorem buffered_cue_mixes_current_body_past_context (G : Geometry) (present past : State)
    (i j : Actor) :
    memoryFeature G (socialFrom present past) i j 0=memoryFeature G past i j 0 ∧
    memoryFeature G (socialFrom present past) i j 1=memoryFeature G past i j 1 ∧
    memoryFeature G (socialFrom present past) i j 2=memoryFeature G present i j 2 := by sorry

theorem buffered_records_current (present past : State) :
    readRecords (socialFrom present past)=readRecords present := by sorry

theorem zero_delay_unchanged (G : Geometry) (history : ℝ → State) (t : ℝ) :
    rhsAlong G 0 history t=rhs G t (history t) := by sorry

theorem only_selected_history_samples (G : Geometry) (τ t : ℝ)
    (h₁ h₂ : ℝ → State) (hn : h₁ t=h₂ t) (hp : h₁ (t-τ)=h₂ (t-τ)) :
    rhsAlong G τ h₁ t=rhsAlong G τ h₂ t := by sorry

end
end HugV3.Source.MemoryRulesVerified
