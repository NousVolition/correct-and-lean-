import V3ClayDefinitions
import V3SourceProofs

/- These results concern the unchanged full-state transcription. They do not
assert that a full solution exists or that the required deformation bound holds. -/
namespace HugV3.Source.ClayVerified
noncomputable section
open Set
open scoped BigOperators

theorem probe_recovers_cell (s : State) (l : Cell) :
    probeEstimate s l = s.b l := by
  unfold probeEstimate
  ring

private theorem positive_buffer_inward (F : Particle → Mat) (l : Cell) :
    0 < fabricRate (fabricStrain F l) (3/500) := by
  have h := Verified.fabric_strain_lower_bound F l
  unfold fabricRate fabricGradient
  linarith

private theorem negative_buffer_inward (F : Particle → Mat) (l : Cell)
    (hF : (∑ i, (F (point l) i (axis l))^2) ≤ (2:ℝ)) :
    fabricRate (fabricStrain F l) (-3/500) < 0 := by
  unfold fabricRate fabricGradient fabricStrain
  linarith

theorem positive_well_preserved (s : ℝ → State) (a b : ℝ) (l : Cell)
    (hc : ContinuousOn (fun t => (s t).b l) (Icc a b))
    (hd : ∀ t ∈ Ico a b, HasDerivWithinAt (fun τ => (s τ).b l)
      (fabricRate (fabricStrain (s t).F l) ((s t).b l)) (Ici t) t)
    (ha : (3/500:ℝ) ≤ (s a).b l) :
    ∀ t ∈ Icc a b, (3/500:ℝ) ≤ (s t).b l := by
  have bound := image_le_of_deriv_right_lt_deriv_boundary hc.neg
    (fun t ht => (hd t ht).neg) (B := fun _ => -(3/500:ℝ))
    (by linarith : -(s a).b l ≤ -(3/500:ℝ))
    (fun t => hasDerivAt_const t (-(3/500:ℝ)))
    (by
      intro t ht heq
      change -(s t).b l = -(3/500:ℝ) at heq
      have hb : (s t).b l = 3/500 := by linarith
      rw [hb]
      linarith [positive_buffer_inward (s t).F l])
  intro t ht
  have := bound ht
  change -(s t).b l ≤ -(3/500:ℝ) at this
  linarith

theorem negative_well_preserved (s : ℝ → State) (a b : ℝ) (l : Cell)
    (hc : ContinuousOn (fun t => (s t).b l) (Icc a b))
    (hd : ∀ t ∈ Ico a b, HasDerivWithinAt (fun τ => (s τ).b l)
      (fabricRate (fabricStrain (s t).F l) ((s t).b l)) (Ici t) t)
    (hF : ∀ t ∈ Ico a b, (∑ i, ((s t).F (point l) i (axis l))^2) ≤ (2:ℝ))
    (ha : (s a).b l ≤ -(3/500:ℝ)) :
    ∀ t ∈ Icc a b, (s t).b l ≤ -(3/500:ℝ) := by
  have bound := image_le_of_deriv_right_lt_deriv_boundary hc hd
    (B := fun _ => -(3/500:ℝ)) ha
    (fun t => hasDerivAt_const t (-(3/500:ℝ)))
    (by
      intro t ht heq
      rw [heq]
      simpa only [neg_div] using negative_buffer_inward (s t).F l (hF t ht))
  exact fun t ht => bound ht

theorem clay_buffer_preserved_on_segment (s : ℝ → State) (a b : ℝ)
    (hc : ∀ l, ContinuousOn (fun t => (s t).b l) (Icc a b))
    (hd : ∀ l, ∀ t ∈ Ico a b, HasDerivWithinAt (fun τ => (s τ).b l)
      (fabricRate (fabricStrain (s t).F l) ((s t).b l)) (Ici t) t)
    (hF : ∀ l, ∀ t ∈ Ico a b,
      (∑ i, ((s t).F (point l) i (axis l))^2) ≤ (2:ℝ))
    (ha : ClayBuffer (s a)) :
    ∀ t ∈ Icc a b, ClayBuffer (s t) := by
  intro t ht l
  rcases le_abs.mp (ha l) with hpos | hneg
  · exact le_trans (positive_well_preserved s a b l (hc l) (hd l) hpos t ht)
      (le_abs_self _)
  · have h := negative_well_preserved s a b l (hc l) (hd l) (hF l)
      (by linarith) t ht
    have hh := neg_le_abs ((s t).b l)
    linarith

