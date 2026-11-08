import V3ORuminationProofs
import V3TransferDefinitions

/-! Read-only candidate observations. A, d and ZERO retain the user's meanings.
Norm alignment is not identified with semantic understanding, association is not
a measured rumination state, and writing work is not a psychological weight.
The old quiet-rumination specification remains historical and is not used here.
No source equation, event or timing rule is changed. -/
namespace HugV3.Source.Coexistence
noncomputable section
open Set
open scoped BigOperators

def normAlignment (s baseline : State) (v : Actor → Fin 2 → ℝ) (i : Actor) : ℝ :=
  ∑ k, v i k*(s.normCenter i k-baseline.normCenter i k)

def normAlignmentRate (s : State) (v : Actor → Fin 2 → ℝ) (i : Actor) : ℝ :=
  ∑ k, v i k*Transfer.normRate s i k

/-- All six actors are checked separately. Positive thresholds are observational
criteria supplied to the theorem, not coefficients added to the equations. -/
def Coexists (s baseline : State) (v : Actor → Fin 2 → ℝ)
    (floor : Actor → ℝ) (rho : ℝ) : Prop :=
  (∀ i, 0<floor i ∧ floor i≤normAlignment s baseline v i) ∧
  0<rho ∧ rho≤s.association 1 0 0 ∧ 0<s.writeWork

/-- The actual full vector field must point inward at every tested alignment
boundary along the segment. This is an assumption to discharge, not a conclusion. -/
def NormInward (tr : Trace) (q : ℕ) (baseline : State)
    (v : Actor → Fin 2 → ℝ) (floor : Actor → ℝ) : Prop :=
  ∀ t ∈ Ico (time q) (time (q+1)), ∀ i,
    normAlignment (tr.path q t).state baseline v i=floor i →
    0<normAlignmentRate (tr.path q t).state v i

/-- A positive association floor is maintained by its actual existing target
at the boundary. No zero-drive or quiet-rumination hypothesis is imposed. -/
def AssociationInward (tr : Trace) (q : ℕ) (rho : ℝ) : Prop :=
  ∀ t ∈ Ico (time q) (time (q+1)), ∀ rs,
    readRecords (tr.path q t).state=some rs →
    (tr.path q t).state.association 1 0 0=rho →
    rho<ORumination.associationDrive sourceGeometry (tr.path q t).state rs 1 0 0

/-- Full input-state diagnostic, not the declared initial condition or a claim
that this state is reached. It keeps a positive association and positive work. -/
def erosionWitness (G : Geometry) : State :=
  { initial G with
    normCenter := fun i k => intent i k+1
    association := fun _ _ _ => 1
    writeWork := 1 }

end
end HugV3.Source.Coexistence
