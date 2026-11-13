import FullCarrying

/-! Conditional gradient norm budgets and the initial-minimum obstruction.
No physical energy coefficient is chosen. These identities preserve the
original scalar dynamics; the spatial PDE transport/IBP assumptions remain
explicit in the accompanying report rather than asserted by this module. -/
set_option autoImplicit false
noncomputable section
open scoped BigOperators
namespace GradientStorage

def normStorage {n : ℕ} (c : ℝ) (g : Fin n → ℝ) : ℝ :=
  c/2 * ∑ i, (g i)^2

theorem norm_storage_rate {n : ℕ} (c : ℝ) (g : ℝ → Fin n → ℝ)
    (h : Fin n → ℝ) (t : ℝ)
    (hg : ∀ i, HasDerivAt (fun s => g s i) (h i) t) :
    HasDerivAt (fun s => normStorage c (g s)) (c*∑ i, g t i*h i) t := by
  have hs : HasDerivAt (fun s => ∑ i, (g s i)^2) (∑ i, 2*g t i*h i) t := by
    simpa [Pi.pow_apply] using
      HasDerivAt.fun_sum (u := Finset.univ) (fun i _ => (hg i).pow 2)
  have he : c*∑ i, g t i*h i = c/2*(∑ i, 2*g t i*h i) := by
    simp_rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i _
    ring
  rw [he]
  exact hs.const_mul (c/2)

theorem norm_storage_transport_rate {n : ℕ} (c : ℝ) (g : ℝ → Fin n → ℝ)
    (Q : Fin n → ℝ) (L : Fin n → Fin n → ℝ) (t : ℝ)
    (hg : ∀ i, HasDerivAt (fun s => g s i) (Q i-∑ j, L j i*g t j) t) :
    HasDerivAt (fun s => normStorage c (g s))
      (c*(∑ i, g t i*Q i) - c*(∑ i, ∑ j, g t i*L j i*g t j)) t := by
  have h := norm_storage_rate c g (fun i => Q i-∑ j, L j i*g t j) t hg
  rw [StorageRequirements.gradient_transport_contraction, mul_sub] at h
  exact h

theorem norm_storage_nonnegative {n : ℕ} (c : ℝ) (hc : 0 ≤ c) (g : Fin n → ℝ) :
    0 ≤ normStorage c g := by
  exact mul_nonneg (div_nonneg hc (by norm_num))
    (Finset.sum_nonneg (fun _ _ => sq_nonneg _))

theorem norm_storage_zero {n : ℕ} (c : ℝ) :
    normStorage c (fun _ : Fin n => 0) = 0 := by
  simp [normStorage]

/- A store whose initial state is a minimum cannot supply a positive net
   demand, irrespective of intermediate releases and replenishment. -/
theorem initial_minimum_cannot_pay (E0 E1 demand : ℝ)
    (hmin : E0 ≤ E1) (hd : 0 < demand) : E1-E0 ≠ -demand := by
  intro he
  linarith

theorem nonnegative_quadratic_cannot_pay {n : ℕ} (c demand : ℝ)
    (hc : 0 ≤ c) (hd : 0 < demand) (g : Fin n → ℝ) :
    normStorage c g-normStorage c (fun _ : Fin n => 0) ≠ -demand := by
  apply initial_minimum_cannot_pay
  · rw [norm_storage_zero]
    exact norm_storage_nonnegative c hc g
  · exact hd

/- Source and diffusion terms must both be retained when testing a candidate.
   Setting the diffusion contribution equal to the target alone is insufficient. -/
theorem integrated_norm_budget (change stretch diffusion source : ℝ)
    (hbalance : change = -stretch-diffusion+source) :
    diffusion = source-stretch-change := by
  linarith

end GradientStorage
