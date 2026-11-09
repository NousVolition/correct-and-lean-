import FullChecks

namespace HugNavierWellposedness
noncomputable section
open HugNavierSingle Set

-- The requested full theorem, copied as a target, has the status of a proposition.
def RequestedExistenceAndUniqueness : Prop :=
  FullExistenceStatement ∧ FullUniquenessStatement

def perturbation (n : ℕ) (r : Point) : ℝ :=
  (1 / (n:ℝ)^2) * Real.cos ((n:ℝ)*r.1)

def nearby (n : ℕ) : Fields :=
  { sourceInitial with xA := fun r => sourceInitial.xA r+perturbation n r }

def UniformlyClose (z w : Fields) (epsilon : ℝ) : Prop :=
  ∀ r, |z.ux r-w.ux r| ≤ epsilon ∧ |z.uy r-w.uy r| ≤ epsilon ∧
    |z.xA r-w.xA r| ≤ epsilon ∧ |z.xB r-w.xB r| ≤ epsilon ∧
    |z.gAB r-w.gAB r| ≤ epsilon ∧ |z.gBA r-w.gBA r| ≤ epsilon

def baseInput : FieldInputs := sourceInputs 1 1 .none

def rateDifference (n : ℕ) : ℝ :=
  (fieldRates baseInput 0 (nearby n) (fun _ => 0)).xA (0,0)-
  (fieldRates baseInput 0 sourceInitial (fun _ => 0)).xA (0,0)

-- Necessary even for this one family if the full raw RHS were locally
-- Lipschitz in the uniform size of the six fields near the original datum.
-- This is NOT a condition imposed on parabolic/mild-solution theories.
def UniformLocalRateBound : Prop :=
  ∃ radius constant : ℝ, 0 < radius ∧ 0 ≤ constant ∧
    ∀ n : ℕ, 0 < n → (1/(n:ℝ)^2) < radius →
      |rateDifference n| ≤ constant*(1/(n:ℝ)^2)

end
end HugNavierWellposedness
