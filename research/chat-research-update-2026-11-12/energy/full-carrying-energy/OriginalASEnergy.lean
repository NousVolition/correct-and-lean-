import OriginalAS

/-! Energy identities for the preserved original A/S--Navier equations.
No breathing drive, guard closure, fabric law, or new force is added.
The pressure in OriginalAS is kinematic pressure: its energy flux is rho*p*u.
All claims below are conditional on the explicitly stated differentiability.
-/
set_option autoImplicit false
noncomputable section
open scoped BigOperators

namespace OriginalAS.Energy

variable {n : ℕ}

def SliceRegular (f : Scalar n) (x : Point n) : Prop :=
  ∀ j, DifferentiableAt ℝ (fun a => f (Function.update x j a)) (x j)

def halfSquare (f : Scalar n) : Scalar n := fun x => (f x)^2 / 2

def kinetic (rho : ℝ) (u : Vector n) : Scalar n :=
  fun x => rho * ∑ i, halfSquare (fun y => u y i) x

def gradSquared (f : Scalar n) (x : Point n) : ℝ :=
  ∑ j, (coordinatePartial f j x)^2

def velocityGradSquared (u : Vector n) (x : Point n) : ℝ :=
  ∑ i, gradSquared (fun y => u y i) x

def hugPower (p : Parameters) (response : ℝ → ℝ) (direction : Fin n)
    (u : Vector n) (S : Scalar n) (x : Point n) : ℝ :=
  -p.sigma * response (excess p S x) * u x direction

theorem halfSquare_time_derivative (f : ℝ → ℝ) (v t : ℝ)
    (h : HasDerivAt f v t) :
    HasDerivAt (fun s => (f s)^2 / 2) (f t * v) t := by
  convert (h.pow 2).div_const 2 using 1 <;> first | rfl | ring

theorem halfSquare_partial (f : Scalar n) (x : Point n)
    (h : SliceRegular f x) (j : Fin n) :
    coordinatePartial (halfSquare f) j x = f x * coordinatePartial f j x := by
  have hd := halfSquare_time_derivative _ _ _ (h j).hasDerivAt
  simpa [coordinatePartial, halfSquare] using hd.deriv

