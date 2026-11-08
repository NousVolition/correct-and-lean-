import WizardDefinitions
import V3SourceSystem

namespace HearthAudit
noncomputable section
open scoped BigOperators Interval
open Matrix

abbrev Space := Fin 3 → ℝ
abbrev Velocity := Space → Space

def partialAt (f : Space → ℝ) (x : Space) (j : Fin 3) : ℝ :=
  deriv (fun s => f (Function.update x j s)) (x j)

def gradient (u : Velocity) (x : Space) (i j : Fin 3) : ℝ :=
  partialAt (fun q => u q i) x j
def laplace (u : Velocity) (x : Space) (i : Fin 3) : ℝ :=
  ∑ j, partialAt (fun q => gradient u q i j) x j
def divergence (u : Velocity) (x : Space) : ℝ := ∑ j, gradient u x j j
def convection (u : Velocity) (x : Space) (i : Fin 3) : ℝ :=
  ∑ j, u x j * gradient u x i j
def strain (u : Velocity) (x : Space) (i j : Fin 3) : ℝ :=
  (gradient u x i j + gradient u x j i)/2
def vorticity (u : Velocity) (x : Space) : Space :=
  ![gradient u x 2 1-gradient u x 1 2,gradient u x 0 2-gradient u x 2 0,
    gradient u x 1 0-gradient u x 0 1]

def dissipation (μ : ℝ) (u : Velocity) (x : Space) : ℝ :=
  2*μ*(∑ i, ∑ j, (strain u x i j)^2)
def convLap (u : Velocity) (x : Space) : ℝ :=
  ∑ i, convection u x i*laplace u x i
def stretching (u : Velocity) (x : Space) : ℝ :=
  ∑ i, ∑ j, vorticity u x i*strain u x i j*vorticity u x j
def cubeIntegral (f : Space → ℝ) : ℝ :=
  ∫ y in (0:ℝ)..2*Real.pi, ∫ x in (0:ℝ)..2*Real.pi,
    ∫ z in (0:ℝ)..2*Real.pi, f ![x,y,z]

def shear (x : Space) : Space := fun i => if i=0 then Real.sin (x 1) else 0

-- Exactly the displayed proposition in the supplied companion, rearranged only in notation.
def companionIdentity (μ : ℝ) (u : Velocity) : Prop :=
  μ*cubeIntegral (convLap u)=μ*cubeIntegral (stretching u)-cubeIntegral (dissipation μ u)

end
end HearthAudit
