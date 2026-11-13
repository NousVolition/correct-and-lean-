import HistoryMatchCore

/-! The explicit common planar fluid, including its actual pressure and PDE.
This constructs the base flow unconditionally. It does not construct S,F,G. -/
set_option autoImplicit false
set_option maxHeartbeats 4000000
namespace HistoryPlanarBase
noncomputable section
open scoped BigOperators
abbrev Point := Fin 3 → ℝ
def coordinateDerivative (j : Fin 3) (f : Point → ℝ) (p : Point) : ℝ :=
  deriv (fun r => f (Function.update p j r)) (p j)
@[simp] theorem triple_last {α : Type} (a b c : α) :
    (![a,b,c] : Fin 3 → α) 2 = c := rfl
@[simp] theorem cons_three_last {α : Type} (a : α) (v : Fin 2 → α) :
    (Matrix.vecCons a v : Fin 3 → α) 2 = v 1 := rfl
@[simp] theorem four_last {α : Type} (a b c d : α) :
    (![a,b,c,d] : Fin 4 → α) 3 = d := rfl
@[simp] theorem cons_four_last {α : Type} (a : α) (v : Fin 3 → α) :
    (Matrix.vecCons a v : Fin 4 → α) 3 = v 2 := rfl
@[simp] theorem four_second {α : Type} (a b c d : α) :
    (![a,b,c,d] : Fin 4 → α) 2 = c := rfl
@[simp] theorem cons_four_second {α : Type} (a : α) (v : Fin 3 → α) :
    (Matrix.vecCons a v : Fin 4 → α) 2 = v 1 := rfl
def frequency : ℝ := 2*Real.pi
def viscosity : ℝ := 3/200
def eigenvalue : ℝ := 5*frequency^2
def waveVector (m : Fin 4) : Point :=
  ![![2,-1,0],![2,1,0],![1,-2,0],![1,2,0]] m
def weight (m : Fin 4) : ℝ := ![1/4,-1/4,-1/4,1/4] m
def phase (m : Fin 4) (p : Point) : ℝ :=
  frequency*(waveVector m 0*p 0+waveVector m 1*p 1+waveVector m 2*p 2)
def phaseD (m : Fin 4) (j : Fin 3) : ℝ := frequency*waveVector m j
def direction (m : Fin 4) : Point := ![-phaseD m 1,phaseD m 0,0]
def addFour (f : Fin 4 → ℝ) : ℝ := f 0+f 1+f 2+f 3
def scalarTerm (m : Fin 4) (p : Point) : ℝ := weight m*Real.cos (phase m p)
def scalarTermD (m : Fin 4) (p : Point) (j : Fin 3) : ℝ :=
  -weight m*Real.sin (phase m p)*phaseD m j
def term (m : Fin 4) (p : Point) (i : Fin 3) : ℝ :=
  weight m*direction m i*Real.sin (phase m p)
def termD (m : Fin 4) (p : Point) (i j : Fin 3) : ℝ :=
  weight m*direction m i*Real.cos (phase m p)*phaseD m j
def profile (p : Point) : ℝ := addFour (fun m => scalarTerm m p)
def profileD (p : Point) (j : Fin 3) : ℝ := addFour (fun m => scalarTermD m p j)
def field (p : Point) (i : Fin 3) : ℝ := addFour (fun m => term m p i)
def fieldD (p : Point) (i j : Fin 3) : ℝ := addFour (fun m => termD m p i j)
def fieldDD (p : Point) (i j : Fin 3) : ℝ :=
  addFour (fun m => -phaseD m j^2*term m p i)
def curlOf (J : Fin 3 → Fin 3 → ℝ) : Point :=
  ![J 2 1-J 1 2,J 0 2-J 2 0,J 1 0-J 0 1]

theorem phase_derivative (m : Fin 4) (j : Fin 3) (p : Point) :
    HasDerivAt (fun r => phase m (Function.update p j r)) (phaseD m j) (p j) := by
  have h := ((hasDerivAt_id (p j)).const_mul (phaseD m j)).add_const
    (phase m p-phaseD m j*p j)
  convert h using 1
  · rfl
  · rfl
  · funext r
    fin_cases j <;> simp [phase,phaseD] <;> ring
  · ring

theorem scalarTerm_derivative (m : Fin 4) (j : Fin 3) (p : Point) :
    HasDerivAt (fun r => scalarTerm m (Function.update p j r))
      (scalarTermD m p j) (p j) := by
  have h := (phase_derivative m j p).cos.const_mul (weight m)
  simp only [Function.update_eq_self] at h
  convert h using 1 <;> first | rfl | (dsimp [scalarTerm,scalarTermD]; ring)

