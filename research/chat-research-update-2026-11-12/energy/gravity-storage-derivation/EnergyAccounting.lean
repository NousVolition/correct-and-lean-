import OriginalASIntegrated
import Mathlib.Analysis.Calculus.MeanValue

/-! Necessary energy closure and passive history accounting.
The reservoir balance below is a stated condition, not a new consequence of
the original A/S equations. Cumulative integrals do not modify the flow.
-/
set_option autoImplicit false
noncomputable section
namespace OriginalAS.Energy.Accounting

def cumulative (rate : ℝ → ℝ) (t : ℝ) : ℝ := ∫ s in (0 : ℝ)..t, rate s

theorem cumulative_derivative (rate : ℝ → ℝ) (hc : Continuous rate) (t : ℝ) :
    HasDerivAt (cumulative rate) (rate t) t := by
  exact intervalIntegral.integral_hasDerivAt_right (hc.intervalIntegrable 0 t)
    hc.aestronglyMeasurable.stronglyMeasurableAtFilter hc.continuousAt

theorem total_rate (K H I : ℝ → ℝ) (D P V t : ℝ)
    (hK : HasDerivAt K (-D+P) t) (hH : HasDerivAt H D t)
    (hI : HasDerivAt I V t) :
    HasDerivAt (fun s => K s + H s + I s) (P+V) t := by
  convert (hK.fun_add hH).fun_add hI using 1 <;> first | rfl | ring

theorem conservation_iff_exchange (K H I : ℝ → ℝ) (D P V t : ℝ)
    (hK : HasDerivAt K (-D+P) t) (hH : HasDerivAt H D t)
    (hI : HasDerivAt I V t) :
    deriv (fun s => K s + H s + I s) t = 0 ↔ V = -P := by
  rw [(total_rate K H I D P V t hK hH hI).deriv]
  constructor <;> intro h <;> linarith

theorem heat_alone_leaves_coupling (K H : ℝ → ℝ) (D P t : ℝ)
    (hK : HasDerivAt K (-D+P) t) (hH : HasDerivAt H D t) :
    HasDerivAt (fun s => K s + H s) P t := by
  convert hK.fun_add hH using 1 <;> first | rfl | ring

theorem heat_ledger_nonnegative (D : ℝ → ℝ)
    (hn : ∀ s, 0 ≤ D s) (t : ℝ) (ht : 0 ≤ t) : 0 ≤ cumulative D t := by
  exact intervalIntegral.integral_nonneg ht (fun s _ => hn s)

/- This is a history-dependent signed work account. It is not identified with
   a state function of A and S or assumed nonnegative. -/
def exchangeLedger (P : ℝ → ℝ) (initial t : ℝ) : ℝ := initial - cumulative P t

theorem exchange_ledger_derivative (P : ℝ → ℝ) (hc : Continuous P)
    (initial t : ℝ) : HasDerivAt (exchangeLedger P initial) (-P t) t := by
  unfold exchangeLedger
  convert (hasDerivAt_const t initial).fun_sub (cumulative_derivative P hc t) using 1 <;>
    first | rfl | ring

theorem history_account_derivative (K D P : ℝ → ℝ) (initial t : ℝ)
    (hD : Continuous D) (hP : Continuous P)
    (hK : HasDerivAt K (-D t+P t) t) :
    HasDerivAt (fun s => K s + cumulative D s + exchangeLedger P initial s) 0 t := by
  simpa using total_rate K (cumulative D) (exchangeLedger P initial) (D t) (P t)
    (-P t) t hK (cumulative_derivative D hD t) (exchange_ledger_derivative P hP initial t)

theorem history_account_constant (K D P : ℝ → ℝ) (initial : ℝ)
    (hD : Continuous D) (hP : Continuous P)
    (hK : ∀ t, HasDerivAt K (-D t+P t) t) (t : ℝ) :
    K t + cumulative D t + exchangeLedger P initial t = K 0 + initial := by
  have hd := fun t => history_account_derivative K D P initial t hD hP (hK t)
  have h := is_const_of_deriv_eq_zero (fun t => (hd t).differentiableAt)
    (fun t => (hd t).deriv) t 0
  simpa [cumulative, exchangeLedger] using h

end OriginalAS.Energy.Accounting
