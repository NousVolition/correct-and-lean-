import OriginalASIntegrated

/-! The history-dependent energy term already stated in STRUCTURAL_MEMORY.md,
sections 3--5, and implemented in structural_memory.py lines 73--89.
This is a source transcription, not an insertion into OriginalAS.rates.
The complete F-to-strain kinematics and PDE existence are not assumed proved.
-/
set_option autoImplicit false
noncomputable section
namespace HugSourceEnergy

def expression (scale memory : ℝ) : ℝ := 1 - Real.exp (-memory/scale)

def recordEnergy (G scale strain memory : ℝ) : ℝ :=
  G/2 * expression scale memory * strain^2

def recordStress (G scale strain memory : ℝ) : ℝ :=
  G * expression scale memory * strain

def writeConjugate (G scale strain memory : ℝ) : ℝ :=
  G/(2*scale) * Real.exp (-memory/scale) * strain^2

theorem expression_derivative (scale : ℝ) (m : ℝ → ℝ) (v t : ℝ)
    (hm : HasDerivAt m v t) :
    HasDerivAt (fun s => expression scale (m s))
      (Real.exp (-m t/scale)/scale*v) t := by
  unfold expression
  convert (hasDerivAt_const t (1 : ℝ)).fun_sub ((hm.neg.div_const scale).exp) using 1 <;>
    first | rfl | (simp only [Pi.neg_apply]; ring)

theorem record_energy_balance (G scale : ℝ) (e m : ℝ → ℝ) (ve vm t : ℝ)
    (hs : scale ≠ 0) (he : HasDerivAt e ve t) (hm : HasDerivAt m vm t) :
    HasDerivAt (fun s => recordEnergy G scale (e s) (m s))
      (recordStress G scale (e t) (m t)*ve +
        writeConjugate G scale (e t) (m t)*vm) t := by
  have hd := ((expression_derivative scale m vm t hm).const_mul (G/2)).fun_mul (he.pow 2)
  convert hd using 1 <;> first
  | rfl
  | (dsimp [recordStress, writeConjugate]; field_simp; ring)

theorem unstrained_energy_zero (G scale memory : ℝ) :
    recordEnergy G scale 0 memory = 0 := by
  simp [recordEnergy]

theorem unstrained_stress_zero (G scale memory : ℝ) :
    recordStress G scale 0 memory = 0 := by
  simp [recordStress]

theorem unstrained_write_conjugate_zero (G scale memory : ℝ) :
    writeConjugate G scale 0 memory = 0 := by
  simp [writeConjugate]

theorem write_conjugate_nonnegative (G scale strain memory : ℝ)
    (hG : 0 ≤ G) (hs : 0 < scale) : 0 ≤ writeConjugate G scale strain memory := by
  unfold writeConjugate
  positivity

theorem changing_records_can_change_response (G scale e m₁ m₂ : ℝ) :
    recordStress G scale e m₂ - recordStress G scale e m₁ =
      G*e*(expression scale m₂-expression scale m₁) := by
  unfold recordStress
  ring

/- The source limits writing by an allocation from viscous stress power. -/
def writingLimiter (eta viscousPower powerFloor rawPower : ℝ) : ℝ :=
  eta*viscousPower/(powerFloor+eta*viscousPower+rawPower)

theorem no_viscous_power_no_writing (eta powerFloor rawPower rate : ℝ) :
    writingLimiter eta 0 powerFloor rawPower * rate = 0 := by
  simp [writingLimiter]

theorem recording_power_bound (eta Q floor raw : ℝ)
    (heta : 0 ≤ eta) (hQ : 0 ≤ Q) (hf : 0 < floor) (hr : 0 ≤ raw) :
    0 ≤ writingLimiter eta Q floor raw * raw ∧
      writingLimiter eta Q floor raw * raw ≤ eta*Q := by
  have hb : 0 ≤ eta*Q := mul_nonneg heta hQ
  have hd : 0 < floor+eta*Q+raw := by linarith
  unfold writingLimiter
  constructor
  · positivity
  · rw [div_mul_eq_mul_div, div_le_iff₀ hd]
    nlinarith

/- Conditional on the three balances already stated in the material notes,
   internal stress and writing transfers cancel, leaving the original coupling.
   This is an accounting identity, not a new proof of the full spatial solver. -/
theorem material_total_residual (K W H : ℝ → ℝ) (Q stressWork writePower release sourcePower t : ℝ)
    (hK : HasDerivAt K (-Q-stressWork+sourcePower) t)
    (hW : HasDerivAt W (stressWork+writePower-release) t)
    (hH : HasDerivAt H (Q-writePower+release) t) :
    HasDerivAt (fun s => K s+W s+H s) sourcePower t := by
  convert (hK.fun_add hW).fun_add hH using 1 <;> first | rfl | ring

theorem material_conservation_iff_zero_source_power (K W H : ℝ → ℝ)
    (Q stressWork writePower release sourcePower t : ℝ)
    (hK : HasDerivAt K (-Q-stressWork+sourcePower) t)
    (hW : HasDerivAt W (stressWork+writePower-release) t)
    (hH : HasDerivAt H (Q-writePower+release) t) :
    deriv (fun s => K s+W s+H s) t = 0 ↔ sourcePower = 0 := by
  rw [(material_total_residual K W H Q stressWork writePower release sourcePower t hK hW hH).deriv]

theorem fixed_strain_and_record_energy_rate_zero (G scale : ℝ)
    (e m : ℝ → ℝ) (t : ℝ) (hs : scale ≠ 0)
    (he : HasDerivAt e 0 t) (hm : HasDerivAt m 0 t) :
    HasDerivAt (fun s => recordEnergy G scale (e s) (m s)) 0 t := by
  simpa using record_energy_balance G scale e m 0 0 t hs he hm

end HugSourceEnergy
