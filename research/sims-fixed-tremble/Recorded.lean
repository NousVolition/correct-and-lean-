import RecordedData

/-!
Finite statements about the saved, explicitly graded reports.
Neither IDENTIFIED nor a denial of recollection is an independently verified
fact about the device or hidden cognition.
-/
set_option autoImplicit false
set_option maxRecDepth 8192
set_option maxHeartbeats 800000
namespace FixedTremble.Recorded

def baselines : List Row := rows.filter (fun r => r.stage == "baseline")
def firstStatuses : List Row := rows.filter (fun r => r.sequence == 3)
def statuses : List Row := rows.filter (fun r => r.phase == "status")
def retrospectives : List Row := rows.filter (fun r => r.phase == "retrospective")
def firstCell (evidence : String) (replay : Bool) : List Row :=
  firstStatuses.filter (fun r => r.evidence == evidence && r.replay == replay)
def settled (r : Row) : Bool :=
  r.phase == "status" && r.judgment == "IDENTIFIED" && r.device == "PAGER"

theorem recorded_turn_count : rows.length = 144 := by decide
theorem recorded_listener_count : baselines.length = 18 := by decide

theorem identical_initial_inputs :
    baselines.all (fun r =>
      r.inputHash == "829653837b28f1dd0a2e5bb16eb62e701ba89c1d0959d3db6e872d5f14cbe432") = true := by decide

theorem three_listeners_in_every_cell :
    (["vague", "linked", "withdrawn"].all fun e =>
      [false, true].all fun b => (firstCell e b).length == 3) = true := by decide

theorem paired_prime_clock :
    statuses.all (fun r =>
      (r.prime == some 2 && r.offsetUs == 0) ||
      (r.prime == some 23 && r.offsetUs == 800000) ||
      (r.prime == some 41 && r.offsetUs == 1200000)) = true := by decide

theorem vague_first_reports_remain_possible :
    (firstStatuses.filter (fun r => r.evidence == "vague")).all
      (fun r => r.judgment == "POSSIBLE" && r.device == "PAGER") = true := by decide

theorem withdrawn_first_reports_remain_open :
    (firstStatuses.filter (fun r => r.evidence == "withdrawn")).all
      (fun r => r.judgment == "OPEN" && r.device == "UNKNOWN") = true := by decide

theorem three_linked_no_replay_settlements :
    ((firstCell "linked" false).filter settled).length = 3 := by decide

theorem three_linked_replay_settlements :
    ((firstCell "linked" true).filter settled).length = 3 := by decide

theorem all_later_statuses_preserve_the_condition_pattern :
    statuses.all (fun r =>
      if r.evidence == "linked" then settled r
      else if r.evidence == "vague" then r.judgment == "POSSIBLE" && r.device == "PAGER"
      else r.judgment == "OPEN" && r.device == "UNKNOWN") = true := by decide

theorem supplied_replay_is_not_necessary_for_recorded_settlement :
    rows.all (fun r => !settled r || r.replay) = false := by decide

theorem no_primary_answer_explicitly_reports_recollection :
    (rows.filter (fun r => r.phase != "retrospective")).all
      (fun r => r.feeling != "recollection") = true := by decide

theorem eighteen_retrospective_denials :
    (retrospectives.filter (fun r => r.revisited == "NO")).length = 18 := by decide

theorem spontaneous_settlement_without_a_personal_feeling_mention :
    (rows.filter (fun r =>
      r.arm == 12 && r.sequence == 2 && !r.replay &&
      r.certainty == "explicit" && r.feeling == "reported_motion")).length = 1 := by decide

theorem that_listener_has_no_personal_reference_before_the_retrospective :
    (rows.filter (fun r => r.arm == 12 && r.sequence < 8)).all
      (fun r => r.feeling != "personal_mention" && r.feeling != "recollection") = true := by decide

theorem five_linked_first_thoughts_mention_the_feeling :
    (rows.filter (fun r => r.evidence == "linked" && r.sequence == 2 &&
      r.feeling == "personal_mention")).length = 5 := by decide

end FixedTremble.Recorded
