import Mathlib

/-! Seven named roles and the supplied real skew matrix. The definitions below
    fix the mathematical meaning of the scalar bracket. -/

open scoped BigOperators
noncomputable section

inductive Wizard : Type
  | hearth      : Wizard  -- W₀: The Living Flame / Conserved Dissipation Core (Φ = 2μ D:D)
  | timekeeper  : Wizard  -- W₁: Unsteady Acceleration (ρ ∂u/∂t)
  | courier     : Wizard  -- W₂: Convection (ρ (u · ∇)u)
  | sculptor    : Wizard  -- W₃: Pressure Gradient (-∇p)
  | weaver      : Wizard  -- W₄: Viscous Diffusion (μ ∇²u)
  | titan       : Wizard  -- W₅: External Body Forcing (f)
  | gatekeeper  : Wizard  -- W₆: Incompressibility / Solenoidal Constraint (∇ · u = 0)
  deriving DecidableEq, Repr

namespace Wizard

/-- Canonical index mapping to `Fin 7`. -/
def toFin : Wizard → Fin 7
  | .hearth      => ⟨0, by decide⟩
  | .timekeeper  => ⟨1, by decide⟩
  | .courier     => ⟨2, by decide⟩
  | .sculptor    => ⟨3, by decide⟩
  | .weaver      => ⟨4, by decide⟩
  | .titan       => ⟨5, by decide⟩
  | .gatekeeper  => ⟨6, by decide⟩

/-- Inverse mapping from `Fin 7` to `Wizard`. -/
def fromFin : Fin 7 → Wizard
  | ⟨0, _⟩ => .hearth
  | ⟨1, _⟩ => .timekeeper
  | ⟨2, _⟩ => .courier
  | ⟨3, _⟩ => .sculptor
  | ⟨4, _⟩ => .weaver
  | ⟨5, _⟩ => .titan
  | ⟨6, _⟩ => .gatekeeper

end Wizard

structure CommutatorMatrix where
  κ : Matrix (Fin 7) (Fin 7) ℝ
  skew_symm : ∀ i j : Fin 7, κ i j = - κ j i

namespace CommutatorMatrix

variable (C : CommutatorMatrix)

def bracket (w₁ w₂ : Wizard) (Φ : ℝ) : ℝ :=
  C.κ w₁.toFin w₂.toFin * Φ


abbrev WizardVector := Fin 7 → ℝ

/-- Bilinear extension of the values on wizard pairs. -/
def form (Φ : ℝ) (v w : WizardVector) : ℝ :=
  Φ * ∑ i, ∑ j, v i * C.κ i j * w j

def basis (a : Fin 7) : WizardVector := fun k => if k=a then 1 else 0

/-- An optional vector-valued bracket. Its output lies along the Hearth basis vector. -/
def hearthLift (Φ : ℝ) (v w : WizardVector) : WizardVector :=
  fun k => if k=Wizard.hearth.toFin then C.form Φ v w else 0

def CentralHearth : Prop := ∀ j, C.κ Wizard.hearth.toFin j=0

def jacobiSum (Φ : ℝ) (u v w : WizardVector) : WizardVector :=
  C.hearthLift Φ u (C.hearthLift Φ v w) +
  C.hearthLift Φ v (C.hearthLift Φ w u) +
  C.hearthLift Φ w (C.hearthLift Φ u v)

def entries (i j : Fin 7) : ℝ :=
  if (i=0 ∧ j=1) ∨ (i=2 ∧ j=3) then 1 else 0

/-- A skew matrix with two nonzero pairs. -/
def twoPairs : CommutatorMatrix where
  κ i j := entries i j-entries j i
  skew_symm i j := by ring

end CommutatorMatrix
end
