import WizardDefinitions

open scoped BigOperators
noncomputable section

namespace Wizard

@[simp]
theorem fromFin_toFin (w : Wizard) : fromFin (toFin w) = w := by
  cases w <;> rfl

@[simp]
theorem toFin_fromFin (i : Fin 7) : toFin (fromFin i) = i := by
  rcases i with ⟨val, hval⟩
  interval_cases val <;> rfl

end Wizard

namespace CommutatorMatrix

variable (C : CommutatorMatrix)

theorem diag_zero (i : Fin 7) : C.κ i i = 0 := by
  have h := C.skew_symm i i
  linarith

theorem bracket_antisymm (w₁ w₂ : Wizard) (Φ : ℝ) :
    C.bracket w₁ w₂ Φ = - C.bracket w₂ w₁ Φ := by
  unfold bracket
  rw [C.skew_symm w₁.toFin w₂.toFin]
  ring

theorem sum_all_vanishes :
    (∑ i : Fin 7, ∑ j : Fin 7, C.κ i j) = 0 := by
  have h_swap : (∑ i : Fin 7, ∑ j : Fin 7, C.κ i j) =
                - (∑ i : Fin 7, ∑ j : Fin 7, C.κ i j) := by
    calc
      (∑ i : Fin 7, ∑ j : Fin 7, C.κ i j)
      _ = ∑ j : Fin 7, ∑ i : Fin 7, C.κ i j       := Finset.sum_comm
      _ = ∑ i : Fin 7, ∑ j : Fin 7, C.κ j i       := rfl
      _ = ∑ i : Fin 7, ∑ j : Fin 7, (- C.κ i j)   := by
            apply Finset.sum_congr rfl; intro i _
            apply Finset.sum_congr rfl; intro j _
            exact C.skew_symm j i
      _ = ∑ i : Fin 7, - (∑ j : Fin 7, C.κ i j)   := by
            apply Finset.sum_congr rfl; intro i _
            exact Finset.sum_neg_distrib _
      _ = - (∑ i : Fin 7, ∑ j : Fin 7, C.κ i j)   := Finset.sum_neg_distrib _
  linarith

theorem quadratic_form_zero (v : Fin 7 → ℝ) :
    (∑ i : Fin 7, ∑ j : Fin 7, v i * C.κ i j * v j) = 0 := by
  have h_self_neg :
      (∑ i : Fin 7, ∑ j : Fin 7, v i * C.κ i j * v j) =
      - (∑ i : Fin 7, ∑ j : Fin 7, v i * C.κ i j * v j) := by
    calc
      (∑ i : Fin 7, ∑ j : Fin 7, v i * C.κ i j * v j)
      _ = ∑ j : Fin 7, ∑ i : Fin 7, v i * C.κ i j * v j       := Finset.sum_comm
      _ = ∑ i : Fin 7, ∑ j : Fin 7, v j * C.κ j i * v i       := rfl
      _ = ∑ i : Fin 7, ∑ j : Fin 7, (- (v i * C.κ i j * v j)) := by
            apply Finset.sum_congr rfl; intro i _
            apply Finset.sum_congr rfl; intro j _
            rw [C.skew_symm j i]
            ring
      _ = ∑ i : Fin 7, - (∑ j : Fin 7, v i * C.κ i j * v j)   := by
            apply Finset.sum_congr rfl; intro i _
            exact Finset.sum_neg_distrib _
      _ = - (∑ i : Fin 7, ∑ j : Fin 7, v i * C.κ i j * v j)   := Finset.sum_neg_distrib _
  linarith

end CommutatorMatrix
end
