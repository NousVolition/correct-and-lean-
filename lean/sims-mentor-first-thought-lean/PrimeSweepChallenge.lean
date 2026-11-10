import MentorThoughtModel

/-! Frozen questions for the fresh-listener prime sweep. -/

namespace MentorThought.Sweep

theorem five_at_every_prime :
    sweepCells.tail.length = 65 ∧ samples.length = 65 ∧
    labels.all (fun p => (atPrime p).map (·.episode) == ["K27","M14","D62","R35","V81"]) = true := by sorry

theorem no_volunteered_certainty :
    samples.all (fun r => r.certainty == "probable") = true ∧
    (samples.filter (fun r => r.certainty == "explicit" || r.certainty == "bare")).length = 0 := by sorry

theorem direct_identifications_by_tick :
    counts identified = [0,0,0,0,0,1,0,0,0,0,0,1,0] ∧
    locations identified = [("13","R35"),("37","R35")] ∧
    (samples.filter (fun r => r.source == "PAGER" && r.judgment == "POSSIBLE")).length = 63 := by sorry

theorem feelings_while_tentative :
    locations ownFeeling = [("2","K27"),("19","D62")] ∧
    (samples.filter ownFeeling).all (fun r => r.certainty == "probable" && r.judgment == "POSSIBLE") = true ∧
    (samples.filter (fun r => r.feeling == "recollection")).length = 0 ∧
    (samples.filter (fun r => r.feeling == "reported_motion")).length = 28 := by sorry

theorem no_majority_and_no_identification_after_personal_mention :
    (counts identified).all (fun n => n < 3) = true ∧
    (samples.filter (fun r => ownFeeling r && identified r)).length = 0 := by sorry

theorem last_bracket_comparison :
    schedule[11]? = some ⟨37,352,275,1100000⟩ ∧ schedule[12]? = some ⟨41,384,300,1200000⟩ ∧
    (1100000 : Nat) < 1104000 ∧ (1104000 : Nat) < 1106000 ∧ (1106000 : Nat) < 1126000 ∧
    (1126000 : Nat) < 1200000 ∧
    ((atPrime 37).filter identified).length = 1 ∧ ((atPrime 41).filter identified).length = 0 := by sorry

theorem one_snapshot_does_not_date_a_switch (t : Nat) (positive : 0 < t) :
    ∃ early late : Nat → Prop,
      (∀ i j, i ≤ j → early i → early j) ∧ (∀ i j, i ≤ j → late i → late j) ∧
      early t ∧ late t ∧ early 0 ∧ ¬ late 0 := by sorry

end MentorThought.Sweep
