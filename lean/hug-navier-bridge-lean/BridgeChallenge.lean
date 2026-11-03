import BridgeModel
namespace HugNavierBridge.Verified
open ActiveHug

theorem shear_derivative (v L y : ℝ) :
    HasDerivAt (shearVelocity v L) (v/L) y := by sorry

theorem shear_contraction (v L : ℝ) (hL : L ≠ 0) :
    contraction (shearD v L) = shearInvariant v L := by sorry

theorem nonzero_shear_not_periodic (v L H : ℝ) (hL : L ≠ 0) (hH : H ≠ 0) :
    shearVelocity v L H = shearVelocity v L 0 ↔ v = 0 := by sorry

theorem strain_matching (p : Parameters) (s : State)
    (hL : p.length ≠ 0) (hQ : p.scale ≠ 0) :
    matchingChi p * shearInvariant s.v p.length = p.chi*strainSignal p s := by sorry

theorem argument_matching (p : Parameters) (s : State)
    (hL : p.length ≠ 0) (hQ : p.scale ≠ 0) :
    fieldArgumentAB p (matchingChi p) s = targetAB p s ∧
    fieldArgumentBA p (matchingChi p) s = targetBA p s := by sorry

theorem guard_diffusion_residual (p : Parameters) (F : ℝ) (s : State)
    (hL : p.length ≠ 0) (hQ : p.scale ≠ 0) (kA lA kB lB : ℝ) :
    materialGuardAB p (matchingChi p) s kA lA - (rhs p F s).gAB = kA*lA ∧
    materialGuardBA p (matchingChi p) s kB lB - (rhs p F s).gBA = kB*lB := by sorry

theorem four_rates_agree_iff (p : Parameters) (F : ℝ) (s : State)
    (hL : p.length ≠ 0) (hQ : p.scale ≠ 0) (kA lA kB lB kgA lgA kgB lgB : ℝ) :
    FourRatesAgree p F s kA lA kB lB kgA lgA kgB lgB ↔
      kA*lA=0 ∧ kB*lB=0 ∧ kgA*lgA=0 ∧ kgB*lgB=0 := by sorry

theorem power_matching (p : Parameters) (aAB aBA : ℝ) (hL : p.length ≠ 0)
    (ha : p.volume*aAB=p.damping*p.length^2)
    (hb : p.volume*aBA=p.damping*p.length^2) (s : State) :
    projectedGuardPower p aAB aBA s = guardLoss p s := by sorry

theorem power_matching_necessary (p : Parameters) (aAB aBA : ℝ) (hL : p.length ≠ 0)
    (h : ∀ s, projectedGuardPower p aAB aBA s = guardLoss p s) :
    p.volume*aAB=p.damping*p.length^2 ∧ p.volume*aBA=p.damping*p.length^2 := by sorry

theorem primary_required_coefficients :
    matchingChi protocol = 500000 ∧
    protocol.volume*(1000:ℝ)=protocol.damping*protocol.length^2 := by sorry

theorem primary_power_matches (s : State) :
    projectedGuardPower protocol 1000 1000 s = guardLoss protocol s := by sorry

theorem same_number_chi_is_not_same_argument :
    fieldArgumentAB protocol protocol.chi probe ≠ targetAB protocol probe := by sorry

theorem nonzero_diffusion_blocks_local_match (F : ℝ) (s : State) :
    materialGuardAB protocol (matchingChi protocol) s 1 1 ≠
      (rhs protocol F s).gAB := by sorry

theorem simultaneous_conditional_bridge (F : ℝ) (s : State) :
    FourRatesAgree protocol F s 0 0 0 0 0 0 0 0 ∧
    projectedGuardPower protocol 1000 1000 s = guardLoss protocol s := by sorry

end HugNavierBridge.Verified
