import AppleTubeProofs
import AppleCarrierUniqueness

namespace HugV3.Source.AppleExistence
noncomputable section
open Set Metric
open scoped NNReal

private def Selected (C : ScheduleCertificate) (k : ℕ) (y : FullState) (x : ℝ → Coordinates) : Prop :=
  x (time k)=pack y.state ∧ PackedSegment k x ∧
  (∀ t ∈ Icc (time k) (time (k+1)), dist (x t) ((C.tube k).center t) ≤ (C.tube k).error t) ∧
  ∀ v : ℝ → Coordinates, v (time k)=pack y.state → PackedSegment k v →
    EqOn x v (Icc (time k) (time (k+1)))

private theorem selection_exists (C : ScheduleCertificate) (k : ℕ) (hk : k<5)
    (y : FullState) (hy : y∈C.entry k) : ∃ x, Selected C k y x :=
  tube_supplies_unique_full_segment (C.tube k) (C.bounds k hk) (pack y.state) (C.starts_close k hk y hy)

private def selectedPath (C : ScheduleCertificate) (k : ℕ) (y : FullState) : ℝ → Coordinates := by
  classical
  exact if h : k<5 ∧ y∈C.entry k then (selection_exists C k h.1 y h.2).choose else fun _ => pack y.state

private theorem selected_spec (C : ScheduleCertificate) {k : ℕ} (hk : k<5)
    {y : FullState} (hy : y∈C.entry k) : Selected C k y (selectedPath C k y) := by
  classical
  simp only [selectedPath,dite_eq_left (And.intro hk hy)]
  exact (selection_exists C k hk y hy).choose_spec

private def pathFrom (C : ScheduleCertificate) (k : ℕ) (y : FullState) (t : ℝ) : FullState :=
  ⟨unpack (selectedPath C k y t), y.starts⟩

private def after (C : ScheduleCertificate) : ℕ → FullState
  | 0 => initialFull
  | k+1 => let y := after C k
           (boundary (k+1) (pathFrom C k y (time (k+1)))).getD initialFull

private def traceFrom (C : ScheduleCertificate) : Trace :=
  ⟨after C,fun k => pathFrom C k (after C k)⟩

private theorem boundary_of_entry (C : ScheduleCertificate) {k : ℕ} (hk : k<5)
    (hy : after C k∈C.entry k) : after C (k+1)∈C.entry (k+1) ∧
    boundary (k+1) (pathFrom C k (after C k) (time (k+1))) = some (after C (k+1)) := by
  have right := right_mem_Icc.mpr (AppleBand.time_monotone (Nat.le_succ k))
  have estimate := (selected_spec C hk hy).2.2.1 (time (k+1)) right
  obtain ⟨w,hw,ok⟩ := C.reset k hk _ hy _ estimate
  change boundary (k+1) (pathFrom C k (after C k) (time (k+1)))=some w at ok
  have hw' : after C (k+1)=w := by simp only [after,ok,Option.getD_some]
  exact ⟨hw' ▸ hw,ok.trans (congrArg some hw'.symm)⟩

private theorem admissible (C : ScheduleCertificate) : ∀ k≤5, after C k∈C.entry k := by
  intro k
  induction k with
  | zero => exact fun _ => C.initial
  | succ k ih => exact fun hk => (boundary_of_entry C (by omega) (ih (by omega))).1

private theorem native_solves (C : ScheduleCertificate) : Solves (traceFrom C) := by
  refine ⟨rfl,?_⟩
  intro k hk
  let x := selectedPath C k (after C k)
  have selected := selected_spec C hk (admissible C k (by omega))
  have xn : PackedSegment k x := selected.2.1
  have xc : ContinuousOn x (Icc (time k) (time (k+1))) := by
    intro t ht
    obtain ⟨_,_,der⟩ := xn t ht
    exact der.continuousWithinAt
  refine ⟨?_,continuous_native_of_packed xc,fun _ _ => rfl,?_,(boundary_of_entry C hk (admissible C k (by omega))).2⟩
  · change (⟨unpack (x (time k)),(after C k).starts⟩ : FullState)=after C k
    have h0 : x (time k)=pack (after C k).state := selected.1
    rw [h0]
    rfl
  · intro t ht
    obtain ⟨d,ok,der⟩ := xn t ht
    refine ⟨d,ok,(packed_derivative_iff (fun t => unpack (x t)) d _ t).1 ?_⟩
    have equal : (fun t => pack (unpack (x t)))=x :=
      funext (fun t => (full_coordinate_round_trip d (x t)).2)
    rw [equal]
    exact der

private theorem rival_segment (other : Trace) (ho : Solves other) {k : ℕ} (hk : k<5) :
    PackedSegment k (fun t => pack (other.path k t).state) := by
  intro t ht
  obtain ⟨d,ok,hd⟩ := (ho.2 k hk).2.2.2.1 t ht
  exact ⟨d,ok,(packed_derivative_iff (fun s => (other.path k s).state) d _ t).2 hd⟩

private theorem unique_trace (C : ScheduleCertificate) (other : Trace) (ho : Solves other) :
    Agreement (traceFrom C) other := by
  let tr := traceFrom C
  have hs := native_solves C
  have piece (k : ℕ) (hk : k<5) (same : tr.after k=other.after k) :
      ∀ t∈Icc (time k) (time (k+1)), tr.path k t=other.path k t := by
    have start : pack (other.path k (time k)).state=pack (after C k).state := by
      rw [(ho.2 k hk).1,←same]
      rfl
    have eq := (selected_spec C hk (admissible C k (by omega))).2.2.2
      (fun t => pack (other.path k t).state) start (rival_segment other ho hk)
    intro t ht
    have stateEq := congrArg unpack (eq ht)
    change (tr.path k t).state=(other.path k t).state at stateEq
    have startEq : (tr.path k t).starts=(other.path k t).starts :=
      ((hs.2 k hk).2.2.1 t ht).trans ((congrArg FullState.starts same).trans ((ho.2 k hk).2.2.1 t ht).symm)
    exact FullState.mk.injEq _ _ _ _ |>.mpr ⟨stateEq,startEq⟩
  have post : ∀ k≤5, tr.after k=other.after k := by
    intro k
    induction k with
    | zero => exact fun _ => hs.1.trans ho.1.symm
    | succ k ih =>
      intro hle
      have hk : k<5 := by omega
      have seam := piece k hk (ih (by omega)) _ (right_mem_Icc.mpr (AppleBand.time_monotone (Nat.le_succ k)))
      apply Option.some.inj
      exact (hs.2 k hk).2.2.2.2.symm.trans ((congrArg (boundary (k+1)) seam).trans (ho.2 k hk).2.2.2.2)
  exact ⟨post,fun k hk => piece k hk (post k (by omega))⟩

theorem certificate_gives_full_apple (cert : ScheduleCertificate) (R : ℝ≥0) (hR : 1≤R) : FullApple R := by
  apply (full_apple_iff_source R hR).2
  exact ⟨traceFrom cert,native_solves cert,unique_trace cert⟩

end
end HugV3.Source.AppleExistence
