import AccountDefinitions
import TransitionDefinitions
import Mathlib

namespace HugV3.Source.AppleBand
noncomputable section
open scoped BigOperators

abbrev Slide := unitInterval
abbrev Band := {z : ℝ × ℝ // z.1^2+z.2^2=1}

/-- The source's three reference semiaxes. A skin and a band are observations. -/
def axes (v : Vec) : Vec := ![(11/50)*v 0,(17/100)*v 1,(19/100)*v 2]
def unitSkin : Set Vec := {v | (v 0)^2+(v 1)^2+(v 2)^2=1}
def referenceSkin : Set Vec := axes '' unitSkin
def latitude (y : Slide × Band) : Vec :=
  ![Real.sqrt (1-(y.1:ℝ)^2)*y.2.val.1,Real.sqrt (1-(y.1:ℝ)^2)*y.2.val.2,(y.1:ℝ)]
def equator (b : Band) : Vec := axes ![b.val.1,b.val.2,0]
def north : Vec := axes ![0,0,1]
def east : Band := ⟨(1,0),by norm_num⟩
def west : Band := ⟨(-1,0),by norm_num⟩

/-- Continuous free contraction of this circle, with every intermediate point constrained to S. -/
def ContractsOn (S : Set Vec) (loop : Band → Vec) (pole : Vec) : Prop :=
  ∃ H : Slide × Band → Vec, Continuous H ∧
    (∀ b, H (0,b)=loop b) ∧ (∀ b, H (1,b)=pole) ∧ ∀ r b, H (r,b)∈S

/-- Slide and model time advance together. The constraint uses the skin at that very time. -/
def MovingContraction (carrier : Slide → Vec → Vec) : Prop :=
  ∃ H : Slide × Band → Vec, Continuous H ∧
    (∀ b, H (0,b)=carrier 0 (equator b)) ∧ (∀ b, H (1,b)=carrier 1 north) ∧
    ∀ r b, H (r,b)∈carrier r '' referenceSkin

def fabricMap (center : Vec) (F : Mat) (z : Vec) : Vec :=
  fun i => center i + ∑ j, F i j*z j

/-- Off-grid observation of the same mechanical velocity that moves the stored particles. -/
def materialVelocity (s : State) (z : Vec) : Vec :=
  fun i => ∑ x, (∏ j, mechanical1D (z j) (x j))*velocity s x i

structure Stages where
  present : State
  predictor : State
  h : ℝ

def stepMap (a : Stages) (z : Vec) : Vec :=
  let v := materialVelocity a.present z
  z + (a.h/2) • (v+materialVelocity a.predictor (z+a.h • v))

def transport : List Stages → Vec → Vec
  | [], z => z
  | a::more,z => transport more (stepMap a z)

/-- Finite sequences of the source's accepted full-coordinate Heun steps and boundary operations. -/
inductive AcceptedChain : List Stages → State → State → Prop where
  | nil (s : State) : AcceptedChain [] s s
  | advance {G : Geometry} {t h : ℝ} {s d p k e f : State} {rest : List Stages} :
      ChildAccount.FullStep G t h s d p k e → AcceptedChain rest e f →
      AcceptedChain (⟨s,p,h⟩::rest) s f
  | checkpoint {j : ℕ} {x y : FullState} {f : State} {rest : List Stages} :
      boundary j x=some y → AcceptedChain rest y.state f → AcceptedChain rest x.state f

def segmentTime (k : ℕ) (r : Slide) : ℝ := (1-(r:ℝ))*time k+(r:ℝ)*time (k+1)
def segmentCarrier (tr : Trace) (k : ℕ) (p : Particle) (r : Slide) : Vec → Vec :=
  let s := (tr.path k (segmentTime k r)).state
  fabricMap (s.X p) (s.F p)

end
end HugV3.Source.AppleBand
