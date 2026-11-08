import V3ORuminationDefinitions

/-! Consequences of the unchanged full vector field. Association is not identified
with human rumination, and no theorem instantiates the open FullO specification. -/
namespace HugV3.Source.ORuminationVerified
noncomputable section
open ORumination Set
open scoped BigOperators
set_option maxRecDepth 4096

private theorem rhs_recovers (G : Geometry) (t : ℝ) (s d : State)
    (h : rhs G t s=some d) :
    ∃ records, readRecords s=some records ∧ d=rhsFromRecords G t s records := by
  classical
  unfold rhs at h
  obtain ⟨records,hr,hd⟩ := Option.bind_eq_some_iff.mp h
  split at hd
  · exact ⟨records,hr,(Option.some.inj hd).symm⟩
  · cases hd

theorem full_rhs_association_equation (G : Geometry) (t : ℝ) (s rate : State)
    (rs : List (Fin 4 × Record)) (hr : readRecords s=some rs)
    (hd : rhs G t s=some rate) (i j : Actor) (k : Fin 3) :
    rate.association i j k=(3/2:ℝ)*(associationDrive G s rs i j k-s.association i j k) := by
  obtain ⟨zs,hz,heq⟩ := rhs_recovers G t s rate hd
  have he : zs=rs := Option.some.inj (hz.symm.trans hr)
  subst zs
  rw [heq]
  change (1.5:ℝ)*(associationDrive G s rs i j k-s.association i j k)=_
  norm_num

theorem full_rhs_source_equation (G : Geometry) (t : ℝ) (s rate : State)
    (rs : List (Fin 4 × Record)) (hr : readRecords s=some rs)
    (hd : rhs G t s=some rate) :
    rate.A=(2/25:ℝ)*(pulse t+internalSourceDrive G s rs) := by
  obtain ⟨zs,hz,heq⟩ := rhs_recovers G t s rate hd
  have he : zs=rs := Option.some.inj (hz.symm.trans hr)
  subst zs
  rw [heq]
  change (0.08:ℝ)*(pulse t+internalSourceDrive G s rs)=_
  norm_num

theorem association_restarts_from_zero (G : Geometry) (t : ℝ) (s rate : State)
    (rs : List (Fin 4 × Record)) (hr : readRecords s=some rs)
    (hd : rhs G t s=some rate) (i j : Actor) (k : Fin 3)
    (ha : s.association i j k=0) (hdrive : 0<associationDrive G s rs i j k) :
    0<rate.association i j k := by
  rw [full_rhs_association_equation G t s rate rs hr hd i j k,ha,sub_zero]
  positivity

private theorem balanced_memory (G : Geometry) (s : State) (r : Record) :
    memory G s (balancedRecords r) r.recipient r.origin 0=
      recordWeight G s r/(0.12+(recordWeight G s r+recordWeight G s r)) ∧
    memory G s (balancedRecords r) r.recipient r.origin 1=
      recordWeight G s r/(0.12+(recordWeight G s r+recordWeight G s r)) := by
  have hp : recordWeight G s (positiveRecord r)=recordWeight G s r := rfl
  have hn : recordWeight G s (negativeRecord r)=recordWeight G s r := rfl
  constructor <;>
    norm_num [memory,exposure,balancedRecords,score,positiveRecord,negativeRecord,
      recordWeight,recordChange]

theorem balanced_channels_positive_equal (G : Geometry) (s : State) (r : Record)
    (ht : r.startTime<r.endTime) :
    0<memory G s (balancedRecords r) r.recipient r.origin 0 ∧
    memory G s (balancedRecords r) r.recipient r.origin 0=
      memory G s (balancedRecords r) r.recipient r.origin 1 := by
  have he := balanced_memory G s r
  have hw := (BridgeReturnVerified.record_relevance_positive_and_bounded G s r ht).1
  rw [he.1,he.2]
  exact ⟨div_pos hw (by positivity),rfl⟩

theorem balanced_channels_zero_association_drive (G : Geometry) (s : State)
    (r : Record) (k : Fin 3) (ht : r.startTime<r.endTime) :
    associationDrive G s (balancedRecords r) r.recipient r.origin k=0 := by
  unfold associationDrive
  rw [(balanced_channels_positive_equal G s r ht).2,sub_self,mul_zero,zero_mul]

private theorem constant_of_zero_derivative (f : ℝ → ℝ) (a b : ℝ)
    (hc : ContinuousOn f (Icc a b))
    (hd : ∀ x ∈ Icc a b, HasDerivWithinAt f 0 (Icc a b) x)
    (t : ℝ) (ht : t ∈ Icc a b) : f t=f a := by
  have hm := monotoneOn_of_hasDerivWithinAt_nonneg (convex_Icc a b) hc
    (fun x hx => (hd x (interior_subset hx)).mono interior_subset)
    (fun _ _ => le_refl (0:ℝ))
  have hmneg := monotoneOn_of_hasDerivWithinAt_nonneg (convex_Icc a b) hc.neg
    (fun x hx => ((hd x (interior_subset hx)).mono interior_subset).neg)
    (fun _ _ => by norm_num)
  have ha := left_mem_Icc.mpr (ht.1.trans ht.2)
  have h₁ := hm ha ht ht.1
  have h₂ := hmneg ha ht ht.1
  change -f a≤-f t at h₂
  exact le_antisymm (neg_le_neg_iff.mp h₂) h₁

