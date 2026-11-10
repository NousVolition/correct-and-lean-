import PrimeMeter.Study
import Mathlib.Tactic.NormNum

/-! A finite certificate for the measured Hug histories on the prime meter.
    All energy operations in the certificate use exact integers or rationals. -/
namespace HugPrimeMeter

open Recorded
set_option autoImplicit false
set_option maxRecDepth 8192
set_option maxHeartbeats 2000000

private def trialPrime (n : Nat) : Bool :=
  decide (2 ≤ n) && (List.range n).all (fun d => decide (d < 2 ∨ ¬d ∣ n))

private theorem trialPrime_spec (n : Nat) : trialPrime n = true ↔ Nat.Prime n := by
  rw [Nat.prime_def_lt']
  simp only [trialPrime, Bool.and_eq_true, decide_eq_true_eq, List.all_eq_true, List.mem_range]
  constructor
  · rintro ⟨hn, h⟩
    exact ⟨hn, fun d hd hdn => (h d hdn).resolve_left (Nat.not_lt.mpr hd)⟩
  · rintro ⟨hn, h⟩
    refine ⟨hn, fun d hdn => ?_⟩
    by_cases hd : d < 2
    · exact Or.inl hd
    · exact Or.inr (h d (Nat.le_of_not_lt hd) hdn)

/-- The enumerated meter labels are exactly Mathlib's primes through 157 in order. -/
theorem prime_meter_labels :
    labels = (List.range 158).filter (fun n => decide (Nat.Prime n)) := by
  have pred : (fun n => decide (Nat.Prime n)) = trialPrime := by
    funext n
    by_cases hp : Nat.Prime n
    · simp [hp, (trialPrime_spec n).2 hp]
    · have hf : trialPrime n = false := by
        cases h : trialPrime n with
        | false => rfl
        | true => exact (hp ((trialPrime_spec n).1 h)).elim
      simp [hp, hf]
  rw [pred]
  decide

theorem write_and_endpoint_clocks :
    labels[16]? = some 59 ∧ 16 * 25 = 400 ∧ 16 * 32 = 512 ∧
    labels[36]? = some 157 ∧ 36 * 25 = 900 ∧ 36 * 32 = 1152 := by decide

/-- Each history has all 37 ticks plus both sides of each of the four writes.
    This checks each ledger equation and ties the special rows to the separate run receipt. -/
theorem all_meter_rows_valid (a : Arm) : goodRun (rows a) (receipt a) = true := by
  cases a <;> decide

theorem record_counts : offRows.length = 41 ∧ onRows.length = 41 ∧ labels.length = 37 := by decide

/-- At the fourth write, the released heat also includes the drop in stored energy.
    At the recorded precision the total energy and write accumulator receive the supplied work. -/
theorem fourth_write_account (a : Arm) :
    let r := receipt a
    r.cost.work = r.cost.heat + r.cost.stored ∧
    0 < r.cost.work ∧ r.cost.work < r.cost.heat ∧ r.cost.stored < 0 ∧
    r.after59.writeWork = round53 (r.before59.writeWork + r.cost.work) ∧
    r.after59.energy = round53 (r.before59.energy + r.cost.work) ∧
    r.before59.residual = r.after59.residual := by
  cases a <;> decide

/-- Work, heat and stored-energy change at prime 59, to 10⁻¹² Hug energy units. -/
theorem prime59_displayed_values :
    roundsTo offReceipt.cost.work 12 12972938 ∧ roundsTo offReceipt.cost.heat 12 13565637 ∧
    roundsTo offReceipt.cost.stored 12 (-592699) ∧
    roundsTo onReceipt.cost.work 12 13040157 ∧ roundsTo onReceipt.cost.heat 12 13605009 ∧
    roundsTo onReceipt.cost.stored 12 (-564852) := by decide

theorem prime157_exact_change :
    hugUnits (residualChange offReceipt) = (2831 : ℚ) / 4503599627370496 ∧
    hugUnits (residualChange onReceipt) = (41501 : ℚ) / 72057594037927936 := by
  norm_num [hugUnits, residualChange, offReceipt, onReceipt, unitDen]

theorem prime157_toward_zero (a : Arm) :
    let r := receipt a
    r.three157.residual < r.four157.residual ∧ r.four157.residual < 0 := by
  cases a <;> decide

/-- Signed residuals to 10⁻¹⁷ and four-minus-three differences to 10⁻¹⁹. -/
theorem prime157_displayed_values :
    roundsTo offReceipt.three157.residual 17 (-2290515626) ∧
    roundsTo offReceipt.four157.residual 17 (-2290452765) ∧
    roundsTo onReceipt.three157.residual 17 (-1466485869) ∧
    roundsTo onReceipt.four157.residual 17 (-1466428275) ∧
    roundsTo (residualChange offReceipt) 19 6286083 ∧
    roundsTo (residualChange onReceipt) 19 5759421 := by decide

#print axioms prime_meter_labels
#print axioms write_and_endpoint_clocks
#print axioms all_meter_rows_valid
#print axioms record_counts
#print axioms fourth_write_account
#print axioms prime59_displayed_values
#print axioms prime157_exact_change
#print axioms prime157_toward_zero
#print axioms prime157_displayed_values

end HugPrimeMeter
