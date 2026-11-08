import ApplePackedProofs
import AppleTraceVelocity

namespace HugV3.Source.AppleExistence
noncomputable section
open Set Metric
open scoped NNReal Topology
set_option maxHeartbeats 850000
set_option maxRecDepth 4000
attribute [local irreducible] fullRate

private theorem subtract_bounds {a x r : ℝ} (hl : a-r≤x) (hr : x≤a+r) :
    -r≤x-a ∧ x-a≤r := by constructor <;> linarith

private theorem bounds_of_subtract {a x r : ℝ} (h : -r≤x-a ∧ x-a≤r) :
    a-r≤x ∧ x≤a+r := by constructor <;> linarith [h.1,h.2]

private theorem clip_real_fixes {c r x : ℝ} (h : -r ≤ x-c ∧ x-c ≤ r) :
    max (min x (c+r)) (c-r)=x := by
  obtain ⟨lo,hi⟩ := bounds_of_subtract h
  rw [min_eq_left hi,max_eq_left lo]

private theorem clip_scalar_cont (x r : ℝ) : Continuous (fun c : ℝ => max (min x (c+r)) (c-r)) := by
  fun_prop

private theorem distance_along {E : Type*} [PseudoMetricSpace E]
    {I : Set ℝ} {f g : ℝ → E} (hf : ContinuousOn f I) (hg : ContinuousOn g I) :
    ContinuousOn (fun t => dist (f t) (g t)) I :=
  (@continuous_dist E _).comp_continuousOn (hf.prodMk hg)

/-- Extension used solely for Picard iteration outside the moving region.
It is the identity at every point used by a certified source solution. -/
private def clip (c : Coordinates) (r : ℝ≥0) (x : Coordinates) : Coordinates :=
  fun i => max (min (x i) (c i+r)) (c i-r)

private theorem clip_inside (c : Coordinates) (r : ℝ≥0) (x : Coordinates) :
    clip c r x ∈ closedBall c (r:ℝ) := by
  apply (dist_pi_le_iff r.2).2
  intro i
  rw [Real.dist_eq,abs_le]
  have lo : c i-r ≤ clip c r x i := le_max_right _ _
  have hi : clip c r x i ≤ c i+r :=
    max_le (min_le_right _ _) (by linarith [r.2])
  exact subtract_bounds lo hi

private theorem clip_fixes (c : Coordinates) (r : ℝ≥0) (x : Coordinates) (h : x∈closedBall c (r:ℝ)) :
    clip c r x=x := by
  funext i
  have hi := (dist_pi_le_iff r.2).1 h i
  rw [Real.dist_eq,abs_le] at hi
  exact clip_real_fixes (c:=c i) (r:=(r:ℝ)) (x:=x i) hi

private theorem clip_lipschitz (c : Coordinates) (r : ℝ≥0) : LipschitzWith 1 (clip c r) := by
  apply LipschitzWith.of_dist_le_mul
  intro x y
  rw [NNReal.coe_one,one_mul]
  apply (dist_pi_le_iff dist_nonneg).2
  intro i
  have h : LipschitzWith 1 (fun s : ℝ => max (min s (c i+r)) (c i-r)) :=
    (LipschitzWith.id.min_const _).max_const _
  exact (by simpa only [clip,NNReal.coe_one,one_mul] using h.dist_le_mul (x i) (y i) : dist (clip c r x i) (clip c r y i) ≤ dist (x i) (y i)) |>.trans
    ((dist_pi_le_iff dist_nonneg).1 le_rfl i)

private def extended {k : ℕ} (B : Tube k) (t : ℝ) (v : Coordinates) : Coordinates :=
  fullRate t (clip (B.center t) B.width v)

private theorem extension_lip {k : ℕ} (B : Tube k) (hB : Bounds B) (t : ℝ)
    (ht : t∈Icc (time k) (time (k+1))) : LipschitzWith B.lip (extended B t) := by
  apply LipschitzWith.of_dist_le_mul
  intro x y
  apply ((hB.spatial t ht).dist_le_mul _ (clip_inside _ _ x) _ (clip_inside _ _ y)).trans
  apply mul_le_mul_of_nonneg_left _ B.lip.2
  simpa using (clip_lipschitz (B.center t) B.width).dist_le_mul x y

