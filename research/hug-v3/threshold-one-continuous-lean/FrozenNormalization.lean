import Mathlib.Tactic.Abel
import Mathlib.Tactic.Convert
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.FunProp
import Mathlib.Tactic.GCongr
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Push
import Mathlib.Tactic.Ring

namespace FrozenNormalization

/-- A residual for a normalized vector component can be certified without
assuming that a proposed square-root polynomial is the exact norm.

`n` is the proposed positive denominator, `z` the actual positive norm.
The square residual, component residual, and both lower bounds must all be
proved separately before this lemma can certify an ODE residual. -/
theorem normalized_component_error
    {m n z w p δ ε V : ℝ}
    (hm : 0 < m) (hn : m ≤ n) (hz : m ≤ z)
    (hδ : |n ^ 2 - z ^ 2| ≤ δ)
    (hε : |w - n * p| ≤ ε) (hV : |p| ≤ V) :
    |w / z - p| ≤ (ε + V * (δ / (2 * m))) / m := by
  have hn0 : 0 < n := lt_of_lt_of_le hm hn
  have hz0 : 0 < z := lt_of_lt_of_le hm hz
  have hδ0 : 0 ≤ δ := le_trans (abs_nonneg _) hδ
  have hε0 : 0 ≤ ε := le_trans (abs_nonneg _) hε
  have hV0 : 0 ≤ V := le_trans (abs_nonneg _) hV
  have hgap : |n - z| ≤ δ / (2 * m) := by
    apply (le_div_iff₀ (by positivity : 0 < 2 * m)).mpr
    have heq : |n ^ 2 - z ^ 2| = |n - z| * (n + z) := by
      rw [show n ^ 2 - z ^ 2 = (n - z) * (n + z) by ring, abs_mul,
        abs_of_pos (add_pos hn0 hz0)]
    rw [heq] at hδ
    nlinarith [abs_nonneg (n - z)]
  have hnum : |w - z * p| ≤ ε + V * (δ / (2 * m)) := by
    calc
      _ = |(w - n * p) + (n - z) * p| := by congr 1; ring
      _ ≤ |w - n * p| + |(n - z) * p| := abs_add_le _ _
      _ = |w - n * p| + |p| * |n - z| := by rw [abs_mul]; ring
      _ ≤ ε + V * (δ / (2 * m)) := by gcongr
  have heq : w / z - p = (w - z * p) / z := by field_simp
  rw [heq, abs_div, abs_of_pos hz0]
  exact div_le_div₀ (by positivity) hnum hm hz

end FrozenNormalization
