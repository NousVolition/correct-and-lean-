import ASCounterexample

/-!
Work receipts, carried configuration and a conditional gravity interpretation.
The original A/S equations are imported unchanged. No force or evolution law
is inserted into them. A potential-force match is an explicit hypothesis.
-/
set_option autoImplicit false
noncomputable section
namespace CarryingGravity
open OriginalAS OriginalAS.Energy

/- The positive solver receipt is work received; the opposite account decreases. -/
theorem receipt_and_reservoir_sign (initial receipt : ℝ) :
    (initial - receipt) - initial = -receipt := by ring

theorem three_channel_balance (E B W C : ℝ → ℝ) (b w p t : ℝ)
    (hE : HasDerivAt E (b+w+p) t) (hB : HasDerivAt B b t)
    (hW : HasDerivAt W w t) (hC : HasDerivAt C p t) :
    HasDerivAt (fun s => E s - B s - W s - C s) 0 t := by
  convert ((hE.fun_sub hB).fun_sub hW).fun_sub hC using 1 <;> first | rfl | ring

theorem three_channel_account_constant (E B W C b w p : ℝ → ℝ)
    (hE : ∀ t, HasDerivAt E (b t+w t+p t) t)
    (hB : ∀ t, HasDerivAt B (b t) t) (hW : ∀ t, HasDerivAt W (w t) t)
    (hC : ∀ t, HasDerivAt C (p t) t) (t : ℝ) :
    E t-B t-W t-C t = E 0-B 0-W 0-C 0 := by
  have hd := fun s => three_channel_balance E B W C (b s) (w s) (p s) s
    (hE s) (hB s) (hW s) (hC s)
  exact is_const_of_deriv_eq_zero (fun s => (hd s).differentiableAt)
    (fun s => (hd s).deriv) t 0

/- One-dimensional conservative-force chain rule along a carried coordinate.
   rho is constant; Phi is static. No claim that the source supplies hforce. -/
theorem carried_potential_work (X Phi : ℝ → ℝ) (rho b v g t : ℝ)
    (hX : HasDerivAt X v t) (hPhi : HasDerivAt Phi g (X t))
    (hforce : b = -rho*g) :
    HasDerivAt (fun s => rho*Phi (X s)) (-b*v) t := by
  convert (hPhi.comp t hX).const_mul rho using 1 <;> first | rfl | (rw [hforce]; ring)

theorem matched_potential_conserves (E X Phi : ℝ → ℝ) (rho b v g t : ℝ)
    (hE : HasDerivAt E (b*v) t) (hX : HasDerivAt X v t)
    (hPhi : HasDerivAt Phi g (X t)) (hforce : b = -rho*g) :
    HasDerivAt (fun s => E s + rho*Phi (X s)) 0 t := by
  convert hE.fun_add (carried_potential_work X Phi rho b v g t hX hPhi hforce)
    using 1 <;> first | rfl | ring

/- A changing strength leaves a term that cannot be discarded. -/
theorem variable_strength_height_balance (E a X : ℝ → ℝ) (sigma da v t : ℝ)
    (hE : HasDerivAt E (-sigma*a t*v) t)
    (ha : HasDerivAt a da t) (hX : HasDerivAt X v t) :
    HasDerivAt (fun s => E s + sigma*a s*X s) (sigma*da*X t) t := by
  convert hE.fun_add ((ha.const_mul sigma).fun_mul hX) using 1 <;> first | rfl | ring

/- The previous exact source solution has uniform acceleration. Its unwrapped
   material coordinate changes even though A and the entire S field do not. -/
def carriedHeight (x0 t : ℝ) : ℝ := x0-t-t^2/2

def carriedPosition (x0 y0 t : ℝ) : Point 2 := ![carriedHeight x0 t, y0]

theorem carried_height_derivative (x0 t : ℝ) :
    HasDerivAt (carriedHeight x0) (-(t+1)) t := by
  convert ((hasDerivAt_const t x0).fun_sub (hasDerivAt_id t)).fun_sub
    (((hasDerivAt_id t).pow 2).div_const 2) using 1 <;>
    first | rfl | (dsimp [carriedHeight]; ring)

theorem position_follows_original_velocity (x0 y0 t : ℝ) (i : Fin 2) :
    HasDerivAt (fun s => carriedPosition x0 y0 s i)
      (Witness.velocity t (carriedPosition x0 y0 t) i) t := by
  fin_cases i
  · simpa [carriedPosition, Witness.velocity] using carried_height_derivative x0 t
  · simpa [carriedPosition, Witness.velocity] using hasDerivAt_const t y0

theorem carried_height_cancels_original_work (x0 t : ℝ) (x : Point 2) :
    HasDerivAt (carriedHeight x0)
      (-hugPower Witness.params sharp 0 (Witness.state t).u (Witness.state t).S x) t := by
  rw [Witness.coupling_power]
  exact carried_height_derivative x0 t

theorem exact_configuration_balance (x0 t : ℝ) :
    Witness.channelKinetic t + carriedHeight x0 t =
      Witness.channelKinetic 0 + carriedHeight x0 0 := by
  rw [Witness.channel_kinetic_value, Witness.channel_kinetic_value]
  dsimp [carriedHeight]
  ring

/- A constant nonzero slope is incompatible with a single-valued potential
   on a unit-periodic coordinate. This is a global obstruction, not a ban on
   unwrapped position or a history account. -/
theorem periodic_potential_constant_slope_zero (Phi : ℝ → ℝ) (g : ℝ)
    (hPhi : ∀ x, HasDerivAt Phi g x) (hperiod : ∀ x, Phi (x+1)=Phi x) : g=0 := by
  have hd : ∀ x, HasDerivAt (fun y => Phi y-g*y) 0 x := by
    intro x
    convert (hPhi x).fun_sub ((hasDerivAt_id x).const_mul g) using 1 <;>
      first | rfl | ring
  have he := is_const_of_deriv_eq_zero (fun x => (hd x).differentiableAt)
    (fun x => (hd x).deriv) (1 : ℝ) 0
  have hp := hperiod 0
  norm_num at hp
  rw [hp] at he
  linarith

theorem no_periodic_potential_for_unit_force :
    ¬ ∃ Phi : ℝ → ℝ, (∀ x, HasDerivAt Phi 1 x) ∧ (∀ x, Phi (x+1)=Phi x) := by
  rintro ⟨Phi, hd, hp⟩
  have h := periodic_potential_constant_slope_zero Phi 1 hd hp
  norm_num at h

end CarryingGravity
