import FrozenEuclidean
import FrozenNormalization
import FrozenPrecondition

namespace FrozenTubeResidual
open FrozenField FrozenEuclidean

/-- A square residual proves that the actual Euclidean norm stays positive.
The proposed denominator need not be an exact square root. -/
theorem radius_lower_from_square {w : Point} {m n δ : ℝ}
    (hm : 0 < m) (hn : 2*m ≤ n)
    (hδ : |n^2 - radius w^2| ≤ δ) (hsmall : δ ≤ 3*m^2) :
    m ≤ radius w := by
  have hr := radius_nonneg w
  have hnum : n^2 - radius w^2 ≤ δ := le_trans (le_abs_self _) hδ
  have hn0 : 0 ≤ n := by linarith
  have hsq : (2*m)^2 ≤ n^2 := pow_le_pow_left₀ (by positivity) hn 2
  nlinarith

theorem normalized_error {w p : Point} {m n δ ε V B : ℝ}
    (hm : 0 < m) (hn : 2*m ≤ n)
    (hδ : |n^2 - radius w^2| ≤ δ) (hsmall : δ ≤ 3*m^2)
    (hε : ∀ i, |w i - n*p i| ≤ ε) (hV : ∀ i, |p i| ≤ V)
    (hB : (ε + V * (δ / (2*m))) / m ≤ B) :
    ‖(radius w)⁻¹ • w - p‖ ≤ B := by
  have hz := radius_lower_from_square hm hn hδ hsmall
  have he (i : Fin 3) : |w i / radius w - p i| ≤ B :=
    le_trans (FrozenNormalization.normalized_component_error hm (by linarith)
      hz hδ (hε i) (hV i)) hB
  have hB0 : 0 ≤ B := le_trans (abs_nonneg _) (he 0)
  apply (pi_norm_le_iff_of_nonneg hB0).mpr
  intro i
  simpa only [Pi.sub_apply, Pi.smul_apply, smul_eq_mul, Real.norm_eq_abs,
    div_eq_mul_inv, mul_comm] using he i

/-- A linear approximation to the normalized field gives a transformed
residual. Every bound here must later hold on the entire physical tube. -/
theorem transformed_residual
    (Z Z' J : Point →L[ℝ] Point) (f : Point → Point) (q q' p d : Point)
    {A L ζ ε : ℝ}
    (hlinear : ‖Z' + Z.comp J‖ ≤ L)
    (hzero : ‖Z (p-q')‖ ≤ A) (hZ : ‖Z‖ ≤ ζ)
    (herr : ‖f (q+d) - (p+J d)‖ ≤ ε) :
    ‖Z' d + Z (f (q+d)-q')‖ ≤ A + L*‖d‖ + ζ*ε := by
  have heq : Z' d + Z (f (q+d)-q') =
      (Z'+Z.comp J) d + Z (p-q') + Z (f (q+d)-(p+J d)) := by
    change _ = Z' d + Z (J d) + Z (p-q') + Z (f (q+d)-(p+J d))
    simp only [map_sub, map_add]
    abel
  have h1 : ‖(Z'+Z.comp J) d‖ ≤ L*‖d‖ :=
    le_trans ((Z'+Z.comp J).le_opNorm d)
      (mul_le_mul_of_nonneg_right hlinear (norm_nonneg _))
  have h2 : ‖Z (f (q+d)-(p+J d))‖ ≤ ζ*ε := by
    apply le_trans (Z.le_opNorm _)
    exact mul_le_mul hZ herr (norm_nonneg _) (le_trans (norm_nonneg _) hZ)
  rw [heq]
  calc
    _ ≤ ‖(Z'+Z.comp J) d‖ + ‖Z (p-q')‖ + ‖Z (f (q+d)-(p+J d))‖ :=
      norm_add₃_le
    _ ≤ L*‖d‖ + A + ζ*ε := add_le_add (add_le_add h1 hzero) h2
    _ = _ := by ring

end FrozenTubeResidual
