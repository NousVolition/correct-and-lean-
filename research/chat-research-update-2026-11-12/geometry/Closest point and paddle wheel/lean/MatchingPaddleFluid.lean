import PeriodicNavierStokes

set_option autoImplicit false
set_option maxHeartbeats 3000000

namespace ClosestPointExample.MatchingPaddle
noncomputable section
open scoped BigOperators

def transverseWave : ℝ := 2 * Real.pi
def phase : ℝ := Real.pi / 3
def modeDecay (h t : ℝ) : ℝ :=
  Real.exp (-viscosity * (wave ^ 2 + h ^ 2) * t + viscosity * h ^ 2 * tick41)
def mode (h c t x y : ℝ) : ℝ :=
  modeDecay h t * Real.sin (wave * x) * Real.cos (h * y + c)
def modeX (h c t x y : ℝ) : ℝ :=
  modeDecay h t * (wave * Real.cos (wave * x)) * Real.cos (h * y + c)
def modeY (h c t x y : ℝ) : ℝ :=
  modeDecay h t * Real.sin (wave * x) * (-h * Real.sin (h * y + c))

theorem mode_x (h c t x y : ℝ) : HasDerivAt (fun v => mode h c t v y) (modeX h c t x y) x := by
  have d := ((((hasDerivAt_id x).const_mul wave).sin).const_mul (modeDecay h t)).mul_const
    (Real.cos (h * y + c))
  convert d using 1 <;> first | rfl | (dsimp [mode, modeX]; ring)

theorem mode_y (h c t x y : ℝ) : HasDerivAt (mode h c t x) (modeY h c t x y) y := by
  have d := ((((hasDerivAt_id y).const_mul h).add_const c).cos).const_mul
    (modeDecay h t * Real.sin (wave * x))
  convert d using 1 <;> first | rfl | (dsimp [mode, modeY]; ring)

theorem mode_xx (h c t x y : ℝ) : HasDerivAt (fun v => modeX h c t v y) (-wave ^ 2 * mode h c t x y) x := by
  have d := (((((hasDerivAt_id x).const_mul wave).cos).const_mul wave).const_mul
    (modeDecay h t)).mul_const (Real.cos (h * y + c))
  convert d using 1 <;> first | rfl | (dsimp [mode, modeX]; ring)

theorem mode_yy (h c t x y : ℝ) : HasDerivAt (modeY h c t x) (-h ^ 2 * mode h c t x y) y := by
  have d := (((((hasDerivAt_id y).const_mul h).add_const c).sin).const_mul (-h)).const_mul
    (modeDecay h t * Real.sin (wave * x))
  convert d using 1 <;> first | rfl | (dsimp [mode, modeY]; ring)

theorem mode_t (h c t x y : ℝ) : HasDerivAt (fun v => mode h c v x y)
    (-viscosity * (wave ^ 2 + h ^ 2) * mode h c t x y) t := by
  have d := (((((hasDerivAt_id t).const_mul (-viscosity * (wave ^ 2 + h ^ 2))).add_const
    (viscosity * h ^ 2 * tick41)).exp).mul_const (Real.sin (wave * x))).mul_const (Real.cos (h * y + c))
  convert d using 1 <;> first | rfl | (dsimp [mode, modeDecay]; ring)

def c0 (b : Bool) : ℝ := if b then -2 else -1
def c1 (b : Bool) : ℝ := if b then 2 else 0
def profile (b : Bool) (t x y : ℝ) : ℝ :=
  c0 b * mode 0 0 t x y + c1 b * mode transverseWave phase t x y
def profileX (b : Bool) (t x y : ℝ) : ℝ :=
  c0 b * modeX 0 0 t x y + c1 b * modeX transverseWave phase t x y
def profileY (b : Bool) (t x y : ℝ) : ℝ :=
  c0 b * modeY 0 0 t x y + c1 b * modeY transverseWave phase t x y
def profileXX (b : Bool) (t x y : ℝ) : ℝ :=
  -wave ^ 2 * profile b t x y
def profileYY (b : Bool) (t x y : ℝ) : ℝ :=
  c1 b * (-transverseWave ^ 2 * mode transverseWave phase t x y)

theorem profile_x (b : Bool) (t x y : ℝ) :
    HasDerivAt (fun v => profile b t v y) (profileX b t x y) x :=
  ((mode_x 0 0 t x y).const_mul (c0 b)).add ((mode_x transverseWave phase t x y).const_mul (c1 b))
