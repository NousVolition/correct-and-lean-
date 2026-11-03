import V3SourceSystem

/-! DDE extension v1. Temporal routing is new; original full-model equations are imported unchanged.
The buffer contains the seven social blocks. Physical observations, material records, explicit
time and physical/source rates remain current. All social arguments, including self-relaxation,
are delayed. This is a proposed timing convention, not a well-posedness theorem. -/
namespace HugV3.Source.Delay
noncomputable section

def socialFrom (present past : State) : State :=
  { present with
    expression := past.expression
    context := past.context
    normCenter := past.normCenter
    logRadius := past.logRadius
    relation := past.relation
    responses := past.responses
    association := past.association }

def SamePhysical (a b : State) : Prop :=
  a.g=b.g ∧ a.X=b.X ∧ a.F=b.F ∧ a.m=b.m ∧ a.b=b.b ∧
  a.A=b.A ∧ a.ledger=b.ledger ∧ a.writeWork=b.writeWork

def SameSocial (a b : State) : Prop :=
  a.expression=b.expression ∧ a.context=b.context ∧ a.normCenter=b.normCenter ∧
  a.logRadius=b.logRadius ∧ a.relation=b.relation ∧ a.responses=b.responses ∧
  a.association=b.association

/-- Current full physical rates, with social rates evaluated at current physical/past social input.
Both original partial-domain checks remain in force. -/
def rhsDelayed (G : Geometry) (t : ℝ) (present past : State) : Option State := do
  let currentRate ← rhs G t present
  let bufferedRate ← rhs G t (socialFrom present past)
  return socialFrom currentRate bufferedRate

/-- The caller supplies a history, including times before the initial time.
For a retarded DDE require τ>0. τ=0 is exposed only for the baseline identity check. -/
def rhsAlong (G : Geometry) (τ : ℝ) (history : ℝ → State) (t : ℝ) : Option State :=
  rhsDelayed G t (history t) (history (t-τ))

/-- Writes use the unchanged present-time event map. A history-aware solver must keep
the recorded past and the pre/post-write side convention; this definition is not that solver. -/
def eventBoundary (k : ℕ) (present : FullState) : Option FullState := boundary k present

end
end HugV3.Source.Delay
