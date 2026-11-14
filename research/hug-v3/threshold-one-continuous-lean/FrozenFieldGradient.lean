import FrozenFieldTaylor

namespace FrozenFieldGradient
open FrozenField FrozenFieldTaylor

def component (w : Wave) (j : Fin 3) : ℤ := ![w.k₀, w.k₁, w.k₂] j

def rotate (w : Wave) (k : ℤ) : Wave :=
  ⟨w.k₀, w.k₁, w.k₂, -w.im*k, w.re*k⟩

def gradientWaves (ws : List Wave) (j : Fin 3) : List Wave :=
  ws.map (fun w => rotate w (component w j))

noncomputable def gradient (ws : List Wave) (D : ℕ) (x : Point) (j : Fin 3) : ℝ :=
  2 * Real.pi * value (gradientWaves ws j) D x

theorem rotate_phase (w : Wave) (k : ℤ) (x : Point) : (rotate w k).phase x = w.phase x := rfl

theorem rotate_value (w : Wave) (k : ℤ) (D : ℕ) (x : Point) :
    (rotate w k).value D x = (k : ℝ) *
      (-(w.re : ℝ)/D * Real.sin (w.phase x) - (w.im : ℝ)/D * Real.cos (w.phase x)) := by
  simp only [Wave.value, rotate, Wave.phase, Int.cast_mul, Int.cast_neg]
  ring

theorem linearPart_eq (w : Wave) (D : ℕ) (x δ : Point) :
    linearPart w D x δ =
      (2*Real.pi*(rotate w w.k₀).value D x)*δ 0 +
      (2*Real.pi*(rotate w w.k₁).value D x)*δ 1 +
      (2*Real.pi*(rotate w w.k₂).value D x)*δ 2 := by
  simp only [linearPart, shift, rotate_value]
  ring

theorem fieldLinear_eq (ws : List Wave) (D : ℕ) (x δ : Point) :
    fieldLinear ws D x δ = gradient ws D x 0 * δ 0 +
      gradient ws D x 1 * δ 1 + gradient ws D x 2 * δ 2 := by
  induction ws with
  | nil => simp [fieldLinear, gradient, gradientWaves, value]
  | cons w ws ih =>
    simp only [fieldLinear, List.map_cons, List.sum_cons] at *
    rw [linearPart_eq, ih]
    simp [gradient, gradientWaves, value, component]
    ring

set_option backward.isDefEq.respectTransparency false in
/-- The linear part is the actual derivative of the archived trigonometric
polynomial, rather than an externally supplied Jacobian. -/
theorem directional_derivative (ws : List Wave) (D : ℕ) (x δ : Point) :
    HasDerivAt (fun t : ℝ => value ws D (x + t • δ)) (fieldLinear ws D x δ) 0 := by
  have hw (w : Wave) : HasDerivAt
      (fun t : ℝ => w.value D (x + t • δ)) (linearPart w D x δ) 0 := by
    have hp : HasDerivAt (fun t : ℝ => w.phase x + t * shift w δ) (shift w δ) 0 := by
      simpa using ((hasDerivAt_id 0).mul_const (shift w δ)).const_add (w.phase x)
    have hcos := hp.cos.const_mul ((w.re : ℝ)/D)
    have hsin := hp.sin.const_mul ((w.im : ℝ)/D)
    convert! hcos.sub hsin using 1
    · funext t
      simp only [Wave.value]
      have heq : w.phase (x + t • δ) = w.phase x + t * shift w δ := by
        simp only [Wave.phase, shift, Pi.add_apply, Pi.smul_apply, smul_eq_mul]
        ring
      rw [heq]
      rfl
    · simp only [zero_mul, add_zero, linearPart]
      ring
  induction ws with
  | nil => simpa only [value, fieldLinear, List.map_nil, List.sum_nil] using hasDerivAt_const (0 : ℝ) (0 : ℝ)
  | cons w ws ih =>
    convert! (hw w).add ih using 1

end FrozenFieldGradient
