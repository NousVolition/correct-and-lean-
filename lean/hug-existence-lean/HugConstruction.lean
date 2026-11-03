import HugBounds
namespace ActiveHug.Full
open Set Metric MeasureTheory intervalIntegral
open scoped NNReal Topology
noncomputable section

theorem cut_exists_unique {a b B : ℝ} (hab : a ≤ b) (F R : ℝ → ℝ) (initial : Vec)
    (hF : ContinuousOn F (Icc a b)) (hR : ContinuousOn R (Icc a b))
    (hbound : ∀ t ∈ Icc a b, 1 ≤ R t ∧ R t ≤ B) :
    ∃ x, Volterra.Solution (cutField F R) a b initial x ∧
      ∀ y, Volterra.Solution (cutField F R) a b initial y → EqOn y x (Icc a b) := by
  obtain ⟨K,hK⟩ := field_lipschitz_ball B
  have hB : 0 ≤ B := by linarith [(hbound a ⟨le_rfl,hab⟩).1,(hbound a ⟨le_rfl,hab⟩).2]
  have hproj (t : ℝ) (ht : t ∈ Icc a b) (x : Vec) : project (R t) x ∈ closedBall (0:Vec) B := by
    rw [mem_closedBall_zero_iff]
    apply (pi_norm_le_iff_of_nonneg hB).mpr
    intro j
    exact ((project_bounds _ x (hbound t ht).1).1 j).trans (hbound t ht).2
  apply Volterra.exists_unique_solution hab _ initial K
  · intro x hx
    exact (continuous_path hF (project_path_continuous hR hx)).intervalIntegrable_of_Icc hab
  · intro t ht
    apply LipschitzWith.of_dist_le_mul
    intro x y
    have h := (hK F t).dist_le_mul _ (hproj t ht x) _ (hproj t ht y)
    have hh : dist (project (R t) x) (project (R t) y) ≤ dist x y := by
      simpa using (project_lipschitz (R t)).dist_le_mul x y
    exact h.trans (mul_le_mul_of_nonneg_left hh K.2)

theorem solution_congr_field {F G : ℝ → Vec → Vec} {a b : ℝ} {initial : Vec} {x : ℝ → Vec}
    (hab : a ≤ b) (hx : Volterra.Solution F a b initial x)
    (he : ∀ t ∈ Icc a b, F t (x t) = G t (x t)) : Volterra.Solution G a b initial x := by
  refine ⟨hx.1,hx.2.1,?_,?_⟩
  · apply hx.2.2.1.congr
    intro t ht
    exact he t ((uIoc_subset_uIcc.trans (by rw [uIcc_of_le hab])) ht)
  · intro t ht
    rw [hx.2.2.2 t ht]
    congr 1
    apply intervalIntegral.integral_congr
    intro s hs
    exact he s (uIcc_subset_Icc ⟨le_rfl,hab⟩ ht hs)

theorem original_guards {a b : ℝ} {F : ℝ → ℝ} {initial : Vec} {x : ℝ → Vec}
    (hab : a ≤ b) (hx : Volterra.Solution (field F) a b initial x) (hi : Admissible initial) :
    ∀ t ∈ Icc a b, Admissible (x t) := by
  have hsA := coord_solution hab hx 6
    (fun t y => guardRate protocol.tau (targetAB protocol (decode (x t))) y) (by intro t; rfl)
  have hsB := coord_solution hab hx 7
    (fun t y => guardRate protocol.tau (targetBA protocol (decode (x t))) y) (by intro t; rfl)
  have hA := Verified.guard_interval_invariant hab (by norm_num [protocol] : 0 < protocol.tau) hi.1 hsA
  have hB := Verified.guard_interval_invariant hab (by norm_num [protocol] : 0 < protocol.tau) hi.2 hsB
  exact fun t ht => ⟨hA t ht,hB t ht⟩

theorem coordinate_norm_bound (x : Vec) (j : Fin 8) : |x j| ≤ ‖x‖ := by
  simpa [Real.norm_eq_abs] using norm_le_pi_norm x j

