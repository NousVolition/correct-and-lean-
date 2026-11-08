import AppleBandDefinitions

namespace HugV3.Source.AppleBand
noncomputable section
open scoped BigOperators
set_option maxHeartbeats 500000

private theorem axes_continuous : Continuous axes := by
  apply continuous_pi
  intro i
  fin_cases i <;> simp [axes] <;> fun_prop

private theorem latitude_continuous : Continuous latitude := by
  apply continuous_pi
  intro i
  fin_cases i <;> simp [latitude] <;> fun_prop

private theorem latitude_on_skin (r : Slide) (b : Band) : latitude (r,b)∈unitSkin := by
  let d : ℝ := r
  have dr : 0≤d := r.2.1
  have dr' : d≤1 := r.2.2
  have rad : 0≤1-d^2 := by nlinarith [mul_nonneg (sub_nonneg.mpr dr') (show 0≤1+d by linarith)]
  change (Real.sqrt (1-d^2)*b.val.1)^2+(Real.sqrt (1-d^2)*b.val.2)^2+d^2=1
  calc
    _ = (Real.sqrt (1-d^2))^2*(b.val.1^2+b.val.2^2)+d^2 := by ring
    _ = 1 := by rw [Real.sq_sqrt rad,b.property]; ring

private theorem latitude_start (b : Band) : axes (latitude (0,b))=equator b := by
  simp [latitude,equator]

private theorem latitude_finish (b : Band) : axes (latitude (1,b))=north := by
  simp [latitude,north]

theorem reference_band_contracts : ContractsOn referenceSkin equator north := by
  refine ⟨fun y => axes (latitude y),axes_continuous.comp latitude_continuous,
    latitude_start,latitude_finish,?_⟩
  intro r b
  exact ⟨latitude (r,b),latitude_on_skin r b,rfl⟩

theorem continuous_map_carries_contraction (f : Vec → Vec) (hf : Continuous f)
    {S : Set Vec} {loop : Band → Vec} {p : Vec} (h : ContractsOn S loop p) :
    ContractsOn (f '' S) (fun b => f (loop b)) (f p) := by
  obtain ⟨H,cont,start,finish,inside⟩ := h
  exact ⟨fun y => f (H y),hf.comp cont,fun b => congrArg f (start b),
    fun b => congrArg f (finish b),fun r b => ⟨H (r,b),inside r b,rfl⟩⟩

theorem moving_skin_carries_contraction (f : Slide → Vec → Vec)
    (hf : Continuous (fun y : Slide × Vec => f y.1 y.2)) : MovingContraction f := by
  obtain ⟨H,cont,start,finish,inside⟩ := reference_band_contracts
  refine ⟨fun y => f y.1 (H y),hf.comp (continuous_fst.prodMk cont),
    fun b => congrArg (f 0) (start b),fun b => congrArg (f 1) (finish b),
    fun r b => ⟨H (r,b),inside r b,rfl⟩⟩

theorem homeomorphic_transport_iff (e : Vec ≃ₜ Vec) (S : Set Vec) (loop : Band → Vec) (p : Vec) :
    ContractsOn (e '' S) (fun b => e (loop b)) (e p) ↔ ContractsOn S loop p := by
  constructor
  · intro h
    have back := continuous_map_carries_contraction e.symm e.symm.continuous h
    simpa [Set.image_image,Function.comp_def] using back
  · exact continuous_map_carries_contraction e e.continuous

theorem stretch_expands_tips_and_preserves_contraction (t : ℝ) (ht : 0<t) :
    let f := fabricMap 0 (FrameTransition.stretch t)
    (11/25:ℝ)<f (equator east) 0-f (equator west) 0 ∧
    ContractsOn (f '' referenceSkin) (fun b => f (equator b)) (f north) := by
  let f := fabricMap 0 (FrameTransition.stretch t)
  change 11/25 < f (equator east) 0-f (equator west) 0 ∧ _
  constructor
  · have span : f (equator east) 0-f (equator west) 0=(11/25:ℝ)*Real.exp t := by
      norm_num [f,fabricMap,FrameTransition.stretch,axes,equator,east,west,Fin.sum_univ_succ]
      ring
    rw [span]
    linarith [Real.one_lt_exp_iff.mpr ht]
  · apply continuous_map_carries_contraction f _ reference_band_contracts
    apply continuous_pi
    intro i
    dsimp [f,fabricMap]
    fun_prop

end
end HugV3.Source.AppleBand
