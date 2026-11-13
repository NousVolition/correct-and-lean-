import HistoryPlanarBase

/-!
Reduction from an actual smooth scalar evolution to a full three-dimensional
unforced fluid. All derivative certificates refer to the actual functions.
No existence of ScalarEvolution is asserted in this file.
-/
set_option autoImplicit false
set_option maxHeartbeats 4000000
namespace HistoryScalarLift
noncomputable section
open Set HistoryPlanarBase
open scoped BigOperators ContDiff

/-- The unresolved analytic object. Smoothness is on t ≥ 0; the time
equation is required for t > 0, so no backward heat evolution is assumed. -/
structure ScalarEvolution (ε : ℝ) (initial : Point → ℝ) where
  value : ℝ → Point → ℝ
  timeD : ℝ → Point → ℝ
  spaceD : ℝ → Point → Fin 3 → ℝ
  spaceDD : ℝ → Point → Fin 3 → ℝ
  time_derivative : ∀ t, 0 < t → ∀ p,
    HasDerivAt (fun r => value r p) (timeD t p) t
  space_derivative : ∀ t, 0 ≤ t → ∀ p j,
    HasDerivAt (fun r => value t (Function.update p j r)) (spaceD t p j) (p j)
  second_derivative : ∀ t, 0 ≤ t → ∀ p j,
    HasDerivAt (fun r => spaceD t (Function.update p j r) j) (spaceDD t p j) (p j)
  smooth : ContDiffOn ℝ ∞ (fun tx : ℝ × Point => value tx.1 tx.2) {tx | 0 ≤ tx.1}
  periodic : ∀ t, 0 ≤ t → ∀ p (n : Fin 3 → ℤ), value t (fun j => p j+n j) = value t p
  initial_value : ∀ p, value 0 p = initial p
  zero_z_derivative : ∀ t, 0 ≤ t → ∀ p, spaceD t p 2 = 0
  equation : ∀ t, 0 < t → ∀ p,
    timeD t p+flow ε t p 0*spaceD t p 0+flow ε t p 1*spaceD t p 1 =
    viscosity*(∑ j : Fin 3, spaceDD t p j)

variable {ε : ℝ} {initial : Point → ℝ}

def liftedFlow (α : ℝ) (H : ScalarEvolution ε initial) (t : ℝ) (p : Point) (i : Fin 3) : ℝ :=
  if i=2 then α*H.value t p else flow ε t p i
def liftedD (α : ℝ) (H : ScalarEvolution ε initial) (t : ℝ) (p : Point) (i j : Fin 3) : ℝ :=
  if i=2 then α*H.spaceD t p j else flowD ε t p i j
def liftedDD (α : ℝ) (H : ScalarEvolution ε initial) (t : ℝ) (p : Point) (i j : Fin 3) : ℝ :=
  if i=2 then α*H.spaceDD t p j else flowDD ε t p i j
def liftedTimeD (α : ℝ) (H : ScalarEvolution ε initial) (t : ℝ) (p : Point) (i : Fin 3) : ℝ :=
  if i=2 then α*H.timeD t p else -viscosity*eigenvalue*flow ε t p i

@[simp] theorem base_vertical (ε t : ℝ) (p : Point) : flow ε t p 2 = 0 := by
  simp [flow,field,term,addFour,direction]

@[simp] theorem base_z_derivative (ε t : ℝ) (p : Point) (i : Fin 3) : flowD ε t p i 2 = 0 := by
  simp [flowD,fieldD,termD,addFour,phaseD,waveVector]

@[simp] theorem base_vertical_derivative (ε t : ℝ) (p : Point) (j : Fin 3) : flowD ε t p 2 j = 0 := by
  simp [flowD,fieldD,termD,addFour,direction]

@[simp] theorem base_pressure_z (ε t : ℝ) (p : Point) :
    coordinateDerivative 2 (pressure ε t) p = 0 := by
  rw [pressure_partial,streamD_flow]
  simp

theorem lifted_partial (α : ℝ) (H : ScalarEvolution ε initial)
    (t : ℝ) (ht : 0 ≤ t) (p : Point) (i j : Fin 3) :
    coordinateDerivative j (fun q => liftedFlow α H t q i) p = liftedD α H t p i j := by
  by_cases hi : i=2
  · simpa [coordinateDerivative,liftedFlow,liftedD,hi] using
      ((H.space_derivative t ht p j).const_mul α).deriv
  · simpa [coordinateDerivative,liftedFlow,liftedD,hi] using flow_partial ε t p i j

theorem lifted_second (α : ℝ) (H : ScalarEvolution ε initial)
    (t : ℝ) (ht : 0 ≤ t) (p : Point) (i j : Fin 3) :
    coordinateDerivative j (fun q => coordinateDerivative j (fun r => liftedFlow α H t r i) q) p =
      liftedDD α H t p i j := by
  simp_rw [lifted_partial α H t ht]
  by_cases hi : i=2
  · simpa [coordinateDerivative,liftedD,liftedDD,hi,flowD,flowDD] using
      ((H.second_derivative t ht p j).const_mul α).deriv
  · simp only [liftedD,liftedDD,if_neg hi]
    change deriv (fun r => amplitude ε t*fieldD (Function.update p j r) i j) (p j) =
      amplitude ε t*fieldDD p i j
    exact ((field_has_second i j p).const_mul (amplitude ε t)).deriv

theorem lifted_time (α : ℝ) (H : ScalarEvolution ε initial)
    (t : ℝ) (ht : 0 < t) (p : Point) (i : Fin 3) :
    deriv (fun r => liftedFlow α H r p i) t = liftedTimeD α H t p i := by
  by_cases hi : i=2
  · simpa [liftedFlow,liftedTimeD,hi] using ((H.time_derivative t ht p).const_mul α).deriv
  · simpa [liftedFlow,liftedTimeD,hi] using flow_time ε t p i

