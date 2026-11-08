import V3SourceSystem
import Mathlib.Tactic

/-!
An auxiliary search/checking interface. Original Hug equations are imported unchanged.
The checker and candidate generator are explicit inputs; Hug does not supply either.
The counter counts checker invocations, NOT elapsed time, bit operations, candidate
generation, memory acquisition, or exact-real evaluation. No P/NP class is defined here.
-/
namespace PersonEnvironment

abbrev Certificate := List Bool

structure SearchResult (Answer : Type*) where
  answer : Option Answer
  checks : ℕ
deriving Repr, DecidableEq

def scan {Answer : Type*} (check : Answer → Bool) : List Answer → SearchResult Answer
  | [] => ⟨none,0⟩
  | a :: rest =>
    if check a then ⟨some a,1⟩
    else let r := scan check rest; ⟨r.answer,r.checks+1⟩

/-- Every binary string of length at most b, each exactly once. -/
def certificates : ℕ → List Certificate
  | 0 => [[]]
  | b+1 => [[]] ++ (certificates b).map (false :: ·) ++
      (certificates b).map (true :: ·)

/-- Bounds are auxiliary certificate lengths, not limits on a person's experience. -/
def hintsWithin (hints : List Certificate) (bound : ℕ) : List Certificate :=
  hints.filter (fun a => decide (a.length ≤ bound))

/-- Remembered candidates are checked in the present input before exhaustive fallback. -/
def memoryFirst {Input : Type*} (check : Input → Certificate → Bool)
    (suggest : Input → List Certificate) (input : Input) (bound : ℕ) :
    SearchResult Certificate :=
  let first := scan (check input) (hintsWithin (suggest input) bound)
  match first.answer with
  | some _ => first
  | none =>
      let next := scan (check input) (certificates bound)
      ⟨next.answer,first.checks+next.checks⟩

def BoundedWitness {Input : Type*} (check : Input → Certificate → Bool)
    (input : Input) (bound : ℕ) : Prop :=
  ∃ answer, answer.length ≤ bound ∧ check input answer = true

/-- Not assumed globally: any identification with actual correctness needs this proof. -/
def Faithful {Input : Type*} (check : Input → Certificate → Bool)
    (valid : Input → Certificate → Prop) : Prop :=
  ∀ input answer, check input answer = true ↔ valid input answer

/-- A full unchanged Hug snapshot, all actors and capture buffers included. -/
structure HugInput where
  fullState : HugV3.Source.FullState
  atTime : ℝ
  person : HugV3.Source.Actor
  question : Certificate

noncomputable def originalGuard (input : HugInput) (receiver : HugV3.Source.Actor) : ℝ :=
  HugV3.Source.margin input.fullState.state receiver input.person

noncomputable def originalRetrieval (G : HugV3.Source.Geometry) (input : HugInput)
    (records : List (Fin 4 × HugV3.Source.Record))
    (origin : HugV3.Source.Actor) (channel : Fin 4) : ℝ :=
  HugV3.Source.memory G input.fullState.state records input.person origin channel

/-- A finite diagnostic: a changing criterion must be rechecked, not trusted from memory. -/
def singleBitCheck (required : Bool) (answer : Certificate) : Bool :=
  decide (answer = [required])

end PersonEnvironment