private theorem relaxation_formula (f : ℝ → ℝ) (a b c : ℝ)
    (hc : ContinuousOn f (Icc a b))
    (hd : ∀ x ∈ Icc a b, HasDerivWithinAt f (-c*f x) (Icc a b) x)
    (t : ℝ) (ht : t ∈ Icc a b) : f t=f a*Real.exp (-c*(t-a)) := by
  let H : ℝ → ℝ := fun x => Real.exp (c*(x-a))*f x
  have hHc : ContinuousOn H (Icc a b) := by
    have he : Continuous (fun x : ℝ => Real.exp (c*(x-a))) :=
      Real.continuous_exp.comp (continuous_const.mul (continuous_id.sub continuous_const))
    exact he.continuousOn.mul hc
  have hHd : ∀ x ∈ Icc a b, HasDerivWithinAt H 0 (Icc a b) x := by
    intro x hx
    have he : HasDerivWithinAt (fun y : ℝ => Real.exp (c*(y-a)))
        (Real.exp (c*(x-a))*c) (Icc a b) x := by
      have hbase : HasDerivWithinAt (fun y : ℝ => c*(y-a)) c (Icc a b) x := by
        simpa using ((hasDerivWithinAt_id x (Icc a b)).sub_const a).const_mul c
      exact hbase.exp
    have hh : HasDerivWithinAt H
        (Real.exp (c*(x-a))*c*f x+Real.exp (c*(x-a))*(-c*f x)) (Icc a b) x :=
      he.mul (hd x hx)
    convert hh using 1 <;> ring
  have heq := constant_of_zero_derivative H a b hHc hHd t ht
  have heq' := congrArg (fun z : ℝ => Real.exp (-c*(t-a))*z) heq
  dsimp [H] at heq'
  have hcanc : Real.exp (-c*(t-a))*Real.exp (c*(t-a))=1 := by
    rw [← Real.exp_add]
    have hz : -c*(t-a)+c*(t-a)=0 := by ring
    rw [hz,Real.exp_zero]
  rw [← mul_assoc,hcanc,one_mul] at heq'
  calc
    f t=Real.exp (-c*(t-a))*f a := by
      simpa only [sub_self,mul_zero,Real.exp_zero,one_mul] using heq'
    _=f a*Real.exp (-c*(t-a)) := mul_comm _ _

theorem full_trace_association_relaxation (tr : Trace) (hsol : Solves tr)
    (q : ℕ) (hq : q<5) (i j : Actor) (k : Fin 3)
    (hoff : ∀ t ∈ Icc (time q) (time (q+1)), ∀ rs,
      readRecords (tr.path q t).state=some rs →
      associationDrive sourceGeometry (tr.path q t).state rs i j k=0) :
    ∀ t ∈ Icc (time q) (time (q+1)),
      (tr.path q t).state.association i j k=
      (tr.after q).state.association i j k*Real.exp (-(3/2:ℝ)*(t-time q)) := by
  have part := hsol.2 q hq
  have hc : ContinuousOn (fun t => (tr.path q t).state.association i j k)
      (Icc (time q) (time (q+1))) := by
    rcases part.2.1 with ⟨_,_,_,_,_,_,_,_,_,_,_,_,_,_,ha⟩
    exact ha i j k
  have hd : ∀ t ∈ Icc (time q) (time (q+1)),
      HasDerivWithinAt (fun x => (tr.path q x).state.association i j k)
        (-(3/2:ℝ)*(tr.path q t).state.association i j k)
        (Icc (time q) (time (q+1))) t := by
    intro t ht
    obtain ⟨rate,hr,hder⟩ := part.2.2.2.1 t ht
    obtain ⟨rs,hrs,_⟩ := rhs_recovers sourceGeometry t (tr.path q t).state rate hr
    rcases hder with ⟨_,_,_,_,_,_,_,_,_,_,_,_,_,_,ha⟩
    have he := full_rhs_association_equation sourceGeometry t (tr.path q t).state rate rs hrs hr i j k
    rw [hoff t ht rs hrs] at he
    have hrate : rate.association i j k=-(3/2:ℝ)*(tr.path q t).state.association i j k := by
      rw [he]; ring
    simpa only [hrate] using ha i j k
  intro t ht
  have he := relaxation_formula _ (time q) (time (q+1)) (3/2) hc hd t ht
  simpa only [part.1] using he

