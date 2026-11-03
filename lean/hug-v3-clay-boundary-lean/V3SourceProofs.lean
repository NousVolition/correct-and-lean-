import V3SourceSystem

/- Concrete component results. No claim of full existence or uniqueness is
   proved in this file, and no reference-only challenge is imported. -/
namespace HugV3.Source.Verified
noncomputable section
open scoped BigOperators

set_option maxRecDepth 4096 in
private theorem rhs_recovers (G : Geometry) (t : ℝ) (s d : State)
    (h : rhs G t s=some d) :
    ∃ records, readRecords s=some records ∧ d=rhsFromRecords G t s records := by
  classical
  unfold rhs at h
  obtain ⟨records,hr,hd⟩ := Option.bind_eq_some_iff.mp h
  split at hd
  · exact ⟨records,hr,(Option.some.inj hd).symm⟩
  · cases hd

theorem rhs_fabric_equation (G : Geometry) (t : ℝ) (s d : State)
    (h : rhs G t s=some d) (l : Cell) :
    d.b l=fabricRate (fabricStrain s.F l) (s.b l) := by
  obtain ⟨records,_,hd⟩ := rhs_recovers G t s d h
  rw [hd]
  rfl

theorem rhs_accumulator_equation (G : Geometry) (t : ℝ) (s d : State)
    (h : rhs G t s=some d) :
    ∃ records, readRecords s=some records ∧
      d.A=0.08*(socialRates G t s records).utility := by
  obtain ⟨records,hr,hd⟩ := rhs_recovers G t s d h
  exact ⟨records,hr,by rw [hd]; rfl⟩

theorem fabric_strain_lower_bound (F : Particle → Mat) (l : Cell) :
    -(1/2:ℝ)≤fabricStrain F l := by
  have hn : 0≤∑ i, (F (point l) i (axis l))^2 :=
    Finset.sum_nonneg (fun i _ => sq_nonneg _)
  unfold fabricStrain
  linarith

private theorem rate_polynomial (e b : ℝ) :
    fabricRate e b=e/500+(31/125)*b-625*b^3 := by
  unfold fabricRate fabricGradient
  ring

theorem positive_read_boundary_inward (F : Particle → Mat) (l : Cell) :
    (259/1600000:ℝ)≤fabricRate (fabricStrain F l) (1/200) := by
  have hf := fabric_strain_lower_bound F l
  rw [rate_polynomial]
  norm_num
  linarith

private theorem negative_boundary_formula (F : Particle → Mat) (l : Cell) :
    fabricRate (fabricStrain F l) (-1/200)=
      (∑ i, (F (point l) i (axis l))^2)/1000-3459/1600000 := by
  rw [rate_polynomial]
  unfold fabricStrain
  ring

theorem negative_read_boundary_inward_iff (F : Particle → Mat) (l : Cell) :
    fabricRate (fabricStrain F l) (-1/200)<0 ↔
      (∑ i, (F (point l) i (axis l))^2)<(3459/1600:ℝ) := by
  rw [negative_boundary_formula]
  constructor <;> intro h <;> linarith

theorem negative_read_boundary_under_two (F : Particle → Mat) (l : Cell)
    (h : (∑ i, (F (point l) i (axis l))^2)≤(2:ℝ)) :
    fabricRate (fabricStrain F l) (-1/200)≤-(259/1600000:ℝ) := by
  rw [negative_boundary_formula]
  linarith

theorem large_deformation_not_automatic :
    0<fabricRate (fabricStrain (fun _ i j => if i=j then 2 else 0) 0) (-1/200) := by
  norm_num [fabricRate,fabricGradient,fabricStrain,point,axis,Fin.sum_univ_succ]

theorem written_cell_restores_margin (s : State) (slot : Fin 4) (bytes : List ℕ) (l : Cell)
    (h : l.val/37264=slot.val) :
    |targetFabric s slot bytes l|=(1/50:ℝ) ∧
      (1/200:ℝ) < |targetFabric s slot bytes l| := by
  have ht : |targetFabric s slot bytes l|=(1/50:ℝ) := by
    unfold targetFabric
    rw [if_pos h]
    unfold bitsOfPayload
    split_ifs <;> norm_num
  exact ⟨ht,by rw [ht]; norm_num⟩

set_option maxRecDepth 8192 in
theorem crc_reference_vector :
    crc32 [49,50,51,52,53,54,55,56,57]=3421780262 := by decide

end
end HugV3.Source.Verified