private theorem clip_path_cont {I : Set ℝ} {c : ℝ → Coordinates} (hc : ContinuousOn c I)
    (r : ℝ≥0) (x : Coordinates) : ContinuousOn (fun t => clip (c t) r x) I := by
  apply continuousOn_pi.2
  intro i
  have proj : Continuous (fun v : Coordinates => v i) := continuous_apply i
  have hci : ContinuousOn (fun t => c t i) I := proj.comp_continuousOn hc
  change ContinuousOn ((fun z : ℝ => max (min (x i) (z+(r:ℝ))) (z-(r:ℝ))) ∘ (fun t => c t i)) I
  exact (clip_scalar_cont (x i) (r:ℝ)).comp_continuousOn hci

private theorem extension_cont {k : ℕ} (B : Tube k) (hB : Bounds B) (x : Coordinates) :
    ContinuousOn (fun t => extended B t x) (Icc (time k) (time (k+1))) := by
  have hc : ContinuousOn B.center (Icc (time k) (time (k+1))) := HasDerivWithinAt.continuousOn hB.center_deriv
  have hclip := clip_path_cont hc B.width x
  have pairs : ContinuousOn (fun t : ℝ => (t,clip (B.center t) B.width x)) (Icc (time k) (time (k+1))) :=
    continuousOn_id.prodMk hclip
  have into : MapsTo (fun t : ℝ => (t,clip (B.center t) B.width x)) (Icc (time k) (time (k+1))) B.region :=
    fun t ht => ⟨ht,clip_inside _ _ _⟩
  unfold extended
  exact ContinuousOn.comp' (g:=fun q : ℝ × Coordinates => fullRate q.1 q.2)
    (f:=fun t : ℝ => (t,clip (B.center t) B.width x)) hB.regular pairs into

