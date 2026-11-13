import Volterra
import ASModel
import Mathlib.MeasureTheory.SpecificCodomains.Pi

open Set MeasureTheory intervalIntegral
open scoped NNReal
namespace SocialAS.Existence
abbrev Pair := Fin 2 → ℝ

theorem intervalIntegrable_fin_iff {n : ℕ} {f : ℝ → Fin n → ℝ} {a b : ℝ} :
    IntervalIntegrable f volume a b ↔ ∀ j, IntervalIntegrable (fun t => f t j) volume a b := by
  constructor
  · intro h j
    exact ⟨h.1.eval j,h.2.eval j⟩
  · intro h
    exact ⟨Integrable.of_eval (fun j => (h j).1),Integrable.of_eval (fun j => (h j).2)⟩

theorem integral_fin_apply {n : ℕ} {f : ℝ → Fin n → ℝ} {a b : ℝ}
    (hf : IntervalIntegrable f volume a b) (j : Fin n) :
    (∫ t in a..b, f t) j = ∫ t in a..b, f t j :=
  ((ContinuousLinearMap.proj (R := ℝ) j).intervalIntegral_comp_comm hf).symm

theorem coord_equation {n : ℕ} {F : ℝ → (Fin n → ℝ) → Fin n → ℝ}
    {a b : ℝ} {initial : Fin n → ℝ} {x : ℝ → Fin n → ℝ}
    (hab : a ≤ b) (hx : Volterra.Solution F a b initial x)
    (t : ℝ) (ht : t ∈ Icc a b) (j : Fin n) :
    x t j = initial j + ∫ s in a..t, F s (x s) j := by
  have hint := hx.2.2.1.mono_set (show uIcc a t ⊆ uIcc a b by
    rw [uIcc_of_le hab]; exact uIcc_subset_Icc ⟨le_rfl,hab⟩ ht)
  have h := congrArg (fun v : Fin n → ℝ => v j) (hx.2.2.2 t ht)
  change x t j = initial j + (∫ s in a..t, F s (x s)) j at h
  rw [integral_fin_apply hint] at h
  exact h

theorem solution_of_coordinates {n : ℕ} {F : ℝ → (Fin n → ℝ) → Fin n → ℝ}
    {a b : ℝ} {initial : Fin n → ℝ} {x : ℝ → Fin n → ℝ}
    (hab : a ≤ b) (hcont : ContinuousOn x (Icc a b)) (hinit : x a = initial)
    (hint : ∀ j, IntervalIntegrable (fun t => F t (x t) j) volume a b)
    (heq : ∀ t ∈ Icc a b, ∀ j, x t j = initial j + ∫ s in a..t, F s (x s) j) :
    Volterra.Solution F a b initial x := by
  have hall := intervalIntegrable_fin_iff.mpr hint
  refine ⟨hcont,hinit,hall,?_⟩
  intro t ht
  funext j
  change x t j = initial j + (∫ s in a..t, F s (x s)) j
  rw [integral_fin_apply (hall.mono_set (show uIcc a t ⊆ uIcc a b by
    rw [uIcc_of_le hab]; exact uIcc_subset_Icc ⟨le_rfl,hab⟩ ht))]
  exact heq t ht j

theorem abs_exchange_sub (w chi x y : ℝ) (hc : UnitInterval chi) :
    |exchange w chi x - exchange w chi y| ≤ 2*|w| * |x-y| := by
  have hmax : |pos x-pos y| ≤ |x-y| := by
    have h := (LipschitzWith.id.max_const (0:ℝ)).dist_le_mul x y
    simpa [pos,Real.dist_eq] using h
  have heq : exchange w chi x-exchange w chi y = w*((x-y)-chi*(pos x-pos y)) := by
    unfold exchange
    ring
  rw [heq,abs_mul]
  have htri := abs_sub (x-y) (chi*(pos x-pos y))
  rw [abs_mul,abs_of_nonneg hc.1] at htri
  have hp := mul_le_mul_of_nonneg_left hmax hc.1
  have hp' := mul_le_mul_of_nonneg_right hc.2 (abs_nonneg (x-y))
  have hb : |(x-y)-chi*(pos x-pos y)| ≤ 2*|x-y| := by linarith
  nlinarith [mul_le_mul_of_nonneg_left hb (abs_nonneg w)]

theorem abs_gap_sub (x y : Pair) (i j : Fin 2) :
    |(x i-x j)-(y i-y j)| ≤ 2*dist x y := by
  have hi : |x i-y i| ≤ dist x y := dist_le_pi_dist x y i
  have hj : |x j-y j| ≤ dist x y := dist_le_pi_dist x y j
  have heq : (x i-x j)-(y i-y j) = (x i-y i)-(x j-y j) := by ring
  rw [heq]
  exact (abs_sub _ _).trans (by linarith)

end SocialAS.Existence
