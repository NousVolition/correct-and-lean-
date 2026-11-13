import PrimeMeter.Study

namespace HugPrimeMeter

open Recorded

theorem prime_meter_labels :
    labels = (List.range 158).filter (fun n => decide (Nat.Prime n)) := by sorry

theorem write_and_endpoint_clocks :
    labels[16]? = some 59 ∧ 16 * 25 = 400 ∧ 16 * 32 = 512 ∧
    labels[36]? = some 157 ∧ 36 * 25 = 900 ∧ 36 * 32 = 1152 := by sorry

theorem all_meter_rows_valid (a : Arm) : goodRun (rows a) (receipt a) = true := by sorry

theorem record_counts : offRows.length = 41 ∧ onRows.length = 41 ∧ labels.length = 37 := by sorry

theorem fourth_write_account (a : Arm) :
    let r := receipt a
    r.cost.work = r.cost.heat + r.cost.stored ∧
    0 < r.cost.work ∧ r.cost.work < r.cost.heat ∧ r.cost.stored < 0 ∧
    r.after59.writeWork = round53 (r.before59.writeWork + r.cost.work) ∧
    r.after59.energy = round53 (r.before59.energy + r.cost.work) ∧
    r.before59.residual = r.after59.residual := by sorry

theorem prime59_displayed_values :
    roundsTo offReceipt.cost.work 12 12972938 ∧ roundsTo offReceipt.cost.heat 12 13565637 ∧
    roundsTo offReceipt.cost.stored 12 (-592699) ∧
    roundsTo onReceipt.cost.work 12 13040157 ∧ roundsTo onReceipt.cost.heat 12 13605009 ∧
    roundsTo onReceipt.cost.stored 12 (-564852) := by sorry

theorem prime157_exact_change :
    hugUnits (residualChange offReceipt) = (2831 : ℚ) / 4503599627370496 ∧
    hugUnits (residualChange onReceipt) = (41501 : ℚ) / 72057594037927936 := by sorry

theorem prime157_toward_zero (a : Arm) :
    let r := receipt a
    r.three157.residual < r.four157.residual ∧ r.four157.residual < 0 := by sorry

theorem prime157_displayed_values :
    roundsTo offReceipt.three157.residual 17 (-2290515626) ∧
    roundsTo offReceipt.four157.residual 17 (-2290452765) ∧
    roundsTo onReceipt.three157.residual 17 (-1466485869) ∧
    roundsTo onReceipt.four157.residual 17 (-1466428275) ∧
    roundsTo (residualChange offReceipt) 19 6286083 ∧
    roundsTo (residualChange onReceipt) 19 5759421 := by sorry

end HugPrimeMeter
