import AppleFlowBounds
import AppleTraceVelocity
import Mathlib.Analysis.ODE.ExistUnique

namespace HugV3.Source.AppleBand
noncomputable section
open Set Metric
open scoped NNReal BigOperators
set_option maxHeartbeats 600000

private theorem unit_coordinate {v : Vec} (hv : v∈unitSkin) (i : Axis) : |v i|≤1 := by
  change (v 0)^2+(v 1)^2+(v 2)^2=1 at hv
  have hs : (v i)^2≤(1:ℝ)^2 := by
    fin_cases i
    · change (v 0)^2≤(1:ℝ)^2; nlinarith only [hv,sq_nonneg (v 1),sq_nonneg (v 2)]
    · change (v 1)^2≤(1:ℝ)^2; nlinarith only [hv,sq_nonneg (v 0),sq_nonneg (v 2)]
    · change (v 2)^2≤(1:ℝ)^2; nlinarith only [hv,sq_nonneg (v 0),sq_nonneg (v 1)]
  simpa using (sq_le_sq.mp hs)

private theorem reference_in_ball (R : ℝ≥0) (big : 1≤R) : referenceSkin⊆closedBall 0 (R:ℝ) := by
  rintro z ⟨v,hv,rfl⟩
  rw [mem_closedBall,dist_zero_right]
  apply le_trans _ (show (1:ℝ)≤R from big)
  apply (pi_norm_le_iff_of_nonneg (by norm_num : (0:ℝ)≤1)).2
  intro i
  have scale (c w : ℝ) (hc : |c|≤1) (hw : |w|≤1) : |c*w|≤1 := by
    rw [abs_mul]; simpa only [one_mul] using mul_le_mul hc hw (abs_nonneg _) zero_le_one
  rw [Real.norm_eq_abs]
  fin_cases i
  · exact scale (11/50) (v 0) (by norm_num) (unit_coordinate hv 0)
  · exact scale (17/100) (v 1) (by norm_num) (unit_coordinate hv 1)
  · exact scale (19/100) (v 2) (by norm_num) (unit_coordinate hv 2)

private theorem flow_on_interval {a b : ℝ} (hab : a≤b) (u : ℝ → Vector) (uc : Continuous u)
    (R L K : ℝ≥0) (bounds : ∀ t∈Icc a b, (∀ z, ‖gridVelocity (u t) z‖≤(L:ℝ)) ∧
                                      LipschitzWith K (gridVelocity (u t))) :
    ∃ φ : Vec × ℝ → Vec, (∀ z∈closedBall 0 (R:ℝ), φ (z,a)=z ∧ ∀ t∈Icc a b,
        HasDerivWithinAt (fun τ => φ (z,τ)) (gridVelocity (u t) (φ (z,t))) (Icc a b) t) ∧
      ContinuousOn φ (closedBall 0 (R:ℝ) ×ˢ Icc a b) := by
  let len : ℝ≥0 := ⟨b-a,sub_nonneg.mpr hab⟩
  let outer : ℝ≥0 := R+L*len
  let left : Icc a b := ⟨a,le_rfl,hab⟩
  have hypotheses : IsPicardLindelof (fun t => gridVelocity (u t)) left (0:Vec) outer R L K := by
    constructor
    · intro t ht
      exact ((bounds t ht).2).lipschitzOnWith
    · intro z _
      apply Continuous.continuousOn
      apply continuous_pi
      intro i
      unfold gridVelocity
      fun_prop
    · intro t ht z _
      exact (bounds t ht).1 z
    · change (L:ℝ)*max (b-a) (a-a)≤(outer:ℝ)-(R:ℝ)
      simp only [sub_self,max_eq_left (sub_nonneg.mpr hab)]
      change (L:ℝ)*(b-a)≤(R:ℝ)+(L:ℝ)*(b-a)-(R:ℝ)
      linarith
  exact hypotheses.exists_forall_mem_closedBall_eq_hasDerivWithinAt_continuousOn

