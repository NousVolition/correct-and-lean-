import CWDefinitions

namespace HugV3.Source.HearthReadout
noncomputable section
open CW
open scoped BigOperators

/-- Vary only velocity to ask a directional question of the actual full-state heat. -/
def atVelocity (s : State) (v : Vector) : State :=
  {s with g := fun x k => if h : k.val<3 then v x ⟨k.val,h⟩ else s.g x k}

def strainAt (v : Vector) (x : Grid) : Mat := symm (gridGradient v x)
def thermalForm (s : State) (u v : Vector) : ℝ :=
  (∑ x, 2*viscosity s x*(∑ i, ∑ j, strainAt u x i j*strainAt v x i j))/4096
def kinetic (u : Vector) : ℝ := inner u u/2
def ordered (s : State) : Vector := directionalBracket s (velocity s)
def heatReading (s : State) : ℝ := 2*thermalForm s (velocity s) (ordered s)
def workReading (s : State) : ℝ := inner (velocity s) (ordered s)
def bracketHeat (s : State) : ℝ := thermalForm s (ordered s) (ordered s)
def retained (v : Vector) : Prop :=
  (∀ i x, filt (fun y => v y i) x=v x i) ∧ project v=v

end
end HugV3.Source.HearthReadout
