import PersonEnvironmentDefinitions
/- Proofs of the frozen auxiliary claims; no original equation is changed. -/
namespace PersonEnvironment.Verified

theorem scan_sound {Answer : Type*} (check : Answer → Bool) (candidates : List Answer)
    (answer : Answer) (h : (scan check candidates).answer = some answer) :
    answer ∈ candidates ∧ check answer = true := by
  induction candidates with
  | nil => simp [scan] at h
  | cons a rest ih =>
    cases hc : check a with
    | false =>
      have ht : (scan check rest).answer = some answer := by simpa [scan, hc] using h
      obtain ⟨hm, hv⟩ := ih ht
      exact ⟨List.mem_cons_of_mem a hm, hv⟩
    | true =>
      have he : a = answer := by simpa [scan, hc] using h
      subst answer
      exact ⟨by simp, hc⟩

theorem scan_none_iff {Answer : Type*} (check : Answer → Bool) (candidates : List Answer) :
    (scan check candidates).answer = none ↔ ∀ a ∈ candidates, check a = false := by
  induction candidates with
  | nil => simp [scan]
  | cons a rest ih =>
    cases hc : check a <;> simp [scan, hc, ih]

theorem scan_checks_le_length {Answer : Type*} (check : Answer → Bool) (candidates : List Answer) :
    (scan check candidates).checks ≤ candidates.length := by
  induction candidates with
  | nil => simp [scan]
  | cons a rest ih =>
    cases hc : check a <;> simp [scan, hc] <;> omega

theorem failed_scan_checks_every_candidate {Answer : Type*}
    (check : Answer → Bool) (candidates : List Answer)
    (h : (scan check candidates).answer = none) :
    (scan check candidates).checks = candidates.length := by
  induction candidates with
  | nil => simp [scan]
  | cons a rest ih =>
    cases hc : check a with
    | false =>
      have ht : (scan check rest).answer = none := by simpa [scan, hc] using h
      simpa [scan, hc] using ih ht
    | true => simp [scan, hc] at h

theorem certificate_membership (bound : ℕ) (answer : Certificate) :
    answer ∈ certificates bound ↔ answer.length ≤ bound := by
  induction bound generalizing answer with
  | zero => cases answer <;> simp [certificates]
  | succ n ih =>
    cases answer with
    | nil => simp [certificates]
    | cons bit tail =>
      cases bit <;> simp [certificates, ih]

theorem certificate_count (bound : ℕ) :
    (certificates bound).length+1 = 2^(bound+1) := by
  induction bound with
  | zero => norm_num [certificates]
  | succ n ih =>
    simp only [certificates, List.length_append, List.length_map,
      List.length_cons, List.length_nil]
    rw [pow_succ]
    omega

theorem memory_first_sound {Input : Type*} (check : Input → Certificate → Bool)
    (suggest : Input → List Certificate) (input : Input) (bound : ℕ) (answer : Certificate)
    (h : (memoryFirst check suggest input bound).answer = some answer) :
    answer.length ≤ bound ∧ check input answer = true := by
  cases hf : (scan (check input) (hintsWithin (suggest input) bound)).answer with
  | none =>
    have hn : (scan (check input) (certificates bound)).answer = some answer := by
      simpa [memoryFirst, hf] using h
    obtain ⟨hm, hv⟩ := scan_sound (check input) (certificates bound) answer hn
    exact ⟨(certificate_membership bound answer).mp hm, hv⟩
  | some a =>
    have he : a = answer := by simpa [memoryFirst, hf] using h
    subst answer
    obtain ⟨hm, hv⟩ := scan_sound (check input) (hintsWithin (suggest input) bound) a hf
    have hl : a.length ≤ bound := by simpa [hintsWithin] using (List.mem_filter.mp hm).2
    exact ⟨hl, hv⟩

theorem memory_first_none_iff {Input : Type*} (check : Input → Certificate → Bool)
    (suggest : Input → List Certificate) (input : Input) (bound : ℕ) :
    (memoryFirst check suggest input bound).answer = none ↔
      ∀ a, a.length ≤ bound → check input a = false := by
  constructor
  · intro h a ha
    cases hf : (scan (check input) (hintsWithin (suggest input) bound)).answer with
    | none =>
      have hn : (scan (check input) (certificates bound)).answer = none := by
        simpa [memoryFirst, hf] using h
      exact (scan_none_iff _ _).mp hn a ((certificate_membership bound a).mpr ha)
    | some b => simp [memoryFirst, hf] at h
  · intro hall
    have hf : (scan (check input) (hintsWithin (suggest input) bound)).answer = none := by
      apply (scan_none_iff _ _).mpr
      intro a ha
      apply hall
      simpa [hintsWithin] using (List.mem_filter.mp ha).2
    have hn : (scan (check input) (certificates bound)).answer = none := by
      apply (scan_none_iff _ _).mpr
      intro a ha
      exact hall a ((certificate_membership bound a).mp ha)
    simp [memoryFirst, hf, hn]

