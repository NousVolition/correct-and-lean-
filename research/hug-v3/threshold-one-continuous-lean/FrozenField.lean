import Mathlib.Analysis.Real.Pi.Bounds
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Bounds
import Mathlib.Analysis.Normed.Group.Constructions
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

namespace FrozenField

private theorem abs_sub_bound (a b : ℝ) : |a - b| ≤ |a| + |b| := by
  simpa only [sub_eq_add_neg, abs_neg] using abs_add_le a (-b)

abbrev Point := Fin 3 → ℝ

/-- Integer coefficients with a common positive binary denominator retain every
archived IEEE-754 coefficient exactly. No Hermitian symmetry is assumed. -/
structure Wave where
  k₀ : ℤ
  k₁ : ℤ
  k₂ : ℤ
  re : ℤ
  im : ℤ
  deriving DecidableEq, Repr

def Wave.mass (w : Wave) : ℕ := w.re.natAbs + w.im.natAbs
def Wave.frequency (w : Wave) : ℕ := w.k₀.natAbs + w.k₁.natAbs + w.k₂.natAbs

noncomputable def Wave.phase (w : Wave) (x : Point) : ℝ :=
  2 * Real.pi * ((w.k₀ : ℝ) * (x 0 + 1/2) +
    (w.k₁ : ℝ) * (x 1 + 1/2) + (w.k₂ : ℝ) * (x 2 + 1/2))

noncomputable def Wave.value (w : Wave) (D : ℕ) (x : Point) : ℝ :=
  (w.re : ℝ) / D * Real.cos (w.phase x) - (w.im : ℝ) / D * Real.sin (w.phase x)

noncomputable def value (ws : List Wave) (D : ℕ) (x : Point) : ℝ :=
  (ws.map (fun w => w.value D x)).sum

def mass (ws : List Wave) : ℕ := (ws.map Wave.mass).sum
def weightedMass (ws : List Wave) : ℕ :=
  (ws.map (fun w => w.mass * w.frequency)).sum

theorem wave_bound (w : Wave) {D : ℕ} (hD : 0 < D) (x : Point) :
    |w.value D x| ≤ (w.mass : ℝ) / D := by
  have hd : (0 : ℝ) < D := by exact_mod_cast hD
  unfold Wave.value Wave.mass
  calc
    _ ≤ |(w.re : ℝ) / D * Real.cos (w.phase x)| +
        |(w.im : ℝ) / D * Real.sin (w.phase x)| := abs_sub_bound _ _
    _ = |(w.re : ℝ)| / D * |Real.cos (w.phase x)| +
        |(w.im : ℝ)| / D * |Real.sin (w.phase x)| := by
          simp only [abs_mul, abs_div, abs_of_pos hd]
    _ ≤ |(w.re : ℝ)| / D * 1 + |(w.im : ℝ)| / D * 1 := by
      gcongr
      · exact Real.abs_cos_le_one _
      · exact Real.abs_sin_le_one _
    _ = (↑(w.re.natAbs + w.im.natAbs) : ℝ) / D := by
      simp only [Nat.cast_add, Nat.cast_natAbs, Int.cast_abs, mul_one, add_div]

/-- A bound at every real spatial point, independent of sampling. -/
theorem field_bound (ws : List Wave) {D : ℕ} (hD : 0 < D) (x : Point) :
    |value ws D x| ≤ (mass ws : ℝ) / D := by
  induction ws with
  | nil => simp [value, mass]
  | cons w ws ih =>
    simp only [value, mass, List.map_cons, List.sum_cons, Nat.cast_add] at *
    calc
      _ ≤ |w.value D x| + |(ws.map (fun w => w.value D x)).sum| := abs_add_le _ _
      _ ≤ (w.mass : ℝ) / D + (↑(ws.map Wave.mass).sum : ℝ) / D :=
        add_le_add (wave_bound w hD x) ih
      _ = _ := by ring

