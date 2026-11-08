import AppleBandTopology
import StreetWholeProofs
import TransitionProofs

namespace HugV3.Source.AppleBand
noncomputable section
open scoped BigOperators
set_option maxHeartbeats 550000

theorem accepted_position_and_fabric_rates (G : Geometry) (t : ℝ) (s d : State) (p : Particle)
    (ok : rhs G t s=some d) : d.X p=materialVelocity s (s.X p) ∧
    d.F p=mm (particleGradient s p) (s.F p) := by
  refine ⟨?_,FrameTransition.actual_accepted_fabric_rate G s d t p ok⟩
  unfold rhs at ok
  obtain ⟨records,_,h⟩ := Option.bind_eq_some_iff.mp ok
  split at h
  · rw [← Option.some.inj h]
    rfl
  · cases h

theorem accepted_step_moves_every_particle {G : Geometry} {t h : ℝ} {s d pr k e : State}
    (ok : ChildAccount.FullStep G t h s d pr k e) (p : Particle) :
    e.X p=stepMap ⟨s,pr,h⟩ (s.X p) := by
  have first := (accepted_position_and_fabric_rates G t s d p ok.first).1
  have second := (accepted_position_and_fabric_rates G (t+h) pr k p ok.second).1
  have predictor : pr.X p=s.X p+h • d.X p := funext (fun i => ok.predictor.2.1 p i)
  have finish : e.X p=s.X p+(h/2) • (d.X p+k.X p) := funext (fun i => ok.endpoint.2.1 p i)
  rw [finish,second,predictor,first]
  rfl

private theorem write_keeps (G : Geometry) (s e : State) (r : Record) (h : writeEvent G s r=some e) :
    e.X=s.X ∧ e.F=s.F := by
  obtain ⟨_,_,_,_,_,_,_,hx,hf,_⟩ := StreetWholeVerified.successful_write_preserves_person_and_line G s e r h
  exact ⟨hx,hf⟩

private theorem completion_keeps (id : Fin 3) (x y : FullState) (ok : completeEvent id x=some y) :
    y.state.X=x.state.X ∧ y.state.F=x.state.F := by
  unfold completeEvent at ok
  obtain ⟨F,_,ok⟩ := Option.bind_eq_some_iff.mp ok
  obtain ⟨r,_,ok⟩ := Option.bind_eq_some_iff.mp ok
  obtain ⟨s,hw,ok⟩ := Option.bind_eq_some_iff.mp ok
  rw [← Option.some.inj ok]
  exact write_keeps sourceGeometry x.state s r hw

theorem accepted_boundary_keeps_material (n : ℕ) (x y : FullState) (ok : boundary n x=some y) :
    y.state.X=x.state.X ∧ y.state.F=x.state.F := by
  match n with
  | 0 => have h : capture 0 x=y := Option.some.inj ok; rw [←h]; exact ⟨rfl,rfl⟩
  | 1 => have h : capture 1 x=y := Option.some.inj ok; rw [←h]; exact ⟨rfl,rfl⟩
  | 2 => exact completion_keeps 0 x y ok
  | 3 =>
    change (completeEvent 1 x).map (capture 2)=some y at ok
    cases step : completeEvent 1 x with
    | none => simp [step] at ok
    | some z =>
      have yz : capture 2 z=y := by simpa [step] using ok
      rw [←yz]
      exact completion_keeps 1 x z step
  | 4 => exact completion_keeps 2 x y ok
  | n+5 => have h : x=y := Option.some.inj ok; rw [h]; exact ⟨rfl,rfl⟩

private theorem material_continuous (s : State) : Continuous (materialVelocity s) := by
  have weight (j : Axis) (i : Fin 16) : Continuous (fun z : Vec => mechanical1D (z j) i) := by
    unfold mechanical1D
    apply Continuous.div_const
    apply continuous_finsetSum
    intro k _
    split <;> fun_prop
  apply continuous_pi
  intro i
  unfold materialVelocity
  apply continuous_finsetSum
  intro x _
  apply Continuous.mul _ continuous_const
  apply continuous_finsetProd
  intro j _
  exact weight j (x j)

private theorem step_continuous (a : Stages) : Continuous (stepMap a) := by
  have v := material_continuous a.present
  have w := material_continuous a.predictor
  have predicted : Continuous (fun z : Vec => z+a.h • materialVelocity a.present z) := by fun_prop
  have second : Continuous (fun z : Vec => materialVelocity a.predictor (z+a.h • materialVelocity a.present z)) :=
    w.comp predicted
  unfold stepMap
  fun_prop

private theorem transport_continuous (stages : List Stages) : Continuous (transport stages) := by
  induction stages with
  | nil => exact continuous_id
  | cons a rest ih => exact ih.comp (step_continuous a)

private theorem particle_carried {stages : List Stages} {s e : State} (ok : AcceptedChain stages s e) :
    ∀ p, e.X p=transport stages (s.X p) := by
  induction ok with
  | nil => intro p; rfl
  | advance hs _ ih =>
    intro p
    rw [ih p,accepted_step_moves_every_particle hs p]
    rfl
  | checkpoint hj _ ih =>
    intro p
    rw [ih p,(accepted_boundary_keeps_material _ _ _ hj).1]

theorem accepted_chain_carries_band {stages : List Stages} {s e : State}
    (ok : AcceptedChain stages s e) :
    (∀ p, e.X p=transport stages (s.X p)) ∧
    ContractsOn (transport stages '' referenceSkin) (fun b => transport stages (equator b))
      (transport stages north) := by
  exact ⟨particle_carried ok,continuous_map_carries_contraction (transport stages)
    (transport_continuous stages) reference_band_contracts⟩

