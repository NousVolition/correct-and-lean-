import V3SourceSocial
namespace HugV3.Source
noncomputable section
attribute [local instance] Classical.propDecidable
open scoped BigOperators
open Finset

def velocity (s : State) : Vector := fun x j => s.g x ⟨j.val, by omega⟩
def fiber (G : Geometry) (s : State) (p : Particle) (k : Direction) : Vec :=
  fun i => ∑ j, s.F p i j*G.directions k j
def velocityGradient (s : State) (x : Grid) : Mat :=
  fun i j => grad (fun y => velocity s y i) x j
def particleGradient (s : State) (p : Particle) : Mat :=
  fun i j => ∑ x, M s.X p x*velocityGradient s x i j
def fiberStrain (G : Geometry) (s : State) (p : Particle) (k : Direction) : ℝ :=
  (sqnorm (fiber G s p k)-1)/2
def fiberRate (G : Geometry) (s : State) (p : Particle) (k : Direction) : ℝ :=
  ∑ i, ∑ j, fiber G s p k i*symm (particleGradient s p) i j*fiber G s p k j
def effective (s : State) (p : Particle) (k : Direction) (a : Fin 2) : ℝ :=
  1-Real.exp (-s.m p k a/0.2)
def rawRate (G : Geometry) (s : State) (p : Particle) (k : Direction) (a : Fin 2) : ℝ :=
  let v := max (if a=0 then fiberRate G s p k else -fiberRate G s p k) 0
  (v/Real.sqrt (v^2+0.04^2))^2
def sensitivity (G : Geometry) (s : State) (p : Particle) (k : Direction) (a : Fin 2) : ℝ :=
  0.5*0.18*Real.exp (-s.m p k a/0.2)/0.2*(fiberStrain G s p k)^2*G.directionWeights k
def materialStress (G : Geometry) (s : State) (p : Particle) : Mat := fun i j =>
  0.08*((∑ k, s.F p i k*s.F p j k)-eye i j)+
  ∑ k, 0.18*(∑ a, effective s p k a)*G.directionWeights k*
    fiberStrain G s p k*fiber G s p k i*fiber G s p k j
def extraConductivity (G : Geometry) (s : State) (p : Particle) : Mat := fun i j =>
  ∑ k, 0.009*(∑ a, effective s p k a)*G.directionWeights k*
    (fiber G s p k i/Real.sqrt (sqnorm (fiber G s p k)))*
    (fiber G s p k j/Real.sqrt (sqnorm (fiber G s p k)))
def viscosity (s : State) (x : Grid) : ℝ := 0.015*Real.exp (-0.35*tanh (s.g x 4/0.03))
def viscousHeat (s : State) (x : Grid) : ℝ :=
  2*viscosity s x*(∑ i, ∑ j, (symm (velocityGradient s x) i j)^2)
def occupancy (G : Geometry) (s : State) (x : Grid) : ℝ := (∑ p, R s.X p x*G.V p)/dv
def available (G : Geometry) (s : State) (p : Particle) : ℝ :=
  ∑ x, R s.X p x*viscousHeat s x/(1+occupancy G s x)
def rawPower (G : Geometry) (s : State) (p : Particle) : ℝ :=
  ∑ k, ∑ a, sensitivity G s p k a*rawRate G s p k a
def powerDenominator (G : Geometry) (s : State) (p : Particle) : ℝ :=
  0.00001+0.7*available G s p+rawPower G s p
def extraction (G : Geometry) (s : State) (x : Grid) : ℝ :=
  0.7*viscousHeat s x/(1+occupancy G s x)*
    (∑ p, R s.X p x*G.V p*rawPower G s p/powerDenominator G s p)/dv
def releaseGrid (G : Geometry) (s : State) (x : Grid) : ℝ :=
  (∑ p, R s.X p x*G.V p*fabricHeat s p)/dv
def conductivity (G : Geometry) (s : State) (x : Grid) : Mat := fun i j =>
  (∑ p, R s.X p x*G.V p*extraConductivity G s p i j)/dv+0.006*eye i j
def heatFlux (G : Geometry) (s : State) : Vector := fun x i =>
  -(∑ j, conductivity G s x i j*grad (fun y => s.g y 4) x j)
def fullStress (G : Geometry) (s : State) (x : Grid) : Mat := fun i j =>
  (∑ p, M s.X p x*G.V p*(materialStress G s p i j+fabricStress s p i j))/dv
def centeredGradient (s : State) (x : Grid) : Vec := fun j =>
  (s.g (shifted x j 1) 3-s.g (shifted x j 15) 3)/(2*dx)
def forcing (s : State) : Vector := fun x =>
  ![-0.16*activation (Real.sqrt (sqnorm (centeredGradient s x)+0.003^2)-
      Real.sqrt (0.015^2+0.003^2)),0,0]
def momentumRate (G : Geometry) (s : State) : Vector :=
  let L := velocityGradient s
  let curl := fun x => ![L x 2 1-L x 1 2,L x 0 2-L x 2 0,L x 1 0-L x 0 1]
  project fun x i => cross (velocity s x) (curl x) i+
    divergence (fun y j => 2*viscosity s y*symm (L y) i j) x+
    divergence (fun y j => fullStress G s y i j) x+forcing s x i

def rhsFromRecords (G : Geometry) (t : ℝ) (s : State)
    (records : List (Fin 4 × Record)) : State :=
  let social := socialRates G t s records
  let kernel := fun x => (∑ p, R s.X p x*social.sourceWeights p)/dv
  let du := momentumRate G s
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
    ledger := ![s.A,(∑ x, dot (velocity s x) (forcing s x))/4096,
      (∑ x, extraction G s x)/4096,
      (∑ x, (viscousHeat s x-extraction G s x+releaseGrid G s x))/4096]
    writeWork := 0
    expression := social.expression, context := social.context, normCenter := social.normCenter
    logRadius := social.logRadius, relation := social.relation, responses := social.responses
    association := social.association }

-- Exact-real partial-domain checks. The source uses exceptions/nonfinite
-- values for failed evaluation; no successful ODE state is assigned to them.
def rhs (G : Geometry) (t : ℝ) (s : State) : Option State := do
  let records ← readRecords s
  if (∀ p k, sqnorm (fiber G s p k)≠0) ∧
      (∀ pair ∈ records, outcomeValid pair.2.observed ∧ outcomeValid pair.2.report) ∧
      (∀ i j, 0.12+exposure G s records i j≠0) ∧
      (∀ x, 1+occupancy G s x≠0) ∧ (∀ p, powerDenominator G s p≠0)
    then some (rhsFromRecords G t s records) else none

def initial (G : Geometry) : State :=
  let θ := fun x : Grid => 0.03*Real.exp (-(
    (((x 0).val/16:ℝ)-1/2)^2/0.19^2+
    (((x 1).val/16:ℝ)-1/2)^2/0.14^2+
    (((x 2).val/16:ℝ)-1/2)^2/0.16^2)/2)
  { g := fun x k => if k=4 then filt θ x else 0
    X := G.X₀, F := fun _ => eye, m := fun _ _ _ => 0, b := fun _ => -1/50
    A := 0, ledger := fun _ => 0, writeWork := 0
    expression := intent, context := home, normCenter := fun i k => 0.65*intent i k
    logRadius := fun _ _ => Real.log 0.72
    relation := fun i j k => mask i j*(![(∑ l, home i l*recognitionBase j l),
      (∑ l, home i l*authorityBase j l),0.5] k)
    responses := fun _ _ _ => 0, association := fun _ _ _ => 0 }

end
end HugV3.Source