theorem profile_y (b : Bool) (t x y : ℝ) :
    HasDerivAt (profile b t x) (profileY b t x y) y :=
  ((mode_y 0 0 t x y).const_mul (c0 b)).add ((mode_y transverseWave phase t x y).const_mul (c1 b))
theorem profile_xx (b : Bool) (t x y : ℝ) :
    HasDerivAt (fun v => profileX b t v y) (profileXX b t x y) x := by
  have d := ((mode_xx 0 0 t x y).const_mul (c0 b)).add ((mode_xx transverseWave phase t x y).const_mul (c1 b))
  convert d using 1 <;> first | rfl | (dsimp [profileXX, profile]; ring)
theorem profile_yy (b : Bool) (t x y : ℝ) :
    HasDerivAt (profileY b t x) (profileYY b t x y) y := by
  have d := ((mode_yy 0 0 t x y).const_mul (c0 b)).add ((mode_yy transverseWave phase t x y).const_mul (c1 b))
  convert d using 1 <;> first | rfl | (dsimp [profileYY]; ring)
theorem profile_heat (b : Bool) (t x y : ℝ) :
    HasDerivAt (fun v => profile b v x y) (viscosity * (profileXX b t x y + profileYY b t x y)) t := by
  have d := ((mode_t 0 0 t x y).const_mul (c0 b)).add ((mode_t transverseWave phase t x y).const_mul (c1 b))
  convert d using 1 <;> first | rfl | (dsimp [profileXX, profileYY, profile]; ring)

theorem partial_plane (f : ℝ → ℝ → ℝ) (p : Point) (j : Fin 3) :
    coordinateDerivative j (fun q => f (q 0) (q 1)) p =
    if j = 0 then deriv (fun v => f v (p 1)) (p 0)
    else if j = 1 then deriv (f (p 0)) (p 1) else 0 := by
  fin_cases j <;> simp [coordinateDerivative]

def flow (b : Bool) (t : ℝ) (p : Point) (i : Fin 3) : ℝ :=
  if i = 2 then profile b t (p 0) (p 1) else 0

theorem flow_partial (b : Bool) (t : ℝ) (p : Point) (i j : Fin 3) :
    coordinateDerivative j (fun q => flow b t q i) p =
    if i = 2 then (if j = 0 then profileX b t (p 0) (p 1)
      else if j = 1 then profileY b t (p 0) (p 1) else 0) else 0 := by
  by_cases hi : i = 2
  · subst i
    simp only [flow, ite_true]
    rw [partial_plane (profile b t) p j, (profile_x b t (p 0) (p 1)).deriv,
      (profile_y b t (p 0) (p 1)).deriv]
  · simp [flow, hi, coordinateDerivative]

theorem flow_second (b : Bool) (t : ℝ) (p : Point) (i j : Fin 3) :
    coordinateDerivative j (fun q => coordinateDerivative j (fun r => flow b t r i) q) p =
    if i = 2 then (if j = 0 then profileXX b t (p 0) (p 1)
      else if j = 1 then profileYY b t (p 0) (p 1) else 0) else 0 := by
  simp_rw [flow_partial]
  by_cases hi : i = 2
  · subst i
    fin_cases j
    · simp
      rw [partial_plane (profileX b t) p 0]
      simp only [ite_true]
      exact (profile_xx b t (p 0) (p 1)).deriv
    · simp
      rw [partial_plane (profileY b t) p 1]
      simp
      exact (profile_yy b t (p 0) (p 1)).deriv
    · simp [coordinateDerivative]
  · simp [hi, coordinateDerivative]

theorem divergence_zero (b : Bool) (t : ℝ) (p : Point) :
    (∑ i : Fin 3, coordinateDerivative i (fun q => flow b t q i) p) = 0 := by
  simp [Fin.sum_univ_succ, flow_partial]

theorem advection_zero (b : Bool) (t : ℝ) (p : Point) (i : Fin 3) :
    (∑ j : Fin 3, flow b t p j * coordinateDerivative j (fun q => flow b t q i) p) = 0 := by
  simp_rw [flow_partial]
  simp [Fin.sum_univ_succ, flow]

