import Mathlib.Analysis.Calculus.ContDiff.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Deriv
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.MeasureTheory.Integral.IntervalIntegral.FundThmCalculus
import Mathlib.Tactic

/- One shared continuum. Exact coefficients and equations from
   sources/ns_fields_methods.md and its directional mode.
   This does not import, attach, or substitute the reduced mechanical Hug ODE.
   Encoding the equations is NOT an existence theorem.
   This corpus closure is explicitly provisional, not a unique derivation
   of the author's entire conceptual framework. -/
namespace HugNavierSingle
noncomputable section
open Set

def sigmoid (x : ℝ) : ℝ := 1 / (1 + Real.exp (-x))

abbrev Point := ℝ × ℝ
abbrev ScalarField := Point → ℝ

structure Fields where
  ux : ScalarField
  uy : ScalarField
  xA : ScalarField
  xB : ScalarField
  gAB : ScalarField
  gBA : ScalarField

def partialX (f : ScalarField) (r : Point) : ℝ := deriv (fun x => f (x,r.2)) r.1
def partialY (f : ScalarField) (r : Point) : ℝ := deriv (fun y => f (r.1,y)) r.2
def laplacian (f : ScalarField) (r : Point) : ℝ :=
  partialX (partialX f) r + partialY (partialY f) r
def advection (z : Fields) (f : ScalarField) (r : Point) : ℝ :=
  z.ux r * partialX f r + z.uy r * partialY f r

-- These are the source's nondimensional fluid coefficients; no substitution
-- of the dimensional shear/viscosity matching numbers from the earlier audit.
def viscosity (z : Fields) (r : Point) : ℝ := 1/50 + (1/25)*(z.gAB r+z.gBA r)
def stressXX (z : Fields) (r : Point) : ℝ := 2*viscosity z r*partialX z.ux r
def stressYY (z : Fields) (r : Point) : ℝ := 2*viscosity z r*partialY z.uy r
def stressXY (z : Fields) (r : Point) : ℝ :=
  viscosity z r*(partialY z.ux r+partialX z.uy r)
def strainSquared (z : Fields) (r : Point) : ℝ :=
  (partialX z.ux r)^2+(partialY z.uy r)^2+
    (1/2)*(partialY z.ux r+partialX z.uy r)^2

structure FieldInputs where
  weightAB : ℝ
  weightBA : ℝ
  sourceA : ℝ → ScalarField
  sourceB : ℝ → ScalarField

-- All six rates, retaining both components of full variable-viscosity stress
-- divergence, transport, scalar diffusion, reaction and directional guards.
def fieldRates (input : FieldInputs) (t : ℝ) (z : Fields) (pressure : ScalarField) : Fields :=
  ⟨(fun r => -advection z z.ux r-partialX pressure r+
       partialX (stressXX z) r+partialY (stressXY z) r),
   (fun r => -advection z z.uy r-partialY pressure r+
       partialX (stressXY z) r+partialY (stressYY z) r),
   (fun r => -advection z z.xA r+(1/50)*laplacian z.xA r+(-11/20-z.xA r)+
       input.weightAB*z.gAB r*(z.xB r-z.xA r)+input.sourceA t r),
   (fun r => -advection z z.xB r+(1/50)*laplacian z.xB r+(7/20-z.xB r)+
       input.weightBA*z.gBA r*(z.xA r-z.xB r)+input.sourceB t r),
   (fun r => -advection z z.gAB r+(3/200)*laplacian z.gAB r+
       (sigmoid (-2/5+2*(z.xB r-z.xA r)+(1/2)*strainSquared z r)-z.gAB r)/(3/5)),
   (fun r => -advection z z.gBA r+(3/200)*laplacian z.gBA r+
       (sigmoid (-2/5+2*(z.xA r-z.xB r)+(1/2)*strainSquared z r)-z.gBA r)/(3/5))⟩

def Periodic (f : ScalarField) : Prop :=
  ∀ r, f (r.1+2*Real.pi,r.2)=f r ∧ f (r.1,r.2+2*Real.pi)=f r
def SpatialRegularity (z : Fields) (pressure : ScalarField) : Prop :=
  ContDiff ℝ 2 z.ux ∧ ContDiff ℝ 2 z.uy ∧
  ContDiff ℝ 2 z.xA ∧ ContDiff ℝ 2 z.xB ∧
  ContDiff ℝ 2 z.gAB ∧ ContDiff ℝ 2 z.gBA ∧ ContDiff ℝ 1 pressure
def PeriodicFields (z : Fields) (pressure : ScalarField) : Prop :=
  Periodic z.ux ∧ Periodic z.uy ∧ Periodic z.xA ∧ Periodic z.xB ∧
    Periodic z.gAB ∧ Periodic z.gBA ∧ Periodic pressure
def Incompressible (z : Fields) : Prop :=
  ∀ r, partialX z.ux r+partialY z.uy r=0

def FieldDifferentialAt (input : FieldInputs) (z : ℝ → Fields)
    (pressure : ℝ → ScalarField) (t : ℝ) : Prop :=
  let rates := fieldRates input t (z t) (pressure t)
  ∀ r,
    HasDerivAt (fun s => (z s).ux r) (rates.ux r) t ∧
    HasDerivAt (fun s => (z s).uy r) (rates.uy r) t ∧
    HasDerivAt (fun s => (z s).xA r) (rates.xA r) t ∧
    HasDerivAt (fun s => (z s).xB r) (rates.xB r) t ∧
    HasDerivAt (fun s => (z s).gAB r) (rates.gAB r) t ∧
    HasDerivAt (fun s => (z s).gBA r) (rates.gBA r) t

