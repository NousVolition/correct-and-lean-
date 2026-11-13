import OriginalASIntegrated

/-! Stress power for the stress already written in OriginalAS.
Its coefficient is mu0. Identifying its bulk heating with the mu-Laplacian
kinetic loss requires the coefficient match and a vanishing cross integral.
Neither is silently inserted into the source equations.
-/
set_option autoImplicit false
noncomputable section
open scoped BigOperators
open MeasureTheory
namespace OriginalAS.Energy.Heat
variable {n : ℕ}

def strainSquared (u : Vector n) (x : Point n) : ℝ :=
  ∑ i, ∑ j, ((coordinatePartial (fun y => u y i) j x +
    coordinatePartial (fun y => u y j) i x)/2)^2

def crossGradient (u : Vector n) (x : Point n) : ℝ :=
  ∑ i, ∑ j, coordinatePartial (fun y => u y i) j x *
    coordinatePartial (fun y => u y j) i x

def sourceStressPower (p : Parameters) (u : Vector n) (x : Point n) : ℝ :=
  ∑ i, ∑ j, stress p u x i j * coordinatePartial (fun y => u y i) j x

theorem source_stress_decomposition (p : Parameters) (u : Vector n) (x : Point n) :
    sourceStressPower p u x =
      p.mu0 * (velocityGradSquared u x + crossGradient u x) := by
  unfold sourceStressPower velocityGradSquared gradSquared crossGradient stress
  simp only [Finset.mul_sum, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro j _
  ring

theorem strain_identity (u : Vector n) (x : Point n) :
    2 * strainSquared u x = velocityGradSquared u x + crossGradient u x := by
  let a := fun i j => coordinatePartial (fun y => u y i) j x
  have hswap : (∑ i, ∑ j, (a j i)^2) = ∑ i, ∑ j, (a i j)^2 := Finset.sum_comm
  change 2 * (∑ i, ∑ j, ((a i j + a j i)/2)^2) =
    (∑ i, ∑ j, (a i j)^2) + ∑ i, ∑ j, a i j * a j i
  calc
    _ = ∑ i, ∑ j, ((a i j)^2/2 + (a j i)^2/2 + a i j*a j i) := by
      simp only [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro i _
      apply Finset.sum_congr rfl
      intro j _
      ring
    _ = _ := by
      simp only [Finset.sum_add_distrib, ← Finset.sum_div]
      rw [hswap]
      ring

theorem source_stress_is_strain_heat (p : Parameters) (u : Vector n) (x : Point n) :
    sourceStressPower p u x = 2*p.mu0*strainSquared u x := by
  rw [source_stress_decomposition, ← strain_identity]
  ring

theorem source_heat_nonnegative (p : Parameters) (u : Vector n) (x : Point n)
    (h : 0 ≤ p.mu0) : 0 ≤ sourceStressPower p u x := by
  rw [source_stress_is_strain_heat]
  apply mul_nonneg (mul_nonneg (by norm_num) h)
  exact Finset.sum_nonneg (fun _ _ => Finset.sum_nonneg (fun _ _ => sq_nonneg _))

theorem bulk_heat_matches_kinetic_loss (p : Parameters) (u : Vector n)
    (m : Measure (Point n))
    (hg : Integrable (velocityGradSquared u) m)
    (hc : Integrable (crossGradient u) m)
    (hcoeff : p.mu0 = p.mu) (hcross : ∫ x, crossGradient u x ∂m = 0) :
    (∫ x, sourceStressPower p u x ∂m) = p.mu * ∫ x, velocityGradSquared u x ∂m := by
  simp_rw [source_stress_decomposition]
  rw [integral_const_mul, integral_add hg hc, hcross, add_zero, hcoeff]

end OriginalAS.Energy.Heat
