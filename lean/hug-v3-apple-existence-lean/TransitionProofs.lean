import TransitionDefinitions
import V3YangMillsAuditProofs

namespace HugV3.Source.FrameTransition
noncomputable section
open YMAudit YMAuditVerified
open scoped BigOperators
set_option maxHeartbeats 450000

theorem actual_accepted_fabric_rate (G : Geometry) (s d : State) (t : ℝ) (p : Particle)
    (accepted : rhs G t s=some d) : d.F p=mm (particleGradient s p) (s.F p) := by
  unfold rhs at accepted
  obtain ⟨rs,_,hr⟩ := Option.bind_eq_some_iff.mp accepted
  split at hr
  · rw [← Option.some.inj hr]
    exact actual_deformation_component G t s rs p
  · cases hr

theorem state_readout_transfers (Q F : Mat) (h : Orthogonal Q) :
    green (mm Q F)=green F := green_objective Q F h

private theorem mm_assoc (A B C : Mat) : mm (mm A B) C=mm A (mm B C) := by
  change ((Matrix.of A)*(Matrix.of B))*(Matrix.of C)=(Matrix.of A)*((Matrix.of B)*(Matrix.of C))
  exact Matrix.mul_assoc _ _ _

private theorem mm_eye (A : Mat) : mm A eye=A := by
  change (Matrix.of A)*1=Matrix.of A
  exact Matrix.mul_one _

private theorem target_intertwines (Q dQ L : Mat) (h : Orthogonal Q) :
    mm (frameRate Q dQ L) Q=dQ+mm Q L := by
  let A := Matrix.of dQ+Matrix.of Q*Matrix.of L
  change (A*(Matrix.of Q).transpose)*Matrix.of Q=A
  rw [Matrix.mul_assoc,show (Matrix.of Q).transpose*Matrix.of Q=1 from h,Matrix.mul_one]

theorem rate_law_all_fabrics_iff (Q dQ L K : Mat) (h : Orthogonal Q) :
    (∀ F : Mat, mm dQ F+mm Q (mm L F)=mm K (mm Q F)) ↔ K=frameRate Q dQ L := by
  constructor
  · intro law
    have atI := law eye
    simp only [mm_eye] at atI
    have hh : Matrix.of Q*(Matrix.of Q).transpose=1 := mul_eq_one_comm.mp h
    change Matrix.of K=(Matrix.of dQ+Matrix.of Q*Matrix.of L)*(Matrix.of Q).transpose
    change Matrix.of dQ+Matrix.of Q*Matrix.of L=Matrix.of K*Matrix.of Q at atI
    rw [atI,Matrix.mul_assoc,hh,Matrix.mul_one]
  · rintro rfl F
    rw [← mm_assoc (frameRate Q dQ L) Q F,target_intertwines _ _ _ h]
    change Matrix.of dQ*Matrix.of F+Matrix.of Q*(Matrix.of L*Matrix.of F) =
      (Matrix.of dQ+Matrix.of Q*Matrix.of L)*Matrix.of F
    rw [Matrix.add_mul,Matrix.mul_assoc]

theorem moving_frame_residual (Q dQ L F V : Mat) (h : Orthogonal Q) :
    mm dQ F+mm Q V-mm (frameRate Q dQ L) (mm Q F)=mm Q (V-mm L F) := by
  rw [← mm_assoc (frameRate Q dQ L) Q F,target_intertwines _ _ _ h]
  change Matrix.of dQ*Matrix.of F+Matrix.of Q*Matrix.of V-
      (Matrix.of dQ+Matrix.of Q*Matrix.of L)*Matrix.of F =
    Matrix.of Q*(Matrix.of V-Matrix.of L*Matrix.of F)
  rw [Matrix.add_mul,Matrix.mul_assoc,Matrix.mul_sub]
  abel

theorem fabric_segment_transfers (I : Set ℝ) (F L Q dQ : ℝ → Mat)
    (hq : ∀ t ∈ I, Orthogonal (Q t)) (hdq : ∀ t ∈ I, MatrixDerivWithin Q (dQ t) I t)
    (source : fabricPath L F I) :
    fabricPath (fun t => frameRate (Q t) (dQ t) (L t)) (fun t => mm (Q t) (F t)) I := by
  intro t ht
  have product := deformation_product_rule Q F (dQ t) (mm (L t) (F t)) I t (hdq t ht) (source t ht)
  have transport := (rate_law_all_fabrics_iff (Q t) (dQ t) (L t)
    (frameRate (Q t) (dQ t) (L t)) (hq t ht)).2 rfl (F t)
  rwa [transport] at product

