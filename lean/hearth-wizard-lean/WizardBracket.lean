import SevenWizardAlgebra

open scoped BigOperators
noncomputable section
namespace CommutatorMatrix
variable (C : CommutatorMatrix)

theorem bracket_self (w : Wizard) (Φ : ℝ) : C.bracket w w Φ=0 := by
  simp [bracket,C.diag_zero]

theorem sum_all_brackets (Φ : ℝ) :
    (∑ i : Fin 7, ∑ j : Fin 7, C.bracket (Wizard.fromFin i) (Wizard.fromFin j) Φ)=0 := by
  simp only [bracket,Wizard.toFin_fromFin]
  simp_rw [← Finset.sum_mul]
  rw [C.sum_all_vanishes,zero_mul]

theorem form_basis_pair (Φ : ℝ) (a b : Fin 7) :
    C.form Φ (basis a) (basis b)=C.κ a b*Φ := by
  classical
  simp [form,basis,ite_mul,mul_ite]
  ring

theorem form_antisymm (Φ : ℝ) (v w : WizardVector) :
    C.form Φ v w= -C.form Φ w v := by
  have flip : (∑ i : Fin 7, ∑ j : Fin 7, v i*C.κ i j*w j) =
      -(∑ i : Fin 7, ∑ j : Fin 7, w i*C.κ i j*v j) := by
    calc
      _ = ∑ i : Fin 7, ∑ j : Fin 7, v j*C.κ j i*w i := Finset.sum_comm
      _ = ∑ i : Fin 7, ∑ j : Fin 7, -(w i*C.κ i j*v j) := by
        apply Finset.sum_congr rfl
        intro i _
        apply Finset.sum_congr rfl
        intro j _
        rw [C.skew_symm j i]
        ring
      _ = _ := by simp only [Finset.sum_neg_distrib]
  unfold form
  rw [flip,mul_neg]

theorem form_bilinear (Φ a b : ℝ) (u v w : WizardVector) :
    C.form Φ (a • u+b • v) w=a*C.form Φ u w+b*C.form Φ v w ∧
    C.form Φ w (a • u+b • v)=a*C.form Φ w u+b*C.form Φ w v := by
  have left (x y z : WizardVector) :
      C.form Φ (a • x+b • y) z=a*C.form Φ x z+b*C.form Φ y z := by
    have term (i j : Fin 7) : (a*x i+b*y i)*C.κ i j*z j =
        a*(x i*C.κ i j*z j)+b*(y i*C.κ i j*z j) := by ring
    simp only [form,Pi.add_apply,Pi.smul_apply,smul_eq_mul]
    simp_rw [term,Finset.sum_add_distrib,← Finset.mul_sum]
    ring
  refine ⟨left u v w,?_⟩
  rw [C.form_antisymm Φ w (a • u+b • v),left,C.form_antisymm Φ u w,C.form_antisymm Φ v w]
  ring

theorem form_alternating (Φ : ℝ) (v : WizardVector) : C.form Φ v v=0 := by
  simp [form,C.quadratic_form_zero]

theorem centrality_criterion (Φ : ℝ) (nonzero : Φ≠0) :
    (∀ w, C.bracket Wizard.hearth w Φ=0) ↔ C.CentralHearth := by
  constructor
  · intro h j
    have product : C.κ Wizard.hearth.toFin j * Φ=0 := by
      simpa [bracket] using h (Wizard.fromFin j)
    exact (mul_eq_zero.mp product).resolve_right nonzero
  · intro h w
    simp only [bracket,h w.toFin,zero_mul]

theorem central_lift_satisfies_jacobi (Φ : ℝ) (central : C.CentralHearth) (u v w : WizardVector) :
    C.jacobiSum Φ u v w=0 := by
  have centralCol (i : Fin 7) : C.κ i Wizard.hearth.toFin=0 := by
    rw [C.skew_symm i Wizard.hearth.toFin,central i,neg_zero]
  have zeroForm (x y z : WizardVector) : C.form Φ x (C.hearthLift Φ y z)=0 := by
    have term (i j : Fin 7) : x i*C.κ i j*C.hearthLift Φ y z j=0 := by
      by_cases hj : j=Wizard.hearth.toFin
      · subst j; simp [centralCol]
      · simp [hearthLift,hj]
    simp only [form,term,Finset.sum_const_zero,mul_zero]
  have zeroLift (x y z : WizardVector) : C.hearthLift Φ x (C.hearthLift Φ y z)=0 := by
    funext i
    change (if i=Wizard.hearth.toFin then C.form Φ x (C.hearthLift Φ y z) else 0)=0
    rw [zeroForm]; simp
  simp [jacobiSum,zeroLift]