private theorem right_deriv {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {f : ℝ → E} {d : E} {a b t : ℝ} (ht : t∈Ico a b)
    (h : HasDerivWithinAt f d (Icc a b) t) : HasDerivWithinAt f d (Ici t) t :=
  h.mono_of_mem_nhdsWithin (Icc_mem_nhdsGE_of_mem ht)

/-- At a first exit, one-sided uniqueness still compares the endpoint. This covers
competitors that have no a priori certificate membership. -/
private theorem first_exit {a b r : ℝ} {f : ℝ → ℝ} (hc : ContinuousOn f (Icc a b))
    {u : ℝ} (hu : u∈Icc a b) (exits : r≤f u) :
    ∃ t∈Icc a b, r≤f t ∧ ∀ v∈Ico a t, f v<r := by
  let I := Icc a b
  let bad : Set I := {v | r≤f v}
  have closed : IsClosed bad := isClosed_le continuous_const (continuousOn_iff_continuous_domRestrict.mp hc)
  have nonempty : bad.Nonempty := ⟨⟨u,hu⟩,exits⟩
  obtain ⟨m,hm,hmin⟩ := closed.isCompact.exists_isMinOn nonempty
    (continuous_subtype_val.continuousOn : ContinuousOn (fun v : I => (v:ℝ)) bad)
  refine ⟨m,m.2,hm,?_⟩
  intro v hv
  by_contra! h
  let z : I := ⟨v,hv.1,hv.2.le.trans m.2.2⟩
  exact (not_le_of_gt hv.2) (hmin (show z∈bad from h))

theorem tube_supplies_unique_full_segment {k : ℕ} (B : Tube k) (hB : Bounds B) (z : Coordinates)
    (hz : dist z (B.center (time k)) ≤ B.entryError) :
    ∃ x : ℝ → Coordinates, x (time k)=z ∧ PackedSegment k x ∧
      (∀ t ∈ Icc (time k) (time (k+1)), dist (x t) (B.center t) ≤ B.error t) ∧
      ∀ y : ℝ → Coordinates, y (time k)=z → PackedSegment k y →
        EqOn x y (Icc (time k) (time (k+1))) := by
  let a := time k
  let b := time (k+1)
  have hab : a≤b := AppleBand.time_monotone (Nat.le_succ k)
  let duration : ℝ≥0 := ⟨b-a,sub_nonneg.mpr hab⟩
  let left : Icc a b := ⟨a,left_mem_Icc.mpr hab⟩
  have pic : IsPicardLindelof (extended B) left z (B.speed*duration) 0 B.speed B.lip := by
    constructor
    · intro t ht
      exact (extension_lip B hB t ht).lipschitzOnWith
    · intro x _
      exact extension_cont B hB x
    · intro t ht x _
      exact hB.bounded (_,_) ⟨ht,clip_inside _ _ _⟩
    · change (B.speed:ℝ)*max (b-a) (a-a) ≤ (B.speed:ℝ)*(b-a)-0
      simp [max_eq_left (sub_nonneg.mpr hab)]
  obtain ⟨x,hx,hd⟩ := pic.exists_eq_forall_mem_Icc_hasDerivWithinAt₀
  change x a = z at hx
  have xc : ContinuousOn x (Icc a b) := HasDerivWithinAt.continuousOn hd
  have cc : ContinuousOn B.center (Icc a b) := HasDerivWithinAt.continuousOn hB.center_deriv
  have estimate : ∀ t∈Icc a b, dist (x t) (B.center t) ≤ B.error t := by
    have h := dist_le_of_approx_trajectories_ODE_of_mem
      (s:=fun _ => (univ : Set Coordinates)) (εf:=0) (εg:=(B.defect:ℝ))
      (fun t (ht : t∈Ico a b) => (extension_lip B hB t (Ico_subset_Icc_self ht)).lipschitzOnWith)
      xc (fun t ht => right_deriv ht (hd t (Ico_subset_Icc_self ht)))
      (fun _ _ => (dist_self _).le) (fun _ _ => mem_univ _)
      cc (fun t ht => right_deriv ht (hB.center_deriv t (Ico_subset_Icc_self ht))) ?_
      (fun _ _ => mem_univ _) (by simpa only [hx] using hz)
    · simpa only [zero_add,Tube.error] using h
    · intro t ht
      simpa only [extended,clip_fixes _ _ _ (mem_closedBall_self B.width.2)] using hB.residual t ht
  have inside (t : ℝ) (ht : t∈Icc a b) : dist (x t) (B.center t) < B.width :=
    (estimate t ht).trans_lt (hB.interior t ht)
  have native : PackedSegment k x := by
    intro t ht
    obtain ⟨d,hd0⟩ := hB.defined (t,x t) ⟨ht,(inside t ht).le⟩
    refine ⟨d,hd0,?_⟩
    simpa only [extended,clip_fixes _ _ _ (inside t ht).le,rate_of_success hd0] using hd t ht
  refine ⟨x,hx,native,estimate,?_⟩
  intro y hy hys
  have yc : ContinuousOn y (Icc a b) := by
    intro t ht
    obtain ⟨_,_,h⟩ := hys t ht
    exact h.continuousWithinAt
  have compare (v : ℝ) (hv : v∈Icc a b)
      (covered : ∀ t∈Ico a v, dist (y t) (B.center t) ≤ B.width) : EqOn x y (Icc a v) := by
    have sub : Icc a v ⊆ Icc a b := Icc_subset_Icc_right hv.2
    apply ODE_solution_unique_of_mem_Icc_right (v:=extended B) (s:=fun _ => (univ : Set Coordinates))
      (fun t ht => (extension_lip B hB t (sub (Ico_subset_Icc_self ht))).lipschitzOnWith)
      (xc.mono sub) _ (fun _ _ => mem_univ _) (yc.mono sub) _ (fun _ _ => mem_univ _) (hx.trans hy.symm)
    · intro t ht
      exact right_deriv ht ((hd t (sub (Ico_subset_Icc_self ht))).mono sub)
    · intro t ht
      obtain ⟨d,ok,der⟩ := hys t (sub (Ico_subset_Icc_self ht))
      rw [extended,clip_fixes _ _ _ (covered t ht),rate_of_success ok]
      exact right_deriv ht (der.mono sub)
  have all_inside (u : ℝ) (hu : u∈Icc a b) : dist (y u) (B.center u)<B.width := by
    by_contra! bad
    have hdist : ContinuousOn (fun v => dist (y v) (B.center v)) (Icc a b) :=
      distance_along yc cc
    obtain ⟨t,ht,exit,earlier⟩ := first_exit hdist hu bad
    have same := compare t ht (fun s hs => (earlier s hs).le) (right_mem_Icc.mpr ht.1)
    rw [←same] at exit
    exact (not_le_of_gt (inside t ht)) exit
  exact compare b (right_mem_Icc.mpr hab) (fun t ht => (all_inside t (Ico_subset_Icc_self ht)).le)

end
end HugV3.Source.AppleExistence

