import Mathlib

/-! The canonical potential of the older, added paired-context alignment law.
The finite chain rule includes changing pair weights and changing sampled
contexts. It does not assert a physical energy identification, a PDE solution,
or a constitutive law for an additional configuration/history-only term. -/
set_option autoImplicit false
noncomputable section
open scoped BigOperators
namespace PairContext

def potential {n : ℕ} (k B : ℝ) (V a c : Fin n → ℝ)
    (partner : Fin n → Fin n) : ℝ :=
  k * B^2 / 2 * ∑ p, V p * a p *
    Real.log (Real.cosh ((c (partner p) - c p) / B))

theorem log_cosh_rate (z : ℝ) :
    HasDerivAt (fun x : ℝ => Real.log (Real.cosh x)) (Real.tanh z) z := by
  simpa [Real.tanh_eq_sinh_div_cosh] using
    (Real.hasDerivAt_cosh z).log (ne_of_gt (Real.cosh_pos z))

theorem potential_nonnegative {n : ℕ} (k B : ℝ) (V a c : Fin n → ℝ)
    (partner : Fin n → Fin n) (hk : 0 ≤ k)
    (hV : ∀ p, 0 ≤ V p) (ha : ∀ p, 0 ≤ a p) :
    0 ≤ potential k B V a c partner := by
  apply mul_nonneg (div_nonneg (mul_nonneg hk (sq_nonneg B)) (by norm_num))
  apply Finset.sum_nonneg
  intro p _
  exact mul_nonneg (mul_nonneg (hV p) (ha p))
    (Real.log_nonneg (Real.one_le_cosh _))

theorem potential_zero {n : ℕ} (k B : ℝ) (V a : Fin n → ℝ)
    (partner : Fin n → Fin n) :
    potential k B V a (fun _ => 0) partner = 0 := by
  simp [potential]

/- This is the full directed-pair chain rule; c may include motion of the
sampling kernel, so c' is not silently replaced with sampling of C'. -/
theorem moving_potential_rate {n : ℕ} (k B : ℝ) (V : Fin n → ℝ)
    (a c : ℝ → Fin n → ℝ) (adot cdot : Fin n → ℝ)
    (partner : Fin n → Fin n) (t : ℝ)
    (ha : ∀ p, HasDerivAt (fun s => a s p) (adot p) t)
    (hc : ∀ p, HasDerivAt (fun s => c s p) (cdot p) t) :
    HasDerivAt (fun s => potential k B V (a s) (c s) partner)
      (k * B^2 / 2 * ∑ p, V p *
        (adot p * Real.log (Real.cosh ((c t (partner p) - c t p) / B)) +
         a t p * Real.tanh ((c t (partner p) - c t p) / B) *
           ((cdot (partner p) - cdot p) / B))) t := by
  have hp (p : Fin n) : HasDerivAt
      (fun s => V p * a s p * Real.log (Real.cosh ((c s (partner p) - c s p) / B)))
      (V p * (adot p * Real.log (Real.cosh ((c t (partner p) - c t p) / B)) +
       a t p * Real.tanh ((c t (partner p) - c t p) / B) *
        ((cdot (partner p) - cdot p) / B))) t := by
    have hdiff : HasDerivAt (fun s => (c s (partner p) - c s p) / B)
        ((cdot (partner p) - cdot p) / B) t :=
      ((hc (partner p)).sub (hc p)).div_const B
    have hlog := hdiff.cosh.log
      (ne_of_gt (Real.cosh_pos ((c t (partner p) - c t p) / B)))
    have hd : HasDerivAt
        (fun s => Real.log (Real.cosh ((c s (partner p) - c s p) / B)))
        (Real.tanh ((c t (partner p) - c t p) / B) *
          ((cdot (partner p) - cdot p) / B)) t := by
      apply hlog.congr_deriv
      rw [Real.tanh_eq_sinh_div_cosh]
      ring
    apply (((ha p).const_mul (V p)).mul hd).congr_deriv
    ring
  exact (HasDerivAt.fun_sum (u := Finset.univ) (fun p _ => hp p)).const_mul (k * B^2 / 2)

/- Changing geometry/history can change a and c arbitrarily between endpoints.
A nonnegative conversion to energy units and a constant reference offset
cannot make this particular potential release energy from zero context. -/
theorem zero_context_cannot_pay {n : ℕ} (k B scale offset demand : ℝ)
    (V a0 a1 c1 : Fin n → ℝ) (partner : Fin n → Fin n)
    (hk : 0 ≤ k) (hs : 0 ≤ scale) (hd : 0 < demand)
    (hV : ∀ p, 0 ≤ V p) (ha1 : ∀ p, 0 ≤ a1 p) :
    (scale * potential k B V a1 c1 partner + offset) -
    (scale * potential k B V a0 (fun _ => 0) partner + offset) ≠ -demand := by
  rw [potential_zero]
  have hn := mul_nonneg hs (potential_nonnegative k B V a1 c1 partner hk hV ha1)
  intro he
  linarith

end PairContext
