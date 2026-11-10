import TwoMemoryModel
import MeetingModel
import MeetingObservations

/-! Frozen target statements. Comparator builds this reference separately from the solutions. -/

open Set MeasureTheory
open scoped NNReal

set_option linter.unusedVariables false

namespace MemoryProof

theorem zeroField (a b x₀ : ℝ) (hab : a ≤ b) :
    ∃ x, Volterra.Solution (fun _ _ : ℝ => (0 : ℝ)) a b x₀ x ∧
      ∀ y, Volterra.Solution (fun _ _ : ℝ => (0 : ℝ)) a b x₀ y → EqOn y x (Icc a b) := by sorry

end MemoryProof

namespace TwoMemory

noncomputable section

theorem recall_eq_tanh (s : ℝ) : memoryField s = Real.tanh s := by sorry

theorem recall_lipschitz : LipschitzWith 1 memoryField := by sorry

theorem unique_memory_trajectory (a b x₀ : ℝ) (hab : a ≤ b) :
    ∃ x, Volterra.Solution (fun _ : ℝ => memoryField) a b x₀ x ∧
      ∀ y, Volterra.Solution (fun _ : ℝ => memoryField) a b x₀ y → EqOn y x (Icc a b) := by sorry

end

end TwoMemory

namespace TwoMemoryTransport

noncomputable section

theorem readout_from_odds (s : ℝ) :
    TwoMemory.memoryField s = (odds s - 1) / (odds s + 1) := by sorry

theorem odds_eq_exp (s : ℝ) : odds s = Real.exp (2 * s) := by sorry

theorem update_odds (a b : ℝ) : transport a b * odds a = odds b := by sorry

theorem compose_transport (a b c : ℝ) :
    transport b c * transport a b = transport a c := by sorry

theorem endpoints_determine_transport (a b : ℝ) (stops : List ℝ) :
    along a stops b = transport a b := by sorry

theorem closed_route (a : ℝ) (stops : List ℝ) : along a stops a = 1 := by sorry

theorem odds_parallel (s : ℝ) : deriv odds s + cueCoefficient * odds s = 0 := by sorry

theorem flat_curvature (i j : Fin 4) (p : Point) :
    curvature potential i j p = 0 := by sorry

theorem source_free (j : Fin 4) (p : Point) : yangMillsResidual potential j p = 0 := by sorry

theorem unit_speed_fails_memory_at_zero :
    deriv (fun t : ℝ => t) 0 ≠ TwoMemory.memoryField 0 := by sorry

end

end TwoMemoryTransport

namespace MeetingThread

theorem room_paused_while_wall_advances (c : Clocks) (duration : ℚ) (hd : 0 < duration) :
    (awaitReply c duration).room = c.room ∧ c.wall < (awaitReply c duration).wall := by sorry

theorem elapsed_interval_is_accounted_for (first lastUnsure firstSure : ℚ) :
    (lastUnsure - first) + (firstSure - lastUnsure) = firstSure - first := by sorry

theorem samples_leave_the_instant_open (l u : ℚ) (h : l < u) :
    ∃ c d : ℚ, l < c ∧ c < d ∧ d < u ∧
      (∀ t : ℚ, t ≤ l ∨ u ≤ t → (sureAt c t ↔ sureAt d t)) ∧
      sureAt c ((c+d)/2) ∧ ¬sureAt d ((c+d)/2) := by sorry

theorem same_question_before_and_after (e : Tremble) (w : WitnessReply)
    (early late : ℚ) (ordered : e.occurred ≤ w.arrives)
    (before : early < w.arrives) (afterwards : w.arrives ≤ late)
    (same : w.about = e.id) (accurate : w.identifies = some e.actualCause) :
    accountAt e w true early = ⟨e.id, none⟩ ∧
    accountAt e w true late = ⟨e.id, some e.actualCause⟩ := by sorry

theorem different_future_replies_same_open_past (e : Tremble) (a b : WitnessReply)
    (t : ℚ) (ha : t < a.arrives) (hb : t < b.arrives) :
    accountAt e a true t = accountAt e b true t := by sorry

theorem different_episode_still_open (e : Tremble) (w : WitnessReply)
    (h : w.about ≠ e.id) (t : ℚ) :
    (accountAt e w true t).answer = none := by sorry

