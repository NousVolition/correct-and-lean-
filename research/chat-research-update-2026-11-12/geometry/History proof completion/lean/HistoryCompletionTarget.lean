import HistoryParameterSelection
import HistoryScalarLift

/-!
The exact end-to-end target. FullPairExists is a proposition, not a proved
theorem. A final completion must supply a closed proof of FullPairExists.
Compiling this definition or the conditional corollary below is not completion.
-/
set_option autoImplicit false
namespace HistoryCompletionTarget
noncomputable section
open Set HistoryPlanarBase
open scoped BigOperators ContDiff
def tag : ℝ := 589/500
def tick41 : ℝ := 6/5
def markerA : Point := fun _ => 0
def markerB : Point := ![0,0,1/4]
def pathA (t : ℝ) : Point := ![0,(t-tick41)/10,0]
def targetSwirl : ℝ := 4*Real.pi*Real.exp (-viscosity*(4*Real.pi)^2*tick41)
def curl (u : ℝ → Point → Point) (t : ℝ) (p : Point) : Point :=
  HistoryScalarLift.actualCurl (u t) p
def swirlSizeSq (u : ℝ → Point → Point) (t : ℝ) (p : Point) : ℝ :=
  ∑ i : Fin 3, (curl u t p i)^2
def distanceToImageSq (p : Point) (n : Fin 3 → ℤ) : ℝ :=
  ∑ i : Fin 3, (p i-markerB i-(n i : ℝ))^2

def Allowed (u : ℝ → Point → Point) (p : ℝ → Point → ℝ) : Prop :=
  (∀ i, ContDiffOn ℝ ∞ (fun tx : ℝ × Point => u tx.1 tx.2 i) {tx | 0 ≤ tx.1}) ∧
  ContDiffOn ℝ ∞ (fun tx : ℝ × Point => p tx.1 tx.2) {tx | 0 ≤ tx.1} ∧
  (∀ t, 0 ≤ t → ∀ x (n : Fin 3 → ℤ), u t (fun i => x i+n i) = u t x) ∧
  (∀ t, 0 ≤ t → ∀ x (n : Fin 3 → ℤ), p t (fun i => x i+n i) = p t x) ∧
  (∀ t, 0 ≤ t → ∀ x, (∑ i : Fin 3, coordinateDerivative i (fun y => u t y i) x) = 0) ∧
  (∀ t, 0 < t → ∀ x i,
    deriv (fun r => u r x i) t+
      (∑ j : Fin 3, u t x j*coordinateDerivative j (fun y => u t y i) x) =
    viscosity*(∑ j : Fin 3, coordinateDerivative j
      (fun y => coordinateDerivative j (fun z => u t z i) y) x)-coordinateDerivative i (p t) x)

structure FluidState where
  velocity : ℝ → Point → Point
  pressure : ℝ → Point → ℝ
  allowed : Allowed velocity pressure
  materialA : ∀ t ∈ Icc tag tick41, ∀ i,
    HasDerivAt (fun r => pathA r i) (velocity t (pathA t) i) t
  positive_paddle_history : ∀ t ∈ Icc tag tick41, 0 < swirlSizeSq velocity t (pathA t)
  paddle_at_tick : curl velocity tick41 markerA = ![0,targetSwirl,0]
  line : ℝ → Point
  line_starts : line 0 = markerA
  line_equation : ∀ r i, HasDerivAt (fun s => line s i) (curl velocity tick41 (line r) i) r
  line_swirl_floor : ∀ r, targetSwirl^2/16 ≤ swirlSizeSq velocity tick41 (line r)
  closest_bound : ∀ r (n : Fin 3 → ℤ), (1/4 : ℝ)^2 ≤ distanceToImageSq (line r) n

def Closed (s : FluidState) : Prop :=
  ∃ r : ℝ, 0 < r ∧ ∀ i : Fin 3, ∃ n : ℤ, s.line r i = (n : ℝ)

abbrev Times := HistoryMatchCore.Times tag tick41
abbrev Observation := (Times → Point) × (Times → Point) × (Point × ℝ × ℝ)
def observation (s : FluidState) : Observation :=
  ((fun t => pathA t.val), (fun t => curl s.velocity t.val (pathA t.val)), (markerA,1/4,0))
def property (s : FluidState) : Bool := by
  classical
  exact decide (Closed s)

/-- This is the proposition still awaiting an unconditional proof. -/
def FullPairExists : Prop := ∃ closed openState : FluidState,
  closed.pressure = openState.pressure ∧
  (∀ t ∈ Icc tag tick41,
    curl closed.velocity t (pathA t) = curl openState.velocity t (pathA t)) ∧
  Closed closed ∧ ¬Closed openState

theorem start_attains_closest_reading (s : FluidState) :
    s.line 0 = markerA ∧ distanceToImageSq (s.line 0) (fun _ => 0) = (1/4 : ℝ)^2 := by
  refine ⟨s.line_starts,?_⟩
  rw [s.line_starts]
  norm_num [distanceToImageSq,markerA,markerB,Fin.sum_univ_succ]

theorem path_at_tick : pathA tick41 = markerA := by
  funext i
  fin_cases i <;> simp [pathA,markerA]

/-- Conditional only: this consumes the still-unproved complete pair. -/
theorem full_pair_rules_out_exact_reader (h : FullPairExists) :
    ¬ ∃ reader : Observation → Bool, ∀ s : FluidState, reader (observation s) = property s := by
  obtain ⟨a,b,hp,hh,ha,hb⟩ := h
  have same : observation a = observation b := by
    have hw : (fun t : Times => curl a.velocity t.val (pathA t.val)) =
        (fun t : Times => curl b.velocity t.val (pathA t.val)) := by
      funext t
      exact hh t.val t.property
    simp only [observation,hw]
  have different : property a ≠ property b := by simp [property,ha,hb]
  exact SIMSLatentReadout.no_exact_reader_of_ambiguous_observation observation property a b same different

#print axioms start_attains_closest_reading
#print axioms path_at_tick
#print axioms full_pair_rules_out_exact_reader
end
end HistoryCompletionTarget
