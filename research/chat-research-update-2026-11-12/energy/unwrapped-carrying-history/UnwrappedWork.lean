import EnergyAccounting

/-! Exact identities behind a passive carrying-work diagnostic.
No original evolution equation is changed. The continuously defined history
account is shown to contain exactly the same signed work as a cumulative ledger;
these identities do not identify a physical gravitational reservoir.
-/
set_option autoImplicit false
noncomputable section
open scoped BigOperators
namespace UnwrappedWork
open OriginalAS.Energy.Accounting

def pathWork (sigma : ℝ) (a X : ℕ → ℝ) (n : ℕ) : ℝ :=
  ∑ i ∈ Finset.range n, -sigma * ((a i+a (i+1))/2) * (X (i+1)-X i)

def activationCorrection (sigma : ℝ) (a X : ℕ → ℝ) (n : ℕ) : ℝ :=
  ∑ i ∈ Finset.range n, sigma * ((X i+X (i+1))/2) * (a (i+1)-a i)

theorem one_step_work_split (sigma a0 a1 X0 X1 : ℝ) :
    -sigma*((a0+a1)/2)*(X1-X0) =
      sigma*a0*X0-sigma*a1*X1+sigma*((X0+X1)/2)*(a1-a0) := by ring

theorem discrete_history_balance (sigma : ℝ) (a X : ℕ → ℝ) (n : ℕ) :
    pathWork sigma a X n = sigma*a 0*X 0-sigma*a n*X n +
      activationCorrection sigma a X n := by
  induction n with
  | zero => simp [pathWork, activationCorrection]
  | succ n ih =>
    have hw : pathWork sigma a X (n+1) = pathWork sigma a X n +
        -sigma*((a n+a (n+1))/2)*(X (n+1)-X n) := by
      simp [pathWork, Finset.sum_range_succ]
      ring
    have hc : activationCorrection sigma a X (n+1) = activationCorrection sigma a X n +
        sigma*((X n+X (n+1))/2)*(a (n+1)-a n) := by
      simp [activationCorrection, Finset.sum_range_succ]
    rw [hw, hc, ih, one_step_work_split]
    ring

theorem returning_endpoints_leave_history (sigma : ℝ) (a X : ℕ → ℝ) (n : ℕ)
    (ha : a n=a 0) (hX : X n=X 0) :
    pathWork sigma a X n = activationCorrection sigma a X n := by
  rw [discrete_history_balance, ha, hX]
  ring

def historyEnergy (sigma : ℝ) (a X da : ℝ → ℝ) (t : ℝ) : ℝ :=
  sigma*a t*X t - cumulative (fun s => sigma*X s*da s) t

theorem history_energy_derivative (sigma : ℝ) (a X da : ℝ → ℝ) (v t : ℝ)
    (ha : HasDerivAt a (da t) t) (hX : HasDerivAt X v t)
    (hc : Continuous (fun s => sigma*X s*da s)) :
    HasDerivAt (historyEnergy sigma a X da) (sigma*a t*v) t := by
  convert ((ha.const_mul sigma).fun_mul hX).fun_sub
    (cumulative_derivative (fun s => sigma*X s*da s) hc t) using 1 <;>
    first | rfl | ring

theorem history_total_constant (sigma : ℝ) (E a X da v : ℝ → ℝ)
    (hE : ∀ t, HasDerivAt E (-sigma*a t*v t) t)
    (ha : ∀ t, HasDerivAt a (da t) t) (hX : ∀ t, HasDerivAt X (v t) t)
    (hc : Continuous (fun s => sigma*X s*da s)) (t : ℝ) :
    E t+historyEnergy sigma a X da t = E 0+historyEnergy sigma a X da 0 := by
  have hd : ∀ s, HasDerivAt (fun r => E r+historyEnergy sigma a X da r) 0 s := by
    intro s
    convert (hE s).fun_add (history_energy_derivative sigma a X da (v s) s (ha s) (hX s) hc)
      using 1 <;> first | rfl | ring
  exact is_const_of_deriv_eq_zero (fun s => (hd s).differentiableAt)
    (fun s => (hd s).deriv) t 0

theorem history_is_opposite_work_receipt (sigma : ℝ) (a X da v : ℝ → ℝ)
    (ha : ∀ t, HasDerivAt a (da t) t) (hX : ∀ t, HasDerivAt X (v t) t)
    (hc : Continuous (fun s => sigma*X s*da s))
    (hp : Continuous (fun s => -sigma*a s*v s)) (t : ℝ) :
    historyEnergy sigma a X da t = historyEnergy sigma a X da 0 -
      cumulative (fun s => -sigma*a s*v s) t := by
  have h := history_total_constant sigma (cumulative (fun s => -sigma*a s*v s))
    a X da v (fun s => cumulative_derivative _ hp s) ha hX hc t
  simp only [cumulative, intervalIntegral.integral_same] at h
  dsimp [cumulative]
  linarith

end UnwrappedWork
