import BridgeModel
namespace HugNavierBridge.Verified
open ActiveHug

theorem shear_derivative (v L y : ℝ) :
    HasDerivAt (shearVelocity v L) (v/L) y := by
  exact hasDerivAt_const_mul (v/L)

theorem shear_contraction (v L : ℝ) (hL : L ≠ 0) :
    contraction (shearD v L) = shearInvariant v L := by
  norm_num [contraction, shearD, shearInvariant, Fin.sum_univ_two]
  field_simp
  <;> ring

theorem nonzero_shear_not_periodic (v L H : ℝ) (hL : L ≠ 0) (hH : H ≠ 0) :
    shearVelocity v L H = shearVelocity v L 0 ↔ v = 0 := by
  simp [shearVelocity, mul_eq_zero, div_eq_zero_iff, hL, hH]

theorem strain_matching (p : Parameters) (s : State)
    (hL : p.length ≠ 0) (hQ : p.scale ≠ 0) :
    matchingChi p * shearInvariant s.v p.length = p.chi*strainSignal p s := by
  dsimp [matchingChi, shearInvariant, strainSignal]
  field_simp
  <;> ring

theorem argument_matching (p : Parameters) (s : State)
    (hL : p.length ≠ 0) (hQ : p.scale ≠ 0) :
    fieldArgumentAB p (matchingChi p) s = targetAB p s ∧
    fieldArgumentBA p (matchingChi p) s = targetBA p s := by
  dsimp [fieldArgumentAB, fieldArgumentBA, targetAB, targetBA]
  rw [strain_matching p s hL hQ]
  exact ⟨rfl,rfl⟩

theorem guard_diffusion_residual (p : Parameters) (F : ℝ) (s : State)
    (hL : p.length ≠ 0) (hQ : p.scale ≠ 0) (kA lA kB lB : ℝ) :
    materialGuardAB p (matchingChi p) s kA lA - (rhs p F s).gAB = kA*lA ∧
    materialGuardBA p (matchingChi p) s kB lB - (rhs p F s).gBA = kB*lB := by
  obtain ⟨ha,hb⟩ := argument_matching p s hL hQ
  simp only [materialGuardAB, materialGuardBA, rhs]
  rw [ha,hb]
  constructor <;> ring

theorem four_rates_agree_iff (p : Parameters) (F : ℝ) (s : State)
    (hL : p.length ≠ 0) (hQ : p.scale ≠ 0) (kA lA kB lB kgA lgA kgB lgB : ℝ) :
    FourRatesAgree p F s kA lA kB lB kgA lgA kgB lgB ↔
      kA*lA=0 ∧ kB*lB=0 ∧ kgA*lgA=0 ∧ kgB*lgB=0 := by
  obtain ⟨hga,hgb⟩ := guard_diffusion_residual p F s hL hQ kgA lgA kgB lgB
  have hra : materialResponseA p s kA lA - (rhs p F s).xA = kA*lA := by
    dsimp [materialResponseA,rhs]; ring
  have hrb : materialResponseB p s kB lB - (rhs p F s).xB = kB*lB := by
    dsimp [materialResponseB,rhs]; ring
  constructor
  · rintro ⟨ha,hb,hc,hd⟩
    exact ⟨by linarith,by linarith,by linarith,by linarith⟩
  · rintro ⟨ha,hb,hc,hd⟩
    exact ⟨by linarith,by linarith,by linarith,by linarith⟩

theorem power_matching (p : Parameters) (aAB aBA : ℝ) (hL : p.length ≠ 0)
    (ha : p.volume*aAB=p.damping*p.length^2)
    (hb : p.volume*aBA=p.damping*p.length^2) (s : State) :
    projectedGuardPower p aAB aBA s = guardLoss p s := by
  dsimp [projectedGuardPower,guardLoss]
  field_simp
  linear_combination (s.gAB*s.v^2)*ha + (s.gBA*s.v^2)*hb

theorem power_matching_necessary (p : Parameters) (aAB aBA : ℝ) (hL : p.length ≠ 0)
    (h : ∀ s, projectedGuardPower p aAB aBA s = guardLoss p s) :
    p.volume*aAB=p.damping*p.length^2 ∧ p.volume*aBA=p.damping*p.length^2 := by
  have ha := h ⟨0,1,0,0,0,0,1,0⟩
  have hb := h ⟨0,1,0,0,0,0,0,1⟩
  norm_num [projectedGuardPower,guardLoss] at ha hb
  field_simp at ha hb
  exact ⟨by nlinarith [ha],by nlinarith [hb]⟩

theorem primary_required_coefficients :
    matchingChi protocol = 500000 ∧
    protocol.volume*(1000:ℝ)=protocol.damping*protocol.length^2 := by
  norm_num [matchingChi,protocol]

theorem primary_power_matches (s : State) :
    projectedGuardPower protocol 1000 1000 s = guardLoss protocol s := by
  apply power_matching
  · norm_num [protocol]
  · norm_num [protocol]
  · norm_num [protocol]

theorem same_number_chi_is_not_same_argument :
    fieldArgumentAB protocol protocol.chi probe ≠ targetAB protocol probe := by
  norm_num [fieldArgumentAB,targetAB,shearInvariant,strainSignal,probe,protocol]

theorem nonzero_diffusion_blocks_local_match (F : ℝ) (s : State) :
    materialGuardAB protocol (matchingChi protocol) s 1 1 ≠
      (rhs protocol F s).gAB := by
  have hd := (guard_diffusion_residual protocol F s (by norm_num [protocol])
    (by norm_num [protocol]) 1 1 0 0).1
  intro h
  rw [h] at hd
  norm_num at hd

theorem simultaneous_conditional_bridge (F : ℝ) (s : State) :
    FourRatesAgree protocol F s 0 0 0 0 0 0 0 0 ∧
    projectedGuardPower protocol 1000 1000 s = guardLoss protocol s := by
  constructor
  · exact (four_rates_agree_iff protocol F s (by norm_num [protocol])
      (by norm_num [protocol]) 0 0 0 0 0 0 0 0).mpr (by norm_num)
  · exact primary_power_matches s

end HugNavierBridge.Verified

#print axioms HugNavierBridge.Verified.shear_derivative
#print axioms HugNavierBridge.Verified.shear_contraction
#print axioms HugNavierBridge.Verified.nonzero_shear_not_periodic
#print axioms HugNavierBridge.Verified.strain_matching
#print axioms HugNavierBridge.Verified.argument_matching
#print axioms HugNavierBridge.Verified.guard_diffusion_residual
#print axioms HugNavierBridge.Verified.four_rates_agree_iff
#print axioms HugNavierBridge.Verified.power_matching
#print axioms HugNavierBridge.Verified.power_matching_necessary
#print axioms HugNavierBridge.Verified.primary_required_coefficients
#print axioms HugNavierBridge.Verified.primary_power_matches
#print axioms HugNavierBridge.Verified.same_number_chi_is_not_same_argument
#print axioms HugNavierBridge.Verified.nonzero_diffusion_blocks_local_match
#print axioms HugNavierBridge.Verified.simultaneous_conditional_bridge