theorem finite_relaxation_retains_nonzero_association (tr : Trace) (hsol : Solves tr)
    (q : ℕ) (hq : q<5) (i j : Actor) (k : Fin 3)
    (hoff : ∀ t ∈ Icc (time q) (time (q+1)), ∀ rs,
      readRecords (tr.path q t).state=some rs →
      associationDrive sourceGeometry (tr.path q t).state rs i j k=0)
    (hn : (tr.after q).state.association i j k≠0) :
    ∀ t ∈ Icc (time q) (time (q+1)),
      (tr.path q t).state.association i j k≠0 := by
  intro t ht
  rw [full_trace_association_relaxation tr hsol q hq i j k hoff t ht]
  exact mul_ne_zero hn (Real.exp_ne_zero _)

theorem full_trace_relaxation_with_retained_records (tr : Trace) (hsol : Solves tr)
    (q : ℕ) (hq : q<5) (i j : Actor) (k : Fin 3)
    (hoff : ∀ t ∈ Icc (time q) (time (q+1)), ∀ rs,
      readRecords (tr.path q t).state=some rs →
      associationDrive sourceGeometry (tr.path q t).state rs i j k=0) :
    ∀ t ∈ Icc (time q) (time (q+1)),
      readRecords (tr.path q t).state=readRecords (tr.after q).state ∧
      (tr.path q t).state.association i j k=
      (tr.after q).state.association i j k*Real.exp (-(3/2:ℝ)*(t-time q)) := by
  intro t ht
  exact ⟨BridgeReturnVerified.full_trace_retains_records_between_writes tr hsol q hq t ht,
    full_trace_association_relaxation tr hsol q hq i j k hoff t ht⟩

theorem full_trace_zero_total_source_retains_accumulator (tr : Trace) (hsol : Solves tr)
    (q : ℕ) (hq : q<5)
    (hoff : ∀ t ∈ Icc (time q) (time (q+1)), ∀ rs,
      readRecords (tr.path q t).state=some rs →
      pulse t+internalSourceDrive sourceGeometry (tr.path q t).state rs=0) :
    ∀ t ∈ Icc (time q) (time (q+1)), (tr.path q t).state.A=(tr.after q).state.A := by
  have part := hsol.2 q hq
  have hc : ContinuousOn (fun t => (tr.path q t).state.A)
      (Icc (time q) (time (q+1))) := part.2.1.2.2.2.2.2.1
  have hd : ∀ t ∈ Icc (time q) (time (q+1)),
      HasDerivWithinAt (fun x => (tr.path q x).state.A) 0
        (Icc (time q) (time (q+1))) t := by
    intro t ht
    obtain ⟨rate,hr,hder⟩ := part.2.2.2.1 t ht
    obtain ⟨rs,hrs,_⟩ := rhs_recovers sourceGeometry t (tr.path q t).state rate hr
    have he := full_rhs_source_equation sourceGeometry t (tr.path q t).state rate rs hrs hr
    rw [hoff t ht rs hrs,mul_zero] at he
    have hh := hder.2.2.2.2.2.1
    simpa only [he] using hh
  intro t ht
  have he := constant_of_zero_derivative _ (time q) (time (q+1)) hc hd t ht
  simpa only [part.1] using he

theorem zero_association_does_not_freeze_student (G : Geometry) (t : ℝ) :
    associationDrive G (initial G) [] 1 0 0=0 ∧
    (initial G).association 1 0 0=0 ∧
    (rhsFromRecords G t (initial G) []).normCenter 1 0=-(49/400:ℝ) := by
  constructor
  · simp [associationDrive,memory,exposure]
  constructor
  · rfl
  · change (socialRates G t (initial G) []).normCenter 1 0=-(49/400:ℝ)
    dsimp only [socialRates,initial]
    norm_num [intent,Fin.sum_univ_succ]

theorem delayed_association_reads_buffered_value (G : Geometry) (t : ℝ)
    (present past rate : State) (rs : List (Fin 4 × Record))
    (hr : readRecords present=some rs)
    (hd : Delay.rhsDelayed G t present past=some rate) (i j : Actor) (k : Fin 3) :
    rate.association i j k=(3/2:ℝ)*
      (associationDrive G (Delay.socialFrom present past) rs i j k-past.association i j k) := by
  unfold Delay.rhsDelayed at hd
  obtain ⟨current,_,hd⟩ := Option.bind_eq_some_iff.mp hd
  obtain ⟨buffered,hb,hd⟩ := Option.bind_eq_some_iff.mp hd
  rw [← Option.some.inj hd]
  exact full_rhs_association_equation G t (Delay.socialFrom present past) buffered rs hr hb i j k

theorem delayed_rate_can_move_at_present_zero (G : Geometry) (t : ℝ)
    (present past rate : State) (rs : List (Fin 4 × Record))
    (hr : readRecords present=some rs)
    (hd : Delay.rhsDelayed G t present past=some rate) (i j : Actor) (k : Fin 3)
    (hnow : present.association i j k=0) (hpast : past.association i j k≠0)
    (hoff : associationDrive G (Delay.socialFrom present past) rs i j k=0) :
    rate.association i j k≠0 := by
  rw [delayed_association_reads_buffered_value G t present past rate rs hr hd i j k,hoff,zero_sub]
  exact mul_ne_zero (by norm_num) (neg_ne_zero.mpr hpast)

end
end HugV3.Source.ORuminationVerified
