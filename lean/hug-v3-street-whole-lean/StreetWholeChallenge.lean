import StreetWholeDefinitions

/-! Frozen reference statements. Comparator placeholders are not submitted proofs. -/
namespace HugV3.Source.StreetWholeVerified
noncomputable section
open StreetWhole
open scoped BigOperators

theorem full_input_keeps_all_other_coordinates (y : FullState) (signal : Scalar) :
    (fullLineInput y signal).starts=y.starts ∧
    {(fullLineInput y signal).state with g := y.state.g}=y.state ∧
    (∀ x k, k≠3 → (fullLineInput y signal).state.g x k=y.state.g x k) := by sorry

theorem line_enters_original_observation (G : Geometry) (s : State)
    (i : Actor) (signal : Scalar) :
    observations G (withLineSignal s signal) i 0=tanh (lineRead G s i signal/0.08) := by sorry

theorem line_keeps_body_and_heat_readings (G : Geometry) (s : State)
    (i : Actor) (signal : Scalar) :
    observations G (withLineSignal s signal) i 1=observations G s i 1 ∧
    observations G (withLineSignal s signal) i 2=observations G s i 2 := by sorry

theorem line_keeps_records_and_current_relevance (G : Geometry) (s : State)
    (signal : Scalar) (r : Record) :
    readRecords (withLineSignal s signal)=readRecords s ∧
    recordWeight G (withLineSignal s signal) r=recordWeight G s r := by sorry

theorem line_keeps_current_guard (s : State) (signal : Scalar) (i j : Actor) :
    margin (withLineSignal s signal) i j=margin s i j := by sorry

theorem personal_context_keeps_physical_state_and_records (G : Geometry)
    (s : State) (i : Actor) (h : ℝ) :
    {shiftPersonalContext s i h with context := s.context}=s ∧
    readRecords (shiftPersonalContext s i h)=readRecords s ∧
    observations G (shiftPersonalContext s i h)=observations G s := by sorry

theorem personal_context_total_preserved (s : State) (i : Actor) (h : ℝ) :
    (∑ k, (shiftPersonalContext s i h).context i k)=∑ k, s.context i k := by sorry

theorem personal_context_stays_in_unit_interval (s : State) (i : Actor) (h : ℝ)
    (hzero : 0≤s.context i 0+h ∧ s.context i 0+h≤1)
    (hone : 0≤s.context i 1-h ∧ s.context i 1-h≤1) :
    ∀ k, 0≤(shiftPersonalContext s i h).context i k ∧
      (shiftPersonalContext s i h).context i k≤1 := by sorry

theorem shifted_record_cue_coordinates (G : Geometry) (s : State) (r : Record)
    (hne : r.recipient≠r.origin) (h : ℝ) (k : Axis) :
    cueDifference G (shiftPersonalContext s r.recipient h) r k=
      cueDifference G s r k-(if k=0 then h/2 else if k=1 then -h/2 else 0) := by sorry

theorem original_weight_uses_current_cue (G : Geometry) (s : State) (r : Record) :
    recordWeight G s r=(r.endTime-r.startTime)*
      Real.exp (-sqnorm (cueDifference G s r)/(2*0.32^2)) := by sorry

theorem matched_record_weight_after_context_shift (G : Geometry) (s : State) (r : Record)
    (hne : r.recipient≠r.origin) (matched : ∀ k, cueDifference G s r k=0) (h : ℝ) :
    recordWeight G (shiftPersonalContext s r.recipient h) r=
      (r.endTime-r.startTime)*Real.exp (-(h^2/2)/(2*0.32^2)) := by sorry

theorem nonzero_context_shift_reduces_matched_weight (G : Geometry) (s : State) (r : Record)
    (hne : r.recipient≠r.origin) (matched : ∀ k, cueDifference G s r k=0)
    (duration : r.startTime<r.endTime) (h : ℝ) (nonzero : h≠0) :
    0<recordWeight G (shiftPersonalContext s r.recipient h) r ∧
    recordWeight G (shiftPersonalContext s r.recipient h) r<recordWeight G s r := by sorry

theorem record_weight_bounded_by_duration (G : Geometry) (s : State) (r : Record)
    (duration : r.startTime≤r.endTime) :
    0≤recordWeight G s r ∧ recordWeight G s r≤r.endTime-r.startTime := by sorry

theorem accepted_full_rhs_keeps_the_coupling (G : Geometry) (t : ℝ) (s d : State)
    (accepted : rhs G t s=some d) :
    ∃ records, readRecords s=some records ∧ d=rhsFromRecords G t s records ∧
      d.A=0.08*(socialRates G t s records).utility ∧
      (∀ x, d.g x 3=contextTransport (fun y => s.g y 3) (velocity s) x+
        s.A*sourceKernel G t s records x) ∧
      d.expression=(socialRates G t s records).expression ∧
      d.context=(socialRates G t s records).context := by sorry

theorem original_guard_rate_uses_line_observation_and_experience
    (G : Geometry) (t : ℝ) (s : State) (records : List (Fin 4 × Record)) (i j : Actor) :
    (rhsFromRecords G t s records).logRadius i j=
      1.8*(Real.log (0.55+0.45*sigmoid
        (1.4*s.relation i j 2+memory G s records i j 0-memory G s records i j 1+
          s.responses i j 6-s.responses i j 4-0.3*observations G s i 0))-s.logRadius i j) := by sorry

theorem constant_signal_shift_keeps_gradient_and_force (s : State) (signal : Scalar)
    (h : ℝ) :
    centeredGradient (withLineSignal s (fun x => signal x+h))=
      centeredGradient (withLineSignal s signal) ∧
    forcing (withLineSignal s (fun x => signal x+h))=
      forcing (withLineSignal s signal) := by sorry

theorem band_edge_gradient (s : State) (height : ℝ) :
    centeredGradient (withLineSignal s (bandSignal height)) (testCell 7)=![8*height,0,0] := by sorry

theorem band_center_does_not_activate (s : State) (height : ℝ) :
    forcing (withLineSignal s (bandSignal height)) (testCell 8)=![0,0,0] := by sorry

theorem small_band_edge_is_off (s : State) :
    forcing (withLineSignal s (bandSignal (1/1000))) (testCell 7)=![0,0,0] := by sorry

theorem larger_band_edge_is_on (s : State) :
    forcing (withLineSignal s (bandSignal (1/100))) (testCell 7) 0<0 := by sorry

theorem successful_write_preserves_person_and_line (G : Geometry) (s w : State) (r : Record)
    (accepted : writeEvent G s r=some w) :
    w.expression=s.expression ∧ w.context=s.context ∧ w.normCenter=s.normCenter ∧
    w.logRadius=s.logRadius ∧ w.relation=s.relation ∧ w.responses=s.responses ∧
    w.association=s.association ∧ w.X=s.X ∧ w.F=s.F ∧ w.A=s.A ∧
    (∀ x, w.g x 3=s.g x 3) ∧ s.writeWork≤w.writeWork := by sorry

theorem self_addressed_episode_is_rejected (r : Record) (self : r.origin=r.recipient) :
    payload r=none := by sorry

end
end HugV3.Source.StreetWholeVerified
