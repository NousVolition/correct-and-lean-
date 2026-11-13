import PeriodicNavierStokes

set_option autoImplicit false
set_option maxHeartbeats 4000000

namespace ClosestPointExample.Winding
noncomputable section
open scoped BigOperators

@[simp] theorem triple_last {α : Type} (a b c : α) : (![a,b,c] : Fin 3 → α) 2 = c := rfl
@[simp] theorem cons_three_last {α : Type} (a : α) (v : Fin 2 → α) :
    (Matrix.vecCons a v : Fin 3 → α) 2 = v 1 := rfl

def frequency : ℝ := 2 * Real.pi
def eigenvalue : ℝ := 3 * frequency
def waveVector (m : Fin 3) : Point :=
  ![![0, 0, 3], ![2, 2, 1], ![2, 2, -1]] m
def cosineVector (b : ℝ) (m : Fin 3) : Point :=
  ![![-b, 1-b, 0], ![b/2, b/2, -2*b], ![b/2, b/2, 2*b]] m
def sineVector (b : ℝ) (m : Fin 3) : Point :=
  ![![1-b, b, 0], ![3*b/2, -3*b/2, 0], ![-3*b/2, 3*b/2, 0]] m
def phase (m : Fin 3) (p : Point) : ℝ :=
  frequency * (waveVector m 0 * p 0 + waveVector m 1 * p 1 + waveVector m 2 * p 2)
def phaseD (m j : Fin 3) : ℝ := frequency * waveVector m j
def term (b : ℝ) (m : Fin 3) (p : Point) (i : Fin 3) : ℝ :=
  cosineVector b m i * Real.cos (phase m p) + sineVector b m i * Real.sin (phase m p)
def termD (b : ℝ) (m : Fin 3) (p : Point) (i j : Fin 3) : ℝ :=
  phaseD m j * (-cosineVector b m i * Real.sin (phase m p) + sineVector b m i * Real.cos (phase m p))
def field (b : ℝ) (p : Point) (i : Fin 3) : ℝ :=
  term b 0 p i + term b 1 p i + term b 2 p i
def fieldD (b : ℝ) (p : Point) (i j : Fin 3) : ℝ :=
  termD b 0 p i j + termD b 1 p i j + termD b 2 p i j
def fieldDD (b : ℝ) (p : Point) (i j : Fin 3) : ℝ :=
  -phaseD 0 j ^ 2 * term b 0 p i - phaseD 1 j ^ 2 * term b 1 p i - phaseD 2 j ^ 2 * term b 2 p i

theorem phase_derivative (m j : Fin 3) (p : Point) :
    HasDerivAt (fun r => phase m (Function.update p j r)) (phaseD m j) (p j) := by
  have d := ((hasDerivAt_id (p j)).const_mul (phaseD m j)).add_const (phase m p - phaseD m j * p j)
  convert d using 1
  · rfl
  · rfl
  · funext r
    fin_cases j <;> simp [phase, phaseD] <;> ring
  · ring

theorem term_derivative (b : ℝ) (m : Fin 3) (p : Point) (i j : Fin 3) :
    HasDerivAt (fun r => term b m (Function.update p j r) i) (termD b m p i j) (p j) := by
  have d := ((phase_derivative m j p).cos.const_mul (cosineVector b m i)).add
    ((phase_derivative m j p).sin.const_mul (sineVector b m i))
  simp only [Function.update_eq_self] at d
  convert d using 1 <;> first | rfl | (dsimp [term, termD]; ring)

theorem term_second (b : ℝ) (m : Fin 3) (p : Point) (i j : Fin 3) :
    HasDerivAt (fun r => termD b m (Function.update p j r) i j)
      (-phaseD m j ^ 2 * term b m p i) (p j) := by
  have d := (((phase_derivative m j p).sin.const_mul (-cosineVector b m i)).add
    ((phase_derivative m j p).cos.const_mul (sineVector b m i))).const_mul (phaseD m j)
  simp only [Function.update_eq_self] at d
  convert d using 1 <;> first | rfl | (dsimp [termD, term]; ring)

