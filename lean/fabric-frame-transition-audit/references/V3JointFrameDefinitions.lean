import V3CovarianceProofs

/-! Coordinate comparison for the SAME constant external physical direction.
The original source modules remain unchanged. These functions expose its
components d in a chosen spatial frame; d=e_x recovers the original definitions.
Material reference axes, actor indices, parameters and memory laws stay fixed.
No state-dependent or time-dependent driving rule is introduced. -/
namespace HugV3.Source.JointFrame
noncomputable section
attribute [local instance] Classical.propDecidable
open Covariance Delay
open scoped BigOperators

def referenceDirection : Vec := ![1,0,0]
def forceAmplitude (s : State) (x : Grid) : ℝ :=
  -0.16*activation (Real.sqrt (sqnorm (centeredGradient s x)+0.003^2)-
    Real.sqrt (0.015^2+0.003^2))
def directedForce (d : Vec) (s : State) : Vector :=
  fun x i => forceAmplitude s x*d i
def scalarPull (f : Scalar) : Scalar := fun x => f (inverseQuarterGrid x)
def vectorPull (v : Vector) : Vector := fun x => quarterVector (v (inverseQuarterGrid x))
def forwardQuarterGrid (x : Grid) : Grid := ![reflectedIndex (x 1),x 0,x 2]
def quarterFabric (F : Particle → Mat) : Particle → Mat :=
  fun p i j => quarterVector (fun k => F p k j) i
def quarterFull (y : FullState) : FullState :=
  ⟨quarterState y.state, fun id => (y.starts id).map quarterFabric⟩
def conjugateQuarter (L : Mat) : Mat :=
  mm (mm YMAudit.quarterTurn L) (fun i j => YMAudit.quarterTurn j i)

def momentumInFrame (d : Vec) (G : Geometry) (s : State) : Vector :=
  let L := velocityGradient s
  let curl := fun x => ![L x 2 1-L x 1 2,L x 0 2-L x 2 0,L x 1 0-L x 0 1]
  project fun x i => cross (velocity s x) (curl x) i+
    divergence (fun y j => 2*viscosity s y*symm (L y) i j) x+
    divergence (fun y j => fullStress G s y i j) x+directedForce d s x i

def ratesInFrame (d : Vec) (G : Geometry) (t : ℝ) (s : State)
    (records : List (Fin 4 × Record)) : State :=
  let social := socialRates G t s records
  let kernel := fun x => (∑ p, R s.X p x*social.sourceWeights p)/dv
  let du := momentumInFrame d G s
  let dC := fun x => contextTransport (fun y => s.g y 3) (velocity s) x+s.A*kernel x
  let dθ := fun x => -divergence (fun y j => velocity s y j*s.g y 4+heatFlux G s y j) x+
    viscousHeat s x-extraction G s x+releaseGrid G s x
  { g := fun x k => if h : k.val<3 then filt (fun y => du y ⟨k.val,h⟩) x
      else if k=3 then dC x else filt dθ x
    X := fun p i => ∑ x, M s.X p x*velocity s x i
    F := fun p => mm (particleGradient s p) (s.F p)
    m := fun p k a => (0.7*available G s p/powerDenominator G s p)*rawRate G s p k a
    b := fun l => fabricRate (fabricStrain s.F l) (s.b l)
    A := 0.08*social.utility
    ledger := ![s.A,(∑ x, dot (velocity s x) (directedForce d s x))/4096,
      (∑ x, extraction G s x)/4096,
      (∑ x, (viscousHeat s x-extraction G s x+releaseGrid G s x))/4096]
    writeWork := 0
    expression := social.expression, context := social.context, normCenter := social.normCenter
    logRadius := social.logRadius, relation := social.relation, responses := social.responses
    association := social.association }

def acceptedInFrame (d : Vec) (G : Geometry) (t : ℝ) (s : State) : Option State := do
  let records ← readRecords s
  if (∀ p k, sqnorm (fiber G s p k)≠0) ∧
      (∀ pair ∈ records, outcomeValid pair.2.observed ∧ outcomeValid pair.2.report) ∧
      (∀ i j, 0.12+exposure G s records i j≠0) ∧
      (∀ x, 1+occupancy G s x≠0) ∧ (∀ p, powerDenominator G s p≠0)
    then some (ratesInFrame d G t s records) else none

def delayedInFrame (d : Vec) (G : Geometry) (t : ℝ)
    (present past : State) : Option State := do
  let currentRate ← acceptedInFrame d G t present
  let bufferedRate ← acceptedInFrame d G t (socialFrom present past)
  return socialFrom currentRate bufferedRate

def SameNonDrivingRates (a b : State) : Prop :=
  (∀ x, a.g x 3=b.g x 3 ∧ a.g x 4=b.g x 4) ∧
  a.X=b.X ∧ a.F=b.F ∧ a.m=b.m ∧ a.b=b.b ∧ a.A=b.A ∧ a.writeWork=b.writeWork ∧
  a.ledger 0=b.ledger 0 ∧ a.ledger 2=b.ledger 2 ∧ a.ledger 3=b.ledger 3 ∧ SameSocial a b

/-- Concrete remaining hypotheses for spatial covariance of heat deposition.
They are not assumed axioms, nor proved grid identities in this module. -/
def ThermalFrameCompatibility : Prop :=
  (∀ X p x, R (fun p => quarterVector (X p)) p x=R X p (inverseQuarterGrid x)) ∧
  (∀ f : Scalar, filt (scalarPull f)=scalarPull (filt f))

end
end HugV3.Source.JointFrame
