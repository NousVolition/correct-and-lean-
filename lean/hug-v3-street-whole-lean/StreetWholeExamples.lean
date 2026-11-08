import StreetWholeProofs

open HugV3.Source HugV3.Source.StreetWhole HugV3.Source.StreetWholeVerified

-- Exact consequences for a synthetic input profile, not measured road markings.
example (s : State) : forcing (withLineSignal s (bandSignal (1/1000))) (testCell 7)=![0,0,0] :=
  small_band_edge_is_off s
example (s : State) : forcing (withLineSignal s (bandSignal (1/100))) (testCell 7) 0<0 :=
  larger_band_edge_is_on s
example (s : State) : forcing (withLineSignal s (bandSignal (1/100))) (testCell 8)=![0,0,0] :=
  band_center_does_not_activate s _

-- A concrete allowed reweighting of the selected person's two context components.
example (s : State) (i : Actor) (h0 : s.context i 0=1/2) (h1 : s.context i 1=1/2) :
    ∀ k, 0≤(shiftPersonalContext s i (1/10)).context i k ∧
      (shiftPersonalContext s i (1/10)).context i k≤1 := by
  apply personal_context_stays_in_unit_interval <;> norm_num [h0,h1]

-- With a matched incoming cue, this shift multiplies the duration by exp(-25/1024).
example (G : Geometry) (s : State) (r : Record) (hne : r.recipient≠r.origin)
    (matched : ∀ k, cueDifference G s r k=0) :
    recordWeight G (shiftPersonalContext s r.recipient (1/10)) r=
      (r.endTime-r.startTime)*Real.exp (-(25/1024)) := by
  rw [matched_record_weight_after_context_shift G s r hne matched]
  norm_num

-- A concrete matched cue on a full input containing the band. The candidate
-- record is evaluated by the original weight; no claim is made about a write
-- succeeding or this synthetic snapshot being reached by the declared trace.
private noncomputable def demoState (G : Geometry) : State :=
  withLineSignal {initial G with context := fun _ _ => 1/2} (bandSignal (1/100))

private noncomputable def demoRecord : Record :=
  {origin := 0, recipient := 1, eventID := 0, startTime := 0, endTime := 1,
   predecessors := 0, observed := some (1/2), report := some (1/2),
   context := fun _ => 1/2, recognition := 0, authority := 0,
   actions := fun _ => 0, deltaE := fun _ _ => 0}

private theorem demo_strain : strainNorm eye=0 := by
  have hg : ∀ i j, green eye i j=0 := by
    intro i j
    classical
    by_cases hij : i=j
    · subst j; simp [green,eye]
    · simp [green,eye,hij,Ne.symm hij]
  simp [strainNorm,hg]

private theorem demo_matched (G : Geometry) :
    ∀ k, cueDifference G (demoState G) demoRecord k=0 := by
  intro k
  fin_cases k <;>
    simp [cueDifference,recordFeature,recordChange,memoryFeature,demoState,demoRecord,
      withLineSignal,initial,demo_strain,HugV3.Source.tanh]

example (G : Geometry) : recordWeight G (demoState G) demoRecord=1 ∧
    recordWeight G (shiftPersonalContext (demoState G) 1 (1/10)) demoRecord=
      Real.exp (-(25/1024)) := by
  constructor
  · rw [original_weight_uses_current_cue]
    have hz : cueDifference G (demoState G) demoRecord=fun _ => 0 := funext (demo_matched G)
    rw [hz]
    norm_num [sqnorm,demoRecord]
  · change recordWeight G (shiftPersonalContext (demoState G) demoRecord.recipient (1/10)) demoRecord=_
    rw [matched_record_weight_after_context_shift G (demoState G) demoRecord
      (by decide) (demo_matched G)]
    norm_num [demoRecord]

#print axioms HugV3.Source.StreetWholeVerified.nonzero_context_shift_reduces_matched_weight
#print axioms HugV3.Source.StreetWholeVerified.accepted_full_rhs_keeps_the_coupling
#print axioms HugV3.Source.StreetWholeVerified.larger_band_edge_is_on
#print axioms HugV3.Source.StreetWholeVerified.successful_write_preserves_person_and_line