theorem field_has_derivative (b : ℝ) (p : Point) (i j : Fin 3) :
    HasDerivAt (fun r => field b (Function.update p j r) i) (fieldD b p i j) (p j) :=
  ((term_derivative b 0 p i j).add (term_derivative b 1 p i j)).add (term_derivative b 2 p i j)

theorem field_has_second (b : ℝ) (p : Point) (i j : Fin 3) :
    HasDerivAt (fun r => fieldD b (Function.update p j r) i j) (fieldDD b p i j) (p j) := by
  have d := ((term_second b 0 p i j).add (term_second b 1 p i j)).add (term_second b 2 p i j)
  convert d using 1 <;> first | rfl | (dsimp [fieldDD]; ring)

theorem field_partial (b : ℝ) (p : Point) (i j : Fin 3) :
    coordinateDerivative j (fun q => field b q i) p = fieldD b p i j :=
  (field_has_derivative b p i j).deriv

theorem field_second (b : ℝ) (p : Point) (i j : Fin 3) :
    coordinateDerivative j (fun q => coordinateDerivative j (fun r => field b r i) q) p = fieldDD b p i j := by
  simp_rw [field_partial]
  exact (field_has_second b p i j).deriv

def curlOf (J : Fin 3 → Fin 3 → ℝ) : Point :=
  ![J 2 1 - J 1 2, J 0 2 - J 2 0, J 1 0 - J 0 1]

theorem field_divergence (b : ℝ) (p : Point) : (∑ i : Fin 3, fieldD b p i i) = 0 := by
  norm_num [Fin.sum_univ_succ, fieldD, termD, phaseD, waveVector, cosineVector, sineVector]
  ring

theorem field_beltrami (b : ℝ) (p : Point) (i : Fin 3) :
    curlOf (fieldD b p) i = eigenvalue * field b p i := by
  fin_cases i <;>
    norm_num [curlOf, fieldD, termD, field, term, phaseD, waveVector, cosineVector, sineVector, eigenvalue] <;> ring

theorem field_laplacian (b : ℝ) (p : Point) (i : Fin 3) :
    (∑ j : Fin 3, fieldDD b p i j) = -eigenvalue ^ 2 * field b p i := by
  norm_num [Fin.sum_univ_succ, fieldDD, phaseD, waveVector, eigenvalue, field]
  ring

theorem field_smooth (b : ℝ) (i : Fin 3) : ContDiff ℝ ⊤ (fun p : Point => field b p i) := by
  dsimp [field, term, phase]
  fun_prop

theorem plane_phase (x y : ℝ) :
    phase 0 ![x,y,0] = 0 ∧
    phase 1 ![x,y,0] = 2 * frequency * (x+y) ∧
    phase 2 ![x,y,0] = 2 * frequency * (x+y) := by
  norm_num [phase, waveVector]
  ring

theorem field_on_plane (b x y : ℝ) :
    field b ![x,y,0] =
      ![b * (Real.cos (2 * frequency * (x+y)) - 1),
        1 + b * (Real.cos (2 * frequency * (x+y)) - 1), 0] := by
  funext i
  have h := plane_phase x y
  fin_cases i <;> norm_num [field, term, cosineVector, sineVector, h.1, h.2.1, h.2.2] <;> ring

theorem field_at_A (b : ℝ) : field b markerA = ![0,1,0] := by
  rw [show markerA = ![0,0,0] from rfl, field_on_plane]
  norm_num

theorem plane_nonzero (b x y : ℝ) :
    (1 / 2 : ℝ) ≤ (field b ![x,y,0] 0) ^ 2 + (field b ![x,y,0] 1) ^ 2 := by
  rw [field_on_plane]
  simp only [Matrix.cons_val_zero, Matrix.cons_val_one]
  nlinarith [sq_nonneg (b * (Real.cos (2 * frequency * (x+y)) - 1) + 1 / 2)]

#print axioms field_divergence
#print axioms field_beltrami
#print axioms field_laplacian
#print axioms field_smooth
#print axioms field_on_plane
#print axioms field_at_A
#print axioms plane_nonzero

end
end ClosestPointExample.Winding
