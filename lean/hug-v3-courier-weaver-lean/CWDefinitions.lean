import V3SourceSystem
import WizardDefinitions

namespace HugV3.Source.CW
noncomputable section
open scoped BigOperators

def mix (a b : ℝ) (u v : Vector) : Vector := fun x i => a*u x i+b*v x i
def gridGradient (u : Vector) (x : Grid) : Mat := fun i j => grad (fun y => u y i) x j
def curl (u : Vector) (x : Grid) : Vec :=
  let L := gridGradient u x
  ![L 2 1-L 1 2, L 0 2-L 2 0, L 1 0-L 0 1]
def rawCourier (u v : Vector) : Vector := fun x => cross (u x) (curl v x)
def rawWeaver (s : State) (u : Vector) : Vector := fun x i =>
  divergence (fun y j => 2*viscosity s y*symm (gridGradient u y) i j) x
def otherForces (G : Geometry) (s : State) : Vector := fun x i =>
  divergence (fun y j => fullStress G s y i j) x+forcing s x i

/-- The actual projection, followed by the component filter in the velocity part of the full RHS. -/
def resolve (v : Vector) : Vector := fun x i => filt (fun y => project v y i) x
def transport (u v : Vector) : Vector := resolve (rawCourier u v)
def courier (u : Vector) : Vector := transport u u
def weaver (s : State) (u : Vector) : Vector := resolve (rawWeaver s u)

def heat (s : State) : ℝ := (∑ x, viscousHeat s x)/4096
def inner (u v : Vector) : ℝ := (∑ x, dot (u x) (v x))/4096
/-- A diagnostic suggested by the companion's integrated pairing, using the RHS sign convention. -/
def pairing (s : State) : ℝ := inner (courier (velocity s)) (weaver s (velocity s))
def reversed (s : State) : State := {s with g := fun x k => if k.val<3 then -s.g x k else s.g x k}

/-- The velocity-sector directional commutator, in the displayed order DC[W] minus DW[C].
    All other coordinates are held fixed only for taking these derivatives. -/
def directionalBracket (s : State) (u : Vector) : Vector := fun x i =>
  transport (weaver s u) u x i + transport u (weaver s u) x i - weaver s (courier u) x i

def pairMatrix (k : ℝ) : CommutatorMatrix where
  κ i j := (if i=Wizard.courier.toFin ∧ j=Wizard.weaver.toFin then k else 0) -
            (if j=Wizard.courier.toFin ∧ i=Wizard.weaver.toFin then k else 0)
  skew_symm i j := by ring

end
end HugV3.Source.CW
