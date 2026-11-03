import FullEquationSpecification
namespace HugNavierFullAudit.Verified
open ActiveHug Set

theorem acceleration_force_difference (p : Parameters) (F G : ℝ) (s : State) :
    (rhs p F s).v-(rhs p G s).v=(F-G)/p.mass := by
  dsimp [rhs]
  ring

theorem force_recovered_from_acceleration (p : Parameters) (hm : p.mass ≠ 0)
    (F acceleration : ℝ) (s : State) :
    (rhs p F s).v=acceleration ↔ F=forceRequired p s acceleration := by
  dsimp [rhs]
  rw [div_eq_iff hm]
  dsimp [forceRequired]
  constructor <;> intro h <;> linarith

theorem same_acceleration_iff_same_force (p : Parameters) (hm : p.mass ≠ 0)
    (F G : ℝ) (s : State) : (rhs p F s).v=(rhs p G s).v ↔ F=G := by
  constructor
  · intro h
    have hd : (F-G)/p.mass=0 := by
      rw [←acceleration_force_difference p F G s,h,sub_self]
    exact sub_eq_zero.mp ((div_eq_zero_iff.mp hd).resolve_right hm)
  · rintro rfl
    rfl

theorem same_motion_requires_same_force (p : Parameters) (hm : p.mass ≠ 0)
    (I : Set ℝ) (F G : ℝ → ℝ) (h : ℝ → State)
    (hF : ∀ t ∈ I, HugDifferentialAt p F h t)
    (hG : ∀ t ∈ I, HugDifferentialAt p G h t) : EqOn F G I := by
  intro t ht
  apply (same_acceleration_iff_same_force p hm (F t) (G t) (h t)).mp
  exact (hF t ht).2.1.unique (hG t ht).2.1

theorem energy_input_difference (p : Parameters) (F G : ℝ) (s : State) :
    energyBalance p F s-energyBalance p G s=(F-G)*s.v := by
  dsimp [energyBalance]
  ring

theorem zero_speed_energy_not_force :
    energyBalance protocol 1 restProbe=energyBalance protocol 0 restProbe ∧
    (rhs protocol 1 restProbe).v-(rhs protocol 0 restProbe).v=5 := by
  constructor
  · simp [energyBalance,restProbe]
  · rw [acceleration_force_difference]
    norm_num [protocol]

theorem nonuniform_initial_requires_spatial_map :
    ¬∃ a : ℝ, ∀ r : Point, sourceInitialXA r=a := by
  rintro ⟨a,h⟩
  have h0 := h (0,0)
  have hpi := h (Real.pi,0)
  norm_num [sourceInitialXA] at h0 hpi
  linarith

end HugNavierFullAudit.Verified

#print axioms HugNavierFullAudit.Verified.acceleration_force_difference
#print axioms HugNavierFullAudit.Verified.force_recovered_from_acceleration
#print axioms HugNavierFullAudit.Verified.same_acceleration_iff_same_force
#print axioms HugNavierFullAudit.Verified.same_motion_requires_same_force
#print axioms HugNavierFullAudit.Verified.energy_input_difference
#print axioms HugNavierFullAudit.Verified.zero_speed_energy_not_force
#print axioms HugNavierFullAudit.Verified.nonuniform_initial_requires_spatial_map
