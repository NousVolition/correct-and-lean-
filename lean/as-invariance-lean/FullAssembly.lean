import Stages

open Set MeasureTheory
namespace SocialAS.Existence
noncomputable section

theorem sol_integrable_to {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E] [CompleteSpace E]
    {F : ℝ → E → E} {a b : ℝ} {initial : E} {x : ℝ → E}
    (hab : a ≤ b) (hx : Volterra.Solution F a b initial x) {t : ℝ} (ht : t ∈ Icc a b) :
    IntervalIntegrable (fun s => F s (x s)) volume a t := by
  apply hx.2.2.1.mono_set
  rw [uIcc_of_le hab]
  exact uIcc_subset_Icc ⟨le_rfl,hab⟩ ht

theorem extract_scalar {p : Parameters} {i : ℝ → Inputs} {a b : ℝ}
    {initial : State} {x : ℝ → State} (hab : a ≤ b)
    (hx : IntegralSolution p i a b initial x) (j : Fin 7) (F : ℝ → ℝ → ℝ)
    (hmatch : ∀ t ∈ Icc a b, F t (x t j) = evolution p (i t) (x t) j) :
    Volterra.Solution F a b (initial j) (fun t => x t j) := by
  have hc := hx.1
  refine ⟨by fun_prop, congrArg (fun v : State => v j) hx.2.1, ?_, ?_⟩
  · apply (hx.2.2.1 j b ⟨hab,le_rfl⟩).congr
    intro t ht
    exact (hmatch t ((uIoc_subset_uIcc.trans (by rw [uIcc_of_le hab])) ht)).symm
  · intro t ht
    change x t j = initial j + ∫ s in a..t, F s (x s j)
    rw [hx.2.2.2 j t ht]
    congr 1
    apply intervalIntegral.integral_congr
    intro s hs
    exact (hmatch s (uIcc_subset_Icc ⟨le_rfl,hab⟩ ht hs)).symm

theorem pair_map_eq (x : State) (j0 j1 : Fin 7) :
    (fun j : Fin 2 => x (![j0,j1] j)) = ![x j0,x j1] := by
  funext j
  fin_cases j <;> rfl

theorem extract_pair {p : Parameters} {i : ℝ → Inputs} {a b : ℝ}
    {initial : State} {x : ℝ → State} (hab : a ≤ b)
    (hx : IntegralSolution p i a b initial x) (j0 j1 : Fin 7) (F : ℝ → Pair → Pair)
    (hmatch : ∀ t ∈ Icc a b, ∀ j : Fin 2,
      F t (![x t j0,x t j1]) j = evolution p (i t) (x t) (![j0,j1] j)) :
    Volterra.Solution F a b ![initial j0,initial j1] (fun t => ![x t j0,x t j1]) := by
  have hc := hx.1
  apply solution_of_coordinates hab (by fun_prop)
  · simp only [hx.2.1]
  · intro j
    apply (hx.2.2.1 (![j0,j1] j) b ⟨hab,le_rfl⟩).congr
    intro t ht
    exact (hmatch t ((uIoc_subset_uIcc.trans (by rw [uIcc_of_le hab])) ht) j).symm
  · intro t ht j
    have h := hx.2.2.2 (![j0,j1] j) t ht
    have he1 : x t (![j0,j1] j) = ![x t j0,x t j1] j := by fin_cases j <;> rfl
    have he2 : initial (![j0,j1] j) = ![initial j0,initial j1] j := by fin_cases j <;> rfl
    rw [he1,he2] at h
    rw [h]
    congr 1
    apply intervalIntegral.integral_congr
    intro s hs
    exact (hmatch s (uIcc_subset_Icc ⟨le_rfl,hab⟩ ht hs) j).symm

def assemble {p : Parameters} {i : ℝ → Inputs} {a b : ℝ} {initial : State}
    (st : Stages p i a b initial) (t : ℝ) : State :=
  ![st.A t,st.S t 0,st.S t 1,st.LF t,st.LR t,st.Z t 0,st.Z t 1]

attribute [local simp] assemble evolution aField loadF loadR sField zField
  chi theta rateF rateR source smokeDrift clayDrift chiForward chiReverse
  thetaForward thetaReverse smokeMeaningDrift clayMeaningDrift