private theorem agree_from_left {a b : ℝ} {v : ℝ → Vec → Vec} {K : ℝ≥0} {f g : ℝ → Vec}
    (lip : ∀ t∈Icc a b, LipschitzWith K (v t))
    (hf : ∀ t∈Icc a b, HasDerivWithinAt f (v t (f t)) (Icc a b) t)
    (hg : ∀ t∈Icc a b, HasDerivWithinAt g (v t (g t)) (Icc a b) t)
    (left : f a=g a) : EqOn f g (Icc a b) := by
  apply ODE_solution_unique_of_mem_Icc_right (s:=fun _ => (univ : Set Vec))
        (fun t ht => (lip t (Ico_subset_Icc_self ht)).lipschitzOnWith)
        (HasDerivWithinAt.continuousOn hf) _ (fun _ _ => mem_univ _)
        (HasDerivWithinAt.continuousOn hg) _ (fun _ _ => mem_univ _) left
  · intro t ht
    exact (hf t (Ico_subset_Icc_self ht)).mono_of_mem_nhdsWithin (Icc_mem_nhdsGE_of_mem ht)
  · intro t ht
    exact (hg t (Ico_subset_Icc_self ht)).mono_of_mem_nhdsWithin (Icc_mem_nhdsGE_of_mem ht)

private theorem no_collision {a b : ℝ} {v : ℝ → Vec → Vec} {K : ℝ≥0}
    {R : ℝ≥0} {φ : Vec × ℝ → Vec}
    (lip : ∀ t∈Icc a b, LipschitzWith K (v t))
    (flow : ∀ z∈closedBall 0 (R:ℝ), φ (z,a)=z ∧ ∀ t∈Icc a b,
       HasDerivWithinAt (fun τ => φ (z,τ)) (v t (φ (z,t))) (Icc a b) t)
    (t : ℝ) (ht : t∈Icc a b) :
    InjOn (fun z => φ (z,t)) (closedBall 0 (R:ℝ)) := by
  intro x hx y hy same
  have subset : Icc a t ⊆ Icc a b := Icc_subset_Icc_right ht.2
  have derivatives (z : Vec) (hz : z∈closedBall 0 (R:ℝ)) (τ : ℝ) (hτ : τ∈Ioc a t) :
      HasDerivWithinAt (fun s => φ (z,s)) (v τ (φ (z,τ))) (Iic τ) τ := by
    have h := (flow z hz).2 τ (subset (Ioc_subset_Icc_self hτ))
    exact h.mono_of_mem_nhdsWithin (Icc_mem_nhdsLE_of_mem ⟨hτ.1,hτ.2.trans ht.2⟩)
  have agreed := ODE_solution_unique_of_mem_Icc_left (s:=fun _ => (univ : Set Vec))
    (fun τ hτ => (lip τ (subset (Ioc_subset_Icc_self hτ))).lipschitzOnWith)
    ((HasDerivWithinAt.continuousOn (flow x hx).2).mono subset) (derivatives x hx)
    (fun _ _ => mem_univ _) ((HasDerivWithinAt.continuousOn (flow y hy).2).mono subset)
    (derivatives y hy) (fun _ _ => mem_univ _) same
  have initial := agreed (left_mem_Icc.mpr ht.1)
  simpa only [(flow x hx).1,(flow y hy).1] using initial

private theorem segment_subset (k : ℕ) (hk : k<5) :
    Icc (time k) (time (k+1))⊆Icc (time 0) (time 5) :=
  Icc_subset_Icc (time_monotone (Nat.zero_le _)) (time_monotone (by omega))

