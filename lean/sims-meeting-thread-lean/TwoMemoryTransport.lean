import TwoMemory

namespace TwoMemoryTransport

noncomputable section

/-- The ratio retains all the information used by the original memory drift. -/
theorem readout_from_odds (s : ℝ) :
    TwoMemory.memoryField s = (odds s - 1) / (odds s + 1) := by
  have hn : minusWeight s ≠ 0 := Real.exp_ne_zero _
  change (plusWeight s - minusWeight s) / (plusWeight s + minusWeight s) = _
  rw [show odds s - 1 = (plusWeight s - minusWeight s) / minusWeight s by
        rw [odds, sub_div, div_self hn],
      show odds s + 1 = (plusWeight s + minusWeight s) / minusWeight s by
        rw [odds, add_div, div_self hn], div_div_div_cancel_right₀ hn]

theorem odds_eq_exp (s : ℝ) : odds s = Real.exp (2 * s) := by
  unfold odds plusWeight minusWeight
  rw [← Real.exp_sub]
  congr 1
  ring

theorem update_odds (a b : ℝ) : transport a b * odds a = odds b := by
  simp only [transport, odds_eq_exp, ← Real.exp_add]
  congr 1
  ring

theorem compose_transport (a b c : ℝ) :
    transport b c * transport a b = transport a c := by
  unfold transport
  rw [← Real.exp_add]
  congr 1
  ring

theorem endpoints_determine_transport (a b : ℝ) (stops : List ℝ) :
    along a stops b = transport a b := by
  induction stops generalizing a with
  | nil => rfl
  | cons next rest ih => rw [along, ih, compose_transport]

theorem closed_route (a : ℝ) (stops : List ℝ) : along a stops a = 1 := by
  rw [endpoints_determine_transport]
  simp [transport]

theorem odds_parallel (s : ℝ) : deriv odds s + cueCoefficient * odds s = 0 := by
  have hlin : HasDerivAt (fun u : ℝ => 2 * u) 2 s := by
    simpa using (hasDerivAt_id s).const_mul 2
  have he : HasDerivAt odds (Real.exp (2 * s) * 2) s := by
    rw [show odds = (fun u : ℝ => Real.exp (2 * u)) from funext odds_eq_exp]
    exact (Real.hasDerivAt_exp _).comp s hlin
  rw [he.deriv, odds_eq_exp, cueCoefficient]
  ring

theorem flat_curvature (i j : Fin 4) (p : Point) :
    curvature potential i j p = 0 := by
  simp [curvature, partialDerivative, potential]

theorem source_free (j : Fin 4) (p : Point) : yangMillsResidual potential j p = 0 := by
  simp [yangMillsResidual, partialDerivative, flat_curvature]

/-- Transport works along any cue path. Unit-speed motion already disagrees
    with the original memory drift at 0. -/
theorem unit_speed_fails_memory_at_zero :
    deriv (fun t : ℝ => t) 0 ≠ TwoMemory.memoryField 0 := by
  simp [TwoMemory.recall_eq_tanh]

end

end TwoMemoryTransport