theorem arbitrary_skew_lift_can_fail_jacobi :
    twoPairs.jacobiSum 1 (basis 1) (basis 2) (basis 3) 0 = -1 := by
  have lift (a b : Fin 7) :
      twoPairs.hearthLift 1 (basis a) (basis b) =
        fun k => if k=(0:Fin 7) then twoPairs.κ a b else 0 := by
    funext k
    simp only [hearthLift,Wizard.toFin,form_basis_pair,mul_one]
    rfl
  have h23 : twoPairs.hearthLift 1 (basis 2) (basis 3)=basis 0 := by
    rw [lift]
    have val : twoPairs.κ 2 3=1 := by
      change entries 2 3-entries 3 2=1
      rw [show entries 2 3=1 from if_pos (by decide),show entries 3 2=0 from if_neg (by decide)]
      norm_num
    rw [val]; rfl
  have vanish (a b : Fin 7) (h : twoPairs.κ a b=0) : twoPairs.hearthLift 1 (basis a) (basis b)=0 := by
    rw [lift,h]; funext k; simp
  have zeroPair (a b : Fin 7)
      (ab : ¬((a=0 ∧ b=1) ∨ (a=2 ∧ b=3))) (ba : ¬((b=0 ∧ a=1) ∨ (b=2 ∧ a=3))) :
      twoPairs.κ a b=0 := by
    change entries a b-entries b a=0
    rw [show entries a b=0 from if_neg ab,show entries b a=0 from if_neg ba,sub_self]
  have h31 := vanish 3 1 (zeroPair 3 1 (by decide) (by decide))
  have h12 := vanish 1 2 (zeroPair 1 2 (by decide) (by decide))
  have zeroR (a : Fin 7) : twoPairs.hearthLift 1 (basis a) 0=0 := by
    funext k; simp [hearthLift,form]
  unfold jacobiSum
  rw [h23,h31,h12,zeroR,zeroR,lift]
  have val10 : twoPairs.κ 1 0 = -1 := by
    change entries 1 0-entries 0 1 = -1
    rw [show entries 1 0=0 from if_neg (by decide),show entries 0 1=1 from if_pos (by decide)]
    norm_num
  simp [val10]

theorem finite_kinetic_energy_rate (Φ : ℝ) (v : ℝ → WizardVector) (t : ℝ)
    (law : ∀ i, HasDerivAt (fun τ => v τ i) (Φ * ∑ j, C.κ i j*v t j) t) :
    HasDerivAt (fun τ => (1/2:ℝ)*∑ i, (v τ i)^2) 0 t := by
  have zeroSum : (∑ i : Fin 7, (2:ℝ)*v t i*(Φ*∑ j, C.κ i j*v t j))=0 := by
    have row (i : Fin 7) : 2*v t i*(Φ*∑ j, C.κ i j*v t j) =
        (2*Φ)*(∑ j, v t i*C.κ i j*v t j) := by
      simp only [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro j _
      ring
    simp_rw [row,← Finset.mul_sum]
    rw [C.quadratic_form_zero,mul_zero]
  have hs := HasDerivAt.sum (u:=Finset.univ) (fun i _ => (law i).pow 2)
  have functions : (∑ i : Fin 7, (fun τ => v τ i)^2)=(fun τ => ∑ i, (v τ i)^2) := by
    funext τ
    simp [Finset.sum_apply,Pi.pow_apply]
  rw [functions] at hs
  have hn : HasDerivAt (fun τ => ∑ i, (v τ i)^2) 0 t := by
    simpa [zeroSum] using hs
  simpa using hn.const_mul (1/2:ℝ)

end CommutatorMatrix
end
