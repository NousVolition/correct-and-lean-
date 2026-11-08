import PersonEnvironmentDefinitions
/- Reference targets for Comparator only. The solution never imports this file. -/
namespace PersonEnvironment.Verified

theorem scan_sound {Answer : Type*} (check : Answer → Bool) (candidates : List Answer)
    (answer : Answer) (h : (scan check candidates).answer = some answer) :
    answer ∈ candidates ∧ check answer = true := by sorry

theorem scan_none_iff {Answer : Type*} (check : Answer → Bool) (candidates : List Answer) :
    (scan check candidates).answer = none ↔ ∀ a ∈ candidates, check a = false := by sorry

theorem scan_checks_le_length {Answer : Type*} (check : Answer → Bool) (candidates : List Answer) :
    (scan check candidates).checks ≤ candidates.length := by sorry

theorem failed_scan_checks_every_candidate {Answer : Type*}
    (check : Answer → Bool) (candidates : List Answer)
    (h : (scan check candidates).answer = none) :
    (scan check candidates).checks = candidates.length := by sorry

theorem certificate_membership (bound : ℕ) (answer : Certificate) :
    answer ∈ certificates bound ↔ answer.length ≤ bound := by sorry

theorem certificate_count (bound : ℕ) :
    (certificates bound).length+1 = 2^(bound+1) := by sorry

theorem memory_first_sound {Input : Type*} (check : Input → Certificate → Bool)
    (suggest : Input → List Certificate) (input : Input) (bound : ℕ) (answer : Certificate)
    (h : (memoryFirst check suggest input bound).answer = some answer) :
    answer.length ≤ bound ∧ check input answer = true := by sorry

theorem memory_first_none_iff {Input : Type*} (check : Input → Certificate → Bool)
    (suggest : Input → List Certificate) (input : Input) (bound : ℕ) :
    (memoryFirst check suggest input bound).answer = none ↔
      ∀ a, a.length ≤ bound → check input a = false := by sorry

theorem memory_first_finds_iff {Input : Type*} (check : Input → Certificate → Bool)
    (suggest : Input → List Certificate) (input : Input) (bound : ℕ) :
    (∃ answer, (memoryFirst check suggest input bound).answer = some answer) ↔
      BoundedWitness check input bound := by sorry

theorem different_experience_preserves_decision {Input : Type*}
    (check : Input → Certificate → Bool) (first second : Input → List Certificate)
    (input : Input) (bound : ℕ) :
    ((memoryFirst check first input bound).answer = none) ↔
      ((memoryFirst check second input bound).answer = none) := by sorry

theorem changed_person_same_check_preserves_decision {Input : Type*}
    (check : Input → Certificate → Bool) (suggest : Input → List Certificate)
    (first second : Input) (bound : ℕ)
    (same : ∀ a, a.length ≤ bound → check first a = check second a) :
    ((memoryFirst check suggest first bound).answer = none) ↔
      ((memoryFirst check suggest second bound).answer = none) := by sorry

theorem successful_memory_skips_fallback {Input : Type*}
    (check : Input → Certificate → Bool) (suggest : Input → List Certificate)
    (input : Input) (bound : ℕ) (answer : Certificate)
    (h : (scan (check input) (hintsWithin (suggest input) bound)).answer = some answer) :
    memoryFirst check suggest input bound = scan (check input) (hintsWithin (suggest input) bound) := by sorry

theorem failed_memory_adds_checks {Input : Type*}
    (check : Input → Certificate → Bool) (suggest : Input → List Certificate)
    (input : Input) (bound : ℕ)
    (h : (scan (check input) (hintsWithin (suggest input) bound)).answer = none) :
    (memoryFirst check suggest input bound).checks =
      (hintsWithin (suggest input) bound).length + (scan (check input) (certificates bound)).checks := by sorry

theorem rejecting_fallback_exact_count (bound : ℕ) :
    (scan (fun _ : Certificate => false) (certificates bound)).checks+1 = 2^(bound+1) := by sorry

theorem faithful_checker_gives_valid_answer {Input : Type*}
    (check : Input → Certificate → Bool) (valid : Input → Certificate → Prop)
    (faithful : Faithful check valid) (suggest : Input → List Certificate)
    (input : Input) (bound : ℕ) (answer : Certificate)
    (h : (memoryFirst check suggest input bound).answer = some answer) :
    valid input answer := by sorry

theorem full_hug_current_context_checked
    (check : HugInput → Certificate → Bool) (suggest : HugInput → List Certificate)
    (input : HugInput) (bound : ℕ) (answer : Certificate)
    (h : (memoryFirst check suggest input bound).answer = some answer) :
    answer.length ≤ bound ∧ check input answer = true := by sorry

theorem original_guard_is_unchanged (input : HugInput) (receiver : HugV3.Source.Actor) :
    originalGuard input receiver = HugV3.Source.margin input.fullState.state receiver input.person := by sorry

theorem original_retrieval_is_unchanged (G : HugV3.Source.Geometry) (input : HugInput)
    (records : List (Fin 4 × HugV3.Source.Record)) (origin : HugV3.Source.Actor) (channel : Fin 4) :
    originalRetrieval G input records origin channel =
      HugV3.Source.memory G input.fullState.state records input.person origin channel := by sorry

theorem memory_only_can_miss_answer :
    (scan (singleBitCheck true) [[false]]).answer = none ∧
      BoundedWitness singleBitCheck true 1 := by sorry

theorem different_memory_same_answer_different_checks :
    (memoryFirst (fun _ : Unit => singleBitCheck true) (fun _ => [[true]]) () 1) = ⟨some [true],1⟩ ∧
    (memoryFirst (fun _ : Unit => singleBitCheck true) (fun _ => [[false]]) () 1) = ⟨some [true],4⟩ := by sorry

theorem stale_answer_is_rechecked :
    singleBitCheck true [true] = true ∧ singleBitCheck false [true] = false ∧
    memoryFirst singleBitCheck (fun _ => [[true]]) false 1 = ⟨some [false],3⟩ := by sorry

end PersonEnvironment.Verified
