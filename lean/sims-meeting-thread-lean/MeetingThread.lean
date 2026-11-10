import MeetingModel
import MeetingObservations
import TwoMemoryTransport

namespace MeetingThread

theorem room_paused_while_wall_advances (c : Clocks) (duration : ℚ) (hd : 0 < duration) :
    (awaitReply c duration).room = c.room ∧ c.wall < (awaitReply c duration).wall := by
  refine ⟨rfl, ?_⟩
  dsimp [awaitReply]
  linarith

theorem elapsed_interval_is_accounted_for (first lastUnsure firstSure : ℚ) :
    (lastUnsure - first) + (firstSure - lastUnsure) = firstSure - first := by ring

/-- Two different interior crossings are distinguishable inside the interval
    and agree at every sample outside its open interior, including both ends. -/
theorem samples_leave_the_instant_open (l u : ℚ) (h : l < u) :
    ∃ c d : ℚ, l < c ∧ c < d ∧ d < u ∧
      (∀ t : ℚ, t ≤ l ∨ u ≤ t → (sureAt c t ↔ sureAt d t)) ∧
      sureAt c ((c+d)/2) ∧ ¬sureAt d ((c+d)/2) := by
  let c := (2*l+u)/3
  let d := (l+2*u)/3
  have hl : l < c := by dsimp [c]; linarith
  have hm : c < d := by dsimp [c,d]; linarith
  have hu : d < u := by dsimp [d]; linarith
  refine ⟨c,d,hl,hm,hu,?_,?_,?_⟩
  · intro t ht
    unfold sureAt
    rcases ht with ht | ht <;> constructor <;> intro hh <;> linarith
  · unfold sureAt
    linarith
  · unfold sureAt
    intro hh
    linarith

theorem same_question_before_and_after (e : Tremble) (w : WitnessReply)
    (early late : ℚ) (ordered : e.occurred ≤ w.arrives)
    (before : early < w.arrives) (afterwards : w.arrives ≤ late)
    (same : w.about = e.id) (accurate : w.identifies = some e.actualCause) :
    accountAt e w true early = ⟨e.id, none⟩ ∧
    accountAt e w true late = ⟨e.id, some e.actualCause⟩ := by
  simp [accountAt, ordered, not_le.mpr before, afterwards, same, accurate]

theorem different_future_replies_same_open_past (e : Tremble) (a b : WitnessReply)
    (t : ℚ) (ha : t < a.arrives) (hb : t < b.arrives) :
    accountAt e a true t = accountAt e b true t := by
  simp [accountAt, not_le.mpr ha, not_le.mpr hb]

theorem different_episode_still_open (e : Tremble) (w : WitnessReply)
    (h : w.about ≠ e.id) (t : ℚ) :
    (accountAt e w true t).answer = none := by simp [accountAt,h]

theorem hearing_can_leave_the_question_open (e : Tremble) (w : WitnessReply) (t : ℚ) :
    (accountAt e w false t).answer = none := by simp [accountAt]

/-- Returning to a cue restores its two-memory odds. The simultaneous account
    of an episode can change, on the stated acceptance and reference conditions. -/
theorem same_cue_same_episode_new_answer (cue : ℝ) (stops : List ℝ)
    (e : Tremble) (w : WitnessReply) (early late : ℚ)
    (ordered : e.occurred ≤ w.arrives) (before : early < w.arrives)
    (afterwards : w.arrives ≤ late) (same : w.about = e.id)
    (accurate : w.identifies = some e.actualCause) :
    TwoMemoryTransport.along cue stops cue * TwoMemoryTransport.odds cue = TwoMemoryTransport.odds cue ∧
    (accountAt e w true early).questionAbout = (accountAt e w true late).questionAbout ∧
    (accountAt e w true early).answer ≠ (accountAt e w true late).answer := by
  obtain ⟨he,hl⟩ := same_question_before_and_after e w early late ordered before afterwards same accurate
  simp [TwoMemoryTransport.closed_route, he, hl]

/-- The reply "before you mentioned it" is compatible with two test times.
    One coincides with feeling the tremble, the other is strictly later. -/
theorem before_mention_does_not_date_the_test (felt mentioned : ℚ) (h : felt < mentioned) :
    ∃ a b : ℚ, a = felt ∧ a < mentioned ∧ felt < b ∧ b < mentioned := by
  refine ⟨felt,(felt+mentioned)/2,rfl,h,?_,?_⟩ <;> linarith