private theorem particle_derivative (tr : Trace) (solves : Solves tr) (k : ℕ) (hk : k<5)
    (p : Particle) (t : ℝ) (ht : t∈Icc (time k) (time (k+1))) :
    HasDerivWithinAt (fun τ => (tr.path k τ).state.X p)
      (gridVelocity (joinedVelocity tr 4 t) ((tr.path k t).state.X p)) (Icc (time k) (time (k+1))) t := by
  obtain ⟨d,ok,hder⟩ := (solves.2 k hk).2.2.2.1 t ht
  rw [joined_equals_native tr solves k hk t ht]
  change HasDerivWithinAt _ (materialVelocity _ _) _ _
  rw [←(accepted_position_and_fabric_rates _ _ _ _ p ok).1]
  exact hasDerivWithinAt_pi.mpr (fun i => hder.2.1 p i)

private theorem anchor_particles (tr : Trace) (solves : Solves tr) (R K : ℝ≥0) (φ : Vec × ℝ → Vec)
    (lip : ∀ t∈Icc (time 0) (time 5), LipschitzWith K (gridVelocity (joinedVelocity tr 4 t)))
    (flow : ∀ z∈closedBall 0 (R:ℝ), φ (z,time 0)=z ∧ ∀ t∈Icc (time 0) (time 5),
      HasDerivWithinAt (fun τ => φ (z,τ)) (gridVelocity (joinedVelocity tr 4 t) (φ (z,t)))
        (Icc (time 0) (time 5)) t)
    (p : Particle) (hp : (tr.path 0 (time 0)).state.X p∈closedBall 0 (R:ℝ)) :
    ∀ k<5, ∀ t∈Icc (time k) (time (k+1)),
      φ ((tr.path 0 (time 0)).state.X p,t)=(tr.path k t).state.X p := by
  let z := (tr.path 0 (time 0)).state.X p
  have propagate (k : ℕ) (hk : k<5) (start : φ (z,time k)=(tr.path k (time k)).state.X p) :
      ∀ t∈Icc (time k) (time (k+1)), φ (z,t)=(tr.path k t).state.X p := by
    apply agree_from_left (v:=fun t => gridVelocity (joinedVelocity tr 4 t))
      (fun t ht => lip t (segment_subset k hk ht)) _ (particle_derivative tr solves k hk p) start
    exact fun t ht => ((flow z hp).2 t (segment_subset k hk ht)).mono (segment_subset k hk)
  intro k
  induction k with
  | zero => intro hk; exact propagate 0 hk (flow z hp).1
  | succ n ih =>
    intro hk
    apply propagate (n+1) hk
    have previous := ih (by omega) (time (n+1)) (right_mem_Icc.mpr (time_monotone (Nat.le_succ n)))
    rw [previous,(solves.2 (n+1) hk).1]
    rw [(accepted_boundary_keeps_material _ _ _ (solves.2 n (by omega)).2.2.2.2).1]

theorem full_trace_material_flow_carries_band (tr : Trace) (solves : Solves tr) (R : ℝ≥0) (big : 1≤R) :
    ∃ φ : Vec × ℝ → Vec, MaterialFlowAcross tr R φ ∧
      MovingContraction (fun r z => φ (z,(r:ℝ)*time 5)) := by
  let U := joinedVelocity tr 4
  have uc : Continuous U := joined_continuous tr solves 4 (by decide)
  obtain ⟨L,K,bounds⟩ := continuous_grid_history_has_global_space_bounds
    (a:=time 0) (b:=time 5) U uc.continuousOn
  obtain ⟨φ,flow,cont⟩ := flow_on_interval (time_monotone (by decide : 0≤5)) U uc R L K bounds
  have lips := fun t ht => (bounds t ht).2
  refine ⟨φ,?_,?_⟩
  · refine ⟨cont,fun z hz => (flow z hz).1,?_,fun t ht => no_collision lips flow t ht,
      anchor_particles tr solves R K φ lips flow⟩
    intro k hk z hz t ht
    have deriv := ((flow z hz).2 t (segment_subset k hk ht)).mono (segment_subset k hk)
    change HasDerivWithinAt _ (gridVelocity (joinedVelocity tr 4 t) (φ (z,t))) _ t at deriv
    rw [joined_equals_native tr solves k hk t ht] at deriv
    exact deriv
  · obtain ⟨H,continuousH,beginning,ending,inside⟩ := reference_band_contracts
    let t := fun r : Slide => (r:ℝ)*time 5
    have ht (r : Slide) : t r∈Icc (time 0) (time 5) := by
      change (time 0)≤(r:ℝ)*time 5 ∧ (r:ℝ)*time 5≤time 5
      norm_num [time]
      constructor <;> nlinarith [r.2.1,r.2.2]
    have map_cont : Continuous (fun y : Slide × Band => (H y,t y.1)) := by
      refine continuousH.prodMk ?_
      dsimp [t]
      fun_prop
    have domain (y : Slide × Band) : (H y,t y.1)∈closedBall 0 (R:ℝ) ×ˢ Icc (time 0) (time 5) :=
      ⟨reference_in_ball R big (inside y.1 y.2),ht y.1⟩
    refine ⟨fun y => φ (H y,t y.1),cont.comp_continuous map_cont domain,?_,?_,?_⟩
    · intro b
      change φ (H (0,b),t 0)=φ (equator b,t 0)
      rw [beginning]
    · intro b
      change φ (H (1,b),t 1)=φ (north,t 1)
      rw [ending]
    · intro r b; exact ⟨H (r,b),inside r b,rfl⟩