theorem assemble_solution {p : Parameters} {i : ℝ → Inputs} {a b : ℝ} {initial : State}
    (hab : a ≤ b) (st : Stages p i a b initial) :
    IntegralSolution p i a b initial (assemble st) := by
  have hAc := st.hA.1.1
  have hFc := st.hLF.1.1
  have hRc := st.hLR.1.1
  have hSc := st.hS.1.1
  have hZc := st.hZ.1.1
  refine ⟨by unfold assemble; fun_prop, ?_, ?_, ?_⟩
  · funext j
    fin_cases j <;> simp [st.hA.1.2.1,st.hLF.1.2.1,st.hLR.1.2.1,st.hS.1.2.1,st.hZ.1.2.1]
  · intro j t ht
    fin_cases j
    · simpa using sol_integrable_to hab st.hA.1 ht
    · simpa using (intervalIntegrable_fin_iff.mp (sol_integrable_to hab st.hS.1 ht) 0)
    · simpa using (intervalIntegrable_fin_iff.mp (sol_integrable_to hab st.hS.1 ht) 1)
    · simpa using sol_integrable_to hab st.hLF.1 ht
    · simpa using sol_integrable_to hab st.hLR.1 ht
    · simpa using (intervalIntegrable_fin_iff.mp (sol_integrable_to hab st.hZ.1 ht) 0)
    · simpa using (intervalIntegrable_fin_iff.mp (sol_integrable_to hab st.hZ.1 ht) 1)
  · intro j t ht
    fin_cases j
    · simpa using st.hA.1.2.2.2 t ht
    · simpa using coord_equation hab st.hS.1 t ht 0
    · simpa using coord_equation hab st.hS.1 t ht 1
    · simpa using st.hLF.1.2.2.2 t ht
    · simpa using st.hLR.1.2.2.2 t ht
    · simpa using coord_equation hab st.hZ.1 t ht 0
    · simpa using coord_equation hab st.hZ.1 t ht 1

theorem assemble_unique {p : Parameters} {i : ℝ → Inputs} {a b : ℝ} {initial : State}
    (hab : a ≤ b) (st : Stages p i a b initial) (other : ℝ → State)
    (ho : IntegralSolution p i a b initial other) :
    EqOn (assemble st) other (Icc a b) := by
  have ha : EqOn (fun t => other t 0) st.A (Icc a b) :=
    st.hA.2 _ (extract_scalar hab ho 0 (aField p i) (by intros; simp))
  have hf : EqOn (fun t => other t 3) st.LF (Icc a b) :=
    st.hLF.2 _ (extract_scalar hab ho 3 (loadF p i) (by intros; simp))
  have hr : EqOn (fun t => other t 4) st.LR (Icc a b) :=
    st.hLR.2 _ (extract_scalar hab ho 4 (loadR p i) (by intros; simp))
  have hs : EqOn (fun t => ![other t 1,other t 2]) st.S (Icc a b) := by
    apply st.hS.2
    apply extract_pair hab ho 1 2
    intro t ht j
    have ha' := ha ht
    have hf' := hf ht
    have hr' := hr ht
    fin_cases j <;> simp [ha',hf',hr']
  have hz : EqOn (fun t => ![other t 5,other t 6]) st.Z (Icc a b) := by
    apply st.hZ.2
    apply extract_pair hab ho 5 6
    intro t ht j
    have hf' := hf ht
    have hr' := hr ht
    have hs0 : other t 1 = st.S t 0 := congrArg (fun q : Pair => q 0) (hs ht)
    have hs1 : other t 2 = st.S t 1 := congrArg (fun q : Pair => q 1) (hs ht)
    fin_cases j <;> simp [hf',hr',hs0,hs1]
  intro t ht
  have ha' := ha ht
  have hf' := hf ht
  have hr' := hr ht
  have hs0 : other t 1 = st.S t 0 := congrArg (fun q : Pair => q 0) (hs ht)
  have hs1 : other t 2 = st.S t 1 := congrArg (fun q : Pair => q 1) (hs ht)
  have hz0 : other t 5 = st.Z t 0 := congrArg (fun q : Pair => q 0) (hz ht)
  have hz1 : other t 6 = st.Z t 1 := congrArg (fun q : Pair => q 1) (hz ht)
  funext j
  fin_cases j <;> simp [ha',hf',hr',hs0,hs1,hz0,hz1]

end
end SocialAS.Existence
