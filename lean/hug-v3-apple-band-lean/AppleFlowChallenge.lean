import AppleBandChallenge
import AppleFlowDefinitions

namespace HugV3.Source.AppleBand
noncomputable section
open scoped NNReal

theorem continuous_grid_history_has_global_space_bounds {a b : ℝ} (u : ℝ → Vector)
    (hc : ContinuousOn u (Set.Icc a b)) :
    ∃ L K : ℝ≥0, ∀ t∈Set.Icc a b,
      (∀ z, ‖gridVelocity (u t) z‖≤(L:ℝ)) ∧ LipschitzWith K (gridVelocity (u t)) := by sorry

theorem accepted_boundary_keeps_velocity (n : ℕ) (x y : FullState) (ok : boundary n x=some y) :
    velocity y.state=velocity x.state := by sorry

theorem full_trace_material_flow_carries_band (tr : Trace) (solves : Solves tr) (R : ℝ≥0) (big : 1≤R) :
    ∃ φ : Vec × ℝ → Vec, MaterialFlowAcross tr R φ ∧
      MovingContraction (fun r z => φ (z,(r:ℝ)*time 5)) := by sorry

end
end HugV3.Source.AppleBand
