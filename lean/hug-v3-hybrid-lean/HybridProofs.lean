import V3HybridSpecification

/- This solution does not import the sorried reference challenge.
   All continuous-segment solvability/uniqueness hypotheses remain explicit.
   No theorem here asserts that the complete V3 RHS has been formalized. -/
namespace Hybrid.Verified
noncomputable section
open Set

theorem read_margin_stable {I : Type*} (b b₀ : I → ℝ) (r δ : ℝ)
    (hr : 0 ≤ r) (hδ : 0 < δ) (hmargin : ∀ i, r + δ ≤ |b₀ i|)
    (hclose : ∀ i, |b i - b₀ i| < δ) :
    (∀ i, r < |b i|) ∧ (∀ i, 0 < b i ↔ 0 < b₀ i) := by
  have pointwise : ∀ i, r < |b i| ∧ (0 < b i ↔ 0 < b₀ i) := by
    intro i
    obtain ⟨hl, hu⟩ := abs_lt.mp (hclose i)
    have hm := hmargin i
    by_cases h0 : 0 ≤ b₀ i
    · rw [abs_of_nonneg h0] at hm
      have hb : r < b i := by linarith
      have hp : 0 < b i := lt_of_le_of_lt hr hb
      have hp0 : 0 < b₀ i := by linarith
      exact ⟨by simpa only [abs_of_pos hp] using hb, iff_of_true hp hp0⟩
    · have hn0 : b₀ i < 0 := lt_of_not_ge h0
      rw [abs_of_neg hn0] at hm
      have hn : b i < 0 := by linarith
      refine ⟨?_, iff_of_false (not_lt.mpr hn.le) (not_lt.mpr hn0.le)⟩
      rw [abs_of_neg hn]
      linarith
  exact ⟨fun i => (pointwise i).1, fun i => (pointwise i).2⟩

theorem decoded_value_stable {I D : Type*} (decode : (I → Bool) → D)
    (b b₀ : I → ℝ) (r δ : ℝ) (hr : 0 ≤ r) (hδ : 0 < δ)
    (hmargin : ∀ i, r + δ ≤ |b₀ i|) (hclose : ∀ i, |b i - b₀ i| < δ) :
    decode (V3Hybrid.bitPattern b) = decode (V3Hybrid.bitPattern b₀) := by
  apply congrArg decode
  funext i
  have hi := (read_margin_stable b b₀ r δ hr hδ hmargin hclose).2 i
  simp only [V3Hybrid.bitPattern, hi]

theorem trace_uniqueness {E : Type*} (S : System E) (N : ℕ) (initial : E)
    (horder : Ordered S N) (hunique : SegmentUniqueness S N)
    (a b : Trace E) (ha : IsTrace S N initial a) (hb : IsTrace S N initial b) :
    Agreement S N a b := by
  have hafter : ∀ k, k ≤ N → a.after k = b.after k := by
    intro k
    induction k with
    | zero =>
      intro _
      exact ha.1.trans hb.1.symm
    | succ k ih =>
      intro hkN
      have hk : k < N := by omega
      have hi := ih (Nat.le_of_lt hk)
      have hsa := ha.2.2 k hk
      have hsb := hb.2.2 k hk
      have hbseg : Segment S k (a.after k) (b.path k) := by
        rw [hi]
        exact hsb.1
      have hp := hunique k hk (a.after k) (ha.2.1 k (Nat.le_of_lt hk))
        (a.path k) (b.path k) hsa.1 hbseg
      have hend := hp (show S.time (k+1) ∈ interval S k from ⟨horder k hk, le_rfl⟩)
      apply Option.some.inj
      exact hsa.2.1.symm.trans ((congrArg (S.boundary (k+1)) hend).trans hsb.2.1)
  refine ⟨hafter, ?_⟩
  intro k hk
  have hsa := ha.2.2 k hk
  have hsb := hb.2.2 k hk
  have hbseg : Segment S k (a.after k) (b.path k) := by
    rw [hafter k (Nat.le_of_lt hk)]
    exact hsb.1
  exact hunique k hk (a.after k) (ha.2.1 k (Nat.le_of_lt hk))
    (a.path k) (b.path k) hsa.1 hbseg

private def chosenStep {E : Type*} (S : System E) (k : ℕ) (start : E) :
    (ℝ → E) × E := by
  classical
  exact if h : ∃ pair : (ℝ → E) × E, Step S k start pair.1 pair.2 then
    Classical.choose h
  else (fun _ => start, start)

