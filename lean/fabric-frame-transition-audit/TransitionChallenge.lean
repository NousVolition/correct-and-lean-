import TransitionDefinitions

namespace HugV3.Source.FrameTransition
noncomputable section
open YMAudit

theorem actual_accepted_fabric_rate (G : Geometry) (s d : State) (t : ℝ) (p : Particle)
    (accepted : rhs G t s=some d) : d.F p=mm (particleGradient s p) (s.F p) := by sorry

theorem state_readout_transfers (Q F : Mat) (h : Orthogonal Q) :
    green (mm Q F)=green F := by sorry

theorem rate_law_all_fabrics_iff (Q dQ L K : Mat) (h : Orthogonal Q) :
    (∀ F : Mat, mm dQ F+mm Q (mm L F)=mm K (mm Q F)) ↔ K=frameRate Q dQ L := by sorry

theorem moving_frame_residual (Q dQ L F V : Mat) (h : Orthogonal Q) :
    mm dQ F+mm Q V-mm (frameRate Q dQ L) (mm Q F)=mm Q (V-mm L F) := by sorry

theorem fabric_segment_transfers (I : Set ℝ) (F L Q dQ : ℝ → Mat)
    (hq : ∀ t ∈ I, Orthogonal (Q t)) (hdq : ∀ t ∈ I, MatrixDerivWithin Q (dQ t) I t)
    (source : fabricPath L F I) :
    fabricPath (fun t => frameRate (Q t) (dQ t) (L t)) (fun t => mm (Q t) (F t)) I := by sorry

theorem quarter_paths_follow_their_rates :
    fabricPath (fun _ => diagonalRate) stretch Set.univ ∧
    fabricPath (fun _ => frameRate quarterTurn 0 diagonalRate)
      (fun t => mm quarterTurn (stretch t)) Set.univ ∧
    fabricPath (fun _ => diagonalRate) (fun t => mm (stretch t) quarterTurn) Set.univ := by sorry

theorem quarter_initial_agreement_and_opposite_strain_rates :
    mm quarterTurn (stretch 0)=mm (stretch 0) quarterTurn ∧
    frameDefect quarterTurn 0 diagonalRate eye 0 1=2 ∧
    HasDerivAt (fun t : ℝ => green (mm quarterTurn (stretch t)) 0 0) 1 0 ∧
    HasDerivAt (fun t : ℝ => green (mm (stretch t) quarterTurn) 0 0) (-1) 0 := by sorry

end
end HugV3.Source.FrameTransition
