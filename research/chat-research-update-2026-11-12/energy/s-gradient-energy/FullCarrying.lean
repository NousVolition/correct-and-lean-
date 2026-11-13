import StorageRequirements

/-! Full configuration constrains the activation history.
These finite-dimensional identities are conditional on the smooth flow and
gradient transport rates. They do not assert that the PDE commutator, numerical
solver, or a new gravitational energy law has been proved. -/
set_option autoImplicit false
noncomputable section
open scoped BigOperators
namespace FullCarrying

def pullback {n : ℕ} (F : Fin n → Fin n → ℝ) (g : Fin n → ℝ) (j : Fin n) : ℝ :=
  ∑ i, F i j*g i

theorem pullback_rate_algebra {n : ℕ} (F L : Fin n → Fin n → ℝ)
    (g Q : Fin n → ℝ) (j : Fin n) :
    (∑ i, ((∑ k, L i k*F k j)*g i + F i j*(Q i-∑ k, L k i*g k))) =
      ∑ i, F i j*Q i := by
  have hc : (∑ i, (∑ k, L i k*F k j)*g i) = ∑ i, F i j*(∑ k, L k i*g k) := by
    simp_rw [Finset.sum_mul, Finset.mul_sum]
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro i _
    apply Finset.sum_congr rfl
    intro k _
    ring
  simp_rw [mul_sub, Finset.sum_add_distrib, Finset.sum_sub_distrib]
  rw [hc]
  ring

theorem carried_gradient_rate {n : ℕ} (F : ℝ → Fin n → Fin n → ℝ)
    (g : ℝ → Fin n → ℝ) (L : Fin n → Fin n → ℝ) (Q : Fin n → ℝ) (t : ℝ)
    (hF : ∀ i j, HasDerivAt (fun s => F s i j) (∑ k, L i k*F t k j) t)
    (hg : ∀ i, HasDerivAt (fun s => g s i) (Q i-∑ k, L k i*g t k) t) (j : Fin n) :
    HasDerivAt (fun s => pullback (F s) (g s) j) (∑ i, F t i j*Q i) t := by
  have h := HasDerivAt.fun_sum (u := Finset.univ)
    (fun i _ => (hF i j).fun_mul (hg i))
  have ht : HasDerivAt (fun s => pullback (F s) (g s) j)
      (∑ i, ((∑ k, L i k*F t k j)*g t i + F t i j*(Q i-∑ k, L k i*g t k))) t := by
    simpa only [pullback] using h
  rw [pullback_rate_algebra] at ht
  exact ht

/- R is the inverse transpose of F, stated by its exact contraction identity. -/
theorem recover_spatial_gradient {n : ℕ} (F R : Fin n → Fin n → ℝ)
    (g : Fin n → ℝ) (hinv : ∀ i k, (∑ j, R i j*F k j) = if i=k then 1 else 0)
    (i : Fin n) : (∑ j, R i j*pullback F g j) = g i := by
  simp only [pullback, Finset.mul_sum]
  simp_rw [← mul_assoc]
  rw [Finset.sum_comm]
  simp_rw [← Finset.sum_mul, hinv]
  simp

/- A history identity following from the independently supplied rate; it is
not an energy ledger and contains no kinetic work. -/
theorem carried_gradient_history (G rate : ℝ → ℝ)
    (hr : Continuous rate) (hG : ∀ t, HasDerivAt G (rate t) t) (t : ℝ) :
    G t = G 0 + OriginalAS.Energy.Accounting.cumulative rate t := by
  have hd : ∀ s, HasDerivAt
      (fun r => G r-OriginalAS.Energy.Accounting.cumulative rate r) 0 s := by
    intro s
    convert (hG s).fun_sub (OriginalAS.Energy.Accounting.cumulative_derivative rate hr s) using 1 <;>
      first | rfl | ring
  have hc := is_const_of_deriv_eq_zero (fun s => (hd s).differentiableAt)
    (fun s => (hd s).deriv) t 0
  simp only [OriginalAS.Energy.Accounting.cumulative, intervalIntegral.integral_same, sub_zero] at hc
  change G t - (∫ r in 0..t, rate r) = G 0 at hc
  dsimp [OriginalAS.Energy.Accounting.cumulative]
  linarith

/- With h = sigma * displacement * response' / |g|, the first term is
the required anisotropic stress contraction and the second is the source /
diffusion contribution. No opposite transfer is assumed to exist. -/
theorem required_transfer_split {n : ℕ} (g Q : Fin n → ℝ)
    (L : Fin n → Fin n → ℝ) (h : ℝ) :
    h*(∑ i, g i*(Q i-∑ j, L j i*g j)) =
      (∑ i, ∑ j, (-h*g i*g j)*L j i) + h*(∑ i, g i*Q i) := by
  rw [StorageRequirements.gradient_transport_contraction]
  simp_rw [mul_sub, Finset.mul_sum]
  have he : (∑ i, ∑ j, (-h*g i*g j)*L j i) = -(∑ i, ∑ j, h*(g i*L j i*g j)) := by
    simp_rw [← Finset.sum_neg_distrib]
    apply Finset.sum_congr rfl
    intro i _
    apply Finset.sum_congr rfl
    intro j _
    ring
  rw [he]
  ring

/- Existing material and heat transfers cancel internally even when their
rates depend on the entire joint history. That dependence does not add an
extra debit to this balance. -/
theorem complete_existing_transfers (K W H V : ℝ → ℝ)
    (d stress write release p remainder t : ℝ)
    (hK : HasDerivAt K (-d-stress+p) t)
    (hW : HasDerivAt W (stress+write-release) t)
    (hH : HasDerivAt H (d-write+release) t)
    (hV : HasDerivAt V (-p+remainder) t) :
    HasDerivAt (fun s => K s+W s+H s+V s) remainder t := by
  convert ((hK.fun_add hW).fun_add hH).fun_add hV using 1 <;> first | rfl | ring

end FullCarrying
