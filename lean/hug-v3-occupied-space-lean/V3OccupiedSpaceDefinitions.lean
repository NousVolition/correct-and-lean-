import V3BridgeReturnProofs
import V3DelayDefinitions

/-! Read-only observations of the unchanged full Hug v3 state.
The author selected the whole region a person can occupy, rather than just a
current point or an actor tag. We test an action-space interpretation of that
region using the existing guards. A guard OWNER admits a VISITOR's expression.
Positive geometric margin is the interior (soft permission > 1/2); it is not
a new hard gate in the vector field. Audience selection is left arbitrary.
No personal-space dimension, collision force, actor, state, or equation is added.
A, d, ZERO and the fixed sameAgent/sameIdea strings retain their source meanings.
-/
namespace HugV3.Source.OccupiedSpace
noncomputable section
open Set
open scoped BigOperators

abbrev Action := Fin 2 → ℝ
abbrev Audience := Actor → Set Actor

def guardMarginAt (s : State) (owner visitor : Actor) (z : Action) : ℝ :=
  Real.exp (s.logRadius owner visitor)-Real.sqrt (∑ k, (z k-s.normCenter owner k)^2)

def guardRegion (s : State) (owner visitor : Actor) : Set Action :=
  {z | 0 < guardMarginAt s owner visitor z}

/-- The whole action region admitted by every selected nonself audience member.
This is a conservative available-region observation, not a new evolution rule.
Results quantify over all audience selections, including singleton audiences. -/
def occupiedRegion (s : State) (audience : Audience) (person : Actor) : Set Action :=
  {z | ∀ owner, owner ∈ audience person → owner ≠ person → z ∈ guardRegion s owner person}

def Exclusion (s : State) (audience : Audience) : Prop :=
  ∀ i j : Actor, i ≠ j → Disjoint (occupiedRegion s audience i) (occupiedRegion s audience j)

def ExclusionThroughout (tr : Trace) (audience : Audience) : Prop :=
  (∀ q ≤ 5, Exclusion (tr.after q).state audience) ∧
  ∀ q < 5, ∀ t ∈ Icc (time q) (time (q+1)), Exclusion (tr.path q t).state audience

def zeroAction : Action := fun _ => 0

abbrev PersonalView := Action × Action × Action × (Actor → ℝ) ×
  (Actor → Fin 3 → ℝ) × (Actor → Fin 7 → ℝ) × (Actor → Fin 3 → ℝ)

def personalView (ss : BridgeReturn.SocialSnapshot) (i : Actor) : PersonalView :=
  (ss.expression i, ss.context i, ss.normCenter i, ss.logRadius i,
   ss.relation i, ss.responses i, ss.association i)

/-- Candidate view of one person's pulley, retaining all seven social blocks
for that actor; its environment remains the complete coupled full state.
This does not assert conscious agency or independence from other people. -/
def pulleyView (s : State) (i : Actor) : PersonalView :=
  personalView (BridgeReturn.socialSnapshot s) i

def regionScore (s : State) (owner visitor : Actor) (z : Action) : ℝ :=
  (Real.exp (s.logRadius owner visitor))^2-∑ k, (z k-s.normCenter owner k)^2

def regionScoreRate (s rate : State) (owner visitor : Actor) (z : Action) : ℝ :=
  2*(Real.exp (s.logRadius owner visitor))^2*rate.logRadius owner visitor+
  2*∑ k, (z k-s.normCenter owner k)*rate.normCenter owner k

end
end HugV3.Source.OccupiedSpace
