import RecordedData

namespace ContinuingEvidence.Recorded

set_option maxRecDepth 4096
set_option maxHeartbeats 1000000

def quietFree (arm : Nat) : List Row :=
  rows.filter (fun r => r.arm == arm && r.quiet && r.free)

def quietStatus : List Row := rows.filter (fun r => r.quiet && !r.free)

def isPersonal (r : Row) : Bool :=
  r.feeling == "personal_mention" || r.feeling == "recollection"

theorem four_paths_and_all_registered_turns :
    rows.length = 120 ∧
    ([0, 1, 2, 3].map (fun a => (rows.filter (fun r => r.arm == a)).length)) = [38, 22, 38, 22] := by
  decide

theorem shared_quiet_clock_and_prime_prefix :
    [0, 1, 2, 3].all (fun a =>
      (quietFree a).map (·.offsetUs) ==
        [0, 100000, 200000, 300000, 400000, 500000, 600000, 700000, 800000,
         900000, 1000000, 1100000, 1200000, 2000000, 5000000, 10000000, 15000000] &&
      (quietFree a).filterMap (·.prime) == [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41]) = true := by
  decide

theorem all_four_start_with_a_tentative_pager_answer :
    (rows.filter (fun r => r.sequence == 1)).all
      (fun r => r.free && r.quiet && r.certainty == "probable") = true ∧
    (rows.filter (fun r => r.sequence == 1)).length = 4 := by decide

theorem quiet_reports_and_the_fifteen_second_endpoint :
    quietStatus.length = 36 ∧
    quietStatus.all (fun r => r.judgment == "POSSIBLE" && r.device == "PAGER") = true ∧
    (quietStatus.filter (fun r => r.offsetUs == 15000000)).length = 4 ∧
    (rows.filter (fun r => r.quiet && r.free && r.certainty == "explicit")).length = 0 := by decide

/-- The broader rule records one unhedged endorsement. It is preserved even
though this listener's later direct judgment is still POSSIBLE. -/
theorem broader_wording_rule_has_one_early_endorsement :
    (rows.filter (fun r => r.quiet && r.free && r.certainty == "bare")).map
      (fun r => (r.arm, r.offsetUs, r.prime)) = [(1, 200000, some 5)] ∧
    (rows.filter (fun r => r.quiet && r.free && r.certainty == "probable")).length = 47 ∧
    (rows.filter (fun r => r.quiet && r.free && r.certainty == "open")).length = 20 := by decide

theorem timing_and_repeat_have_different_reported_endpoints :
    (rows.filter (fun r => !r.quiet && !r.free)).map
      (fun r => (r.arm, r.afterFollowupUs, r.judgment)) =
        [(0, 0, "POSSIBLE"), (0, 1000000, "POSSIBLE"),
         (1, 0, "IDENTIFIED"), (1, 1000000, "IDENTIFIED"),
         (2, 0, "IDENTIFIED"), (2, 1000000, "IDENTIFIED"),
         (3, 0, "POSSIBLE"), (3, 1000000, "POSSIBLE")] := by decide

theorem personal_reference_and_first_explicit_certainty_share_one_reply :
    (rows.filter isPersonal).map
      (fun r => (r.arm, r.sequence, r.quiet, r.free, r.afterFollowupUs, r.certainty)) =
        [(2, 35, false, true, 0, "explicit")] ∧
    (rows.filter (fun r => r.feeling == "recollection")).length = 0 ∧
    (rows.filter (fun r => r.free && r.certainty == "explicit")).map
      (fun r => (r.arm, r.sequence)) = [(1, 19), (2, 35)] := by decide

/-- These are all recorded judgments. The pilot has one path per condition. -/
theorem final_judgments_under_both_interview_schedules :
    [0, 1, 2, 3].map (fun a =>
      ((rows.filter (fun r => r.arm == a && !r.free)).getLast?).map (·.judgment)) =
      [some "POSSIBLE", some "IDENTIFIED", some "IDENTIFIED", some "POSSIBLE"] := by decide

end ContinuingEvidence.Recorded
