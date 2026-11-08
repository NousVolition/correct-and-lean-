import V3YangMillsAuditProofs

/-! Comparison actions and solution predicates only. All Hug source equations,
parameters, initial data, events, writes and the saved delay convention are imported
unchanged. A fixed particle-wise sign is a discrete internal fabric symmetry, not
an arbitrary spatial frame rotation or a newly introduced gauge field. -/
namespace HugV3.Source.Covariance
noncomputable section
open Set

def signedFabric (ε : Particle → Bool) (F : Particle → Mat) : Particle → Mat :=
  fun p => if ε p then -F p else F p

def signState (ε : Particle → Bool) (s : State) : State :=
  {s with F := signedFabric ε s.F}

def signFull (ε : Particle → Bool) (y : FullState) : FullState :=
  ⟨signState ε y.state, fun id => (y.starts id).map (signedFabric ε)⟩

def signTrace (ε : Particle → Bool) (tr : Trace) : Trace :=
  ⟨fun k => signFull ε (tr.after k), fun k t => signFull ε (tr.path k t)⟩

/-- The original solution conditions with the initial datum made explicit for
comparison. At initialFull this is definitionally the original Solves predicate. -/
def SolvesFrom (y₀ : FullState) (tr : Trace) : Prop :=
  tr.after 0=y₀ ∧ ∀ k<5,
    tr.path k (time k)=tr.after k ∧
    ContinuousStateOn (fun t => (tr.path k t).state) (Icc (time k) (time (k+1))) ∧
    (∀ t ∈ Icc (time k) (time (k+1)), (tr.path k t).starts=(tr.after k).starts) ∧
    (∀ t ∈ Icc (time k) (time (k+1)), ∃ d,
      rhs sourceGeometry t (tr.path k t).state=some d ∧
      StateHasDerivWithinAt (fun τ => (tr.path k τ).state) d
        (Icc (time k) (time (k+1))) t) ∧
    boundary (k+1) (tr.path k (time (k+1)))=some (tr.after (k+1))

def DelayedSegment (G : Geometry) (τ : ℝ) (history : ℝ → State) (I : Set ℝ) : Prop :=
  ContinuousStateOn history I ∧ ∀ t ∈ I, ∃ d,
    Delay.rhsAlong G τ history t=some d ∧ StateHasDerivWithinAt history d I t

/-- The spatial quarter-turn used in the corpus controls, with positions AND
vector components transformed. The external forcing direction stays as saved
in the source. No new field interpolation or numerical scheme is inserted. -/
def quarterVector (v : Vec) : Vec := ![-v 1,v 0,v 2]
def reflectedIndex (i : Fin 16) : Fin 16 := ⟨(16-i.val)%16, Nat.mod_lt _ (by decide)⟩
def inverseQuarterGrid (x : Grid) : Grid := ![x 1,reflectedIndex (x 0),x 2]
def quarterState (s : State) : State :=
  {s with
    g := fun x k => if h : k.val<3 then
      quarterVector (velocity s (inverseQuarterGrid x)) ⟨k.val,h⟩
      else s.g (inverseQuarterGrid x) k
    X := fun p => quarterVector (s.X p)
    F := fun p i j => quarterVector (fun k => s.F p k j) i}

def zeroGrid : Grid := fun _ => 0
def gradientWitness (G : Geometry) : State :=
  {initial G with g := fun x k => if k=3 then (x 0).val/112 else 0}

end
end HugV3.Source.Covariance
