import V3TransferDefinitions

namespace HugV3.Source.TransferVerified
noncomputable section
open Transfer Set
open scoped BigOperators

theorem memory_stays_with_original_pair (G : Geometry) (s : State)
    (rs : List (Fin 4 × Record)) (slot : Fin 4) (r : Record) (i j : Actor)
    (hne : r.origin≠j) (k : Fin 4) :
    memory G s ((slot,r)::rs) i j k = memory G s rs i j k := by
  simp [memory,exposure,hne]

private theorem weight_pos (G : Geometry) (s : State) (r : Record)
    (htime : r.startTime<r.endTime) : 0<recordWeight G s r := by
  unfold recordWeight
  exact mul_pos (sub_pos.mpr htime) (Real.exp_pos _)

theorem positive_record_has_positive_evidence (G : Geometry) (s : State)
    (slot : Fin 4) (r : Record) (y : ℝ) (hy : 0<y)
    (hscore : score r=some y) (htime : r.startTime<r.endTime) :
    0<memory G s [(slot,r)] r.recipient r.origin 0 := by
  have hw := weight_pos G s r htime
  have hh : 0<(0.12:ℝ)+recordWeight G s r := by linarith
  simpa [memory,exposure,hscore,max_eq_left hy.le] using div_pos (mul_pos hw hy) hh

private theorem sigmoid_lt {x y : ℝ} (h : x<y) : sigmoid x<sigmoid y := by
  unfold sigmoid
  apply one_div_lt_one_div_of_lt
  · positivity
  · linarith [Real.exp_lt_exp.mpr (neg_lt_neg h)]

