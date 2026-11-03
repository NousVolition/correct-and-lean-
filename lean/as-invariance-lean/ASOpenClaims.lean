import ASModel

/- These are precise remaining proof obligations, not theorems or axioms.
No `sorry` is used. The verified Comparator targets are listed separately.
Finite jumps in the forcing are allowed; all equations stay unchanged. -/
namespace SocialAS.Open
open SocialAS
noncomputable section

def PiecewiseContinuousBounded (f : ℝ → ℝ) (a b : ℝ) : Prop :=
  ∃ cuts : Finset ℝ,
    ContinuousOn f (Set.Icc a b \ (cuts : Set ℝ)) ∧
    ∃ M : ℝ, ∀ t ∈ Set.Icc a b, |f t| ≤ M
def RegularInputs (i : ℝ → Inputs) (a b : ℝ) : Prop :=
  PiecewiseContinuousBounded (fun t => (i t).utility) a b ∧
  PiecewiseContinuousBounded (fun t => indicator (i t).adverseForward * (i t).exposureForward) a b ∧
  PiecewiseContinuousBounded (fun t => indicator (i t).adverseReverse * (i t).exposureReverse) a b ∧
  PiecewiseContinuousBounded (fun t => (i t).clearForward) a b ∧
  PiecewiseContinuousBounded (fun t => (i t).clearReverse) a b ∧
  PiecewiseContinuousBounded (fun t => (i t).clarifySmoke) a b ∧
  PiecewiseContinuousBounded (fun t => (i t).clarifyClay) a b

def FullExistenceUniqueness : Prop :=
  ∀ (p : Parameters) (i : ℝ → Inputs) (a b : ℝ) (initial : State),
    ParametersOK p → (∀ t ∈ Set.Icc a b, InputsOK (i t)) →
    RegularInputs i a b → a ≤ b → StateOK initial →
    ∃ trajectory, IntegralSolution p i a b initial trajectory ∧
      ∀ other, IntegralSolution p i a b initial other →
        Set.EqOn trajectory other (Set.Icc a b)

def FullStateInvariance : Prop :=
  ∀ (p : Parameters) (i : ℝ → Inputs) (a b : ℝ) (initial : State)
    (trajectory : ℝ → State),
    ParametersOK p → (∀ t ∈ Set.Icc a b, InputsOK (i t)) →
    RegularInputs i a b → a ≤ b → StateOK initial →
    IntegralSolution p i a b initial trajectory →
    ∀ t ∈ Set.Icc a b, StateOK (trajectory t)

def FullSuppressionComparison : Prop :=
  ∀ (p : Parameters) (i : ℝ → Inputs) (a b : ℝ) (initial : State)
    (suppressed baseline : ℝ → State),
    ParametersOK p → (∀ t ∈ Set.Icc a b, InputsOK (i t)) →
    RegularInputs i a b → a ≤ b → StateOK initial →
    IntegralSolution p i a b initial suppressed →
    IntegralSolution {p with chiMax := 0} i a b initial baseline →
    ∀ t ∈ Set.Icc a b, suppressed t 1 ≤ baseline t 1 ∧ suppressed t 2 ≤ baseline t 2

end
end SocialAS.Open
