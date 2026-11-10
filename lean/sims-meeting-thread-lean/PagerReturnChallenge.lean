import PagerReturnModel
import PagerReturnReadings
import TwoMemoryModel

/-! Frozen questions about cue return and the matched restaurant observations. -/

namespace MeetingThread.PagerReturn

theorem receive_agrees_with_original (e : Tremble) (later : List Focus)
    (w : WitnessReply) (accepted : Bool) (now : ℚ) :
    (receive (episodeRef e) later w accepted now).report = accountAt e w accepted now := by sorry

theorem recognition_on_an_open_route (e : Tremble) (w : WitnessReply) (now : ℚ)
    (first : ℝ) (cues : List ℝ) (away : first ∉ cues)
    (ordered : e.occurred ≤ w.arrives) (heard : w.arrives ≤ now)
    (same : w.about = e.id) (accurate : w.identifies = some e.actualCause) :
    let later := cues.map Focus.look
    ¬ReturnsTo first later ∧ later.any Focus.isReplay = false ∧
      (receive (episodeRef e) later w true now).marker = none ∧
      (receive (episodeRef e) later w true now).report = ⟨e.id, some e.actualCause⟩ := by sorry

theorem circle_is_not_necessary :
    ∃ (e : Tremble) (w : WitnessReply) (now : ℚ) (first : ℝ) (later : List Focus),
      e.actualCause = .pager ∧ e.occurred < w.arrives ∧ w.arrives ≤ now ∧
      later ≠ [] ∧ (receive (episodeRef e) later w true e.occurred).report.answer = none ∧
      (receive (episodeRef e) later w true now).report = ⟨e.id, some .pager⟩ ∧
      ¬ReturnsTo first later ∧ later.any Focus.isReplay = false ∧ visibleMarker later = none := by sorry

theorem matched_views_can_agree (ref : EpisodeRef) (first away : ℝ)
    (distinct : first ≠ away) (marker : String) (w : WitnessReply) (accepted : Bool) (now : ℚ) :
    let direct := [Focus.look away]
    let replay := [Focus.look away, Focus.replay first marker]
    ¬ReturnsTo first direct ∧ ReturnsTo first replay ∧
      (receive ref direct w accepted now).marker = none ∧
      (receive ref replay w accepted now).marker = some marker ∧
      (receive ref direct w accepted now).report = (receive ref replay w accepted now).report := by sorry

theorem replay_with_wrong_episode_stays_open (ref : EpisodeRef) (first : ℝ)
    (marker : String) (w : WitnessReply) (wrong : w.about ≠ ref.id) (now : ℚ) :
    let later := [Focus.replay first marker]
    ReturnsTo first later ∧ (receive ref later w true now).marker = some marker ∧
      (receive ref later w true now).report = ⟨ref.id, none⟩ := by sorry

theorem same_odds_iff_same_cue (a b : ℝ) :
    TwoMemoryTransport.odds a = TwoMemoryTransport.odds b ↔ a = b := by sorry

theorem five_matched_reports_both_ways :
    readingCells.tail.length = 5 ∧ readings.map (·.episode) = ["K27","M14","D62","R35","V81"] ∧
    readings.all (fun r => groundedPager r.direct && groundedPager r.replay) = true := by sorry

theorem pre_witness_and_other_pager_controls :
    readings.all (fun r => r.initial == "UNKNOWN/OPEN" && openControls r.direct &&
      openControls r.replay) = true := by sorry

theorem only_replay_reports_original_marker :
    readings.map (·.originalMotif) = ["fern","anchor","acorn","comet","shell"] ∧
    readings.all (fun r => r.direct.motif == "UNSPECIFIED" &&
      r.replay.motif == r.originalMotif) = true := by sorry

end MeetingThread.PagerReturn
