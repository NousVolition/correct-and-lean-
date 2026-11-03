import ActiveHugModel
import Volterra

namespace ActiveHug.Full
open Set
noncomputable section
abbrev Vec := Fin 8 → ℝ
def decode (x : Vec) : State := ⟨x 0,x 1,x 2,x 3,x 4,x 5,x 6,x 7⟩
def encode (s : State) : Vec := ![s.q,s.v,s.u,s.w,s.xA,s.xB,s.gAB,s.gBA]
def field (F : ℝ → ℝ) (t : ℝ) (x : Vec) : Vec := encode (rhs protocol (F t) (decode x))
def Admissible (x : Vec) : Prop := Hug.UnitInterval (x 6) ∧ Hug.UnitInterval (x 7)

-- All eight rates are the frozen primary directional protocol, without a
-- frozen guard, altered force law, cap on the dynamics, or omitted state.
-- Continuous prescribed force is the explicit input assumption.
def FullCoupledExistenceUniqueness : Prop :=
  ∀ (a b : ℝ) (F : ℝ → ℝ) (initial : Vec), a ≤ b →
    ContinuousOn F (Icc a b) → Admissible initial →
    ∃ x : ℝ → Vec, Volterra.Solution (field F) a b initial x ∧
      (∀ other, Volterra.Solution (field F) a b initial other → EqOn other x (Icc a b)) ∧
      (∀ t ∈ Ioo a b, HasDerivAt x (field F t (x t)) t) ∧
      (∀ t ∈ Icc a b, Admissible (x t))
end
end ActiveHug.Full
