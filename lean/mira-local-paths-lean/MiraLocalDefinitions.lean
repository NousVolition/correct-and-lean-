import PersonEnvironmentDefinitions
import Mathlib.Combinatorics.SimpleGraph.Hamiltonian

/-!
An auxiliary chamber-graph interpretation of the unchanged full Hug input.
The corpus motivates local permissions, experience and context sensitivity.
It does not define this graph extraction, a choice algorithm, or a complexity bound.
`Walk.IsHamiltonian` means every chamber exactly once; no return to the start is added.
-/
namespace MiraLocal
open SimpleGraph

variable {V : Type*} {G : SimpleGraph V}

/-- Joining counts the common handoff chamber only once. All subsequent chambers
must be fresh relative to the entire previous route, not just its last local unit. -/
inductive Joined (G : SimpleGraph V) : {a b : V} → G.Walk a b → Prop
  | start (a : V) : Joined G (Walk.nil : G.Walk a a)
  | extend {a b c : V} {p : G.Walk a b} {q : G.Walk b c}
      (previous : Joined G p) (unit_path : q.IsPath)
      (fresh : List.Disjoint p.support q.support.tail) : Joined G (p.append q)

def Stuck {a b : V} (p : G.Walk a b) : Prop :=
  ∀ v, v ∉ p.support → ¬ G.Adj b v

/-- Explicit, presently unproved interpretation layer; not a new Hug equation. -/
abbrev ChamberView (V : Type*) := PersonEnvironment.HugInput → SimpleGraph V

/-- Triangle 0,1,2 with chamber 3 attached only to chamber 2. -/
def trapGraph : SimpleGraph (Fin 4) where
  Adj a b := a ≠ b ∧ ((a ≠ 3 ∧ b ≠ 3) ∨ a = 2 ∨ b = 2)
  symm := ⟨by intro a b h; exact ⟨Ne.symm h.1, by aesop⟩⟩
  loopless := ⟨by intro a h; exact h.1 rfl⟩

instance : DecidableRel trapGraph.Adj := fun a b =>
  inferInstanceAs (Decidable (a ≠ b ∧ ((a ≠ 3 ∧ b ≠ 3) ∨ a = 2 ∨ b = 2)))

def goodFirst : trapGraph.Walk 0 2 :=
  .cons (v := 1) (by decide) (.cons (by decide) (.nil : trapGraph.Walk 2 2))

def goodLast : trapGraph.Walk 2 3 := .cons (by decide) .nil

def goodRoute : trapGraph.Walk 0 3 := goodFirst.append goodLast

def trapPrefix : trapGraph.Walk 0 1 :=
  .cons (v := 2) (by decide) (.cons (by decide) (.nil : trapGraph.Walk 1 1))

def overlapFirst : (⊤ : SimpleGraph (Fin 4)).Walk 0 2 :=
  .cons (v := 1) (by decide) (.cons (by decide) (.nil : (⊤ : SimpleGraph (Fin 4)).Walk 2 2))

def overlapLast : (⊤ : SimpleGraph (Fin 4)).Walk 2 3 :=
  .cons (v := 1) (by decide) (.cons (by decide) (.nil : (⊤ : SimpleGraph (Fin 4)).Walk 3 3))

/-- These lists specify a fixed snapshot. Temporal routes require their own timing rules. -/
def oldGraph : SimpleGraph (Fin 3) where
  Adj a b := (a = 0 ∧ b = 1) ∨ (a = 1 ∧ b = 0)
  symm := ⟨by intro a b h; aesop⟩
  loopless := ⟨by intro a h; rcases h with ⟨h0,h1⟩ | ⟨h1,h0⟩ <;> omega⟩

def newGraph : SimpleGraph (Fin 3) where
  Adj a b := (a = 1 ∧ b = 2) ∨ (a = 2 ∧ b = 1)
  symm := ⟨by intro a b h; aesop⟩
  loopless := ⟨by intro a h; rcases h with ⟨h1,h2⟩ | ⟨h2,h1⟩ <;> omega⟩

instance : DecidableRel oldGraph.Adj := fun a b =>
  inferInstanceAs (Decidable ((a = 0 ∧ b = 1) ∨ (a = 1 ∧ b = 0)))
instance : DecidableRel newGraph.Adj := fun a b =>
  inferInstanceAs (Decidable ((a = 1 ∧ b = 2) ∨ (a = 2 ∧ b = 1)))

end MiraLocal
