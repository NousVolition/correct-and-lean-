import V3MemoryRulesDefinitions
import V3DelayProofs

namespace HugV3.Source.MemoryRulesVerified
noncomputable section
open MemoryRules Delay

theorem report_without_observation (r : Record) (y : ℝ) :
    score {r with observed := none, report := some y}=some y := by rfl

theorem both_missing_ignored (G : Geometry) (s : State) (rs : List (Fin 4 × Record))
    (slot : Fin 4) (r : Record) (i j : Actor) (k : Fin 4)
    (ho : r.observed=none) (hr : r.report=none) :
    memory G s ((slot,r)::rs) i j k=memory G s rs i j k := by
  have hs : score r=none := by simp [score,ho,hr]
  simp [memory,exposure,hs]

theorem opposing_reports_zero (r : Record) (y : ℝ) :
    score {r with observed := some y, report := some (-y)}=some 0 := by
  simp [score]

theorem different_reports_same_score (r : Record) (x y δ : ℝ) :
    score {r with observed := some (x+δ), report := some (y-δ)}=
    score {r with observed := some x, report := some y} := by
  simp only [score]
  congr 1
  ring

theorem time_translation_weight (G : Geometry) (s : State) (r : Record) (δ : ℝ) :
    recordWeight G s {r with startTime := r.startTime+δ, endTime := r.endTime+δ}=
    recordWeight G s r := by
  simp only [recordWeight,recordChange]
  congr 1
  ring

theorem closer_cue_increases_weight (G : Geometry) (s z : State) (r : Record)
    (ht : r.startTime<r.endTime)
    (hc : cueDistanceSquared G s r<cueDistanceSquared G z r) :
    recordWeight G z r<recordWeight G s r := by
  change (r.endTime-r.startTime)*Real.exp (-cueDistanceSquared G z r/(2*0.32^2)) <
    (r.endTime-r.startTime)*Real.exp (-cueDistanceSquared G s r/(2*0.32^2))
  apply mul_lt_mul_of_pos_left _ (sub_pos.mpr ht)
  apply Real.exp_lt_exp.mpr
  exact div_lt_div_of_pos_right (neg_lt_neg hc) (by norm_num)

theorem association_changes_cue (G : Geometry) (s : State) (r : Record)
    (a : Actor → Actor → Fin 3 → ℝ) (k : Fin 3) :
    cueDifference G {s with association := a} r k-cueDifference G s r k=
    -0.15*(tanh (a r.recipient r.origin k)-tanh (s.association r.recipient r.origin k)) := by
  simp only [cueDifference,memoryFeature]
  ring

theorem changed_context_and_association_keep_record_bytes (s : State)
    (c : Actor → Fin 2 → ℝ) (a : Actor → Actor → Fin 3 → ℝ) :
    readRecords {s with context := c, association := a}=readRecords s := by rfl

theorem exposure_adds_across_records (G : Geometry) (s : State)
    (rs zs : List (Fin 4 × Record)) (i j : Actor) :
    exposure G s (rs++zs) i j=exposure G s rs i j+exposure G s zs i j := by
  simp [exposure]

theorem weighted_memory_merge (G : Geometry) (s : State)
    (rs zs : List (Fin 4 × Record)) (i j : Actor) (k : Fin 4)
    (hr : 0.12+exposure G s rs i j≠0) (hz : 0.12+exposure G s zs i j≠0) :
    memory G s (rs++zs) i j k=
    ((0.12+exposure G s rs i j)*memory G s rs i j k+
     (0.12+exposure G s zs i j)*memory G s zs i j k)/
    (0.12+exposure G s rs i j+exposure G s zs i j) := by
  simp only [memory,List.map_append,List.sum_append,exposure_adds_across_records]
  rw [mul_div_cancel₀ _ hr,mul_div_cancel₀ _ hz]
  congr 1
  ring

private theorem weight_positive (G : Geometry) (s : State) (r : Record)
    (ht : r.startTime<r.endTime) : 0<recordWeight G s r := by
  unfold recordWeight
  exact mul_pos (sub_pos.mpr ht) (Real.exp_pos _)

theorem opposite_events_both_influence (G : Geometry) (s : State) (r z : Record)
    (hr : r.startTime<r.endTime) (hz : z.startTime<z.endTime)
    (hi : z.recipient=r.recipient) (hj : z.origin=r.origin)
    (y v : ℝ) (hy : 0<y) (hv : v<0)
    (hry : score r=some y) (hzv : score z=some v) :
    0<memory G s [(0,r),(1,z)] r.recipient r.origin 0 ∧
    0<memory G s [(0,r),(1,z)] r.recipient r.origin 1 := by
  have hwr := weight_positive G s r hr
  have hwz := weight_positive G s z hz
  have hden : 0<(0.12:ℝ)+(recordWeight G s r+recordWeight G s z) := by positivity
  constructor
  · simpa [memory,exposure,hi,hj,hry,hzv,max_eq_left hy.le,max_eq_right hv.le,
      max_eq_right (by linarith : -y≤0),max_eq_left (by linarith : 0≤-v)] using
      div_pos (mul_pos hwr hy) hden
  · simpa [memory,exposure,hi,hj,hry,hzv,max_eq_left hy.le,max_eq_right hv.le,
      max_eq_right (by linarith : -y≤0),max_eq_left (by linarith : 0≤-v)] using
      div_pos (mul_pos hwz (by linarith : 0< -v)) hden

theorem source_partner_remains_identified (G : Geometry) (s : State)
    (rs : List (Fin 4 × Record)) (slot : Fin 4) (r : Record) (i j : Actor)
    (hne : r.origin≠j) (k : Fin 4) :
    memory G s ((slot,r)::rs) i j k=memory G s rs i j k := by
  simp [memory,exposure,hne]

theorem self_record_rejected (r : Record) (h : r.origin=r.recipient) :
    payload r=none := by
  unfold payload
  rw [ite_eq_left (Or.inl h)]

theorem buffered_cue_mixes_current_body_past_context (G : Geometry) (present past : State)
    (i j : Actor) :
    memoryFeature G (socialFrom present past) i j 0=memoryFeature G past i j 0 ∧
    memoryFeature G (socialFrom present past) i j 1=memoryFeature G past i j 1 ∧
    memoryFeature G (socialFrom present past) i j 2=memoryFeature G present i j 2 := by
  simp only [memoryFeature,socialFrom,Matrix.cons_val_zero,Matrix.cons_val_one,
    Matrix.cons_val_two,Matrix.vecHead,Matrix.vecTail,Function.comp_apply,
    Matrix.cons_val_succ,true_and]

theorem buffered_records_current (present past : State) :
    readRecords (socialFrom present past)=readRecords present := by rfl

theorem zero_delay_unchanged (G : Geometry) (history : ℝ → State) (t : ℝ) :
    rhsAlong G 0 history t=rhs G t (history t) := by
  exact DelayVerified.history_zero_delay G history t

theorem only_selected_history_samples (G : Geometry) (τ t : ℝ)
    (h₁ h₂ : ℝ → State) (hn : h₁ t=h₂ t) (hp : h₁ (t-τ)=h₂ (t-τ)) :
    rhsAlong G τ h₁ t=rhsAlong G τ h₂ t := by
  simp only [rhsAlong,hn,hp]

end
end HugV3.Source.MemoryRulesVerified
