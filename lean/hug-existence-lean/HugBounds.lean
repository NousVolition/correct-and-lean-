import HugBox
namespace ActiveHug.Full
open Set Metric MeasureTheory intervalIntegral
open scoped NNReal
noncomputable section

def scalarize (G : ℝ → Vec → Vec) (x : ℝ → Vec) (j : Fin 8) (t y : ℝ) : ℝ :=
  G t (Function.update (x t) j y) j
theorem scalarized_solution {G : ℝ → Vec → Vec} {a b : ℝ} {x0 : Vec} {x : ℝ → Vec}
    (hab : a ≤ b) (hx : Volterra.Solution G a b x0 x) (j : Fin 8) :
    IntegralSolution (scalarize G x j) a b (x0 j) (fun t => x t j) := by
  apply coord_solution hab hx j
  intro t
  simp [scalarize]

theorem constant_solution (a b c : ℝ) :
    IntegralSolution (fun _ _ => 0) a b c (fun _ => c) := by
  refine ⟨continuousOn_const,rfl,intervalIntegrable_const,?_⟩
  intro t ht
  simp

theorem radius_derivative (a R0 M t : ℝ) :
    HasDerivAt (radius a R0 M) (growth M*radius a R0 M t) t := by
  have h := ((((hasDerivAt_id t).sub_const a).const_mul (growth M)).exp).const_mul R0
  apply h.congr_deriv
  dsimp [radius]
  ring

theorem radius_solution (a b R0 M : ℝ) :
    IntegralSolution (fun t _ => growth M*radius a R0 M t) a b (radius a R0 M a) (radius a R0 M) := by
  have hc : Continuous (radius a R0 M) := by unfold radius; fun_prop
  have hdc : Continuous (fun t => growth M*radius a R0 M t) := continuous_const.mul hc
  refine ⟨hc.continuousOn,rfl,hdc.intervalIntegrable a b,?_⟩
  intro t ht
  rw [intervalIntegral.integral_eq_sub_of_hasDerivAt (fun s _ => radius_derivative a R0 M s) (hdc.intervalIntegrable a t)]
  ring

theorem neg_radius_solution (a b R0 M : ℝ) :
    IntegralSolution (fun t _ => -(growth M*radius a R0 M t)) a b
      (-radius a R0 M a) (fun t => -radius a R0 M t) := by
  have h := radius_solution a b R0 M
  refine ⟨h.1.neg,rfl,?_,?_⟩
  · apply h.2.2.1.neg.congr
    intro t ht
    rfl
  · intro t ht
    change -radius a R0 M t = _
    rw [intervalIntegral.integral_neg, h.2.2.2 t ht]
    ring

theorem radius_ge_one (a R0 M t : ℝ) (h0 : 1 ≤ R0) (hM : 0 ≤ M) (ht : a ≤ t) :
    1 ≤ radius a R0 M t := by
  have hg : 0 ≤ growth M := by unfold growth; linarith
  have he : 1 ≤ Real.exp (growth M*(t-a)) := Real.one_le_exp (mul_nonneg hg (sub_nonneg.mpr ht))
  unfold radius
  nlinarith