theorem hearing_can_leave_the_question_open (e : Tremble) (w : WitnessReply) (t : ℚ) :
    (accountAt e w false t).answer = none := by sorry

theorem same_cue_same_episode_new_answer (cue : ℝ) (stops : List ℝ)
    (e : Tremble) (w : WitnessReply) (early late : ℚ)
    (ordered : e.occurred ≤ w.arrives) (before : early < w.arrives)
    (afterwards : w.arrives ≤ late) (same : w.about = e.id)
    (accurate : w.identifies = some e.actualCause) :
    TwoMemoryTransport.along cue stops cue * TwoMemoryTransport.odds cue = TwoMemoryTransport.odds cue ∧
    (accountAt e w true early).questionAbout = (accountAt e w true late).questionAbout ∧
    (accountAt e w true early).answer ≠ (accountAt e w true late).answer := by sorry

theorem before_mention_does_not_date_the_test (felt mentioned : ℚ) (h : felt < mentioned) :
    ∃ a b : ℚ, a = felt ∧ a < mentioned ∧ felt < b ∧ b < mentioned := by sorry

theorem one_circuit_same_station_and_volume (p n : Nat) (hp : p < n)
    (V r : ℚ) (hV : 0 < V) (hr : 0 ≤ r) (hr' : r ≤ 1) :
    (p+n) % n = p ∧ 0 ≤ remainingVolume V r ∧
    0 ≤ r*V ∧ returnedVolume V r = V := by sorry

theorem net_marker_exchange (V r old incoming : ℚ) :
    returnedMarker V r old incoming - V*old = r*V*(incoming-old) := by sorry

theorem equal_volume_different_contents :
    returnedVolume 1 0 = returnedVolume 1 1 ∧
      returnedMarker 1 0 0 1 ≠ returnedMarker 1 1 0 1 := by sorry

theorem growth_or_decay_after_one_circuit (V r old incoming : ℚ)
    (hV : 0 < V) (hr : 0 < r) :
    (V*old < returnedMarker V r old incoming ↔ old < incoming) ∧
    (returnedMarker V r old incoming < V*old ↔ incoming < old) := by sorry

theorem onset_at_threshold : sharpPush (99/100) = 0 ∧ sharpPush (101/100) = 1/100 := by sorry

theorem halved_playback_or_halved_flow (m v : ℚ) :
    (1/2 : ℚ)*v = 1*(v/2) ∧ m*(v/2)^2/2 = (m*v^2/2)/4 := by sorry

theorem same_snapshot_different_parcel_paths :
    (∀ t : ℝ, HasDerivAt (fun s : ℝ => (s,(0:ℝ))) (1,0) t ∧
              HasDerivAt (fun s : ℝ => (s,s^2)) (1,2*t) t) ∧
    ((1,(0:ℝ)) : ℝ × ℝ) = (1,2*0) ∧
    ((0,(0:ℝ)) : ℝ × ℝ) = (0,0^2) ∧
    ((1,(0:ℝ)) : ℝ × ℝ) ≠ (1,1^2) := by sorry

theorem positive_gross_flow_at_zero_net (q : ℚ) (hq : 0 < q) :
    q-q = 0 ∧ 0 < q+q := by sorry

theorem global_excess_allows_small_energy (C floor : ℚ) (hC : 0 < C) (hf : 0 < floor) :
    ∃ ε : ℚ, 0 < ε ∧ ∀ K : ℚ, K ≤ C*ε^2 → K < floor := by sorry

theorem scalar_refill_balance (total evolvedTag savedTag : ℚ) :
    (total - evolvedTag + savedTag) - total = savedTag - evolvedTag := by sorry

theorem same_readout_cannot_recover_both {S O : Type*} (readout : S → O)
    {s t : S} (different : s ≠ t) (same : readout s = readout t) :
    ¬∃ recover : O → S, ∀ x, recover (readout x) = x := by sorry

theorem energy_alone_cannot_recover_heading :
    ¬∃ recover : ℚ → ℚ × ℚ, ∀ v, recover (energy2 v) = v := by sorry

theorem restart_at_return {S D : Type*} (readDir : S → D) (advance : D → S → S)
    (n m : Nat) (s : S) :
    circuits readDir advance (n+m) s =
      circuits readDir advance m (circuits readDir advance n s) := by sorry

theorem recorded_B_endpoints :
    [pair1Quiet, pair1Anxious, pair2Quiet, pair2Anxious, pair3Quiet, pair3Anxious, pair4Quiet, pair4Anxious, pair5Quiet, pair5Anxious].map firstPager =
      [none, none, some 24278956, none, some 24378956, none, none, none, some 24078956, some 24078956] := by sorry

theorem recorded_A_time_partition :
    (aTimesMs.map (fun p => p.2.1 - p.1)).sum = 6460 ∧
    (aTimesMs.map (fun p => p.2.2 - p.2.1)).sum = 1250 ∧
    (aTimesMs.map (fun p => p.2.2 - p.1)).sum = 7710 := by sorry

theorem recorded_B_completion_counts :
    (quietReports.filterMap firstPager).length = 3 ∧
    (anxiousReports.filterMap firstPager).length = 1 := by sorry

theorem missing_endpoints_allow_opposite_mean_orders :
    (quietReports ++ anxiousReports).all (fun r => r.all (fun p => p.1 < 40000000)) = true ∧
    filledSum 40000000 quietReports < filledSum 40000000 anxiousReports ∧
    filledSum 40000000 anxiousReports < filledSum 100000000 quietReports := by sorry

theorem six_followups_remained_open : pagerAfterSecondReply = List.replicate 6 false := by sorry

theorem first_mentor_controls : initialMentorArms = [false,false,false,true] ∧
    organicProfiles = List.replicate 4 true := by sorry

theorem room_alert_and_false_notice_controls : fiveMinuteCues = [0,120,240] ∧
    finalAlertDeliveries = [[0,5],[0,5]] ∧ apparentTrembles = [0,120,240] ∧ physicalPulsesAtB = [] := by sorry

theorem recorded_native_controls : (strictSuiteCases.all (·.2)) = true ∧
    (strictSuiteCases.filter (fun c => c.1 == "accepted")).length = 4 ∧
    (strictSuiteCases.filter (fun c => c.1 == "rejected")).length = 8 ∧
    (strictSuiteCases.filter (fun c => c.1 == "no_application")).length = 2 := by sorry

theorem sampled_image_turns : (∀ x ∈ upperCirculations, 0 < x) ∧ (∀ x ∈ lowerCirculations, x < 0) := by sorry

theorem basin_startup_readings : let (a,b,c,d) := recordedStartupEnergy
    let (force,speed,into,outOf) := recordedMovingH
    a = 0 ∧ a < b ∧ b < c ∧ c < d ∧ force = 0 ∧ 0 < speed ∧
      0 < into ∧ 0 < outOf ∧ |into-outOf| < (1/10^16 : ℚ) := by sorry

theorem eight_refills_use_their_own_endpoints : basinBranches.length = 14 ∧
    basinBranches.all (fun branch => branch.length == 8 && linkedCheckpoints branch) = true := by sorry

end MeetingThread

namespace ApplicationControls

theorem all_premises (a b c x₀ : ℝ) (F G : ℝ → ℝ → ℝ) (K J : ℝ≥0)
    (e0 : a ≤ b)
    (e1 : ∀ x : ℝ → ℝ, ContinuousOn x (Icc a b) → IntervalIntegrable (fun t => F t (x t)) volume a b)
    (e2 : ∀ t ∈ Icc a b, LipschitzWith K (F t)) :
    ∃ x, Volterra.Solution F a b x₀ x ∧
      ∀ y, Volterra.Solution F a b x₀ y → EqOn y x (Icc a b) := by sorry

theorem new_field_repaired (a b c x₀ : ℝ) (F G : ℝ → ℝ → ℝ) (K J : ℝ≥0)
    (e0 : a ≤ b)
    (e1 : ∀ x : ℝ → ℝ, ContinuousOn x (Icc a b) → IntervalIntegrable (fun t => G t (x t)) volume a b)
    (e2 : ∀ t ∈ Icc a b, LipschitzWith K (G t)) :
    ∃ x, Volterra.Solution G a b x₀ x ∧
      ∀ y, Volterra.Solution G a b x₀ y → EqOn y x (Icc a b) := by sorry

end ApplicationControls