theorem halfSquare_advection (u : Vector n) (f : Scalar n) (x : Point n)
    (h : SliceRegular f x) :
    advect u (halfSquare f) x = f x * advect u f x := by
  simp only [advect, halfSquare_partial f x h, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _
  ring

theorem kinetic_time_derivative (rho : ℝ) (u : ℝ → Vector n)
    (v : Fin n → ℝ) (t : ℝ) (x : Point n)
    (h : ∀ i, HasDerivAt (fun s => u s x i) (v i) t) :
    HasDerivAt (fun s => kinetic rho (u s) x)
      (rho * ∑ i, u t x i * v i) t := by
  exact (HasDerivAt.fun_sum (fun i _ => halfSquare_time_derivative _ _ _ (h i))).const_mul rho

theorem kinetic_partial (rho : ℝ) (u : Vector n) (x : Point n)
    (h : ∀ i, SliceRegular (fun y => u y i) x) (j : Fin n) :
    coordinatePartial (kinetic rho u) j x =
      rho * ∑ i, u x i * coordinatePartial (fun y => u y i) j x := by
  have hd := kinetic_time_derivative rho (fun a y i => u (Function.update y j a) i)
    (fun i => coordinatePartial (fun y => u y i) j x) (x j) x
    (fun i => (h i j).hasDerivAt)
  simpa [coordinatePartial, kinetic, halfSquare] using hd.deriv

theorem kinetic_advection (rho : ℝ) (u : Vector n) (x : Point n)
    (h : ∀ i, SliceRegular (fun y => u y i) x) :
    advect u (kinetic rho u) x =
      rho * ∑ i, u x i * advect u (fun y => u y i) x := by
  simp only [advect, kinetic_partial rho u x h, Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro j _
  ring

theorem force_power (p : Parameters) (response : ℝ → ℝ) (direction : Fin n)
    (u : Vector n) (S : Scalar n) (x : Point n) (hrho : p.rho ≠ 0) :
    p.rho * ∑ i, u x i * force p response direction S x i =
      hugPower p response direction u S x := by
  simp [force, hugPower, mul_ite]
  field_simp

theorem kinetic_material_balance
    (p : Parameters) (response : ℝ → ℝ) (direction : Fin n)
    (U : ℝ → ℝ) (K : Scalar n) (x0 : Point n)
    (domain : Set (Point n)) (z : ℝ → Fields n) (pressure : ℝ → Scalar n)
    (t : ℝ) (x : Point n) (hx : x ∈ domain) (hrho : p.rho ≠ 0)
    (heq : FullDifferentialAt p response direction U K x0 domain z pressure t)
    (hu : ∀ i, SliceRegular (fun y => (z t).u y i) x) :
    deriv (fun s => kinetic p.rho (z s).u x) t +
      advect (z t).u (kinetic p.rho (z t).u) x =
      -p.rho * ∑ i, (z t).u x i * coordinatePartial (pressure t) i x +
      p.mu * ∑ i, (z t).u x i * laplacian (fun y => (z t).u y i) x +
      hugPower p response direction (z t).u (z t).S x := by
  rw [(kinetic_time_derivative p.rho (fun s => (z s).u) _ t x
    (heq x hx).2.2).deriv, kinetic_advection p.rho (z t).u x hu]
  rw [← force_power p response direction (z t).u (z t).S x hrho]
  simp only [Finset.mul_sum, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i _
  dsimp only [rates]
  field_simp
  ring

theorem scalar_material_balance
    (p : Parameters) (response : ℝ → ℝ) (direction : Fin n)
    (U : ℝ → ℝ) (K : Scalar n) (x0 : Point n)
    (domain : Set (Point n)) (z : ℝ → Fields n) (pressure : ℝ → Scalar n)
    (t : ℝ) (x : Point n) (hx : x ∈ domain)
    (heq : FullDifferentialAt p response direction U K x0 domain z pressure t)
    (hS : SliceRegular (z t).S x) :
    deriv (fun s => halfSquare (z s).S x) t +
      advect (z t).u (halfSquare (z t).S) x =
      p.diffusion * (z t).S x * laplacian (z t).S x +
      (z t).S x * K (x-x0) * sourceRate p U t := by
  have hd : deriv (fun s => halfSquare (z s).S x) t =
      (z t).S x * (rates p response direction U K x0 t (z t) (pressure t)).S x := by
    simpa only [halfSquare] using (halfSquare_time_derivative _ _ _ (heq x hx).2.1).deriv
  rw [hd,
    halfSquare_advection (z t).u (z t).S x hS]
  simp only [rates]
  ring

/- Spatial product rules expose the actual energy flux and dissipation. -/
theorem partial_mul (f g : Scalar n) (x : Point n)
    (hf : SliceRegular f x) (hg : SliceRegular g x) (j : Fin n) :
    coordinatePartial (fun y => f y * g y) j x =
      coordinatePartial f j x * g x + f x * coordinatePartial g j x := by
  simpa [coordinatePartial] using ((hf j).hasDerivAt.fun_mul (hg j).hasDerivAt).deriv

theorem pressure_flux (q : Scalar n) (u : Vector n) (x : Point n)
    (hq : SliceRegular q x) (hu : ∀ i, SliceRegular (fun y => u y i) x)
    (hdiv : divergence u x = 0) :
    divergence (fun y i => q y * u y i) x =
      ∑ i, u x i * coordinatePartial q i x := by
  simp only [divergence, partial_mul q _ x hq (hu _),
    Finset.sum_add_distrib, ← Finset.mul_sum]
  change (∑ i, coordinatePartial q i x * u x i) + q x * divergence u x = _
  rw [hdiv]
  simp [mul_comm]

theorem diffusion_flux (f : Scalar n) (x : Point n)
    (hf : SliceRegular f x)
    (hg : ∀ j, SliceRegular (coordinatePartial f j) x) :
    divergence (fun y j => f y * coordinatePartial f j y) x =
      gradSquared f x + f x * laplacian f x := by
  simp only [divergence, partial_mul f _ x hf (hg _),
    Finset.sum_add_distrib, ← Finset.mul_sum, gradSquared, laplacian, pow_two]

theorem gradSquared_nonneg (f : Scalar n) (x : Point n) : 0 ≤ gradSquared f x := by
  exact Finset.sum_nonneg (fun _ _ => sq_nonneg _)

theorem viscous_loss_nonneg (p : Parameters) (u : Vector n) (x : Point n)
    (hmu : 0 ≤ p.mu) : 0 ≤ p.mu * velocityGradSquared u x := by
  exact mul_nonneg hmu (Finset.sum_nonneg (fun _ _ => gradSquared_nonneg _ _))

theorem hugPower_nonpos (p : Parameters) (response : ℝ → ℝ) (direction : Fin n)
    (u : Vector n) (S : Scalar n) (x : Point n)
    (hs : 0 ≤ p.sigma) (ha : 0 ≤ response (excess p S x))
    (hu : 0 ≤ u x direction) : hugPower p response direction u S x ≤ 0 := by
  exact mul_nonpos_of_nonpos_of_nonneg (mul_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr hs) ha) hu

theorem hugPower_pos (p : Parameters) (response : ℝ → ℝ) (direction : Fin n)
    (u : Vector n) (S : Scalar n) (x : Point n)
    (hs : 0 < p.sigma) (ha : 0 < response (excess p S x))
    (hu : u x direction < 0) : 0 < hugPower p response direction u S x := by
  exact mul_pos_of_neg_of_neg (mul_neg_of_neg_of_pos (neg_neg_of_pos hs) ha) hu

end OriginalAS.Energy