private theorem exp_neg_derivative (t : ℝ) :
    HasDerivAt (fun x : ℝ => Real.exp (-x)) (-Real.exp (-t)) t := by
  simpa [Function.comp_def] using (Real.hasDerivAt_exp (-t)).comp t ((hasDerivAt_id t).neg)

private theorem constant_derivative (Q : Mat) (t : ℝ) (I : Set ℝ) :
    MatrixDerivWithin (fun _ => Q) 0 I t := by
  intro i j
  exact (hasDerivAt_const t (Q i j)).hasDerivWithinAt

private theorem diagonal_path : fabricPath (fun _ => diagonalRate) stretch Set.univ := by
  intro t _ i j
  fin_cases i <;> fin_cases j <;> simp [stretch,diagonalRate,mm,Fin.sum_univ_succ] <;>
    first | exact Real.hasDerivAt_exp t | exact exp_neg_derivative t | exact hasDerivAt_const _ _

theorem quarter_paths_follow_their_rates :
    fabricPath (fun _ => diagonalRate) stretch Set.univ ∧
    fabricPath (fun _ => frameRate quarterTurn 0 diagonalRate)
      (fun t => mm quarterTurn (stretch t)) Set.univ ∧
    fabricPath (fun _ => diagonalRate) (fun t => mm (stretch t) quarterTurn) Set.univ := by
  refine ⟨diagonal_path,?_,?_⟩
  · exact fabric_segment_transfers Set.univ stretch (fun _ => diagonalRate) (fun _ => quarterTurn)
      (fun _ => 0) (fun _ _ => quarter_turn_is_orthogonal)
      (fun t _ => constant_derivative quarterTurn t Set.univ) diagonal_path
  · intro t ht
    have h := deformation_product_rule stretch (fun _ => quarterTurn) (mm diagonalRate (stretch t)) 0
      Set.univ t (diagonal_path t ht) (constant_derivative quarterTurn t Set.univ)
    have z : mm (stretch t) 0=0 := by funext i j; simp [mm]
    simpa only [z,add_zero,mm_assoc] using h

private theorem correct_readout (t : ℝ) :
    green (mm quarterTurn (stretch t)) 0 0=((Real.exp t)^2-1)/2 := by
  rw [state_readout_transfers _ _ quarter_turn_is_orthogonal]
  norm_num [green,stretch,eye,Fin.sum_univ_succ]
  ring

private theorem fixed_rate_readout (t : ℝ) :
    green (mm (stretch t) quarterTurn) 0 0=((Real.exp (-t))^2-1)/2 := by
  norm_num [green,mm,quarterTurn,stretch,eye,Fin.sum_univ_succ]
  ring

theorem quarter_initial_agreement_and_opposite_strain_rates :
    mm quarterTurn (stretch 0)=mm (stretch 0) quarterTurn ∧
    frameDefect quarterTurn 0 diagonalRate eye 0 1=2 ∧
    HasDerivAt (fun t : ℝ => green (mm quarterTurn (stretch t)) 0 0) 1 0 ∧
    HasDerivAt (fun t : ℝ => green (mm (stretch t) quarterTurn) 0 0) (-1) 0 := by
  refine ⟨?_,explicit_nonzero_frame_defect,?_,?_⟩
  · funext i j
    fin_cases i <;> fin_cases j <;> norm_num [mm,stretch,quarterTurn,Fin.sum_univ_succ]
  · simp_rw [correct_readout]
    convert (((Real.hasDerivAt_exp 0).pow 2).sub_const 1).div_const 2 using 1 <;>
      first | rfl | norm_num
  · simp_rw [fixed_rate_readout]
    convert (((exp_neg_derivative 0).pow 2).sub_const 1).div_const 2 using 1 <;>
      first | rfl | norm_num

end
end HugV3.Source.FrameTransition
