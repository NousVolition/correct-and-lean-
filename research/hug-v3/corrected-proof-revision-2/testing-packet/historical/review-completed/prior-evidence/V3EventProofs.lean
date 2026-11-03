import V3EventSpecification
namespace HugV3Event.Verified
noncomputable section
open Filter Set
open scoped Topology

theorem probe_recovers_rest_strain (k load b : ℝ) (hk : k ≠ 0) :
    inferredRestStrain k load b = b := by
  unfold inferredRestStrain traction
  field_simp
  <;> ring

theorem header_first_bit_is_one : headerMagic % 2 = 1 := by
  norm_num [headerMagic]

theorem valid_empty_coordinate_changes (a margin b : ℝ)
    (h : ValidEmptyCoordinate a margin b) : writtenBit a true ≠ b := by
  rcases h with ⟨ha, hm, hb⟩
  have hp : 0 < margin * a := mul_pos hm ha
  simp only [writtenBit, Bool.true_eq, if_true, mul_one]
  linarith

theorem event_prevents_continuity (f : ℝ → ℝ) (eventTime before a : ℝ)
    (h : EventWitness f eventTime before a) : ¬ ContinuousAt f eventTime := by
  intro hc
  rcases h with ⟨hleft, hvalue, hbefore, ha⟩
  have hs : Tendsto f (𝓝[<] eventTime) (𝓝 (f eventTime)) :=
    hc.tendsto.mono_left nhdsWithin_le_nhds
  have heq : f eventTime = before := tendsto_nhds_unique hs hleft
  simp only [writtenBit, Bool.true_eq, if_true, mul_one] at hvalue
  linarith

theorem event_prevents_derivative (f : ℝ → ℝ) (eventTime before a rate : ℝ)
    (h : EventWitness f eventTime before a) : ¬ HasDerivAt f rate eventTime := by
  intro hd
  exact event_prevents_continuity f eventTime before a h hd.continuousAt

theorem full_state_prevents_continuity {E : Type*} [TopologicalSpace E]
    (read : E → ℝ) (hread : Continuous read) (path : ℝ → E)
    (eventTime before a : ℝ) (h : EventWitness (read ∘ path) eventTime before a) :
    ¬ ContinuousAt path eventTime := by
  intro hc
  exact event_prevents_continuity (read ∘ path) eventTime before a h
    (hread.continuousAt.comp hc)

#print axioms probe_recovers_rest_strain
#print axioms header_first_bit_is_one
#print axioms valid_empty_coordinate_changes
#print axioms event_prevents_continuity
#print axioms event_prevents_derivative
#print axioms full_state_prevents_continuity
end
end HugV3Event.Verified
