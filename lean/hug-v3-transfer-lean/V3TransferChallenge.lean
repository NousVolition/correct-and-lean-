import V3TransferDefinitions

/- Reference-only statements frozen before solution creation. -/
namespace HugV3.Source.TransferVerified
noncomputable section
open Transfer Set
open scoped BigOperators

theorem memory_stays_with_original_pair (G : Geometry) (s : State)
    (rs : List (Fin 4 × Record)) (slot : Fin 4) (r : Record) (i j : Actor)
    (hne : r.origin≠j) (k : Fin 4) :
    memory G s ((slot,r)::rs) i j k = memory G s rs i j k := by sorry

theorem positive_record_has_positive_evidence (G : Geometry) (s : State)
    (slot : Fin 4) (r : Record) (y : ℝ) (hy : 0<y)
    (hscore : score r=some y) (htime : r.startTime<r.endTime) :
    0<memory G s [(slot,r)] r.recipient r.origin 0 := by sorry

theorem positive_record_increases_cooperation_rate (G : Geometry) (t : ℝ) (s : State)
    (slot : Fin 4) (r : Record) (y : ℝ) (hy : 0<y)
    (hscore : score r=some y) (htime : r.startTime<r.endTime)
    (ha : 0<attention s r.recipient r.origin) :
    (rhsFromRecords G t s []).responses r.recipient r.origin 1 <
      (rhsFromRecords G t s [(slot,r)]).responses r.recipient r.origin 1 := by sorry

theorem cooperation_changes_shared_norm_rate (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (student first : Actor) (δ : ℝ) (k : Fin 2) :
    (rhsFromRecords G t (bumpCooperation s student first δ) rs).normCenter student k-
      (rhsFromRecords G t s rs).normCenter student k =
      δ*(s.expression first k-s.normCenter student k)/5 := by sorry

theorem other_person_expression_rate_unchanged (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (student first second : Actor) (δ : ℝ)
    (hne : second≠student) :
    (rhsFromRecords G t (bumpCooperation s student first δ) rs).expression second =
      (rhsFromRecords G t s rs).expression second := by sorry

theorem radius_rate_unchanged_at_comparison (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (student first : Actor) (δ : ℝ) :
    (rhsFromRecords G t (bumpCooperation s student first δ) rs).logRadius =
      (rhsFromRecords G t s rs).logRadius := by sorry

theorem squared_guard_has_same_positive_side (s : State) (i j : Actor) :
    0<guardSquared s i j ↔ 0<margin s i j := by sorry

theorem squared_guard_derivative_on_full_state (s : ℝ → State) (d : State)
    (I : Set ℝ) (t : ℝ) (hd : StateHasDerivWithinAt s d I t) (i j : Actor) :
    HasDerivWithinAt (fun τ => guardSquared (s τ) i j)
      (guardSquaredRate (s t) d i j) I t := by sorry

theorem transfer_to_distinct_partner_guard_rate (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (student first second : Actor) (δ : ℝ)
    (hsecond : second≠student) (hpartners : first≠second) :
    guardSquaredRate (bumpCooperation s student first δ)
        (rhsFromRecords G t (bumpCooperation s student first δ) rs) student second-
      guardSquaredRate s (rhsFromRecords G t s rs) student second =
      (2*δ/5)*alignment s student first second := by sorry

theorem domain_checked_transfer (G : Geometry) (t : ℝ) (s d e : State)
    (student first second : Actor) (δ : ℝ) (hsecond : second≠student)
    (hpartners : first≠second) (hd : rhs G t s=some d)
    (he : rhs G t (bumpCooperation s student first δ)=some e) :
    guardSquaredRate (bumpCooperation s student first δ) e student second-
      guardSquaredRate s d student second =
      (2*δ/5)*alignment s student first second := by sorry

theorem positive_alignment_opens_guard_instantaneously (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (student first second : Actor) (δ : ℝ)
    (hsecond : second≠student) (hpartners : first≠second)
    (hδ : 0<δ) (ha : 0<alignment s student first second) :
    guardSquaredRate s (rhsFromRecords G t s rs) student second <
      guardSquaredRate (bumpCooperation s student first δ)
        (rhsFromRecords G t (bumpCooperation s student first δ) rs) student second := by sorry

theorem orthogonal_alignment_has_zero_instantaneous_transfer (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (student first second : Actor) (δ : ℝ)
    (hsecond : second≠student) (hpartners : first≠second)
    (ha : alignment s student first second=0) :
    guardSquaredRate (bumpCooperation s student first δ)
        (rhsFromRecords G t (bumpCooperation s student first δ) rs) student second =
      guardSquaredRate s (rhsFromRecords G t s rs) student second := by sorry

theorem initial_coordinate_example :
    guardSquaredRate (bumpCooperation (initial sourceGeometry) 1 0 (1/10))
        (rhsFromRecords sourceGeometry 0 (bumpCooperation (initial sourceGeometry) 1 0 (1/10)) []) 1 2-
      guardSquaredRate (initial sourceGeometry) (rhsFromRecords sourceGeometry 0 (initial sourceGeometry) []) 1 2
      = (76341/4000000:ℝ) := by sorry

theorem full_trace_guard_observable (tr : Trace) (hsol : Solves tr) (k : ℕ) (hk : k<5)
    (t : ℝ) (ht : t∈Icc (time k) (time (k+1))) (i j : Actor) :
    ∃ d, rhs sourceGeometry t (tr.path k t).state=some d ∧
      HasDerivWithinAt (fun τ => guardSquared (tr.path k τ).state i j)
        (guardSquaredRate (tr.path k t).state d i j) (Icc (time k) (time (k+1))) t := by sorry

end
end HugV3.Source.TransferVerified