theorem solves_navier_stokes (b : Bool) (t : ℝ) (p : Point) (i : Fin 3) :
    deriv (fun v => flow b v p i) t +
      (∑ j : Fin 3, flow b t p j * coordinateDerivative j (fun q => flow b t q i) p) =
    viscosity * (∑ j : Fin 3,
      coordinateDerivative j (fun q => coordinateDerivative j (fun r => flow b t r i) q) p)
      - coordinateDerivative i (pressure t) p + force t p i := by
  rw [advection_zero]
  simp_rw [flow_second]
  by_cases hi : i = 2
  · subst i
    simp [flow, Fin.sum_univ_succ, pressure, force, coordinateDerivative,
      (profile_heat b t (p 0) (p 1)).deriv]
  · simp [hi, flow, pressure, force, coordinateDerivative]

theorem smooth_flow (b : Bool) (i : Fin 3) :
    ContDiff ℝ ⊤ (fun tx : ℝ × Point => flow b tx.1 tx.2 i) := by
  by_cases hi : i = 2
  · simp only [flow, hi, ite_true]
    dsimp [profile, mode, modeDecay]
    fun_prop
  · simp only [flow, hi, ite_false]
    exact contDiff_const

theorem sin_wave_periodic (x : ℝ) (n : ℤ) :
    Real.sin (wave * (x + n)) = Real.sin (wave * x) := by
  convert Real.sin_add_int_mul_two_pi (wave * x) (2 * n) using 1 <;>
    push_cast <;> unfold wave <;> congr 1 <;> ring

theorem cos_transverse_periodic (y : ℝ) (n : ℤ) :
    Real.cos (transverseWave * (y + n) + phase) = Real.cos (transverseWave * y + phase) := by
  convert Real.cos_add_int_mul_two_pi (transverseWave * y + phase) n using 1 <;>
    unfold transverseWave <;> congr 1 <;> ring

theorem periodic_flow (b : Bool) (t : ℝ) (p : Point) (n : Fin 3 → ℤ) :
    flow b t (fun i => p i + n i) = flow b t p := by
  funext i
  simp [flow, profile, mode, sin_wave_periodic, cos_transverse_periodic]

theorem material_markers_stationary (b : Bool) (t : ℝ) :
    flow b t markerA = (fun _ => 0) ∧ flow b t markerB = (fun _ => 0) := by
  constructor <;> funext i <;> simp [flow, profile, mode, markerA, markerB]

def vorticity (b : Bool) (t : ℝ) (p : Point) : Point :=
  ![coordinateDerivative 1 (fun q => flow b t q 2) p - coordinateDerivative 2 (fun q => flow b t q 1) p,
    coordinateDerivative 2 (fun q => flow b t q 0) p - coordinateDerivative 0 (fun q => flow b t q 2) p,
    coordinateDerivative 0 (fun q => flow b t q 1) p - coordinateDerivative 1 (fun q => flow b t q 0) p]
def swirlScale : ℝ := wave * decay tick41
def gain (b : Bool) (y : ℝ) : ℝ :=
  if b then 2 * (1 - Real.cos (transverseWave * y + phase)) else 1

theorem mode_decay_at_tick (h : ℝ) : modeDecay h tick41 = decay tick41 := by
  unfold modeDecay decay
  congr 1
  ring

theorem curl_on_axis (b : Bool) (y : ℝ) (i : Fin 3) :
    vorticity b tick41 (line 0 y) i = swirlScale * gain b y * direction 0 i := by
  cases b <;> fin_cases i <;>
    simp [vorticity, flow_partial, profileX, profileY, modeX, modeY, mode_decay_at_tick,
      line, direction, c0, c1, gain, swirlScale] <;> ring

theorem same_paddle_wheel : vorticity false tick41 markerA = vorticity true tick41 markerA := by
  have hA : markerA = line 0 0 := by simp [line, markerA]
  rw [hA]
  funext i
  rw [curl_on_axis, curl_on_axis]
  norm_num [gain, phase, Real.cos_pi_div_three]

theorem same_paddle_as_previous :
    vorticity false tick41 markerA = ClosestPointExample.curl 0 tick41 markerA := by
  have hA : markerA = line 0 0 := by simp [line, markerA]
  rw [hA]
  funext i
  rw [curl_on_axis, ClosestPointExample.curl_on_line]
  simp [gain, swirlScale]

theorem swirlScale_positive : 0 < swirlScale := vortex_parameter_scale_positive tick41

#print axioms solves_navier_stokes
#print axioms divergence_zero
#print axioms smooth_flow
#print axioms periodic_flow
#print axioms material_markers_stationary
#print axioms curl_on_axis
#print axioms same_paddle_wheel
#print axioms same_paddle_as_previous

end
end ClosestPointExample.MatchingPaddle