private theorem reference_compact : IsCompact referenceSkin := by
  have closed : IsClosed unitSkin := isClosed_eq (by fun_prop : Continuous (fun v : Vec =>
    (v 0)^2+(v 1)^2+(v 2)^2)) continuous_const
  have subset : unitSkin⊆closedBall 0 1 := by
    intro v hv
    rw [mem_closedBall,dist_zero_right]
    exact (pi_norm_le_iff_of_nonneg zero_le_one).2 (fun i => unit_coordinate hv i)
  have compact := (isCompact_closedBall (0:Vec) 1).of_isClosed_subset closed subset
  have cont : Continuous axes := by
    apply continuous_pi
    intro i
    fin_cases i <;> simp [axes] <;> fun_prop
  exact compact.image cont

theorem band_on_the_embedded_skin_at_each_time {tr : Trace} {R : ℝ≥0} {φ : Vec × ℝ → Vec}
    (flow : MaterialFlowAcross tr R φ) (big : 1≤R) (t : ℝ) (ht : t∈Set.Icc (time 0) (time 5)) :
    Topology.IsEmbedding (fun z : referenceSkin => φ ((z:Vec),t)) ∧
    ContractsOn ((fun z : Vec => φ (z,t)) '' referenceSkin)
      (fun b => φ (equator b,t)) (φ (north,t)) := by
  let _ : CompactSpace referenceSkin := isCompact_iff_compactSpace.mp reference_compact
  have cf : Continuous (fun z : referenceSkin => φ ((z:Vec),t)) :=
    flow.1.comp_continuous (continuous_subtype_val.prodMk continuous_const)
      (fun z => ⟨reference_in_ball R big z.2,ht⟩)
  have inj : Function.Injective (fun z : referenceSkin => φ ((z:Vec),t)) := by
    intro z w eq
    exact Subtype.ext (flow.2.2.2.1 t ht (reference_in_ball R big z.2) (reference_in_ball R big w.2) eq)
  refine ⟨(cf.isClosedEmbedding inj).isEmbedding,?_⟩
  obtain ⟨H,continuousH,beginning,ending,inside⟩ := reference_band_contracts
  refine ⟨fun y => φ (H y,t),flow.1.comp_continuous (continuousH.prodMk continuous_const)
    (fun y => ⟨reference_in_ball R big (inside y.1 y.2),ht⟩),?_,?_,?_⟩
  · intro b; exact congrArg (fun z => φ (z,t)) (beginning b)
  · intro b; exact congrArg (fun z => φ (z,t)) (ending b)
  · intro r b; exact ⟨H (r,b),inside r b,rfl⟩

end
end HugV3.Source.AppleBand
