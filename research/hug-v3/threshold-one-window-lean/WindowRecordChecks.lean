import WindowRecordData
set_option maxRecDepth 100000
set_option maxHeartbeats 20000000
namespace ThresholdOneRecords

theorem decimal_scale_positive : 0 < decimalScale := by decide

theorem complete_record_counts :
    samples.length = 40 ∧ windows.length = 6 ∧
    inclusions.length = 12 ∧ tighterSamples.length = 6 := by decide

theorem forty_distinct_sample_labels :
    (samples.map Sample.label).eraseDups.length = 40 := by decide

theorem recorded_candidate_count :
    (samples.flatMap fun r => windows.flatMap fun w => (r.read w).candidates).length =
      candidateCount := by decide

theorem all_240_recorded_gaps_positive :
    samples.all (fun r => windows.all (fun w => decide (0 < (r.read w).gap))) = true := by decide

theorem all_240_selected_arclengths_in_window :
    samples.all (fun r => windows.all (fun w => inBounds decimalScale w (r.read w).s)) = true := by decide

theorem all_recorded_candidates_in_window :
    samples.all (fun r => windows.all (fun w =>
      (r.read w).candidates.all (fun c => inBounds decimalScale w c.1))) = true := by decide

theorem all_240_saved_minima_attained_and_minimal :
    samples.all (fun r => windows.all (fun w => savedMinimum (r.read w))) = true := by decide

theorem all_480_recorded_nested_window_inequalities :
    samples.all (fun r => inclusions.all (fun (small, large) =>
      decide ((r.read large).gap ≤ (r.read small).gap))) = true := by decide

theorem all_18_event_side_backward_gaps_strictly_smaller :
    eventSides.all (fun r => backwardWindows.all (fun w =>
      decide ((r.read w).gap < r.forward075.gap))) = true := by decide

theorem all_18_event_side_selected_arclengths_negative :
    eventSides.all (fun r => backwardWindows.all (fun w =>
      decide ((r.read w).s < 0))) = true := by decide

/-- Each recorded backward-0.75 improvement exceeds 0.0002 cube lengths. -/
theorem six_backward075_improvements_exceed_0002 :
    eventSides.all (fun r => decide
      (5000 * r.both075.gap + decimalScale < 5000 * r.forward075.gap)) = true := by decide

/-- Bracket width is positive and at most 2e-9 in the written time decimals. -/
theorem three_saved_time_brackets_narrow :
    eventPairs.all (fun (l, r) => decide (l.stamp < r.stamp ∧
      500000000 * (r.stamp - l.stamp) ≤ decimalScale)) = true := by decide

/-- The original selected arclengths differ by more than 0.1 across each bracket. -/
theorem three_original_recorded_arclength_changes_large :
    eventPairs.all (fun (l, r) => decide
      (decimalScale < 10 * (r.forward075.s - l.forward075.s).natAbs)) = true := by decide

/-- A bound on the two saved values, not continuity between their times. -/
theorem nine_backward_recorded_arclength_changes_below_two_millionths :
    eventPairs.all (fun (l, r) => backwardWindows.all (fun w => decide
      (500000 * ((r.read w).s - (l.read w).s).natAbs < decimalScale))) = true := by decide

theorem first_two_forward150_recorded_gaps_improve :
    firstTwoEventSides.all (fun r => decide
      (r.forward150.gap < r.forward075.gap ∧
       3 * (decimalScale : Int) < 4 * r.forward150.s)) = true := by decide

theorem third_forward_extensions_preserve_recorded_selection :
    thirdEventSides.all (fun r => decide
      (r.forward150.s = r.forward075.s ∧ r.forward150.gap = r.forward075.gap ∧
       r.forward300.s = r.forward075.s ∧ r.forward300.gap = r.forward075.gap)) = true := by decide

theorem third_original_left_selection_is_A : event3Left.forward075.s = 0 := by decide

theorem first_two_both300_recorded_gaps_improve_on_both150 :
    firstTwoEventSides.all (fun r => decide
      (r.both300.gap < r.both150.gap)) = true := by decide

theorem third_both300_and_both150_recorded_selections_agree :
    thirdEventSides.all (fun r => decide
      (r.both300.s = r.both150.s ∧ r.both300.gap = r.both150.gap)) = true := by decide

theorem tighter_records_match_event_labels_and_times :
    eventSides.length = tighterSamples.length ∧
    (eventSides.zip tighterSamples).all (fun (a, b) =>
      decide (a.label = b.label ∧ a.stamp = b.stamp)) = true := by decide

/-- All 36 written distance differences are at most 2.20e-13. -/
theorem all_36_tighter_distance_differences_bounded :
    (eventSides.zip tighterSamples).all (fun (a, b) => windows.all (fun w => decide
      (100000000000000 * (((a.read w).gap : Int) - ((b.read w).gap : Int)).natAbs ≤
        22 * decimalScale))) = true := by decide

/-- All 36 written signed-arclength differences are at most 6.68e-13. -/
theorem all_36_tighter_arclength_differences_bounded :
    (eventSides.zip tighterSamples).all (fun (a, b) => windows.all (fun w => decide
      (1000000000000000 * ((a.read w).s - (b.read w).s).natAbs ≤
        668 * decimalScale))) = true := by decide

end ThresholdOneRecords
