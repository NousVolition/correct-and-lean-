import PagerReturnModel
import PagerReturnReadings
import TwoMemoryTransport

namespace MeetingThread.PagerReturn

/-- Erasing the hidden cause from the listener's input preserves the previously checked rule. -/
theorem receive_agrees_with_original (e : Tremble) (later : List Focus)
    (w : WitnessReply) (accepted : Bool) (now : ℚ) :
    (receive (episodeRef e) later w accepted now).report = accountAt e w accepted now := rfl

/-- One can identify the correct cause on any open list of ordinary cue changes.
No later cue in this trace equals the first cue and there is no sensory replay action. -/
theorem recognition_on_an_open_route (e : Tremble) (w : WitnessReply) (now : ℚ)
    (first : ℝ) (cues : List ℝ) (away : first ∉ cues)
    (ordered : e.occurred ≤ w.arrives) (heard : w.arrives ≤ now)
    (same : w.about = e.id) (accurate : w.identifies = some e.actualCause) :
    let later := cues.map Focus.look
    ¬ReturnsTo first later ∧ later.any Focus.isReplay = false ∧
      (receive (episodeRef e) later w true now).marker = none ∧
      (receive (episodeRef e) later w true now).report = ⟨e.id, some e.actualCause⟩ := by
  dsimp only
  have noReturn : (cues.map Focus.look).map Focus.cue = cues := by
    simp [List.map_map, Function.comp_def, Focus.cue]
  have noReplay : (cues.map Focus.look).any Focus.isReplay = false := by
    simp [List.any_map, Function.comp_def, Focus.isReplay]
  have noMarker : visibleMarker (cues.map Focus.look) = none := by
    unfold visibleMarker
    rw [List.getLast?_map]
    cases cues.getLast? <;> rfl
  refine ⟨?_, noReplay, noMarker, ?_⟩
  · simpa [ReturnsTo, noReturn] using away
  · simp [receive, episodeRef, ordered, heard, same, accurate]

/-- A literal counterexample to universal necessity, with a positive time gap and
a nonempty route. The same instance defeats both proposed requirements at once. -/
theorem circle_is_not_necessary :
    ∃ (e : Tremble) (w : WitnessReply) (now : ℚ) (first : ℝ) (later : List Focus),
      e.actualCause = .pager ∧ e.occurred < w.arrives ∧ w.arrives ≤ now ∧
      later ≠ [] ∧ (receive (episodeRef e) later w true e.occurred).report.answer = none ∧
      (receive (episodeRef e) later w true now).report = ⟨e.id, some .pager⟩ ∧
      ¬ReturnsTo first later ∧ later.any Focus.isReplay = false ∧ visibleMarker later = none := by
  refine ⟨⟨7, 0, .pager⟩, ⟨7, 1, some .pager⟩, 2, 0, [.look 1], ?_⟩
  norm_num [receive, episodeRef, ReturnsTo, Focus.cue, Focus.isReplay, visibleMarker]

/-- Both listeners hear exactly the same answer. Only the returning view contains
the sensory marker, although both give the same report about the same episode. -/
theorem matched_views_can_agree (ref : EpisodeRef) (first away : ℝ)
    (distinct : first ≠ away) (marker : String) (w : WitnessReply) (accepted : Bool) (now : ℚ) :
    let direct := [Focus.look away]
    let replay := [Focus.look away, Focus.replay first marker]
    ¬ReturnsTo first direct ∧ ReturnsTo first replay ∧
      (receive ref direct w accepted now).marker = none ∧
      (receive ref replay w accepted now).marker = some marker ∧
      (receive ref direct w accepted now).report = (receive ref replay w accepted now).report := by
  simp [ReturnsTo, Focus.cue, receive, visibleMarker, distinct]

/-- Replay alone cannot make testimony about a different episode identify this one. -/
theorem replay_with_wrong_episode_stays_open (ref : EpisodeRef) (first : ℝ)
    (marker : String) (w : WitnessReply) (wrong : w.about ≠ ref.id) (now : ℚ) :
    let later := [Focus.replay first marker]
    ReturnsTo first later ∧ (receive ref later w true now).marker = some marker ∧
      (receive ref later w true now).report = ⟨ref.id, none⟩ := by
  simp [ReturnsTo, Focus.cue, receive, visibleMarker, wrong]

/-- In the Gaussian model exactly restoring the old odds does require the old cue. -/
theorem same_odds_iff_same_cue (a b : ℝ) :
    TwoMemoryTransport.odds a = TwoMemoryTransport.odds b ↔ a = b := by
  rw [TwoMemoryTransport.odds_eq_exp, TwoMemoryTransport.odds_eq_exp, Real.exp_eq_exp]
  constructor <;> intro h <;> linarith

/-! Exact statements about the five recorded pairs. The table is an empirical input. -/

theorem five_matched_reports_both_ways :
    readingCells.tail.length = 5 ∧ readings.map (·.episode) = ["K27","M14","D62","R35","V81"] ∧
    readings.all (fun r => groundedPager r.direct && groundedPager r.replay) = true := by decide

theorem pre_witness_and_other_pager_controls :
    readings.all (fun r => r.initial == "UNKNOWN/OPEN" && openControls r.direct &&
      openControls r.replay) = true := by decide

theorem only_replay_reports_original_marker :
    readings.map (·.originalMotif) = ["fern","anchor","acorn","comet","shell"] ∧
    readings.all (fun r => r.direct.motif == "UNSPECIFIED" &&
      r.replay.motif == r.originalMotif) = true := by decide

end MeetingThread.PagerReturn