theorem full_exists {a b : ℝ} (hab : a ≤ b) (F : ℝ → ℝ) (initial : Vec)
    (hF : ContinuousOn F (Icc a b)) (hi : Admissible initial) :
    ∃ x, Volterra.Solution (field F) a b initial x ∧ ∀ t ∈ Icc a b, Admissible (x t) := by
  obtain ⟨C,hC⟩ := isCompact_Icc.exists_bound_of_continuousOn hF
  let M := max C 0
  let R0 := 1+‖initial‖
  let R := radius a R0 M
  have hM : 0 ≤ M := le_max_right _ _
  have hR0 : 1 ≤ R0 := by dsimp [R0]; linarith [norm_nonneg initial]
  have hforce : ∀ t ∈ Icc a b, |F t| ≤ M := fun t ht => (hC t ht).trans (le_max_left _ _)
  have hinit : ∀ j, |initial j| ≤ R0 := by
    intro j
    exact (coordinate_norm_bound initial j).trans (by dsimp [R0]; linarith)
  have hR : Continuous R := by change Continuous (radius a R0 M); unfold radius; fun_prop
  obtain ⟨B,hB⟩ := isCompact_Icc.exists_bound_of_continuousOn hR.continuousOn
  have hbound : ∀ t ∈ Icc a b, 1 ≤ R t ∧ R t ≤ B := by
    intro t ht
    refine ⟨radius_ge_one a R0 M t hR0 hM ht.1,?_⟩
    exact (le_abs_self _).trans (hB t ht)
  obtain ⟨x,hx,_⟩ := cut_exists_unique hab F R initial hF hR.continuousOn hbound
  have hb := cut_state_bounds hab hR0 hM hforce hinit hi hx
  refine ⟨x,solution_congr_field hab hx ?_, fun t ht => (hb t ht).2⟩
  intro t ht
  unfold cutField
  rw [project_identity (hb t ht).1 (hb t ht).2]

theorem full_unique {a b : ℝ} {F : ℝ → ℝ} {initial : Vec} {x y : ℝ → Vec}
    (hab : a ≤ b) (hF : ContinuousOn F (Icc a b)) (hi : Admissible initial)
    (hx : Volterra.Solution (field F) a b initial x)
    (hy : Volterra.Solution (field F) a b initial y) : EqOn y x (Icc a b) := by
  obtain ⟨Cx,hCx⟩ := isCompact_Icc.exists_bound_of_continuousOn hx.1
  obtain ⟨Cy,hCy⟩ := isCompact_Icc.exists_bound_of_continuousOn hy.1
  let B := 1+|Cx|+|Cy|
  have hB : 1 ≤ B := by dsimp [B]; linarith [abs_nonneg Cx,abs_nonneg Cy]
  have bx : ∀ t ∈ Icc a b, ∀ j, |x t j| ≤ B := by
    intro t ht j
    apply (coordinate_norm_bound (x t) j).trans ((hCx t ht).trans ?_)
    dsimp [B]
    linarith [le_abs_self Cx,abs_nonneg Cy]
  have by' : ∀ t ∈ Icc a b, ∀ j, |y t j| ≤ B := by
    intro t ht j
    apply (coordinate_norm_bound (y t) j).trans ((hCy t ht).trans ?_)
    dsimp [B]
    linarith [le_abs_self Cy,abs_nonneg Cx]
  have gx := original_guards hab hx hi
  have gy := original_guards hab hy hi
  have hxc : Volterra.Solution (cutField F (fun _ => B)) a b initial x := by
    apply solution_congr_field hab hx
    intro t ht
    simp only [cutField,project_identity (bx t ht) (gx t ht)]
  have hyc : Volterra.Solution (cutField F (fun _ => B)) a b initial y := by
    apply solution_congr_field hab hy
    intro t ht
    simp only [cutField,project_identity (by' t ht) (gy t ht)]
  obtain ⟨z,hz,hu⟩ := cut_exists_unique hab F (fun _ => B) initial hF continuousOn_const (fun _ _ => ⟨hB,le_rfl⟩)
  exact fun t ht => (hu y hyc ht).trans (hu x hxc ht).symm

theorem full_derivative {a b : ℝ} {F : ℝ → ℝ} {initial : Vec} {x : ℝ → Vec}
    (hab : a ≤ b) (hF : ContinuousOn F (Icc a b))
    (hx : Volterra.Solution (field F) a b initial x) :
    ∀ t ∈ Ioo a b, HasDerivAt x (field F t (x t)) t := by
  intro t ht
  have hc := continuous_path hF hx.1
  have hn := Icc_mem_nhds ht.1 ht.2
  have hint := hx.2.2.1.mono_set (show uIcc a t ⊆ uIcc a b by
    rw [uIcc_of_le hab]; exact uIcc_subset_Icc ⟨le_rfl,hab⟩ (Ioo_subset_Icc_self ht))
  have hm := (hc.mono Ioo_subset_Icc_self).stronglyMeasurableAtFilter (μ := volume) isOpen_Ioo t ht
  have hd := (intervalIntegral.integral_hasDerivAt_right hint hm (hc.continuousAt hn)).const_add initial
  apply hd.congr_of_eventuallyEq
  filter_upwards [hn] with s hs
  exact hx.2.2.2 s hs

end
end ActiveHug.Full