def FieldProblem (input : FieldInputs) (a b : ℝ) (initial : Fields)
    (z : ℝ → Fields) (pressure : ℝ → ScalarField) : Prop :=
  z a=initial ∧
  (∀ r, ContinuousOn (fun t => (z t).ux r) (Icc a b) ∧
    ContinuousOn (fun t => (z t).uy r) (Icc a b) ∧
    ContinuousOn (fun t => (z t).xA r) (Icc a b) ∧
    ContinuousOn (fun t => (z t).xB r) (Icc a b) ∧
    ContinuousOn (fun t => (z t).gAB r) (Icc a b) ∧
    ContinuousOn (fun t => (z t).gBA r) (Icc a b)) ∧
  (∀ t ∈ Icc a b, SpatialRegularity (z t) (pressure t) ∧
    PeriodicFields (z t) (pressure t) ∧ Incompressible (z t)) ∧
  (∀ t ∈ Ioo a b, FieldDifferentialAt input z pressure t)


-- The source's exact, nonuniform initial data. No numerical grid is used.
def sourceInitial : Fields :=
  ⟨(fun r => Real.sin r.1 * Real.cos r.2 - (1/4)*Real.sin (2*r.1+r.2)
       - (3/10)*Real.cos (r.1-2*r.2)),
   (fun r => -Real.cos r.1 * Real.sin r.2 + (1/2)*Real.sin (2*r.1+r.2)
       - (3/20)*Real.cos (r.1-2*r.2)),
   (fun r => -11/20+(3/20)*Real.cos r.1+(1/10)*Real.sin r.2),
   (fun r => 7/20+(1/10)*Real.sin r.1-(3/20)*Real.cos r.2),
   (fun _ => 1/2), (fun _ => 1/2)⟩

def pulseProfile (r : Point) : ℝ :=
  ((1 + Real.cos (r.1-Real.pi/2))/2)^2 *
    ((1 + Real.cos (r.2-Real.pi/3))/2)^2

def pulse (t : ℝ) (r : Point) : ℝ :=
  if 1/2 < t ∧ t < 1 then
    (4/5)*pulseProfile r*(Real.sin (2*Real.pi*(t-1/2)))^2 else 0

inductive PulseRecipient | none | A | B

def sourceInputs (kAB kBA : ℝ) (who : PulseRecipient) : FieldInputs :=
  ⟨kAB,kBA,(if who matches .A then pulse else fun _ _ => 0),
            (if who matches .B then pulse else fun _ _ => 0)⟩

-- A mathematical quadratic bookkeeping functional for all six fields;
-- no claim that internal-state squares are measured physical/personal energy.
def energy (z : Fields) (r : Point) : ℝ :=
  ((z.ux r)^2+(z.uy r)^2+(z.xA r)^2+(z.xB r)^2+
    (z.gAB r)^2+(z.gBA r)^2)/2

def reactionA (i : FieldInputs) (t : ℝ) (z : Fields) (r : Point) : ℝ :=
  -11/20-z.xA r+i.weightAB*z.gAB r*(z.xB r-z.xA r)+i.sourceA t r
def reactionB (i : FieldInputs) (t : ℝ) (z : Fields) (r : Point) : ℝ :=
  7/20-z.xB r+i.weightBA*z.gBA r*(z.xA r-z.xB r)+i.sourceB t r
def reactionAB (z : Fields) (r : Point) : ℝ :=
  (sigmoid (-2/5+2*(z.xB r-z.xA r)+(1/2)*strainSquared z r)-z.gAB r)/(3/5)
def reactionBA (z : Fields) (r : Point) : ℝ :=
  (sigmoid (-2/5+2*(z.xA r-z.xB r)+(1/2)*strainSquared z r)-z.gBA r)/(3/5)

def energyProduction (i : FieldInputs) (t : ℝ) (z : Fields)
    (p : ScalarField) (r : Point) : ℝ :=
  -(z.ux r*partialX p r+z.uy r*partialY p r)+
  z.ux r*(partialX (stressXX z) r+partialY (stressXY z) r)+
  z.uy r*(partialX (stressXY z) r+partialY (stressYY z) r)+
  (1/50)*(z.xA r*laplacian z.xA r+z.xB r*laplacian z.xB r)+
  (3/200)*(z.gAB r*laplacian z.gAB r+z.gBA r*laplacian z.gBA r)+
  z.xA r*reactionA i t z r+z.xB r*reactionB i t z r+
  z.gAB r*reactionAB z r+z.gBA r*reactionBA z r

def FirstSpatialRegularity (z : Fields) : Prop :=
  Differentiable ℝ z.ux ∧ Differentiable ℝ z.uy ∧
  Differentiable ℝ z.xA ∧ Differentiable ℝ z.xB ∧
  Differentiable ℝ z.gAB ∧ Differentiable ℝ z.gBA

-- Standard full smooth initial-value existence/uniqueness TARGETS, not axioms.
-- Pressure is deliberately excluded from uniqueness without a normalization.
def FullExistenceStatement : Prop :=
  ∀ (who : PulseRecipient) (ks : ℝ × ℝ),
    ks ∈ ({(1,1),(3/2,1/2),(1/2,3/2)} : Set (ℝ × ℝ)) →
    ∀ T : ℝ, 0 < T → ∃ z p,
      FieldProblem (sourceInputs ks.1 ks.2 who) 0 T sourceInitial z p

def FullUniquenessStatement : Prop :=
  ∀ (i : FieldInputs) (T : ℝ) (z w : ℝ → Fields)
    (p q : ℝ → ScalarField), 0 < T →
    FieldProblem i 0 T sourceInitial z p →
    FieldProblem i 0 T sourceInitial w q → EqOn z w (Icc 0 T)

end
end HugNavierSingle
