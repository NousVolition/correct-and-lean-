import FrozenField
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Topology.Algebra.Module.ContinuousLinearMap.PiProd

namespace FrozenMatrixBounds
open FrozenField
open scoped BigOperators

abbrev Matrix3 := Fin 3 → Fin 3 → ℝ

noncomputable def unit (i j : Fin 3) : Point →L[ℝ] Point :=
  (ContinuousLinearMap.single ℝ (fun _ : Fin 3 => ℝ) i).comp (ContinuousLinearMap.proj j)

noncomputable def operator (M : Matrix3) : Point →L[ℝ] Point :=
  ∑ i : Fin 3, ∑ j : Fin 3, M i j • unit i j

theorem unit_apply (i j : Fin 3) (v : Point) (k : Fin 3) :
    unit i j v k = if k = i then v j else 0 := by
  simp [unit, Pi.single_apply, eq_comm]

theorem operator_apply (M : Matrix3) (v : Point) (i : Fin 3) :
    operator M v i = ∑ j : Fin 3, M i j * v j := by
  simp [operator, Finset.sum_apply, unit_apply, smul_eq_mul]

theorem norm_operator_le (M : Matrix3) {r : ℝ} (hr : 0 ≤ r)
    (hrow : ∀ i : Fin 3, (∑ j : Fin 3, |M i j|) ≤ r) : ‖operator M‖ ≤ r := by
  apply (operator M).opNorm_le_bound hr
  intro v
  apply (pi_norm_le_iff_of_nonneg (mul_nonneg hr (norm_nonneg v))).mpr
  intro i
  rw [Real.norm_eq_abs, operator_apply]
  calc
    _ ≤ ∑ j : Fin 3, |M i j * v j| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ j : Fin 3, |M i j| * ‖v‖ := by
      apply Finset.sum_le_sum
      intro j hj
      rw [abs_mul]
      apply mul_le_mul_of_nonneg_left _ (abs_nonneg _)
      simpa only [Real.norm_eq_abs] using norm_le_pi_norm v j
    _ = (∑ j : Fin 3, |M i j|) * ‖v‖ := by rw [Finset.sum_mul]
    _ ≤ r * ‖v‖ := mul_le_mul_of_nonneg_right (hrow i) (norm_nonneg v)

def multiply (M N : Matrix3) : Matrix3 := fun i j => ∑ k : Fin 3, M i k * N k j

theorem operator_multiply (M N : Matrix3) :
    operator (multiply M N) = (operator M).comp (operator N) := by
  ext v i
  simp only [operator_apply, multiply, ContinuousLinearMap.comp_apply, Finset.sum_mul, Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro j hj
  apply Finset.sum_congr rfl
  intro k hk
  ring

def identity : Matrix3 := fun i j => if i = j then 1 else 0

theorem operator_identity : operator identity = ContinuousLinearMap.id ℝ Point := by
  ext v i
  simp [operator_apply, identity]

theorem operator_sub (M N : Matrix3) : operator (M-N) = operator M - operator N := by
  ext v i
  simp [operator_apply, sub_mul, Finset.sum_sub_distrib]

theorem operator_derivative {M M' : ℝ → Matrix3} {s : Set ℝ} {x : ℝ}
    (h : ∀ i j, HasDerivWithinAt (fun t => M t i j) (M' x i j) s x) :
    HasDerivWithinAt (fun t => operator (M t)) (operator (M' x)) s x := by
  convert! (HasDerivWithinAt.sum (u := Finset.univ) (fun i _ =>
    HasDerivWithinAt.sum (u := Finset.univ) (fun j _ => (h i j).smul_const (unit i j)))) using 1

end FrozenMatrixBounds
