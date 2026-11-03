import V3HybridSpecification
namespace Hybrid.Verified
noncomputable section
open Set

theorem read_margin_stable {I : Type*} (b b₀ : I → ℝ) (r δ : ℝ)
    (hr : 0 ≤ r) (hδ : 0 < δ) (hmargin : ∀ i, r + δ ≤ |b₀ i|)
    (hclose : ∀ i, |b i - b₀ i| < δ) :
    (∀ i, r < |b i|) ∧ (∀ i, 0 < b i ↔ 0 < b₀ i) := by sorry

theorem decoded_value_stable {I D : Type*} (decode : (I → Bool) → D)
    (b b₀ : I → ℝ) (r δ : ℝ) (hr : 0 ≤ r) (hδ : 0 < δ)
    (hmargin : ∀ i, r + δ ≤ |b₀ i|) (hclose : ∀ i, |b i - b₀ i| < δ) :
    decode (V3Hybrid.bitPattern b) = decode (V3Hybrid.bitPattern b₀) := by sorry

theorem trace_uniqueness {E : Type*} (S : System E) (N : ℕ) (initial : E)
    (horder : Ordered S N) (hunique : SegmentUniqueness S N)
    (a b : Trace E) (ha : IsTrace S N initial a) (hb : IsTrace S N initial b) :
    Agreement S N a b := by sorry

theorem trace_exists {E : Type*} (S : System E) (N : ℕ) (initial : E)
    (hinit : S.admissible 0 initial) (hsolve : StepSolvability S N) :
    ∃ tr, IsTrace S N initial tr := by sorry

theorem assemble_exists_unique {E : Type*} (S : System E) (N : ℕ) (initial : E)
    (horder : Ordered S N) (hinit : S.admissible 0 initial)
    (hsolve : StepSolvability S N) (hunique : SegmentUniqueness S N) :
    ∃ tr, IsTrace S N initial tr ∧
      ∀ other, IsTrace S N initial other → Agreement S N tr other := by sorry

theorem event_failure_excluded {E : Type*} (S : System E) (N : ℕ) (initial : E)
    (tr : Trace E) (ht : IsTrace S N initial tr) (k : ℕ) (hk : k < N) :
    S.boundary (k+1) (tr.path k (S.time (k+1))) ≠ none := by sorry

theorem v3_main_time_order : ∀ k < 5, V3Hybrid.time k < V3Hybrid.time (k+1) := by sorry

theorem v3_simultaneous_event_order {E : Type*}
    (op : V3Hybrid.Action → E → Option E) (s : E) :
    V3Hybrid.runActions op (V3Hybrid.actions 3) s =
      (op (.write 1) s).bind (fun next => op (.capture 2) next) := by sorry

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
        Agreement (V3Hybrid.mainSystem law admissible op) 5 tr other := by sorry

end
end Hybrid.Verified