private theorem clock_mem (k : ℕ) (hk : k<5) (r : Slide) :
    segmentTime k r ∈ Set.Icc (time k) (time (k+1)) := by
  have h : time k≤time (k+1) := by interval_cases k <;> norm_num [time]
  have l := mul_nonneg r.2.1 (sub_nonneg.mpr h)
  have u := mul_nonneg (sub_nonneg.mpr r.2.2) (sub_nonneg.mpr h)
  constructor <;> dsimp [segmentTime] <;> nlinarith only [l,u]

theorem full_segment_local_band (tr : Trace) (solves : Solves tr) (k : ℕ) (hk : k<5) (p : Particle) :
    MovingContraction (segmentCarrier tr k p) := by
  have cont := ((solves.2 k hk).2.1)
  have tc : Continuous (segmentTime k) := by unfold segmentTime; fun_prop
  have coord (f : State → ℝ)
      (hf : ContinuousOn (fun t => f (tr.path k t).state) (Set.Icc (time k) (time (k+1)))) :
      Continuous (fun r : Slide => f (tr.path k (segmentTime k r)).state) := by
    exact (continuousOn_iff_continuous_domRestrict.mp hf).comp (tc.subtype_mk (clock_mem k hk))
  apply moving_skin_carries_contraction
  apply continuous_pi
  intro i
  change Continuous (fun y : Slide × Vec => (tr.path k (segmentTime k y.1)).state.X p i+
    ∑ j, (tr.path k (segmentTime k y.1)).state.F p i j*y.2 j)
  have hx : Continuous (fun y : Slide × Vec => (tr.path k (segmentTime k y.1)).state.X p i) :=
    (coord (fun s => s.X p i) (cont.2.1 p i)).comp continuous_fst
  have term (j : Axis) : Continuous (fun y : Slide × Vec =>
      (tr.path k (segmentTime k y.1)).state.F p i j*y.2 j) := by
    have hf : Continuous (fun y : Slide × Vec => (tr.path k (segmentTime k y.1)).state.F p i j) :=
      (coord (fun s => s.F p i j) (cont.2.2.1 p i j)).comp continuous_fst
    fun_prop
  exact hx.add (continuous_finsetSum _ (fun j _ => term j))

theorem small_step_preserves_distinct_points (a : Stages) (A B : ℝ)
    (_hA : 0≤A) (hB : 0≤B)
    (first : ∀ x y, ‖materialVelocity a.present x-materialVelocity a.present y‖≤A*‖x-y‖)
    (second : ∀ x y, ‖materialVelocity a.predictor x-materialVelocity a.predictor y‖≤B*‖x-y‖)
    (small : |a.h| / 2*(A+B*(1+|a.h| * A))<1) : Function.Injective (stepMap a) := by
  intro x y he
  by_contra xy
  let u := materialVelocity a.present
  let pt := fun z : Vec => z+a.h • u z
  let w := fun z => materialVelocity a.predictor (pt z)
  let delta := fun z : Vec => (a.h/2) • (u z+w z)
  have pos : 0<‖x-y‖ := norm_pos_iff.mpr (sub_ne_zero.mpr xy)
  have hp : ‖pt x-pt y‖≤(1+|a.h| * A)*‖x-y‖ := by
    have eqn : pt x-pt y=(x-y)+a.h • (u x-u y) := by dsimp [pt]; rw [smul_sub]; abel
    rw [eqn]
    calc
      _ ≤ ‖x-y‖+‖a.h • (u x-u y)‖ := norm_add_le _ _
      _ ≤ ‖x-y‖+|a.h| * (A*‖x-y‖) := by
        rw [norm_smul,Real.norm_eq_abs]
        exact add_le_add le_rfl (mul_le_mul_of_nonneg_left (first x y) (abs_nonneg a.h))
      _ = _ := by ring
  have hw : ‖w x-w y‖≤B*((1+|a.h| * A)*‖x-y‖) :=
    (second (pt x) (pt y)).trans (mul_le_mul_of_nonneg_left hp hB)
  have bound : ‖delta x-delta y‖≤(|a.h| / 2*(A+B*(1+|a.h| * A)))*‖x-y‖ := by
    have identity : delta x-delta y=(a.h/2) • ((u x-u y)+(w x-w y)) := by
      dsimp only [delta]; rw [←smul_sub]; congr 1; abel
    rw [identity,norm_smul,Real.norm_eq_abs,abs_div,abs_of_pos (by norm_num : (0:ℝ)<2)]
    calc
      _ ≤ |a.h| / 2*(A*‖x-y‖+B*((1+|a.h| * A)*‖x-y‖)) := by
        apply mul_le_mul_of_nonneg_left _ (by positivity)
        exact (norm_add_le _ _).trans (add_le_add (first x y) hw)
      _ = _ := by ring
  change x+delta x=y+delta y at he
  have hd : x-y=delta y-delta x := calc
    _ = (x+delta x)-(y+delta y)+(delta y-delta x) := by abel
    _ = _ := by rw [he]; simp
  have equal : ‖x-y‖=‖delta x-delta y‖ := by rw [hd,norm_sub_rev (delta y)]
  have strictly := mul_lt_mul_of_pos_right small pos
  linarith

end
end HugV3.Source.AppleBand