theorem term_derivative (m : Fin 4) (i j : Fin 3) (p : Point) :
    HasDerivAt (fun r => term m (Function.update p j r) i) (termD m p i j) (p j) := by
  have h := (phase_derivative m j p).sin.const_mul (weight m*direction m i)
  simp only [Function.update_eq_self] at h
  convert h using 1 <;> first | rfl | (dsimp [term,termD]; ring)

theorem term_second (m : Fin 4) (i j : Fin 3) (p : Point) :
    HasDerivAt (fun r => termD m (Function.update p j r) i j)
      (-phaseD m j^2*term m p i) (p j) := by
  have h := ((phase_derivative m j p).cos.const_mul (weight m*direction m i)).mul_const (phaseD m j)
  simp only [Function.update_eq_self] at h
  convert h using 1 <;> first | rfl | (dsimp [term,termD]; ring)

theorem profile_has_derivative (j : Fin 3) (p : Point) :
    HasDerivAt (fun r => profile (Function.update p j r)) (profileD p j) (p j) :=
  (((scalarTerm_derivative 0 j p).add (scalarTerm_derivative 1 j p)).add
    (scalarTerm_derivative 2 j p)).add (scalarTerm_derivative 3 j p)

theorem field_has_derivative (i j : Fin 3) (p : Point) :
    HasDerivAt (fun r => field (Function.update p j r) i) (fieldD p i j) (p j) :=
  (((term_derivative 0 i j p).add (term_derivative 1 i j p)).add
    (term_derivative 2 i j p)).add (term_derivative 3 i j p)

theorem field_has_second (i j : Fin 3) (p : Point) :
    HasDerivAt (fun r => fieldD (Function.update p j r) i j) (fieldDD p i j) (p j) :=
  (((term_second 0 i j p).add (term_second 1 i j p)).add
    (term_second 2 i j p)).add (term_second 3 i j p)

theorem profileD_field (p : Point) : profileD p = ![-field p 1,field p 0,0] := by
  funext j
  fin_cases j <;> norm_num [profileD,field,scalarTermD,term,addFour,direction,phaseD,waveVector] <;> ring

theorem field_divergence (p : Point) : (∑ i : Fin 3, fieldD p i i) = 0 := by
  norm_num [Fin.sum_univ_succ,fieldD,termD,addFour,direction,phaseD,waveVector,weight]
  ring

theorem field_curl (p : Point) : curlOf (fieldD p) = ![0,0,eigenvalue*profile p] := by
  funext i
  fin_cases i <;>
    norm_num [curlOf,fieldD,termD,profile,scalarTerm,addFour,direction,phaseD,waveVector,weight,eigenvalue] <;> ring

theorem field_laplacian (p : Point) (i : Fin 3) :
    (∑ j : Fin 3, fieldDD p i j) = -eigenvalue*field p i := by
  norm_num [Fin.sum_univ_succ,fieldDD,field,addFour,phaseD,waveVector,eigenvalue]
  ring

theorem profile_original_formula (p : Point) :
    profile p = Real.sin (frequency*p 0)*Real.sin (frequency*p 1)*
      (Real.cos (frequency*p 0)-Real.cos (frequency*p 1)) := by
  have h0 : phase 0 p = 2*(frequency*p 0)-(frequency*p 1) := by
    norm_num [phase,waveVector]; ring
  have h1 : phase 1 p = 2*(frequency*p 0)+(frequency*p 1) := by
    norm_num [phase,waveVector]; ring
  have h2 : phase 2 p = (frequency*p 0)-2*(frequency*p 1) := by
    norm_num [phase,waveVector]; ring
  have h3 : phase 3 p = (frequency*p 0)+2*(frequency*p 1) := by
    norm_num [phase,waveVector]; ring
  norm_num [profile,scalarTerm,addFour,weight,h0,h1,h2,h3,
    Real.cos_sub,Real.cos_add,Real.sin_two_mul]
  ring

theorem profile_and_field_at_origin : profile (fun _ => 0) = 0 ∧ field (fun _ => 0) = 0 := by
  constructor
  · norm_num [profile,scalarTerm,addFour,phase,weight]
  · funext i
    simp [field,addFour,term,phase]

theorem fieldD_at_origin (i j : Fin 3) : fieldD (fun _ => 0) i j = 0 := by
  fin_cases i <;> fin_cases j <;>
    norm_num [fieldD,termD,addFour,phase,direction,phaseD,waveVector,weight] <;> ring