private theorem chosenStep_spec {E : Type*} (S : System E) (k : ℕ) (start : E)
    (h : ∃ pair : (ℝ → E) × E, Step S k start pair.1 pair.2) :
    Step S k start (chosenStep S k start).1 (chosenStep S k start).2 := by
  rw [chosenStep, dif_pos h]
  exact Classical.choose_spec h

private def chosenState {E : Type*} (S : System E) (initial : E) : ℕ → E
  | 0 => initial
  | k+1 => (chosenStep S k (chosenState S initial k)).2

theorem trace_exists {E : Type*} (S : System E) (N : ℕ) (initial : E)
    (hinit : S.admissible 0 initial) (hsolve : StepSolvability S N) :
    ∃ tr, IsTrace S N initial tr := by
  have hvalid : ∀ k, k ≤ N → S.admissible k (chosenState S initial k) := by
    intro k
    induction k with
    | zero =>
      intro _
      exact hinit
    | succ k ih =>
      intro hkN
      have hk : k < N := by omega
      have hs := chosenStep_spec S k (chosenState S initial k)
        (hsolve k hk (chosenState S initial k) (ih (Nat.le_of_lt hk)))
      exact hs.2.2
  refine ⟨⟨chosenState S initial, fun k => (chosenStep S k (chosenState S initial k)).1⟩,
    rfl, hvalid, ?_⟩
  intro k hk
  exact chosenStep_spec S k (chosenState S initial k)
    (hsolve k hk (chosenState S initial k) (hvalid k (Nat.le_of_lt hk)))

theorem assemble_exists_unique {E : Type*} (S : System E) (N : ℕ) (initial : E)
    (horder : Ordered S N) (hinit : S.admissible 0 initial)
    (hsolve : StepSolvability S N) (hunique : SegmentUniqueness S N) :
    ∃ tr, IsTrace S N initial tr ∧
      ∀ other, IsTrace S N initial other → Agreement S N tr other := by
  obtain ⟨tr, ht⟩ := trace_exists S N initial hinit hsolve
  exact ⟨tr, ht, fun other ho => trace_uniqueness S N initial horder hunique tr other ht ho⟩

theorem event_failure_excluded {E : Type*} (S : System E) (N : ℕ) (initial : E)
    (tr : Trace E) (ht : IsTrace S N initial tr) (k : ℕ) (hk : k < N) :
    S.boundary (k+1) (tr.path k (S.time (k+1))) ≠ none := by
  rw [(ht.2.2 k hk).2.1]
  exact Option.some_ne_none _

theorem v3_main_time_order : ∀ k < 5, V3Hybrid.time k < V3Hybrid.time (k+1) := by
  intro k hk
  interval_cases k <;> norm_num [V3Hybrid.time]

theorem v3_simultaneous_event_order {E : Type*}
    (op : V3Hybrid.Action → E → Option E) (s : E) :
    V3Hybrid.runActions op (V3Hybrid.actions 3) s =
      (op (.write 1) s).bind (fun next => op (.capture 2) next) := by
  simp [V3Hybrid.actions, V3Hybrid.runActions]

theorem v3_main_conditional
    (law : ℕ → (ℝ → V3Hybrid.MainState) → Prop)
    (admissible : ℕ → V3Hybrid.MainState → Prop)
    (op : V3Hybrid.Action → V3Hybrid.MainState → Option V3Hybrid.MainState)
    (raw initial : V3Hybrid.MainState)
    (hcaptured : V3Hybrid.Initialized op raw initial)
    (hinit : admissible 0 initial)
    (hsolve : StepSolvability (V3Hybrid.mainSystem law admissible op) 5)
    (hunique : SegmentUniqueness (V3Hybrid.mainSystem law admissible op) 5) :
    V3Hybrid.Initialized op raw initial ∧
    ∃ tr, IsTrace (V3Hybrid.mainSystem law admissible op) 5 initial tr ∧
      ∀ other, IsTrace (V3Hybrid.mainSystem law admissible op) 5 initial other →
        Agreement (V3Hybrid.mainSystem law admissible op) 5 tr other := by
  refine ⟨hcaptured, assemble_exists_unique (V3Hybrid.mainSystem law admissible op)
    5 initial ?_ hinit hsolve hunique⟩
  intro k hk
  exact (v3_main_time_order k hk).le

end
end Hybrid.Verified