theorem lifted_divergence (α : ℝ) (H : ScalarEvolution ε initial)
    (t : ℝ) (ht : 0 ≤ t) (p : Point) :
    (∑ i : Fin 3, coordinateDerivative i (fun q => liftedFlow α H t q i) p) = 0 := by
  have hb := flow_divergence ε t p
  simp_rw [flow_partial] at hb
  simp_rw [lifted_partial α H t ht]
  simpa [Fin.sum_univ_succ,liftedD,H.zero_z_derivative t ht p] using hb

theorem lifted_solves_unforced_navier_stokes (α : ℝ) (H : ScalarEvolution ε initial)
    (t : ℝ) (ht : 0 < t) (p : Point) (i : Fin 3) :
    deriv (fun r => liftedFlow α H r p i) t+
      (∑ j : Fin 3, liftedFlow α H t p j*coordinateDerivative j (fun q => liftedFlow α H t q i) p) =
    viscosity*(∑ j : Fin 3, coordinateDerivative j
      (fun q => coordinateDerivative j (fun r => liftedFlow α H t r i) q) p)-
      coordinateDerivative i (pressure ε t) p := by
  rw [lifted_time α H t ht]
  simp_rw [lifted_second α H t ht.le,lifted_partial α H t ht.le]
  have hb := solves_unforced_navier_stokes ε t p i
  rw [flow_time] at hb
  simp_rw [flow_second,flow_partial] at hb
  have hh := H.equation t ht p
  have hz := H.zero_z_derivative t ht.le p
  fin_cases i
  · simpa [liftedTimeD,liftedFlow,liftedD,liftedDD,Fin.sum_univ_succ] using hb
  · simpa [liftedTimeD,liftedFlow,liftedD,liftedDD,Fin.sum_univ_succ] using hb
  · simp [liftedTimeD,liftedFlow,liftedD,liftedDD,Fin.sum_univ_succ,hz] at *
    linear_combination α*hh

def actualCurl (u : Point → Point) (p : Point) : Point :=
  curlOf (fun i j => coordinateDerivative j (fun q => u q i) p)

theorem lifted_actual_curl (α : ℝ) (H : ScalarEvolution ε initial)
    (t : ℝ) (ht : 0 ≤ t) (p : Point) :
    actualCurl (liftedFlow α H t) p =
      ![α*H.spaceD t p 1,-α*H.spaceD t p 0,eigenvalue*stream ε t p] := by
  have hc := flow_curl ε t p
  have hc2 := congrFun hc 2
  simp [curlOf] at hc2
  unfold actualCurl
  simp_rw [lifted_partial α H t ht]
  funext i
  fin_cases i <;> simp [curlOf,liftedD,hc2]

theorem lifted_smooth (α : ℝ) (H : ScalarEvolution ε initial) (i : Fin 3) :
    ContDiffOn ℝ ∞ (fun tx : ℝ × Point => liftedFlow α H tx.1 tx.2 i) {tx | 0 ≤ tx.1} := by
  by_cases hi : i=2
  · simpa [liftedFlow,hi] using (contDiffOn_const.mul H.smooth :
      ContDiffOn ℝ ∞ (fun tx : ℝ × Point => α*H.value tx.1 tx.2) {tx | 0 ≤ tx.1})
  · simpa [liftedFlow,hi] using ((smooth_flow ε i).of_le le_top).contDiffOn

theorem lifted_periodic (α : ℝ) (H : ScalarEvolution ε initial)
    (t : ℝ) (ht : 0 ≤ t) (p : Point) (n : Fin 3 → ℤ) :
    liftedFlow α H t (fun j => p j+n j) = liftedFlow α H t p := by
  funext i
  simp [liftedFlow,H.periodic t ht p n,periodic_flow]

theorem lifted_origin_stationary (α : ℝ) (H : ScalarEvolution ε initial)
    (hzero : ∀ t, 0 ≤ t → H.value t (fun _ => 0) = 0)
    (t : ℝ) (ht : 0 ≤ t) : liftedFlow α H t (fun _ => 0) = 0 := by
  have hb := profile_and_field_at_origin.2
  funext i
  simp [liftedFlow,flow,hzero t ht,hb]

/-- These are exact smooth periodic initial data from the analytic construction. -/
def tick41 : ℝ := 6/5
def initialS (p : Point) : ℝ :=
  Real.exp (viscosity*frequency^2*tick41)*Real.sin (frequency*p 0)
def initialF (p : Point) : ℝ :=
  Real.exp (viscosity*frequency^2*tick41)*(Real.cos (frequency*p 0)-Real.cos (frequency*p 1))
def initialG (p : Point) : ℝ :=
  Real.exp (2*viscosity*frequency^2*tick41)*Real.sin (frequency*p 0)*Real.sin (frequency*p 1)

/-- The local parameter range actually needed by the construction.
This is an outstanding existence obligation, not a proved theorem. -/
def SmallParameterThreeScalarExistence : Prop := ∃ r : ℝ, 0 < r ∧
  ∀ ε ∈ Ico (0 : ℝ) r,
    Nonempty (ScalarEvolution ε initialS) ∧
    Nonempty (ScalarEvolution ε initialF) ∧
    Nonempty (ScalarEvolution ε initialG)

#print axioms lifted_divergence
#print axioms lifted_solves_unforced_navier_stokes
#print axioms lifted_actual_curl
#print axioms lifted_smooth
#print axioms lifted_periodic
#print axioms lifted_origin_stationary
end
end HistoryScalarLift
