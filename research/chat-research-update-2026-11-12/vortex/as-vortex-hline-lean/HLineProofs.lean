import HLineGeometry
import HLineIntegral
import HLineStatements

noncomputable section
namespace SignedVortex.HLine
open Set NavierStokes NavierStokes.ProblemStatement
open scoped Topology

theorem hline_both (a : ℕ → ℕ) :
    ∃ η : ℝ, 0 < η ∧ ∀ τ : ℝ, 0 < τ → τ < η →
      ∀ d ∈ Ioo (-(1/16):ℝ) (1/8),
        loopResidual (vortex a) (1-τ) 0 1 d = signal (1-τ) d ∧
        loopResidual (vortex a) (1-τ) 1 0 d = -signal (1-τ) d := by
  obtain ⟨η,hη,H⟩ := late_loops a
  refine ⟨η,hη,?_⟩
  intro τ hτ hτη d hd
  let F := radial nativeC nativeH
  have hh := NavierStokes.CorrectionInitialization.ActualPrimary.outgoing.data.h_pos
  have h01 : loopResidual (vortex a) (1-τ) 0 1 d = avg (lineValue F 1 (1-τ) d) := by
    apply intervalIntegral.integral_congr
    intro y hy
    rw [uIcc_of_le (by norm_num : (-(1/2):ℝ) ≤ 1/2)] at hy
    have h := (H τ hτ hτη d hd y hy).1
    have hr := ResidualRegularity.residual_congr (native_is_spin h) (Filter.EventuallyEq.rfl
      (f := (fun _ : SpaceTime => (0:ℝ))))
    exact (congrArg (fun v : Space => v 1) hr).trans
      (radial_components (radial_smooth nativeC nativeH hh) (1-τ) d y).1
  have h10 : loopResidual (vortex a) (1-τ) 1 0 d = avg (lineValue F (-1) (1-τ) d) := by
    apply intervalIntegral.integral_congr
    intro y hy
    rw [uIcc_of_le (by norm_num : (-(1/2):ℝ) ≤ 1/2)] at hy
    have h := (H τ hτ hτη d hd y hy).2
    have hr := ResidualRegularity.residual_congr (native_is_spin h) (Filter.EventuallyEq.rfl
      (f := (fun _ : SpaceTime => (0:ℝ))))
    exact (congrArg (fun v : Space => v 0) hr).trans
      (radial_components (radial_smooth nativeC nativeH hh) (1-τ) d y).2
  have he : signal (1-τ) d = coeff F (1-τ) d := defect_deriv nativeC nativeH (1-τ) hh hd.2
  rw [h01,h10,integrated_line nativeC nativeH _ _ 1 hh,
    integrated_line nativeC nativeH _ _ (-1) hh,he]
  simp [F]

theorem hline_xy (a : ℕ → ℕ) :
    ∃ η : ℝ, 0 < η ∧ ∀ τ : ℝ, 0 < τ → τ < η →
      ∀ d ∈ Ioo (-(1/16):ℝ) (1/8),
        loopResidual (vortex a) (1-τ) 0 1 d = signal (1-τ) d := by
  obtain ⟨η,hη,h⟩ := hline_both a
  exact ⟨η,hη,fun τ hτ ht d hd => (h τ hτ ht d hd).1⟩

theorem hline_yx (a : ℕ → ℕ) :
    ∃ η : ℝ, 0 < η ∧ ∀ τ : ℝ, 0 < τ → τ < η →
      ∀ d ∈ Ioo (-(1/16):ℝ) (1/8),
        loopResidual (vortex a) (1-τ) 1 0 d = -signal (1-τ) d := by
  obtain ⟨η,hη,h⟩ := hline_both a
  exact ⟨η,hη,fun τ hτ ht d hd => (h τ hτ ht d hd).2⟩

/-- The same late-time window excludes every signed field for every Cartesian
forcing axis. There is no line-identity premise. -/
theorem signed_excluded_at_late_times (a : ℕ → ℕ) :
    ∃ η : ℝ, 0 < η ∧ ∀ τ : ℝ, 0 < τ → τ < η →
    ∀ (k : Fin 3) (ε Γ c : ℝ), ¬ ∃ (p : PressureField) (S : Space → ℝ),
      ContDiff ℝ 1 (fun x => p (1-τ,x)) ∧
      (∀ x j, p (1-τ,x+coordinateVector j) = p (1-τ,x)) ∧
      MatchesSignedAt (vortex a) p S k ε Γ c (1-τ) := by
  obtain ⟨η,hη,H⟩ := hline_both a
  refine ⟨η,hη,?_⟩
  intro τ hτ ht k ε Γ c
  rintro ⟨p,S,hp,hper,hm⟩
  by_cases hk : (1 : Fin 3) ≠ k
  · apply signed_target_excluded_if_line_identified a (i:=0) hk
        (show 1-τ<1 by linarith) (1:ℝ) one_ne_zero _ ⟨p,S,hp,fun x => hper x 1,hm⟩
    intro d hd; simpa only [one_mul, signal, vortex] using (H τ hτ ht d hd).1
  · have hk' : (0:Fin 3) ≠ k := by have := not_ne_iff.mp hk; omega
    apply signed_target_excluded_if_line_identified a (i:=1) hk'
        (show 1-τ<1 by linarith) (-1:ℝ) (by norm_num) _ ⟨p,S,hp,fun x => hper x 0,hm⟩
    intro d hd; simpa only [neg_one_mul, signal, vortex] using (H τ hτ ht d hd).2

theorem no_signed_full_trajectory (a : ℕ → ℕ) (k : Fin 3) (ε Γ c : ℝ) :
    ¬ ∃ (p : PressureField) (S : ℝ → Space → ℝ),
      (∀ t ∈ Ioo (0:ℝ) 1, ContDiff ℝ 1 (fun x => p (t,x))) ∧
      (∀ t ∈ Ioo (0:ℝ) 1, ∀ x j, p (t,x+coordinateVector j) = p (t,x)) ∧
      ∀ t ∈ Ioo (0:ℝ) 1, MatchesSignedAt (vortex a) p (S t) k ε Γ c t := by
  rintro ⟨p,S,hp,hper,hm⟩
  obtain ⟨η,hη,H⟩ := signed_excluded_at_late_times a
  let τ := min 1 η / 2
  have ht : 0 < τ := div_pos (lt_min zero_lt_one hη) (by norm_num)
  have hsmall : τ < η := by dsimp [τ]; linarith [min_le_right (1:ℝ) η]
  have hin : 1-τ ∈ Ioo (0:ℝ) 1 := by
    constructor <;> dsimp [τ] at * <;> linarith [min_le_left (1:ℝ) η]
  exact H τ ht hsmall k ε Γ c ⟨p,S (1-τ),hp _ hin,hper _ hin,hm _ hin⟩

end SignedVortex.HLine
