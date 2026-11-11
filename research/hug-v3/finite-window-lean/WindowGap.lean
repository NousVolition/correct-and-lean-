/-
Finite observation windows and nearest gaps.

These statements apply to any fixed gap function. When the function is distance
to the same B along the same path at the same time, a larger parameter window
cannot increase the minimum or infimum. Existence of the stated nearest point
or infimum is explicit; it is not silently assumed or postulated as an axiom.

No numerical fluid model, continuity, or closure claim is encoded here.
-/
namespace WindowGap

def Contained {Point : Type} (small large : Point → Prop) : Prop :=
  ∀ p, small p → large p

def Nearest {Point Value : Type} [LE Value]
    (gap : Point → Value) (window : Point → Prop) (p : Point) : Prop :=
  window p ∧ ∀ q, window q → gap p ≤ gap q

def LowerBound {Point Value : Type} [LE Value]
    (gap : Point → Value) (window : Point → Prop) (bound : Value) : Prop :=
  ∀ p, window p → bound ≤ gap p

def IsInfimum {Point Value : Type} [LE Value]
    (gap : Point → Value) (window : Point → Prop) (value : Value) : Prop :=
  LowerBound gap window value ∧
  ∀ lower, LowerBound gap window lower → lower ≤ value

/-- A larger window's nearest point is no farther than a smaller one's. -/
theorem nearest_gap_cannot_increase {Point Value : Type} [LE Value]
    (gap : Point → Value) (small large : Point → Prop)
    (included : Contained small large) (p q : Point)
    (small_nearest : Nearest gap small p)
    (large_nearest : Nearest gap large q) : gap q ≤ gap p := by
  exact large_nearest.2 p (included p small_nearest.1)

/-- The same rule holds for infima, including when no nearest point is attained. -/
theorem infimum_gap_cannot_increase {Point Value : Type} [LE Value]
    (gap : Point → Value) (small large : Point → Prop)
    (included : Contained small large) (small_gap large_gap : Value)
    (small_infimum : IsInfimum gap small small_gap)
    (large_infimum : IsInfimum gap large large_gap) : large_gap ≤ small_gap := by
  apply small_infimum.2 large_gap
  intro p hp
  exact large_infimum.1 p (included p hp)

/-- A lower bound on the whole path restricts to each visible part. -/
theorem whole_path_bound_restricts {Point Value : Type} [LE Value]
    (gap : Point → Value) (small large : Point → Prop)
    (included : Contained small large) (bound : Value)
    (whole_bound : LowerBound gap large bound) : LowerBound gap small bound := by
  intro p hp
  exact whole_bound p (included p hp)

/-- For nested parameter prefixes of one fixed path, inclusion follows from
transitivity of the parameter order. This is a spatial extent comparison,
not a claim comparing two model times or two different paths. -/
theorem prefix_nearest_gap_cannot_increase {Parameter Value : Type}
    [LE Parameter] [LE Value]
    (le_transitive : ∀ a b c : Parameter, a ≤ b → b ≤ c → a ≤ c)
    (gap : Parameter → Value) (start short long p q : Parameter)
    (length_order : short ≤ long)
    (short_nearest : Nearest gap (fun s => start ≤ s ∧ s ≤ short) p)
    (long_nearest : Nearest gap (fun s => start ≤ s ∧ s ≤ long) q) : gap q ≤ gap p := by
  apply nearest_gap_cannot_increase gap (fun s => start ≤ s ∧ s ≤ short)
    (fun s => start ≤ s ∧ s ≤ long)
    ?_ p q short_nearest long_nearest
  intro s hs
  exact ⟨hs.1, le_transitive s short long hs.2 length_order⟩

/- A concrete sample counterexample: the first point is one unit from B;
the second point is B itself. This demonstrates the invalid inference about
sampled windows. It is not a replacement for a continuous fluid trajectory. -/
def sampleSmall (p : Nat) : Prop := p = 0
def sampleLarge (p : Nat) : Prop := p = 0 ∨ p = 1
def sampleGap (p : Nat) : Nat := if p = 0 then 1 else 0

theorem sample_windows_are_nested : Contained sampleSmall sampleLarge := by
  intro p hp
  exact Or.inl hp

theorem sample_small_has_positive_gap : Nearest sampleGap sampleSmall 0 ∧
    sampleGap 0 = 1 := by
  constructor
  · constructor
    · rfl
    · intro p hp
      cases hp
      exact Nat.le_refl _
  · rfl

theorem sample_extension_reaches_zero : Nearest sampleGap sampleLarge 1 ∧
    sampleGap 1 = 0 := by
  constructor
  · constructor
    · exact Or.inr rfl
    · intro p _
      exact Nat.zero_le _
  · rfl

/-- A lower bound on the visible part cannot generally be promoted to the whole. -/
theorem visible_positive_gap_does_not_imply_whole_positive_gap :
    LowerBound sampleGap sampleSmall 1 ∧
    ¬ LowerBound sampleGap sampleLarge 1 := by
  constructor
  · intro p hp
    cases hp
    exact Nat.le_refl 1
  · intro whole_bound
    have impossible : 1 ≤ 0 := whole_bound 1 (Or.inr rfl)
    exact Nat.not_succ_le_zero 0 impossible

end WindowGap