theorem one_circuit_same_station_and_volume (p n : Nat) (hp : p < n)
    (V r : ℚ) (hV : 0 < V) (hr : 0 ≤ r) (hr' : r ≤ 1) :
    (p+n) % n = p ∧ 0 ≤ remainingVolume V r ∧
    0 ≤ r*V ∧ returnedVolume V r = V := by
  refine ⟨by simp [Nat.mod_eq_of_lt hp], ?_, mul_nonneg hr hV.le, ?_⟩
  · unfold remainingVolume
    nlinarith [mul_nonneg (sub_nonneg.mpr hr') hV.le]
  · unfold returnedVolume remainingVolume
    ring

theorem net_marker_exchange (V r old incoming : ℚ) :
    returnedMarker V r old incoming - V*old = r*V*(incoming-old) := by
  unfold returnedMarker remainingVolume
  ring

/-- An unchanged reading of total volume cannot distinguish no turnover from
    full replacement. A marker distinguishes these two concrete histories. -/
theorem equal_volume_different_contents :
    returnedVolume 1 0 = returnedVolume 1 1 ∧
      returnedMarker 1 0 0 1 ≠ returnedMarker 1 1 0 1 := by
  norm_num [returnedVolume, returnedMarker, remainingVolume]

theorem growth_or_decay_after_one_circuit (V r old incoming : ℚ)
    (hV : 0 < V) (hr : 0 < r) :
    (V*old < returnedMarker V r old incoming ↔ old < incoming) ∧
    (returnedMarker V r old incoming < V*old ↔ incoming < old) := by
  have h := net_marker_exchange V r old incoming
  have hpos : 0 < r*V := mul_pos hr hV
  constructor
  · rw [← sub_pos, h, mul_pos_iff_of_pos_left hpos, sub_pos]
  · constructor
    · intro decrease
      by_contra! hinc
      have hprod := mul_nonneg hpos.le (sub_nonneg.mpr hinc)
      linarith
    · intro decrease
      have hprod := mul_neg_of_pos_of_neg hpos (sub_neg.mpr decrease)
      linarith

theorem onset_at_threshold : sharpPush (99/100) = 0 ∧ sharpPush (101/100) = 1/100 := by
  norm_num [sharpPush]

theorem halved_playback_or_halved_flow (m v : ℚ) :
    (1/2 : ℚ)*v = 1*(v/2) ∧ m*(v/2)^2/2 = (m*v^2/2)/4 := by
  constructor <;> ring

/-- Two smooth spatially uniform flows can agree everywhere at the first
    snapshot. The first parcel keeps going straight; the second bends.
    This is a counterexample about snapshots, not a reconstructed basin trail. -/
theorem same_snapshot_different_parcel_paths :
    (∀ t : ℝ, HasDerivAt (fun s : ℝ => (s,(0:ℝ))) (1,0) t ∧
              HasDerivAt (fun s : ℝ => (s,s^2)) (1,2*t) t) ∧
    ((1,(0:ℝ)) : ℝ × ℝ) = (1,2*0) ∧
    ((0,(0:ℝ)) : ℝ × ℝ) = (0,0^2) ∧
    ((1,(0:ℝ)) : ℝ × ℝ) ≠ (1,1^2) := by
  constructor
  · intro t
    constructor
    · exact (hasDerivAt_id t).prodMk (hasDerivAt_const t (0:ℝ))
    · have square : HasDerivAt (fun s : ℝ => s^2) (2*t) t := by
        simpa using (hasDerivAt_pow 2 t)
      exact (hasDerivAt_id t).prodMk square
  · norm_num

theorem positive_gross_flow_at_zero_net (q : ℚ) (hq : 0 < q) :
    q-q = 0 ∧ 0 < q+q := by constructor <;> linarith

/-- Given the finite-time sharp-start bound K ≤ C ε² above the global threshold,
    it forces K below any proposed positive floor for a sufficiently small ε.
    The bound does not assert that the chosen run has a positive excitation. -/
theorem global_excess_allows_small_energy (C floor : ℚ) (hC : 0 < C) (hf : 0 < floor) :
    ∃ ε : ℚ, 0 < ε ∧ ∀ K : ℚ, K ≤ C*ε^2 → K < floor := by
  let ε := min 1 (floor/(2*C))
  have he : 0 < ε := lt_min (by norm_num) (div_pos hf (by linarith))
  have h1 : ε ≤ 1 := min_le_left _ _
  have h2 : ε ≤ floor/(2*C) := min_le_right _ _
  have hm := (le_div_iff₀ (by linarith : 0 < 2*C)).mp h2
  have hs : ε*ε ≤ ε := by simpa using mul_le_mul_of_nonneg_left h1 he.le
  have hb := mul_le_mul_of_nonneg_left hs hC.le
  refine ⟨ε, he, ?_⟩
  intro K hK
  nlinarith only [hK, hm, hb, hf]

/-- At the scalar write in the numerical experiment, the evolved tag is
    withdrawn and the saved tag restored. This statement concerns their integrals. -/
theorem scalar_refill_balance (total evolvedTag savedTag : ℚ) :
    (total - evolvedTag + savedTag) - total = savedTag - evolvedTag := by ring

/-- An observation shared by two different states has no inverse recovering
    every state. This applies to a clock, visible action, scalar energy or an
    addressee's account only when the two-state premise is established. -/
theorem same_readout_cannot_recover_both {S O : Type*} (readout : S → O)
    {s t : S} (different : s ≠ t) (same : readout s = readout t) :
    ¬∃ recover : O → S, ∀ x, recover (readout x) = x := by
  rintro ⟨recover, inverse⟩
  exact different ((inverse s).symm.trans ((congrArg recover same).trans (inverse t)))

theorem energy_alone_cannot_recover_heading :
    ¬∃ recover : ℚ → ℚ × ℚ, ∀ v, recover (energy2 v) = v := by
  apply same_readout_cannot_recover_both energy2 (s := (1,0)) (t := (-1,0))
  · norm_num
  · norm_num [energy2]

theorem restart_at_return {S D : Type*} (readDir : S → D) (advance : D → S → S)
    (n m : Nat) (s : S) :
    circuits readDir advance (n+m) s =
      circuits readDir advance m (circuits readDir advance n s) := by
  induction n generalizing s with
  | zero => simp [circuits]
  | succ n ih => rw [Nat.succ_add]; exact ih _

theorem recorded_B_endpoints :
    [pair1Quiet, pair1Anxious, pair2Quiet, pair2Anxious, pair3Quiet, pair3Anxious, pair4Quiet, pair4Anxious, pair5Quiet, pair5Anxious].map firstPager =
      [none, none, some 24278956, none, some 24378956, none, none, none, some 24078956, some 24078956] := by decide

theorem recorded_A_time_partition :
    (aTimesMs.map (fun p => p.2.1 - p.1)).sum = 6460 ∧
    (aTimesMs.map (fun p => p.2.2 - p.2.1)).sum = 1250 ∧
    (aTimesMs.map (fun p => p.2.2 - p.1)).sum = 7710 := by decide

theorem recorded_B_completion_counts :
    (quietReports.filterMap firstPager).length = 3 ∧
    (anxiousReports.filterMap firstPager).length = 1 := by decide

/-- Two hypothetical completions after every recorded probe reverse the ordering of the two group sums. With five per group they also reverse the mean ordering. -/
theorem missing_endpoints_allow_opposite_mean_orders :
    (quietReports ++ anxiousReports).all (fun r => r.all (fun p => p.1 < 40000000)) = true ∧
    filledSum 40000000 quietReports < filledSum 40000000 anxiousReports ∧
    filledSum 40000000 anxiousReports < filledSum 100000000 quietReports := by decide

theorem six_followups_remained_open : pagerAfterSecondReply = List.replicate 6 false := by decide

theorem first_mentor_controls : initialMentorArms = [false,false,false,true] ∧
    organicProfiles = List.replicate 4 true := by decide

theorem room_alert_and_false_notice_controls : fiveMinuteCues = [0,120,240] ∧
    finalAlertDeliveries = [[0,5],[0,5]] ∧ apparentTrembles = [0,120,240] ∧ physicalPulsesAtB = [] := by decide

theorem recorded_native_controls : (strictSuiteCases.all (·.2)) = true ∧
    (strictSuiteCases.filter (fun c => c.1 == "accepted")).length = 4 ∧
    (strictSuiteCases.filter (fun c => c.1 == "rejected")).length = 8 ∧
    (strictSuiteCases.filter (fun c => c.1 == "no_application")).length = 2 := by decide

/-- Signs of the four positive-clockwise contour readings in each half on the 384 grid. -/
theorem sampled_image_turns : (∀ x ∈ upperCirculations, 0 < x) ∧ (∀ x ∈ lowerCirculations, x < 0) := by
  constructor
  · intro x hx
    simp only [upperCirculations, List.mem_cons, List.not_mem_nil, or_false] at hx
    rcases hx with rfl | rfl | rfl | rfl <;> norm_num
  · intro x hx
    simp only [lowerCirculations, List.mem_cons, List.not_mem_nil, or_false] at hx
    rcases hx with rfl | rfl | rfl | rfl <;> norm_num

/-- Comparisons of recorded decimal readings, with an explicit flux tolerance. -/
theorem basin_startup_readings : let (a,b,c,d) := recordedStartupEnergy
    let (force,speed,into,outOf) := recordedMovingH
    a = 0 ∧ a < b ∧ b < c ∧ c < d ∧ force = 0 ∧ 0 < speed ∧
      0 < into ∧ 0 < outOf ∧ |into-outOf| < (1/10^16 : ℚ) := by
  norm_num [recordedStartupEnergy, recordedMovingH, abs_lt]

theorem eight_refills_use_their_own_endpoints : basinBranches.length = 14 ∧
    basinBranches.all (fun branch => branch.length == 8 && linkedCheckpoints branch) = true := by decide

end MeetingThread
