import OriginalASBalance

/-! Integration of the source-derived local kinetic balance.
The boundary-flux condition and differentiation under the integral are explicit
assumptions. This file does not claim to derive them from unspecified boundary
data or to prove existence of a PDE solution.
-/
set_option autoImplicit false
noncomputable section
open MeasureTheory
open scoped BigOperators
namespace OriginalAS.Energy

theorem integrate_zero_flux_balance {α : Type*} [MeasurableSpace α]
    (m : Measure α) (rate flux loss work : α → ℝ)
    (hr : Integrable rate m) (hf : Integrable flux m)
    (hl : Integrable loss m) (hw : Integrable work m)
    (hlocal : ∀ᵐ x ∂m, rate x + flux x = -loss x + work x)
    (hflux : ∫ x, flux x ∂m = 0) :
    (∫ x, rate x ∂m) = -(∫ x, loss x ∂m) + ∫ x, work x ∂m := by
  have he := integral_congr_ae hlocal
  rw [integral_add hr hf, integral_add (f := fun x => -loss x) hl.neg hw,
    integral_neg, hflux, add_zero] at he
  exact he

theorem kinetic_global_balance {n : ℕ}
    (p : Parameters) (response : ℝ → ℝ) (direction : Fin n)
    (U : ℝ → ℝ) (K : Scalar n) (x0 : Point n)
    (domain : Set (Point n)) (z : ℝ → Fields n) (pressure : ℝ → Scalar n)
    (t : ℝ) (m : Measure (Point n)) (hrho : p.rho ≠ 0)
    (heq : FullDifferentialAt p response direction U K x0 domain z pressure t)
    (hdom : ∀ᵐ x ∂m, x ∈ domain)
    (hu : ∀ x ∈ domain, ∀ i, SliceRegular (fun y => (z t).u y i) x)
    (hdu : ∀ x ∈ domain, ∀ i j, SliceRegular (coordinatePartial (fun y => (z t).u y i) j) x)
    (hp : ∀ x ∈ domain, SliceRegular (pressure t) x)
    (_hiEnergy : ∀ᶠ s in nhds t, Integrable (kinetic p.rho (z s).u) m)
    (hdt : HasDerivAt (fun s => ∫ x, kinetic p.rho (z s).u x ∂m)
      (∫ x, deriv (fun s => kinetic p.rho (z s).u x) t ∂m) t)
    (hiRate : Integrable (fun x => deriv (fun s => kinetic p.rho (z s).u x) t) m)
    (hiFlux : Integrable (kineticNetFlux p (z t).u (pressure t)) m)
    (hiGrad : Integrable (velocityGradSquared (z t).u) m)
    (hiPower : Integrable (hugPower p response direction (z t).u (z t).S) m)
    (hflux : ∫ x, kineticNetFlux p (z t).u (pressure t) x ∂m = 0) :
    HasDerivAt (fun s => ∫ x, kinetic p.rho (z s).u x ∂m)
      (-p.mu * (∫ x, velocityGradSquared (z t).u x ∂m) +
        ∫ x, hugPower p response direction (z t).u (z t).S x ∂m) t := by
  have hlocal : ∀ᵐ x ∂m,
      deriv (fun s => kinetic p.rho (z s).u x) t +
        kineticNetFlux p (z t).u (pressure t) x =
      -(p.mu * velocityGradSquared (z t).u x) +
        hugPower p response direction (z t).u (z t).S x := by
    filter_upwards [hdom] with x hx
    simpa only [neg_mul] using kinetic_local_balance p response direction U K x0
      domain z pressure t x hx hrho heq (hu x hx) (hdu x hx) (hp x hx)
  have hi := integrate_zero_flux_balance m _ _ _ _ hiRate hiFlux
    (hiGrad.const_mul p.mu) hiPower hlocal hflux
  rw [integral_const_mul, ← neg_mul] at hi
  rw [hi] at hdt
  exact hdt

end OriginalAS.Energy
