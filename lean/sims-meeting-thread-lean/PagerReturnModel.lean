import MeetingModel

/-! A restaurant listener retains an episode reference. A private attention trace
records later cues, including any explicit replay of the first sensation.
The listener can receive evidence without receiving the world's hidden cause. -/
namespace MeetingThread.PagerReturn

structure EpisodeRef where
  id : Nat
  occurred : ℚ

def episodeRef (e : Tremble) : EpisodeRef := ⟨e.id, e.occurred⟩

inductive Focus where
  | look (cue : ℝ)
  | replay (cue : ℝ) (marker : String)

def Focus.cue : Focus → ℝ
  | .look s | .replay s _ => s

def Focus.isReplay : Focus → Bool
  | .look _ => false
  | .replay _ _ => true

/-- Later cues only. Counting the initial feeling as a return would make every route return. -/
def ReturnsTo (first : ℝ) (later : List Focus) : Prop :=
  first ∈ later.map Focus.cue

/-- The trace visible at the report. Looking elsewhere makes the sensory detail unavailable. -/
def visibleMarker (later : List Focus) : Option String :=
  match later.getLast? with
  | some (.replay _ marker) => some marker
  | _ => none

structure ListenerView where
  marker : Option String
  report : Account
  deriving DecidableEq

/-- The evidence rule from accountAt, expressed using only information available to the
listener. A matching, accepted witness can resolve the retained question once heard. -/
def receive (ref : EpisodeRef) (later : List Focus) (w : WitnessReply)
    (accepted : Bool) (now : ℚ) : ListenerView :=
  ⟨visibleMarker later,
    ⟨ref.id, if ref.occurred ≤ w.arrives ∧ w.arrives ≤ now ∧
      w.about = ref.id ∧ accepted = true then w.identifies else none⟩⟩

end MeetingThread.PagerReturn