def amplitude (ε t : ℝ) : ℝ := ε*Real.exp (-viscosity*eigenvalue*t)
def stream (ε t : ℝ) (p : Point) : ℝ := amplitude ε t*profile p
def streamD (ε t : ℝ) (p : Point) (j : Fin 3) : ℝ := amplitude ε t*profileD p j
def flow (ε t : ℝ) (p : Point) (i : Fin 3) : ℝ := amplitude ε t*field p i
def flowD (ε t : ℝ) (p : Point) (i j : Fin 3) : ℝ := amplitude ε t*fieldD p i j
def flowDD (ε t : ℝ) (p : Point) (i j : Fin 3) : ℝ := amplitude ε t*fieldDD p i j
def pressure (ε t : ℝ) (p : Point) : ℝ :=
  -((flow ε t p 0)^2+(flow ε t p 1)^2+(flow ε t p 2)^2+eigenvalue*(stream ε t p)^2)/2

theorem flow_partial (ε t : ℝ) (p : Point) (i j : Fin 3) :
    coordinateDerivative j (fun q => flow ε t q i) p = flowD ε t p i j :=
  ((field_has_derivative i j p).const_mul (amplitude ε t)).deriv

theorem flow_second (ε t : ℝ) (p : Point) (i j : Fin 3) :
    coordinateDerivative j (fun q => coordinateDerivative j (fun r => flow ε t r i) q) p =
      flowDD ε t p i j := by
  simp_rw [flow_partial]
  exact ((field_has_second i j p).const_mul (amplitude ε t)).deriv

theorem stream_partial (ε t : ℝ) (p : Point) (j : Fin 3) :
    coordinateDerivative j (stream ε t) p = streamD ε t p j :=
  ((profile_has_derivative j p).const_mul (amplitude ε t)).deriv

theorem flow_time (ε t : ℝ) (p : Point) (i : Fin 3) :
    deriv (fun r => flow ε r p i) t = -viscosity*eigenvalue*flow ε t p i := by
  have h := ((((hasDerivAt_id t).const_mul (-viscosity*eigenvalue)).exp).const_mul ε).mul_const (field p i)
  have h' : HasDerivAt (fun r => flow ε r p i) (-viscosity*eigenvalue*flow ε t p i) t := by
    convert h using 1 <;> first | rfl | (dsimp [flow,amplitude]; ring)
  exact h'.deriv

theorem flow_laplacian (ε t : ℝ) (p : Point) (i : Fin 3) :
    (∑ j : Fin 3, coordinateDerivative j (fun q => coordinateDerivative j (fun r => flow ε t r i) q) p) =
      -eigenvalue*flow ε t p i := by
  simp_rw [flow_second,flowDD]
  rw [← Finset.mul_sum,field_laplacian]
  unfold flow
  ring

theorem pressure_partial (ε t : ℝ) (p : Point) (j : Fin 3) :
    coordinateDerivative j (pressure ε t) p =
      -(∑ i : Fin 3, flow ε t p i*flowD ε t p i j)-
      eigenvalue*stream ε t p*streamD ε t p j := by
  have hu (i : Fin 3) := (field_has_derivative i j p).const_mul (amplitude ε t)
  have hs := (profile_has_derivative j p).const_mul (amplitude ε t)
  have h := ((((((hu 0).pow 2).add ((hu 1).pow 2)).add ((hu 2).pow 2)).add
    ((hs.pow 2).const_mul eigenvalue)).neg).div_const 2
  have h' : HasDerivAt (fun r => pressure ε t (Function.update p j r))
      (-(∑ i : Fin 3, flow ε t p i*flowD ε t p i j)-
      eigenvalue*stream ε t p*streamD ε t p j) (p j) := by
    convert h using 1 <;> first | rfl |
      (simp [Fin.sum_univ_succ,flow,flowD,stream,streamD]; ring)
  exact h'.deriv

theorem advection_identity (u : Point) (J : Fin 3 → Fin 3 → ℝ) (s l : ℝ) (g : Point)
    (hc : curlOf J = ![0,0,l*s]) (hg : g = ![-u 1,u 0,0]) (i : Fin 3) :
    (∑ j : Fin 3, u j*J i j) = (∑ j : Fin 3, u j*J j i)+l*s*g i := by
  have h0 := congrFun hc 0
  have h1 := congrFun hc 1
  have h2 := congrFun hc 2
  simp only [curlOf,Matrix.cons_val_zero,Matrix.cons_val_one,triple_last] at h0 h1 h2
  rw [hg]
  fin_cases i <;> simp [Fin.sum_univ_succ]
  · linear_combination -u 1*h2+u 2*h1
  · linear_combination u 0*h2-u 2*h0
  · linear_combination -u 0*h1+u 1*h0

