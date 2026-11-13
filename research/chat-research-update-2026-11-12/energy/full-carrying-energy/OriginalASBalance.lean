import OriginalASEnergy

/-! Conservative local energy balances for the original A/S--Navier branch.
Fluxes are kept as a sum of divergences, with identical coefficients to rates.
The scalar square is a variance budget, not an asserted physical stored energy.
-/
set_option autoImplicit false
noncomputable section
open scoped BigOperators
namespace OriginalAS.Energy
variable {n : ℕ}

theorem halfSquare_regular (f : Scalar n) (x : Point n) (h : SliceRegular f x) :
    SliceRegular (halfSquare f) x := by
  intro j
  exact (halfSquare_time_derivative _ _ _ (h j).hasDerivAt).differentiableAt

theorem kinetic_regular (rho : ℝ) (u : Vector n) (x : Point n)
    (h : ∀ i, SliceRegular (fun y => u y i) x) : SliceRegular (kinetic rho u) x := by
  intro j
  have hd := kinetic_time_derivative rho (fun a y i => u (Function.update y j a) i)
    (fun i => coordinatePartial (fun y => u y i) j x) (x j) x
    (fun i => (h i j).hasDerivAt)
  simpa only [kinetic, halfSquare] using hd.differentiableAt

theorem transport_flux (f : Scalar n) (u : Vector n) (x : Point n)
    (hf : SliceRegular f x) (hu : ∀ i, SliceRegular (fun y => u y i) x)
    (hdiv : divergence u x = 0) :
    divergence (fun y i => f y * u y i) x = advect u f x :=
  pressure_flux f u x hf hu hdiv

def kineticNetFlux (p : Parameters) (u : Vector n) (pressure : Scalar n)
    (x : Point n) : ℝ :=
    divergence (fun y j => kinetic p.rho u y * u y j) x +
    p.rho * divergence (fun y j => pressure y * u y j) x -
    p.mu * ∑ i, divergence (fun y j => u y i * coordinatePartial (fun w => u w i) j y) x

def scalarNetFlux (p : Parameters) (u : Vector n) (S : Scalar n)
    (x : Point n) : ℝ :=
    divergence (fun y j => halfSquare S y * u y j) x -
    p.diffusion * divergence (fun y j => S y * coordinatePartial S j y) x

theorem kinetic_local_balance
    (p : Parameters) (response : ℝ → ℝ) (direction : Fin n)
    (U : ℝ → ℝ) (K : Scalar n) (x0 : Point n)
    (domain : Set (Point n)) (z : ℝ → Fields n) (pressure : ℝ → Scalar n)
    (t : ℝ) (x : Point n) (hx : x ∈ domain) (hrho : p.rho ≠ 0)
    (heq : FullDifferentialAt p response direction U K x0 domain z pressure t)
    (hu : ∀ i, SliceRegular (fun y => (z t).u y i) x)
    (hdu : ∀ i j, SliceRegular (coordinatePartial (fun y => (z t).u y i) j) x)
    (hp : SliceRegular (pressure t) x) :
    deriv (fun s => kinetic p.rho (z s).u x) t +
      kineticNetFlux p (z t).u (pressure t) x =
      -p.mu * velocityGradSquared (z t).u x +
      hugPower p response direction (z t).u (z t).S x := by
  have hm := kinetic_material_balance p response direction U K x0 domain z pressure
    t x hx hrho heq hu
  have hd : (∑ i, divergence (fun y j => (z t).u y i *
        coordinatePartial (fun w => (z t).u w i) j y) x) =
      velocityGradSquared (z t).u x +
        ∑ i, (z t).u x i * laplacian (fun y => (z t).u y i) x := by
    simp_rw [diffusion_flux _ x (hu _) (hdu _)]
    rw [Finset.sum_add_distrib]
    rfl
  rw [kineticNetFlux, transport_flux _ _ x (kinetic_regular _ _ x hu) hu (heq x hx).1,
    pressure_flux _ _ x hp hu (heq x hx).1, hd]
  linarith

theorem scalar_local_balance
    (p : Parameters) (response : ℝ → ℝ) (direction : Fin n)
    (U : ℝ → ℝ) (K : Scalar n) (x0 : Point n)
    (domain : Set (Point n)) (z : ℝ → Fields n) (pressure : ℝ → Scalar n)
    (t : ℝ) (x : Point n) (hx : x ∈ domain)
    (heq : FullDifferentialAt p response direction U K x0 domain z pressure t)
    (hu : ∀ i, SliceRegular (fun y => (z t).u y i) x)
    (hS : SliceRegular (z t).S x)
    (hdS : ∀ j, SliceRegular (coordinatePartial (z t).S j) x) :
    deriv (fun s => halfSquare (z s).S x) t +
      scalarNetFlux p (z t).u (z t).S x =
      -p.diffusion * gradSquared (z t).S x +
      (z t).S x * K (x-x0) * sourceRate p U t := by
  have hm := scalar_material_balance p response direction U K x0 domain z pressure
    t x hx heq hS
  rw [scalarNetFlux, transport_flux _ _ x (halfSquare_regular _ x hS) hu (heq x hx).1,
    diffusion_flux _ x hS hdS]
  linarith

/- The original integral memory, with the same continuous-input hypothesis as
   OriginalAS.Verified.original_memory_derivative in the preserved FullChecks. -/
theorem memory_derivative (p : Parameters) (U : ℝ → ℝ)
    (hU : Continuous U) (t : ℝ) :
    HasDerivAt (memory p U) (p.gamma * (U t-p.baseline)) t := by
  have hc : Continuous (fun s => p.gamma*(U s-p.baseline)) :=
    continuous_const.mul (hU.sub continuous_const)
  exact intervalIntegral.integral_hasDerivAt_right (hc.intervalIntegrable 0 t)
    hc.aestronglyMeasurable.stronglyMeasurableAtFilter hc.continuousAt

theorem memory_square_balance (p : Parameters) (U : ℝ → ℝ)
    (hU : Continuous U) (t : ℝ) :
    HasDerivAt (fun s => (memory p U s)^2/2)
      (memory p U t * p.gamma * (U t-p.baseline)) t := by
  convert halfSquare_time_derivative _ _ _ (memory_derivative p U hU t) using 1
  ring

theorem memory_at_baseline (p : Parameters) (t : ℝ) :
    memory p (fun _ => p.baseline) t = 0 := by
  simp [memory]

theorem source_at_baseline (p : Parameters) (t : ℝ) :
    sourceRate p (fun _ => p.baseline) t = 0 := by
  simp [sourceRate, memory_at_baseline]

theorem sharp_power_off (p : Parameters) (direction : Fin n)
    (u : Vector n) (S : Scalar n) (x : Point n) (h : excess p S x ≤ 0) :
    hugPower p sharp direction u S x = 0 := by
  simp [hugPower, sharp, max_eq_right h]

/- A negative velocity component produces positive coupling work whenever the
   sharp response is active. This is a local conditional statement, not a
   constructed PDE solution or a global kinetic-energy growth theorem. -/
theorem sharp_power_positive (p : Parameters) (direction : Fin n)
    (u : Vector n) (S : Scalar n) (x : Point n)
    (hs : 0 < p.sigma) (hq : 0 < excess p S x) (hu : u x direction < 0) :
    0 < hugPower p sharp direction u S x := by
  apply hugPower_pos p sharp direction u S x hs _ hu
  simpa [sharp, max_eq_left (le_of_lt hq)] using hq

end OriginalAS.Energy