theorem cut_guard_bounds {a b : ℝ} {F R : ℝ → ℝ} {x0 : Vec} {x : ℝ → Vec}
    (hab : a ≤ b) (hx : Volterra.Solution (cutField F R) a b x0 x) (h0 : Admissible x0) :
    ∀ t ∈ Icc a b, Admissible (x t) := by
  have one (j : Fin 8) (hj : j = 6 ∨ j = 7) (hi : Hug.UnitInterval (x0 j)) :
      ∀ t ∈ Icc a b, Hug.UnitInterval (x t j) := by
    have hs := scalarized_solution hab hx j
    have hlo : ∀ t ∈ Icc a b, 0 ≤ x t j := by
      apply Barrier.solution_nonnegative hab hs hi.1
      intro t ht y hy
      have hcl : Hug.clip y = 0 := by simp [Hug.clip, max_eq_left hy]
      rcases hj with rfl | rfl
      all_goals dsimp [scalarize, cutField, field, encode, rhs, decode, guardRate]
      all_goals change 0 ≤ (sigmoid _ - Hug.clip y)/(3/5:ℝ)
      all_goals rw [hcl, sub_zero]
      all_goals exact div_nonneg (Verified.sigmoid_bounds _).1.le (by norm_num)
    have hhi : ∀ t ∈ Icc a b, x t j ≤ 1 := by
      apply upper_barrier hab hs (constant_solution a b 1) hi.2
      intro t ht y hy
      have hcl : Hug.clip y = 1 := min_eq_left (hy.trans (le_max_right _ _))
      rcases hj with rfl | rfl
      all_goals dsimp [scalarize, cutField, field, encode, rhs, decode, guardRate]
      all_goals change (sigmoid _ - Hug.clip y)/(3/5:ℝ) ≤ 0
      all_goals rw [hcl]
      all_goals exact div_nonpos_of_nonpos_of_nonneg (sub_nonpos.mpr (Verified.sigmoid_bounds _).2.le) (by norm_num)
    exact fun t ht => ⟨hlo t ht,hhi t ht⟩
  exact fun t ht => ⟨one 6 (Or.inl rfl) h0.1 t ht,one 7 (Or.inr rfl) h0.2 t ht⟩

theorem cut_state_bounds {a b R0 M : ℝ} {F : ℝ → ℝ} {x0 : Vec} {x : ℝ → Vec}
    (hab : a ≤ b) (hR0 : 1 ≤ R0) (hM : 0 ≤ M)
    (hF : ∀ t ∈ Icc a b, |F t| ≤ M) (hinit : ∀ j, |x0 j| ≤ R0)
    (h0 : Admissible x0)
    (hx : Volterra.Solution (cutField F (radius a R0 M)) a b x0 x) :
    ∀ t ∈ Icc a b, (∀ j, |x t j| ≤ radius a R0 M t) ∧ Admissible (x t) := by
  have hg := cut_guard_bounds hab hx h0
  have hR (t : ℝ) (ht : t ∈ Icc a b) := radius_ge_one a R0 M t hR0 hM ht.1
  have hcoord (j : Fin 8) (hj : j.val < 6) :
      ∀ t ∈ Icc a b, -radius a R0 M t ≤ x t j ∧ x t j ≤ radius a R0 M t := by
    have hs := scalarized_solution hab hx j
    have hupper : ∀ t ∈ Icc a b, x t j ≤ radius a R0 M t := by
      apply upper_barrier hab hs (radius_solution a b R0 M)
      · simpa [radius] using (abs_le.mp (hinit j)).2
      · intro t ht y hy
        let z := project (radius a R0 M t) (Function.update (x t) j y)
        have hz := project_bounds _ (Function.update (x t) j y) (hR t ht)
        have he : z j = radius a R0 M t := by
          simp only [z, project, if_pos hj, Function.update_self, box]
          exact min_eq_left (hy.trans (le_max_right _ _))
        exact field_upper M _ (F t) z j hM (hR t ht) (hF t ht) hz.1 hz.2 hj he
    have hlower : ∀ t ∈ Icc a b, -radius a R0 M t ≤ x t j := by
      apply lower_barrier hab hs (neg_radius_solution a b R0 M)
      · simpa [radius] using (abs_le.mp (hinit j)).1
      · intro t ht y hy
        let z := project (radius a R0 M t) (Function.update (x t) j y)
        have hz := project_bounds _ (Function.update (x t) j y) (hR t ht)
        have he : z j = -radius a R0 M t := by
          simp only [z, project, if_pos hj, Function.update_self, box, max_eq_left hy]
          apply min_eq_right
          linarith [hR t ht]
        exact field_lower M _ (F t) z j hM (hR t ht) (hF t ht) hz.1 hz.2 hj he
    exact fun t ht => ⟨hlower t ht,hupper t ht⟩
  intro t ht
  refine ⟨?_,hg t ht⟩
  intro j
  by_cases hj : j.val < 6
  · exact abs_le.mpr (hcoord j hj t ht)
  · have hg' : Hug.UnitInterval (x t j) := by fin_cases j <;> simp_all [Admissible]
    rw [abs_of_nonneg hg'.1]
    exact hg'.2.trans (hR t ht)

end
end ActiveHug.Full
