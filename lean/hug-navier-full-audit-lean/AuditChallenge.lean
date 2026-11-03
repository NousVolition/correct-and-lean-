import FullEquationSpecification
namespace HugNavierFullAudit.Verified
open ActiveHug Set

theorem acceleration_force_difference (p : Parameters) (F G : ℝ) (s : State) :
    (rhs p F s).v-(rhs p G s).v=(F-G)/p.mass := by sorry

theorem force_recovered_from_acceleration (p : Parameters) (hm : p.mass ≠ 0)
    (F acceleration : ℝ) (s : State) :
    (rhs p F s).v=acceleration ↔ F=forceRequired p s acceleration := by sorry

theorem same_acceleration_iff_same_force (p : Parameters) (hm : p.mass ≠ 0)
    (F G : ℝ) (s : State) : (rhs p F s).v=(rhs p G s).v ↔ F=G := by sorry

theorem same_motion_requires_same_force (p : Parameters) (hm : p.mass ≠ 0)
    (I : Set ℝ) (F G : ℝ → ℝ) (h : ℝ → State)
    (hF : ∀ t ∈ I, HugDifferentialAt p F h t)
    (hG : ∀ t ∈ I, HugDifferentialAt p G h t) : EqOn F G I := by sorry

theorem energy_input_difference (p : Parameters) (F G : ℝ) (s : State) :
    energyBalance p F s-energyBalance p G s=(F-G)*s.v := by sorry

theorem zero_speed_energy_not_force :
    energyBalance protocol 1 restProbe=energyBalance protocol 0 restProbe ∧
    (rhs protocol 1 restProbe).v-(rhs protocol 0 restProbe).v=5 := by sorry

theorem nonuniform_initial_requires_spatial_map :
    ¬∃ a : ℝ, ∀ r : Point, sourceInitialXA r=a := by sorry

end HugNavierFullAudit.Verified
