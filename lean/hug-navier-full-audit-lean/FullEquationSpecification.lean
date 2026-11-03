import ActiveHugModel

/- Full source equations, with an explicitly OPEN joint specification.
   HugModel and ActiveHugModel are unchanged copies of the existing proof model.
   The field equations are the six-field periodic NS/SIMS formulation in
   sources/ns_fields_methods.md, not a new spatial reduction of Hug.
   No affine flow, zero diffusion, invented traction law or automatic clock/unit
   identification is imposed. SeparateEvolutions is deliberately NOT named or
   claimed to be a reciprocal Hug--Navier solution. -/
namespace HugNavierFullAudit
noncomputable section
open ActiveHug Set

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

-- All eight unchanged Hug coordinates evolve; u here is its Kelvin strain,
-- whereas ux and uy above are the two components of fluid velocity.
def HugDifferentialAt (p : Parameters) (force : ℝ → ℝ) (h : ℝ → State) (t : ℝ) : Prop :=
  let rates := rhs p (force t) (h t)
  HasDerivAt (fun s => (h s).q) rates.q t ∧
  HasDerivAt (fun s => (h s).v) rates.v t ∧
  HasDerivAt (fun s => (h s).u) rates.u t ∧
  HasDerivAt (fun s => (h s).w) rates.w t ∧
  HasDerivAt (fun s => (h s).xA) rates.xA t ∧
  HasDerivAt (fun s => (h s).xB) rates.xB t ∧
  HasDerivAt (fun s => (h s).gAB) rates.gAB t ∧
  HasDerivAt (fun s => (h s).gBA) rates.gBA t

def HugProblem (p : Parameters) (force : ℝ → ℝ) (a b : ℝ) (initial : State)
    (h : ℝ → State) : Prop :=
  h a=initial ∧ ContinuousOn force (Icc a b) ∧
  ContinuousOn (fun t => (h t).q) (Icc a b) ∧ ContinuousOn (fun t => (h t).v) (Icc a b) ∧
  ContinuousOn (fun t => (h t).u) (Icc a b) ∧ ContinuousOn (fun t => (h t).w) (Icc a b) ∧
  ContinuousOn (fun t => (h t).xA) (Icc a b) ∧ ContinuousOn (fun t => (h t).xB) (Icc a b) ∧
  ContinuousOn (fun t => (h t).gAB) (Icc a b) ∧ ContinuousOn (fun t => (h t).gBA) (Icc a b) ∧
  (∀ t ∈ Ioo a b, HugDifferentialAt p force h t)

-- This is a conjunction of two source systems, NOT a coupling law. Even the
-- shared time variable requires an explicit conversion between the fluid's
-- nondimensional clock and Hug's simulation seconds. No such conversion,
-- load/traction rule, shared-state map or interface is inferred here.
def SeparateEvolutions (input : FieldInputs) (force : ℝ → ℝ) (a b : ℝ)
    (h0 : State) (z0 : Fields) (h : ℝ → State) (z : ℝ → Fields)
    (pressure : ℝ → ScalarField) : Prop :=
  HugProblem protocol force a b h0 h ∧ FieldProblem input a b z0 z pressure

-- A diagnostic source initial field: the scalar Hug state cannot be copied
-- uniformly over space and reproduce this existing nonuniform NS initial data.
def sourceInitialXA (r : Point) : ℝ :=
  -11/20+(3/20)*Real.cos r.1+(1/10)*Real.sin r.2

-- Algebraic inverse of the existing mechanical acceleration equation, not
-- permission to choose a force after seeing a desired trajectory.
def forceRequired (p : Parameters) (s : State) (acceleration : ℝ) : ℝ :=
  p.mass*acceleration-(p.gain-p.saturation*s.q^2)*s.v+
    p.damping*(s.gAB+s.gBA)*s.v+p.stiffness*s.q+p.volume/p.length*stress p s

def restProbe : State := ⟨0,0,0,0,protocol.baselineA,protocol.baselineB,1/2,1/2⟩

end
end HugNavierFullAudit