theorem flow_curl (ε t : ℝ) (p : Point) :
    curlOf (flowD ε t p) = ![0,0,eigenvalue*stream ε t p] := by
  have h := field_curl p
  funext i
  have hi := congrFun h i
  fin_cases i <;> simp [curlOf,flowD,stream] at * <;>
    linear_combination amplitude ε t*hi

theorem streamD_flow (ε t : ℝ) (p : Point) :
    streamD ε t p = ![-flow ε t p 1,flow ε t p 0,0] := by
  funext j
  simp only [streamD,profileD_field]
  fin_cases j <;> simp [flow]

theorem flow_divergence (ε t : ℝ) (p : Point) :
    (∑ i : Fin 3, coordinateDerivative i (fun q => flow ε t q i) p) = 0 := by
  simp_rw [flow_partial,flowD]
  rw [← Finset.mul_sum,field_divergence]
  ring

theorem solves_unforced_navier_stokes (ε t : ℝ) (p : Point) (i : Fin 3) :
    deriv (fun r => flow ε r p i) t+
      (∑ j : Fin 3, flow ε t p j*coordinateDerivative j (fun q => flow ε t q i) p) =
    viscosity*(∑ j : Fin 3, coordinateDerivative j
      (fun q => coordinateDerivative j (fun r => flow ε t r i) q) p)-
      coordinateDerivative i (pressure ε t) p := by
  rw [flow_time,flow_laplacian,pressure_partial]
  simp_rw [flow_partial]
  rw [advection_identity (flow ε t p) (flowD ε t p) (stream ε t p) eigenvalue
    (streamD ε t p) (flow_curl ε t p) (streamD_flow ε t p)]
  ring

theorem smooth_flow (ε : ℝ) (i : Fin 3) :
    ContDiff ℝ ⊤ (fun tx : ℝ × Point => flow ε tx.1 tx.2 i) := by
  dsimp [flow,amplitude,field,addFour,term,phase]
  fun_prop

theorem smooth_pressure (ε : ℝ) :
    ContDiff ℝ ⊤ (fun tx : ℝ × Point => pressure ε tx.1 tx.2) := by
  dsimp [pressure,flow,stream,amplitude,field,profile,addFour,term,scalarTerm,phase]
  fun_prop

theorem phase_shift (m : Fin 4) (p : Point) (n : Fin 3 → ℤ) :
    ∃ k : ℤ, phase m (fun i => p i+n i) = phase m p+k*frequency := by
  fin_cases m
  · refine ⟨2*n 0-n 1,?_⟩; norm_num [phase,waveVector]; ring
  · refine ⟨2*n 0+n 1,?_⟩; norm_num [phase,waveVector]; ring
  · refine ⟨n 0-2*n 1,?_⟩; norm_num [phase,waveVector]; ring
  · refine ⟨n 0+2*n 1,?_⟩; norm_num [phase,waveVector]; ring

theorem periodic_term (m : Fin 4) (p : Point) (n : Fin 3 → ℤ) (i : Fin 3) :
    term m (fun j => p j+n j) i = term m p i := by
  obtain ⟨k,hk⟩ := phase_shift m p n
  simp [term,hk,frequency,Real.sin_add_int_mul_two_pi]

theorem periodic_scalar (m : Fin 4) (p : Point) (n : Fin 3 → ℤ) :
    scalarTerm m (fun j => p j+n j) = scalarTerm m p := by
  obtain ⟨k,hk⟩ := phase_shift m p n
  simp [scalarTerm,hk,frequency,Real.cos_add_int_mul_two_pi]

theorem periodic_flow (ε t : ℝ) (p : Point) (n : Fin 3 → ℤ) :
    flow ε t (fun j => p j+n j) = flow ε t p := by
  funext i
  simp [flow,field,addFour,periodic_term]

theorem periodic_pressure (ε t : ℝ) (p : Point) (n : Fin 3 → ℤ) :
    pressure ε t (fun j => p j+n j) = pressure ε t p := by
  simp [pressure,periodic_flow,stream,profile,addFour,periodic_scalar]

#print axioms profile_original_formula
#print axioms fieldD_at_origin
#print axioms flow_curl
#print axioms flow_divergence
#print axioms solves_unforced_navier_stokes
#print axioms smooth_flow
#print axioms smooth_pressure
#print axioms periodic_flow
#print axioms periodic_pressure
end
end HistoryPlanarBase
