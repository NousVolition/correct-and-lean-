import EdgeControlStatements

noncomputable section
namespace SignedVortex.Rescaled.EdgeControl
open Set NavierStokes NavierStokes.ProblemStatement HLine

theorem edge_signal_zero (t : ℝ) : signal t 0 = 0 := by sorry

theorem native_in_every_collar {t L : ℝ} (ht : t < 1) (hL : 0 < L) (hR : L < 1/8) :
    ∃ d ∈ Ioo (0:ℝ) L, signal t d ≠ 0 := by sorry

theorem inward_small {t m D ε : ℝ} (ht : t < 1) (hm : 0 < m) (hD : 0 < D) (hε : 0 < ε) :
    ∃ d ∈ Ioo (0:ℝ) (1/8), d < D ∧ 0 < |m * signal t d| ∧ |m * signal t d| < ε := by sorry

theorem control_for_pinned_scale {a : ℕ → ℕ} (ha : LocalScheduleWitness.Selected a)
    {ν l : ℝ} (hν : 0 < ν) (hl : 1 < l)
    (hK : compactSet ν l ⊆ PeriodicPaper.fundamentalInterior)
    (hu : ∀ t < (1:ℝ), ∀ x : Space, compact ν l a (t,x) ≠ 0 → ∀ i, |x i| ≤ 1/4) :
    SilentAndFaint ν l a := by sorry

theorem every_viscosity_has_control (ν : ℝ) (hν : 0 < ν) :
    ∃ a : ℕ → ℕ, ∃ l : ℝ, ∃ f : VelocityField, FamilyWitness ν l a f ∧ SilentAndFaint ν l a := by sorry

theorem exterior_from_support {a : ℕ → ℕ} {ν l d : ℝ} (hν : 0 < ν) (hl : 0 < l)
    (hfit : width ν l < 2)
    (hu : ∀ t < (1:ℝ), ∀ x : Space, compact ν l a (t,x) ≠ 0 → ∀ i, |x i| ≤ 1/4)
    (hd : d ∈ Ioo (-(1/16):ℝ) 0) (t : ℝ) {i j : Fin 3} (hij : i ≠ j) :
    lineIntegral ν l (torusVelocity ν l a) t i j d = 0 := by sorry

end SignedVortex.Rescaled.EdgeControl