theorem clay_buffer_implies_read_margin (s : State) (h : ClayBuffer s) :
    ∀ l, (1/200:ℝ) < |probeEstimate s l| := by
  intro l
  rw [probe_recovers_cell]
  linarith [h l]

theorem initial_clay_buffer (G : Geometry) : ClayBuffer (initial G) := by
  intro l
  norm_num [initial]

private theorem target_preserves_buffer (s : State) (slot : Fin 4) (bytes : List ℕ)
    (hs : ClayBuffer s) :
    ∀ l, (3/500:ℝ) ≤ |targetFabric s slot bytes l| := by
  intro l
  by_cases h : l.val/37264=slot.val
  · rw [(Verified.written_cell_restores_margin s slot bytes l h).1]
    norm_num
  · simpa [targetFabric,h] using hs l

set_option maxRecDepth 4096 in
theorem write_event_preserves_clay_buffer (G : Geometry) (s w : State) (r : Record)
    (hs : ClayBuffer s) (hw : writeEvent G s r = some w) :
    ClayBuffer w := by
  classical
  unfold writeEvent at hw
  obtain ⟨records,_,hw⟩ := Option.bind_eq_some_iff.mp hw
  split at hw
  · cases hw
  · obtain ⟨slot,_,hw⟩ := Option.bind_eq_some_iff.mp hw
    obtain ⟨bytes,_,hw⟩ := Option.bind_eq_some_iff.mp hw
    dsimp only at hw
    split at hw
    · cases hw
    · have heq := Option.some.inj hw
      rw [← heq]
      exact target_preserves_buffer s slot bytes hs

theorem complete_event_preserves_clay_buffer (id : Fin 3) (s w : FullState)
    (hs : ClayBuffer s.state) (hw : completeEvent id s = some w) :
    ClayBuffer w.state := by
  unfold completeEvent at hw
  obtain ⟨startF,_,hw⟩ := Option.bind_eq_some_iff.mp hw
  obtain ⟨record,_,hw⟩ := Option.bind_eq_some_iff.mp hw
  obtain ⟨state,hwrite,hw⟩ := Option.bind_eq_some_iff.mp hw
  have heq := Option.some.inj hw
  rw [← heq]
  exact write_event_preserves_clay_buffer sourceGeometry s.state state record hs hwrite

theorem boundary_preserves_clay_buffer (k : ℕ) (s w : FullState)
    (hs : ClayBuffer s.state) (hw : boundary k s = some w) :
    ClayBuffer w.state := by
  match k with
  | 0 =>
    have heq := Option.some.inj hw
    rw [← heq]
    exact hs
  | 1 =>
    have heq := Option.some.inj hw
    rw [← heq]
    exact hs
  | 2 => exact complete_event_preserves_clay_buffer 0 s w hs hw
  | 3 =>
    change (completeEvent 1 s).map (capture 2) = some w at hw
    obtain ⟨v,hv,heq⟩ := Option.map_eq_some_iff.mp hw
    rw [← heq]
    exact complete_event_preserves_clay_buffer 1 s v hs hv
  | 4 => exact complete_event_preserves_clay_buffer 2 s w hs hw
  | n+5 =>
    have heq := Option.some.inj hw
    rw [← heq]
    exact hs

private theorem successful_read_margin (s : State) (records : List (Fin 4 × Record))
    (hr : readRecords s = some records) : ∀ l, (1/200:ℝ) ≤ |s.b l| := by
  classical
  have hg : ∀ l, (1/200:ℝ) ≤ |probeEstimate s l| := by
    unfold readRecords at hr
    split at hr
    · cases hr
    · rename_i h
      exact Classical.not_not.mp h
  simpa only [probe_recovers_cell] using hg