private theorem cooperation_formula (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (i j : Actor) :
    (rhsFromRecords G t s rs).responses i j 1 =
      4*(sigmoid (cooperationBase s i j+memory G s rs i j 0-memory G s rs i j 1)*
        attention s i j-s.responses i j 1) := by
  change 4*(sigmoid (-0.9+1.7*s.relation i j 2+
      Real.exp (-(∑ k, (s.expression j k-s.expression i k)^2)/0.6)+
      memory G s rs i j 0-memory G s rs i j 1+
      0.6*s.responses i j 6-0.5*s.responses i j 2)*attention s i j-s.responses i j 1)=_
  have harg : -0.9+1.7*s.relation i j 2+
      Real.exp (-(∑ k, (s.expression j k-s.expression i k)^2)/0.6)+
      memory G s rs i j 0-memory G s rs i j 1+
      0.6*s.responses i j 6-0.5*s.responses i j 2=
      cooperationBase s i j+memory G s rs i j 0-memory G s rs i j 1 := by
    unfold cooperationBase
    ring
  rw [harg]

theorem positive_record_increases_cooperation_rate (G : Geometry) (t : ℝ) (s : State)
    (slot : Fin 4) (r : Record) (y : ℝ) (hy : 0<y)
    (hscore : score r=some y) (htime : r.startTime<r.endTime)
    (ha : 0<attention s r.recipient r.origin) :
    (rhsFromRecords G t s []).responses r.recipient r.origin 1 <
      (rhsFromRecords G t s [(slot,r)]).responses r.recipient r.origin 1 := by
  have hp := positive_record_has_positive_evidence G s slot r y hy hscore htime
  have hn : memory G s [(slot,r)] r.recipient r.origin 1=0 := by
    simp [memory,exposure,hscore,max_eq_right (by linarith : -y≤0)]
  have hz : ∀ k, memory G s [] r.recipient r.origin k=0 := by
    intro k
    simp [memory,exposure]
  rw [cooperation_formula,cooperation_formula,hz 0,hz 1,hn]
  simp only [add_zero,sub_zero]
  have hsig := sigmoid_lt (show cooperationBase s r.recipient r.origin <
    cooperationBase s r.recipient r.origin+memory G s [(slot,r)] r.recipient r.origin 0 by linarith)
  nlinarith [mul_lt_mul_of_pos_right hsig ha]

private theorem norm_projection (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) : (rhsFromRecords G t s rs).normCenter=normRate s := by rfl

private theorem expression_projection (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) : (rhsFromRecords G t s rs).expression=expressionRate s := by rfl

theorem cooperation_changes_shared_norm_rate (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (student first : Actor) (δ : ℝ) (k : Fin 2) :
    (rhsFromRecords G t (bumpCooperation s student first δ) rs).normCenter student k-
      (rhsFromRecords G t s rs).normCenter student k =
      δ*(s.expression first k-s.normCenter student k)/5 := by
  classical
  rw [norm_projection,norm_projection]
  have hterm : ∀ j : Actor,
      ((bumpCooperation s student first δ).responses student j 1+
        (bumpCooperation s student first δ).responses student j 6-
        (bumpCooperation s student first δ).responses student j 4)*
        (s.expression j k-s.normCenter student k)=
      (s.responses student j 1+s.responses student j 6-s.responses student j 4)*
        (s.expression j k-s.normCenter student k)+
        if j=first then δ*(s.expression first k-s.normCenter student k) else 0 := by
    intro j
    by_cases hj : j=first
    · subst j
      simp [bumpCooperation]
      ring
    · simp [bumpCooperation,hj]
  unfold normRate
  simp only [bumpCooperation] at hterm ⊢
  simp_rw [hterm]
  rw [Finset.sum_add_distrib]
  simp
  ring

theorem other_person_expression_rate_unchanged (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (student first second : Actor) (δ : ℝ)
    (hne : second≠student) :
    (rhsFromRecords G t (bumpCooperation s student first δ) rs).expression second =
      (rhsFromRecords G t s rs).expression second := by
  rw [expression_projection,expression_projection]
  funext k
  simp [expressionRate,bumpCooperation,hne]

theorem radius_rate_unchanged_at_comparison (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (student first : Actor) (δ : ℝ) :
    (rhsFromRecords G t (bumpCooperation s student first δ) rs).logRadius =
      (rhsFromRecords G t s rs).logRadius := by
  funext i j
  change 1.8*(Real.log (0.55+0.45*sigmoid
      (1.4*s.relation i j 2+memory G s rs i j 0-memory G s rs i j 1+
      (bumpCooperation s student first δ).responses i j 6-
      (bumpCooperation s student first δ).responses i j 4-0.3*observations G s i 0))-s.logRadius i j)=_
  simp only [bumpCooperation,show (6:Fin 7)≠1 by decide,show (4:Fin 7)≠1 by decide,
    and_false,ite_false,add_zero]
  rfl

theorem squared_guard_has_same_positive_side (s : State) (i j : Actor) :
    0<guardSquared s i j ↔ 0<margin s i j := by
  have hsq : 0≤∑ k, (s.expression j k-s.normCenter i k)^2 :=
    Finset.sum_nonneg fun k _ => sq_nonneg _
  have hsqrt := Real.sq_sqrt hsq
  have hr := Real.exp_pos (s.logRadius i j)
  have hn := Real.sqrt_nonneg (∑ k, (s.expression j k-s.normCenter i k)^2)
  have heq : guardSquared s i j=
      (Real.exp (s.logRadius i j)+Real.sqrt (∑ k, (s.expression j k-s.normCenter i k)^2))*margin s i j := by
    unfold guardSquared margin
    nlinarith
  rw [heq]
  exact mul_pos_iff_of_pos_left (by positivity)

theorem squared_guard_derivative_on_full_state (s : ℝ → State) (d : State)
    (I : Set ℝ) (t : ℝ) (hd : StateHasDerivWithinAt s d I t) (i j : Actor) :
    HasDerivWithinAt (fun τ => guardSquared (s τ) i j)
      (guardSquaredRate (s t) d i j) I t := by
  rcases hd with ⟨_,_,_,_,_,_,_,_,he,_,hn,hl,_,_,_⟩
  have hexp := ((hl i j).exp).pow 2
  have hsum := HasDerivWithinAt.sum (u := Finset.univ)
    (fun k _ => ((he j k).sub (hn i k)).pow 2)
  convert! hexp.sub hsum using 1 <;>
    simp [guardSquared,guardSquaredRate,Finset.mul_sum,pow_two,mul_assoc] <;> ring

theorem transfer_to_distinct_partner_guard_rate (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (student first second : Actor) (δ : ℝ)
    (hsecond : second≠student) (hpartners : first≠second) :
    guardSquaredRate (bumpCooperation s student first δ)
        (rhsFromRecords G t (bumpCooperation s student first δ) rs) student second-
      guardSquaredRate s (rhsFromRecords G t s rs) student second =
      (2*δ/5)*alignment s student first second := by
  have hn : ∀ k, (rhsFromRecords G t (bumpCooperation s student first δ) rs).normCenter student k=
      (rhsFromRecords G t s rs).normCenter student k+
      δ*(s.expression first k-s.normCenter student k)/5 := by
    intro k
    linarith [cooperation_changes_shared_norm_rate G t s rs student first δ k]
  have he := other_person_expression_rate_unchanged G t s rs student first second δ hsecond
  have hl := radius_rate_unchanged_at_comparison G t s rs student first δ
  unfold guardSquaredRate alignment
  simp only [bumpCooperation] at hn he hl ⊢
  rw [hl,he]
  simp_rw [hn]
  simp only [Fin.sum_univ_succ]
  ring

set_option maxRecDepth 4096 in
private theorem recover_rhs (G : Geometry) (t : ℝ) (s d : State) (h : rhs G t s=some d) :
    ∃ rs, readRecords s=some rs ∧ d=rhsFromRecords G t s rs := by
  unfold rhs at h
  obtain ⟨rs,hr,hd⟩ := Option.bind_eq_some_iff.mp h
  split at hd
  · exact ⟨rs,hr,(Option.some.inj hd).symm⟩
  · cases hd

theorem domain_checked_transfer (G : Geometry) (t : ℝ) (s d e : State)
    (student first second : Actor) (δ : ℝ) (hsecond : second≠student)
    (hpartners : first≠second) (hd : rhs G t s=some d)
    (he : rhs G t (bumpCooperation s student first δ)=some e) :
    guardSquaredRate (bumpCooperation s student first δ) e student second-
      guardSquaredRate s d student second =
      (2*δ/5)*alignment s student first second := by
  obtain ⟨rs,hr,hd⟩ := recover_rhs G t s d hd
  obtain ⟨rs',hr',he⟩ := recover_rhs G t (bumpCooperation s student first δ) e he
  have hread : readRecords (bumpCooperation s student first δ)=readRecords s := rfl
  rw [hread,hr] at hr'
  have hrs := Option.some.inj hr'
  subst rs'
  rw [hd,he]
  exact transfer_to_distinct_partner_guard_rate G t s rs student first second δ hsecond hpartners

theorem positive_alignment_opens_guard_instantaneously (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (student first second : Actor) (δ : ℝ)
    (hsecond : second≠student) (hpartners : first≠second)
    (hδ : 0<δ) (ha : 0<alignment s student first second) :
    guardSquaredRate s (rhsFromRecords G t s rs) student second <
      guardSquaredRate (bumpCooperation s student first δ)
        (rhsFromRecords G t (bumpCooperation s student first δ) rs) student second := by
  have h := transfer_to_distinct_partner_guard_rate G t s rs student first second δ hsecond hpartners
  have hp : 0<(2*δ/5)*alignment s student first second := by positivity
  linarith

theorem orthogonal_alignment_has_zero_instantaneous_transfer (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (student first second : Actor) (δ : ℝ)
    (hsecond : second≠student) (hpartners : first≠second)
    (ha : alignment s student first second=0) :
    guardSquaredRate (bumpCooperation s student first δ)
        (rhsFromRecords G t (bumpCooperation s student first δ) rs) student second =
      guardSquaredRate s (rhsFromRecords G t s rs) student second := by
  have h := transfer_to_distinct_partner_guard_rate G t s rs student first second δ hsecond hpartners
  rw [ha,mul_zero] at h
  linarith

theorem initial_coordinate_example :
    guardSquaredRate (bumpCooperation (initial sourceGeometry) 1 0 (1/10))
        (rhsFromRecords sourceGeometry 0 (bumpCooperation (initial sourceGeometry) 1 0 (1/10)) []) 1 2-
      guardSquaredRate (initial sourceGeometry) (rhsFromRecords sourceGeometry 0 (initial sourceGeometry) []) 1 2
      = (76341/4000000:ℝ) := by
  rw [transfer_to_distinct_partner_guard_rate sourceGeometry 0 (initial sourceGeometry) [] 1 0 2 (1/10) (by decide) (by decide)]
  norm_num [alignment,initial,intent,Fin.sum_univ_succ,Matrix.cons_val_succ,
    Matrix.cons_val_two,Matrix.vecHead,Matrix.vecTail]

theorem full_trace_guard_observable (tr : Trace) (hsol : Solves tr) (k : ℕ) (hk : k<5)
    (t : ℝ) (ht : t∈Icc (time k) (time (k+1))) (i j : Actor) :
    ∃ d, rhs sourceGeometry t (tr.path k t).state=some d ∧
      HasDerivWithinAt (fun τ => guardSquared (tr.path k τ).state i j)
        (guardSquaredRate (tr.path k t).state d i j) (Icc (time k) (time (k+1))) t := by
  obtain ⟨d,hr,hd⟩ := (hsol.2 k hk).2.2.2.1 t ht
  exact ⟨d,hr,squared_guard_derivative_on_full_state (fun τ => (tr.path k τ).state)
    d (Icc (time k) (time (k+1))) t hd i j⟩

end
end HugV3.Source.TransferVerified