theorem phase_difference_bound (w : Wave) (x y : Point) :
    |w.phase x - w.phase y| ≤ 8 * w.frequency * ‖x - y‖ := by
  have hx (i : Fin 3) : |x i - y i| ≤ ‖x - y‖ := by
    simpa only [Real.norm_eq_abs, Pi.sub_apply] using norm_le_pi_norm (x - y) i
  have hp : |(2 : ℝ) * Real.pi| ≤ 8 := by
    rw [abs_of_pos (mul_pos (by norm_num) Real.pi_pos)]
    linarith [Real.pi_lt_four]
  have heq : w.phase x - w.phase y = 2 * Real.pi *
      ((w.k₀ : ℝ) * (x 0 - y 0) + (w.k₁ : ℝ) * (x 1 - y 1) +
       (w.k₂ : ℝ) * (x 2 - y 2)) := by unfold Wave.phase; ring
  rw [heq, abs_mul]
  calc
    _ ≤ 8 * (|(w.k₀ : ℝ) * (x 0 - y 0)| + |(w.k₁ : ℝ) * (x 1 - y 1)| +
        |(w.k₂ : ℝ) * (x 2 - y 2)|) :=
      mul_le_mul hp (abs_add_three _ _ _) (abs_nonneg _) (by norm_num)
    _ ≤ 8 * (|(w.k₀ : ℝ)| * ‖x - y‖ + |(w.k₁ : ℝ)| * ‖x - y‖ +
        |(w.k₂ : ℝ)| * ‖x - y‖) := by simp only [abs_mul]; gcongr <;> apply hx
    _ = 8 * w.frequency * ‖x - y‖ := by
      simp only [Wave.frequency, Nat.cast_add, Nat.cast_natAbs, Int.cast_abs]
      ring

theorem wave_difference_bound (w : Wave) {D : ℕ} (hD : 0 < D) (x y : Point) :
    |w.value D x - w.value D y| ≤ 8 * (w.mass * w.frequency : ℕ) / D * ‖x - y‖ := by
  have hd : (0 : ℝ) < D := by exact_mod_cast hD
  have hcos := le_trans (Real.abs_cos_sub_cos_le (w.phase x) (w.phase y)) (phase_difference_bound w x y)
  have hsin := le_trans (Real.abs_sin_sub_sin_le (w.phase x) (w.phase y)) (phase_difference_bound w x y)
  have heq : w.value D x - w.value D y = (w.re : ℝ) / D *
      (Real.cos (w.phase x) - Real.cos (w.phase y)) - (w.im : ℝ) / D *
      (Real.sin (w.phase x) - Real.sin (w.phase y)) := by unfold Wave.value; ring
  rw [heq]
  calc
    _ ≤ |(w.re : ℝ) / D * (Real.cos (w.phase x) - Real.cos (w.phase y))| +
        |(w.im : ℝ) / D * (Real.sin (w.phase x) - Real.sin (w.phase y))| := abs_sub_bound _ _
    _ ≤ |(w.re : ℝ)| / D * (8 * w.frequency * ‖x - y‖) +
        |(w.im : ℝ)| / D * (8 * w.frequency * ‖x - y‖) := by
      simp only [abs_mul, abs_div, abs_of_pos hd]
      gcongr
    _ = _ := by
      simp only [Wave.mass, Nat.cast_mul, Nat.cast_add, Nat.cast_natAbs, Int.cast_abs]
      ring

theorem field_difference_bound (ws : List Wave) {D : ℕ} (hD : 0 < D) (x y : Point) :
    |value ws D x - value ws D y| ≤ 8 * (weightedMass ws : ℝ) / D * ‖x - y‖ := by
  induction ws with
  | nil => simp [value, weightedMass]
  | cons w ws ih =>
    simp only [value, weightedMass, List.map_cons, List.sum_cons, Nat.cast_add] at *
    calc
      _ = |(w.value D x - w.value D y) +
          ((ws.map (fun w => w.value D x)).sum - (ws.map (fun w => w.value D y)).sum)| := by congr 1; ring
      _ ≤ |w.value D x - w.value D y| +
          |(ws.map (fun w => w.value D x)).sum - (ws.map (fun w => w.value D y)).sum| := abs_add_le _ _
      _ ≤ 8 * (w.mass * w.frequency : ℕ) / D * ‖x - y‖ +
          8 * (((ws.map (fun w => w.mass * w.frequency)).sum : ℕ) : ℝ) / D * ‖x - y‖ :=
        add_le_add (wave_difference_bound w hD x y) ih
      _ = _ := by ring

end FrozenField
