import V3ClayTrajectoryProofs
import V3MemoryRulesProofs

/-! Read-only observations of the unchanged full Hug v3 model.

The user's A is the bridge, d is durability of person and group, and ZERO is
Z/history, E/direction, R/flow, O/destination and starting point. No scalar d,
semantic O detector, forgetting multiplier, or new evolution law is introduced.
SocialSnapshot reads all six actors, rather than a replacement two-state model.
AtO and ReturnedToO require a supplied observation: the corpus has not selected
one. They describe an explicit proof obligation, not a theorem of eventual return.
-/
namespace HugV3.Source.BridgeReturn
noncomputable section
open Set

structure SocialSnapshot where
  expression : Actor → Fin 2 → ℝ
  context : Actor → Fin 2 → ℝ
  normCenter : Actor → Fin 2 → ℝ
  logRadius : Actor → Actor → ℝ
  relation : Actor → Actor → Fin 3 → ℝ
  responses : Actor → Actor → Fin 7 → ℝ
  association : Actor → Actor → Fin 3 → ℝ

def socialSnapshot (s : State) : SocialSnapshot :=
  ⟨s.expression,s.context,s.normCenter,s.logRadius,s.relation,s.responses,s.association⟩

def AtO {Ω : Type} (observe : SocialSnapshot → Ω) (O : Ω) (s : State) : Prop :=
  observe (socialSnapshot s)=O

def ReturnedToO {Ω : Type} (observe : SocialSnapshot → Ω) (O : Ω)
    (s : ℝ → State) (a b : ℝ) : Prop :=
  a<b ∧ AtO observe O (s a) ∧ AtO observe O (s b) ∧
  ∃ t ∈ Ioo a b, ¬AtO observe O (s t)

/-- A full-state input for a diagnostic of expression/intent alignment.
It is not claimed to be a reached trajectory state or the user's definition of O. -/
def engagementWitness (G : Geometry) : State :=
  { initial G with responses := fun i j k =>
      if i=1 ∧ j=0 ∧ k=1 then 1 else 0 }

end
end HugV3.Source.BridgeReturn