private theorem sign_fixed (f : ℝ → ℝ) (a b t : ℝ)
    (hc : ContinuousOn f (Icc a b)) (hn : ∀ x ∈ Icc a b, f x ≠ 0)
    (ht : t ∈ Icc a b) : (0 < f t ↔ 0 < f a) := by
  have hab : a ≤ b := ht.1.trans ht.2
  have hsub : Icc a t ⊆ Icc a b := Icc_subset_Icc le_rfl ht.2
  constructor
  · intro hp
    by_contra h
    have hz : (0:ℝ) ∈ Icc (f a) (f t) := ⟨le_of_not_gt h,hp.le⟩
    obtain ⟨x,hx,heq⟩ := intermediate_value_Icc ht.1 (hc.mono hsub) hz
    exact hn x (hsub hx) heq
  · intro hp
    by_contra h
    have hz : (0:ℝ) ∈ Icc (f t) (f a) := ⟨le_of_not_gt h,hp.le⟩
    obtain ⟨x,hx,heq⟩ := intermediate_value_Icc' ht.1 (hc.mono hsub) hz
    exact hn x (hsub hx) heq

theorem decoded_records_fixed_on_segment (s : ℝ → State) (a b : ℝ)
    (hc : ∀ l, ContinuousOn (fun t => (s t).b l) (Icc a b))
    (hr : ∀ t ∈ Icc a b, ∃ records, readRecords (s t) = some records) :
    ∀ t ∈ Icc a b, readRecords (s t) = readRecords (s a) := by
  classical
  intro t ht
  have hab : a ≤ b := ht.1.trans ht.2
  have ha : a ∈ Icc a b := left_mem_Icc.mpr hab
  have hm : ∀ x ∈ Icc a b, ∀ l, (1/200:ℝ) ≤ |(s x).b l| := by
    intro x hx
    obtain ⟨rs,hrs⟩ := hr x hx
    exact successful_read_margin (s x) rs hrs
  have hsign : ∀ l, (0 < probeEstimate (s t) l ↔ 0 < probeEstimate (s a) l) := by
    intro l
    simp only [probe_recovers_cell]
    apply sign_fixed (fun x => (s x).b l) a b t (hc l) _ ht
    intro x hx hz
    have h := hm x hx l
    rw [hz,abs_zero] at h
    norm_num at h
  have hbytes : slotBytes (s t) = slotBytes (s a) := by
    funext slot
    unfold slotBytes
    congr 1
    funext byte
    apply Finset.sum_congr rfl
    intro bit _
    simp only [hsign]
  have hgt : ∀ l, (1/200:ℝ) ≤ |probeEstimate (s t) l| := by
    simpa only [probe_recovers_cell] using hm t ht
  have hga : ∀ l, (1/200:ℝ) ≤ |probeEstimate (s a) l| := by
    simpa only [probe_recovers_cell] using hm a ha
  simp only [readRecords,hgt,hga,hbytes]

/-- The decoder's result is fixed by a continuous memory path with read margin.
Unlike `decoded_records_fixed_on_segment`, this does not assume a successful
read at every time. It also preserves failure if the starting bytes are invalid. -/
theorem decoded_records_fixed_of_read_margin (s : ℝ → State) (a b : ℝ)
    (hc : ∀ l, ContinuousOn (fun t => (s t).b l) (Icc a b))
    (hm : ∀ t ∈ Icc a b, ∀ l, (1/200:ℝ) ≤ |(s t).b l|) :
    ∀ t ∈ Icc a b, readRecords (s t) = readRecords (s a) := by
  classical
  intro t ht
  have ha : a ∈ Icc a b := left_mem_Icc.mpr (ht.1.trans ht.2)
  have hsign : ∀ l, (0 < probeEstimate (s t) l ↔ 0 < probeEstimate (s a) l) := by
    intro l
    simp only [probe_recovers_cell]
    apply sign_fixed (fun x => (s x).b l) a b t (hc l) _ ht
    intro x hx hz
    have h := hm x hx l
    rw [hz, abs_zero] at h
    norm_num at h
  have hbytes : slotBytes (s t) = slotBytes (s a) := by
    funext slot
    unfold slotBytes
    congr 1
    funext byte
    apply Finset.sum_congr rfl
    intro bit _
    simp only [hsign]
  have hgt : ∀ l, (1/200:ℝ) ≤ |probeEstimate (s t) l| := by
    simpa only [probe_recovers_cell] using hm t ht
  have hga : ∀ l, (1/200:ℝ) ≤ |probeEstimate (s a) l| := by
    simpa only [probe_recovers_cell] using hm a ha
  simp only [readRecords, hgt, hga, hbytes]

