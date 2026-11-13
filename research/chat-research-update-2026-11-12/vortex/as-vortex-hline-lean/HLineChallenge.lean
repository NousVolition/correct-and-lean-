import HLineStatements

noncomputable section
namespace SignedVortex.HLine
open Set NavierStokes.ProblemStatement

theorem hline_both (a : ℕ → ℕ) :
    ∃ η : ℝ, 0 < η ∧ ∀ τ : ℝ, 0 < τ → τ < η →
      ∀ d ∈ Ioo (-(1/16):ℝ) (1/8),
        loopResidual (vortex a) (1-τ) 0 1 d = signal (1-τ) d ∧
        loopResidual (vortex a) (1-τ) 1 0 d = -signal (1-τ) d := by sorry

theorem hline_xy (a : ℕ → ℕ) :
    ∃ η : ℝ, 0 < η ∧ ∀ τ : ℝ, 0 < τ → τ < η →
      ∀ d ∈ Ioo (-(1/16):ℝ) (1/8), loopResidual (vortex a) (1-τ) 0 1 d = signal (1-τ) d := by sorry

theorem hline_yx (a : ℕ → ℕ) :
    ∃ η : ℝ, 0 < η ∧ ∀ τ : ℝ, 0 < τ → τ < η →
      ∀ d ∈ Ioo (-(1/16):ℝ) (1/8), loopResidual (vortex a) (1-τ) 1 0 d = -signal (1-τ) d := by sorry

theorem signed_excluded_at_late_times (a : ℕ → ℕ) :
    ∃ η : ℝ, 0 < η ∧ ∀ τ : ℝ, 0 < τ → τ < η →
    ∀ (k : Fin 3) (ε Γ c : ℝ), ¬ ∃ (p : PressureField) (S : Space → ℝ),
      ContDiff ℝ 1 (fun x => p (1-τ,x)) ∧
      (∀ x j, p (1-τ,x+coordinateVector j) = p (1-τ,x)) ∧
      MatchesSignedAt (vortex a) p S k ε Γ c (1-τ) := by sorry

theorem no_signed_full_trajectory (a : ℕ → ℕ) (k : Fin 3) (ε Γ c : ℝ) :
    ¬ ∃ (p : PressureField) (S : ℝ → Space → ℝ),
      (∀ t ∈ Ioo (0:ℝ) 1, ContDiff ℝ 1 (fun x => p (t,x))) ∧
      (∀ t ∈ Ioo (0:ℝ) 1, ∀ x j, p (t,x+coordinateVector j) = p (t,x)) ∧
      ∀ t ∈ Ioo (0:ℝ) 1, MatchesSignedAt (vortex a) p (S t) k ε Γ c t := by sorry
end SignedVortex.HLine
