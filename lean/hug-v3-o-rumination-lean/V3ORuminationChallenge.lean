import V3ORuminationDefinitions

namespace HugV3.Source.ORuminationVerified
noncomputable section
open ORumination Set

theorem full_rhs_association_equation (G : Geometry) (t : ℝ) (s rate : State)
    (rs : List (Fin 4 × Record)) (hr : readRecords s=some rs)
    (hd : rhs G t s=some rate) (i j : Actor) (k : Fin 3) :
    rate.association i j k=(3/2:ℝ)*(associationDrive G s rs i j k-s.association i j k) := by sorry

theorem full_rhs_source_equation (G : Geometry) (t : ℝ) (s rate : State)
    (rs : List (Fin 4 × Record)) (hr : readRecords s=some rs)
    (hd : rhs G t s=some rate) :
    rate.A=(2/25:ℝ)*(pulse t+internalSourceDrive G s rs) := by sorry

theorem association_restarts_from_zero (G : Geometry) (t : ℝ) (s rate : State)
    (rs : List (Fin 4 × Record)) (hr : readRecords s=some rs)
    (hd : rhs G t s=some rate) (i j : Actor) (k : Fin 3)
    (ha : s.association i j k=0) (hdrive : 0<associationDrive G s rs i j k) :
    0<rate.association i j k := by sorry

theorem balanced_channels_positive_equal (G : Geometry) (s : State) (r : Record)
    (ht : r.startTime<r.endTime) :
    0<memory G s (balancedRecords r) r.recipient r.origin 0 ∧
    memory G s (balancedRecords r) r.recipient r.origin 0=
      memory G s (balancedRecords r) r.recipient r.origin 1 := by sorry

theorem balanced_channels_zero_association_drive (G : Geometry) (s : State)
    (r : Record) (k : Fin 3) (ht : r.startTime<r.endTime) :
    associationDrive G s (balancedRecords r) r.recipient r.origin k=0 := by sorry

theorem full_trace_association_relaxation (tr : Trace) (hsol : Solves tr)
    (q : ℕ) (hq : q<5) (i j : Actor) (k : Fin 3)
    (hoff : ∀ t ∈ Icc (time q) (time (q+1)), ∀ rs,
      readRecords (tr.path q t).state=some rs →
      associationDrive sourceGeometry (tr.path q t).state rs i j k=0) :
    ∀ t ∈ Icc (time q) (time (q+1)),
      (tr.path q t).state.association i j k=
      (tr.after q).state.association i j k*Real.exp (-(3/2:ℝ)*(t-time q)) := by sorry

theorem finite_relaxation_retains_nonzero_association (tr : Trace) (hsol : Solves tr)
    (q : ℕ) (hq : q<5) (i j : Actor) (k : Fin 3)
    (hoff : ∀ t ∈ Icc (time q) (time (q+1)), ∀ rs,
      readRecords (tr.path q t).state=some rs →
      associationDrive sourceGeometry (tr.path q t).state rs i j k=0)
    (hn : (tr.after q).state.association i j k≠0) :
    ∀ t ∈ Icc (time q) (time (q+1)),
      (tr.path q t).state.association i j k≠0 := by sorry

theorem full_trace_relaxation_with_retained_records (tr : Trace) (hsol : Solves tr)
    (q : ℕ) (hq : q<5) (i j : Actor) (k : Fin 3)
    (hoff : ∀ t ∈ Icc (time q) (time (q+1)), ∀ rs,
      readRecords (tr.path q t).state=some rs →
      associationDrive sourceGeometry (tr.path q t).state rs i j k=0) :
    ∀ t ∈ Icc (time q) (time (q+1)),
      readRecords (tr.path q t).state=readRecords (tr.after q).state ∧
      (tr.path q t).state.association i j k=
      (tr.after q).state.association i j k*Real.exp (-(3/2:ℝ)*(t-time q)) := by sorry

theorem full_trace_zero_total_source_retains_accumulator (tr : Trace) (hsol : Solves tr)
    (q : ℕ) (hq : q<5)
    (hoff : ∀ t ∈ Icc (time q) (time (q+1)), ∀ rs,
      readRecords (tr.path q t).state=some rs →
      pulse t+internalSourceDrive sourceGeometry (tr.path q t).state rs=0) :
    ∀ t ∈ Icc (time q) (time (q+1)), (tr.path q t).state.A=(tr.after q).state.A := by sorry

theorem zero_association_does_not_freeze_student (G : Geometry) (t : ℝ) :
    associationDrive G (initial G) [] 1 0 0=0 ∧
    (initial G).association 1 0 0=0 ∧
    (rhsFromRecords G t (initial G) []).normCenter 1 0=-(49/400:ℝ) := by sorry

theorem delayed_association_reads_buffered_value (G : Geometry) (t : ℝ)
    (present past rate : State) (rs : List (Fin 4 × Record))
    (hr : readRecords present=some rs)
    (hd : Delay.rhsDelayed G t present past=some rate) (i j : Actor) (k : Fin 3) :
    rate.association i j k=(3/2:ℝ)*
      (associationDrive G (Delay.socialFrom present past) rs i j k-past.association i j k) := by sorry

theorem delayed_rate_can_move_at_present_zero (G : Geometry) (t : ℝ)
    (present past rate : State) (rs : List (Fin 4 × Record))
    (hr : readRecords present=some rs)
    (hd : Delay.rhsDelayed G t present past=some rate) (i j : Actor) (k : Fin 3)
    (hnow : present.association i j k=0) (hpast : past.association i j k≠0)
    (hoff : associationDrive G (Delay.socialFrom present past) rs i j k=0) :
    rate.association i j k≠0 := by sorry

end
end HugV3.Source.ORuminationVerified