/-- One successful starting read, together with the buffer, suffices for every
later read on the interval. The bytes, checksum and decoded fields stay fixed. -/
theorem decoded_records_preserved_of_clay_buffer (s : ℝ → State) (a b : ℝ)
    (records : List (Fin 4 × Record))
    (hc : ∀ l, ContinuousOn (fun t => (s t).b l) (Icc a b))
    (hb : ∀ t ∈ Icc a b, ClayBuffer (s t))
    (hr : readRecords (s a) = some records) :
    ∀ t ∈ Icc a b, readRecords (s t) = some records := by
  have hm : ∀ t ∈ Icc a b, ∀ l, (1/200:ℝ) ≤ |(s t).b l| := by
    intro t ht l
    have h := hb t ht l
    linarith
  intro t ht
  exact (decoded_records_fixed_of_read_margin s a b hc hm t ht).trans hr

/-- Use the unchanged fabric equation and the existing deformation hypothesis
to prove decoding succeeds throughout the interval, from a single initial read. -/
theorem decoded_records_preserved_on_segment (s : ℝ → State) (a b : ℝ)
    (records : List (Fin 4 × Record))
    (hc : ∀ l, ContinuousOn (fun t => (s t).b l) (Icc a b))
    (hd : ∀ l, ∀ t ∈ Ico a b, HasDerivWithinAt (fun τ => (s τ).b l)
      (fabricRate (fabricStrain (s t).F l) ((s t).b l)) (Ici t) t)
    (hF : ∀ l, ∀ t ∈ Ico a b,
      (∑ i, ((s t).F (point l) i (axis l))^2) ≤ (2:ℝ))
    (ha : ClayBuffer (s a))
    (hr : readRecords (s a) = some records) :
    ∀ t ∈ Icc a b, readRecords (s t) = some records := by
  exact decoded_records_preserved_of_clay_buffer s a b records hc
    (clay_buffer_preserved_on_segment s a b hc hd hF ha) hr

/-- The exact initial state decodes successfully to four empty slots and hence
an empty record list. This is a kernel proof of the concrete decoder. -/
theorem initial_read_records (G : Geometry) :
    readRecords (initial G) = some [] := by
  classical
  have hm : ∀ l, (1/200:ℝ) ≤ |probeEstimate (initial G) l| := by
    intro l
    rw [probe_recovers_cell]
    norm_num [initial]
  have hbytes : ∀ slot, slotBytes (initial G) slot = List.replicate 4658 0 := by
    intro slot
    have hp : ∀ l, ¬ (0 < probeEstimate (initial G) l) := by
      intro l
      rw [probe_recovers_cell]
      norm_num [initial]
    simp only [slotBytes, hp, ite_false, Finset.sum_const_zero, List.ofFn_const]
  have hu : ∀ slot, unpack (slotBytes (initial G) slot) = some none := by
    intro slot
    rw [hbytes]
    have hz : (List.replicate 4658 (0:ℕ)).all (· == 0) = true := by
      rw [List.all_replicate]
      rfl
    rw [unpack, hz]
    rfl
  simp only [readRecords, hm, hu]
  norm_num [List.ofFn_succ]

/-- The first interval has no assumed decoder-success premise. Its concrete
initial read is proved above; the differential and deformation premises remain. -/
theorem initial_segment_read_records (G : Geometry) (s : ℝ → State) (a b : ℝ)
    (hc : ∀ l, ContinuousOn (fun t => (s t).b l) (Icc a b))
    (hd : ∀ l, ∀ t ∈ Ico a b, HasDerivWithinAt (fun τ => (s τ).b l)
      (fabricRate (fabricStrain (s t).F l) ((s t).b l)) (Ici t) t)
    (hF : ∀ l, ∀ t ∈ Ico a b,
      (∑ i, ((s t).F (point l) i (axis l))^2) ≤ (2:ℝ))
    (hinit : s a = initial G) :
    ∀ t ∈ Icc a b, readRecords (s t) = some [] := by
  apply decoded_records_preserved_on_segment s a b [] hc hd hF
  · rw [hinit]
    exact initial_clay_buffer G
  · rw [hinit]
    exact initial_read_records G

end
end HugV3.Source.ClayVerified