theorem memory_first_finds_iff {Input : Type*} (check : Input → Certificate → Bool)
    (suggest : Input → List Certificate) (input : Input) (bound : ℕ) :
    (∃ answer, (memoryFirst check suggest input bound).answer = some answer) ↔
      BoundedWitness check input bound := by
  constructor
  · rintro ⟨answer, h⟩
    exact ⟨answer, memory_first_sound check suggest input bound answer h⟩
  · rintro ⟨answer, hl, hv⟩
    cases h : (memoryFirst check suggest input bound).answer with
    | none =>
      have hf := (memory_first_none_iff check suggest input bound).mp h answer hl
      simp [hv] at hf
    | some a => exact ⟨a, rfl⟩

theorem different_experience_preserves_decision {Input : Type*}
    (check : Input → Certificate → Bool) (first second : Input → List Certificate)
    (input : Input) (bound : ℕ) :
    ((memoryFirst check first input bound).answer = none) ↔
      ((memoryFirst check second input bound).answer = none) := by
  rw [memory_first_none_iff, memory_first_none_iff]

theorem changed_person_same_check_preserves_decision {Input : Type*}
    (check : Input → Certificate → Bool) (suggest : Input → List Certificate)
    (first second : Input) (bound : ℕ)
    (same : ∀ a, a.length ≤ bound → check first a = check second a) :
    ((memoryFirst check suggest first bound).answer = none) ↔
      ((memoryFirst check suggest second bound).answer = none) := by
  rw [memory_first_none_iff, memory_first_none_iff]
  constructor
  · intro h a ha
    rw [← same a ha]
    exact h a ha
  · intro h a ha
    rw [same a ha]
    exact h a ha

theorem successful_memory_skips_fallback {Input : Type*}
    (check : Input → Certificate → Bool) (suggest : Input → List Certificate)
    (input : Input) (bound : ℕ) (answer : Certificate)
    (h : (scan (check input) (hintsWithin (suggest input) bound)).answer = some answer) :
    memoryFirst check suggest input bound = scan (check input) (hintsWithin (suggest input) bound) := by
  simp [memoryFirst, h]

theorem failed_memory_adds_checks {Input : Type*}
    (check : Input → Certificate → Bool) (suggest : Input → List Certificate)
    (input : Input) (bound : ℕ)
    (h : (scan (check input) (hintsWithin (suggest input) bound)).answer = none) :
    (memoryFirst check suggest input bound).checks =
      (hintsWithin (suggest input) bound).length + (scan (check input) (certificates bound)).checks := by
  simp only [memoryFirst, h]
  rw [failed_scan_checks_every_candidate (check input) (hintsWithin (suggest input) bound) h]

theorem rejecting_fallback_exact_count (bound : ℕ) :
    (scan (fun _ : Certificate => false) (certificates bound)).checks+1 = 2^(bound+1) := by
  have h : (scan (fun _ : Certificate => false) (certificates bound)).answer = none :=
    (scan_none_iff _ _).mpr (by simp)
  rw [failed_scan_checks_every_candidate _ _ h]
  exact certificate_count bound

theorem faithful_checker_gives_valid_answer {Input : Type*}
    (check : Input → Certificate → Bool) (valid : Input → Certificate → Prop)
    (faithful : Faithful check valid) (suggest : Input → List Certificate)
    (input : Input) (bound : ℕ) (answer : Certificate)
    (h : (memoryFirst check suggest input bound).answer = some answer) :
    valid input answer := by
  exact (faithful input answer).mp (memory_first_sound check suggest input bound answer h).2

theorem full_hug_current_context_checked
    (check : HugInput → Certificate → Bool) (suggest : HugInput → List Certificate)
    (input : HugInput) (bound : ℕ) (answer : Certificate)
    (h : (memoryFirst check suggest input bound).answer = some answer) :
    answer.length ≤ bound ∧ check input answer = true := by
  exact memory_first_sound check suggest input bound answer h

theorem original_guard_is_unchanged (input : HugInput) (receiver : HugV3.Source.Actor) :
    originalGuard input receiver = HugV3.Source.margin input.fullState.state receiver input.person := by
  rfl

theorem original_retrieval_is_unchanged (G : HugV3.Source.Geometry) (input : HugInput)
    (records : List (Fin 4 × HugV3.Source.Record)) (origin : HugV3.Source.Actor) (channel : Fin 4) :
    originalRetrieval G input records origin channel =
      HugV3.Source.memory G input.fullState.state records input.person origin channel := by
  rfl

theorem memory_only_can_miss_answer :
    (scan (singleBitCheck true) [[false]]).answer = none ∧
      BoundedWitness singleBitCheck true 1 := by
  constructor
  · decide
  · exact ⟨[true], by decide, by decide⟩

theorem different_memory_same_answer_different_checks :
    (memoryFirst (fun _ : Unit => singleBitCheck true) (fun _ => [[true]]) () 1) = ⟨some [true],1⟩ ∧
    (memoryFirst (fun _ : Unit => singleBitCheck true) (fun _ => [[false]]) () 1) = ⟨some [true],4⟩ := by
  decide

theorem stale_answer_is_rechecked :
    singleBitCheck true [true] = true ∧ singleBitCheck false [true] = false ∧
    memoryFirst singleBitCheck (fun _ => [[true]]) false 1 = ⟨some [false],3⟩ := by
  decide

end PersonEnvironment.Verified
