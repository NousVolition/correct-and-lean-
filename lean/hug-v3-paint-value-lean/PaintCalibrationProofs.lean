import PaintCalibrationDefinitions

namespace HugV3.Source.PaintCalibrationVerified
noncomputable section
open StreetWhole PaintCalibration
open scoped BigOperators

private theorem total_affine (f g : Scalar) (h : ℝ) :
    total (fun x => f x + h*g x) = total f + h*total g := by
  unfold total
  rw [Finset.sum_add_distrib, ← Finset.mul_sum]
  ring

private theorem gaussian_positive (z : ℝ) : 0 < gaussianImages z :=
  Finset.sum_pos (fun _ _ => Real.exp_pos _) Finset.univ_nonempty

private theorem thermal_positive (z : ℝ) (k : Fin 16) : 0 < thermal1D z k :=
  div_pos (gaussian_positive _) (Finset.sum_pos (fun _ _ => gaussian_positive _) Finset.univ_nonempty)

private theorem thermal_sum (z : ℝ) : (∑ k : Fin 16, thermal1D z k) = 1 := by
  unfold thermal1D
  rw [← Finset.sum_div, div_self]
  exact ne_of_gt (Finset.sum_pos (fun _ _ => gaussian_positive _) Finset.univ_nonempty)

private theorem grid_weight_positive (X : Particle → Vec) (p : Particle) (x : Grid) :
    0 < R X p x := Finset.prod_pos (fun _ _ => thermal_positive _ _)

private theorem grid_weight_sum (X : Particle → Vec) (p : Particle) :
    (∑ x : Grid, R X p x) = 1 := by
  unfold R
  rw [← Fintype.prod_sum]
  simp [thermal_sum]

private def backward (j : Axis) : Equiv.Perm Grid where
  toFun x := shifted x j 15
  invFun x := shifted x j 1
  left_inv x := by
    funext k
    by_cases hk : k = j
    · subst k
      apply Fin.ext
      have hx := (x j).isLt
      simp [shifted]
      omega
    · simp [shifted,hk]
  right_inv x := by
    funext k
    by_cases hk : k = j
    · subst k
      apply Fin.ext
      have hx := (x j).isLt
      simp [shifted]
      omega
    · simp [shifted,hk]

private theorem periodic_flux_sum (flux : Axis → Grid → ℝ) :
    (∑ x : Grid, -(∑ j : Axis, (flux j x-flux j (shifted x j 15))/dx)) = 0 := by
  have cancels (j : Axis) : (∑ x : Grid, (flux j x-flux j (shifted x j 15))/dx) = 0 := by
    have permutes : (∑ x, flux j (shifted x j 15)) = ∑ x, flux j x :=
      Equiv.sum_comp (backward j) (flux j)
    rw [← Finset.sum_div, Finset.sum_sub_distrib, permutes, sub_self, zero_div]
  rw [Finset.sum_neg_distrib, Finset.sum_comm]
  simp [cancels]

private theorem original_sensor_inverse (v : ℝ) :
    Real.log ((1+tanh v)/(1-tanh v)) = 2*v := by
  have hd : Real.exp v + Real.exp (-v) ≠ 0 :=
    ne_of_gt (add_pos (Real.exp_pos _) (Real.exp_pos _))
  have plus : 1 + tanh v = 2*Real.exp v / (Real.exp v + Real.exp (-v)) := by
    unfold tanh
    field_simp [hd]
    ring
  have minus : 1 - tanh v = 2*Real.exp (-v) / (Real.exp v + Real.exp (-v)) := by
    unfold tanh
    field_simp [hd]
    ring
  have ratio : (1+tanh v)/(1-tanh v) = Real.exp v / Real.exp (-v) := by
    rw [plus, minus]
    field_simp [hd, (Real.exp_pos (-v)).ne']
  rw [ratio, ← Real.exp_sub, Real.log_exp]
  ring

theorem declared_start (G : Geometry) :
    (∀ x, (initial G).g x 3 = 0) ∧ (initial G).A = 0 ∧ (initial G).context = home := by
  refine ⟨?_,rfl,rfl⟩
  intro x
  simp [initial, show (3 : Fin 5) ≠ 4 by decide]

theorem accepted_original_field_rate (G : Geometry) (s d : State) (t : ℝ)
    (ok : rhs G t s = some d) :
    ∃ rs, readRecords s = some rs ∧ d = rhsFromRecords G t s rs ∧
      d.A = 0.08 * (socialRates G t s rs).utility ∧
      ∀ x, d.g x 3 = contextTransport (fun y => s.g y 3) (velocity s) x
        + s.A * sourceKernel G t s rs x := by
  unfold rhs at ok
  obtain ⟨rs,hrs,h⟩ := Option.bind_eq_some_iff.mp ok
  split at h
  · have eqn : d = rhsFromRecords G t s rs := (Option.some.inj h).symm
    refine ⟨rs,hrs,eqn,?_,?_⟩ <;> rw [eqn]
    · rfl
    · intro x; rfl
  · cases h

theorem private_context_comparison (G : Geometry) (s : State) (i : Actor)
    (h t : ℝ) (rs : List (Fin 4 × Record)) :
    (shiftPersonalContext s i h).g = s.g ∧
    observations G (shiftPersonalContext s i h) = observations G s ∧
    readRecords (shiftPersonalContext s i h) = readRecords s ∧
    ∀ x, (rhsFromRecords G t (shiftPersonalContext s i h) rs).g x 3 =
      (rhsFromRecords G t s rs).g x 3 := by
  exact ⟨rfl,rfl,rfl,fun _ => rfl⟩

theorem footprint_compares_full_inputs (y : FullState) (B : Scalar) (L : Footprint) (h : ℝ) :
    (fullLineInput y (profile B L h)).state.context = y.state.context ∧
    (fullLineInput y (profile B L h)).starts = y.starts ∧
    {(fullLineInput y (profile B L h)).state with g := y.state.g} = y.state ∧
    (∀ x k, k ≠ 3 → (fullLineInput y (profile B L h)).state.g x k = y.state.g x k) ∧
    ∀ x, (fullLineInput y (profile B L h)).state.g x 3 = B x + h * indicator L x := by
  refine ⟨rfl,rfl,rfl,?_,fun _ => rfl⟩
  intro x k hk
  simp [fullLineInput,withLineSignal,hk]

theorem same_footprint_and_person_distinct_values (y : FullState) (B : Scalar)
    (L : Footprint) (x : Grid) (marked : L x = true) (h : ℝ) (pos : 0 < h) :
    (∀ z, (profile B L h z ≠ B z ↔ profile B L (2*h) z ≠ B z)) ∧
    (fullLineInput y (profile B L h)).state.context =
      (fullLineInput y (profile B L (2*h))).state.context ∧
    (fullLineInput y (profile B L h)).state.g x 3 ≠
      (fullLineInput y (profile B L (2*h))).state.g x 3 := by
  refine ⟨?_,rfl,?_⟩
  · intro z
    cases hz : L z <;> simp [profile,indicator,hz,pos.ne']
  · change profile B L h x ≠ profile B L (2*h) x
    simp [profile,indicator,marked]
    linarith

theorem unfixed_background_allows_any_contrast (B : Scalar) (L : Footprint) (h k : ℝ) :
    profile (fun x => B x + (h-k)*indicator L x) L k = profile B L h := by
  funext x
  unfold profile
  ring

theorem independent_field_total_recovers_contrast (B : Scalar) (L : Footprint)
    (h : ℝ) (nonemptyVolume : total (indicator L) ≠ 0) :
    (total (profile B L h) - total B) / total (indicator L) = h := by
  rw [show total (profile B L h) = total B + h*total (indicator L) from total_affine B (indicator L) h]
  apply (div_eq_iff nonemptyVolume).mpr
  ring

theorem marked_cell_has_positive_volume (L : Footprint) (x : Grid) (marked : L x = true) :
    0 < total (indicator L) := by
  have positiveAt : 0 < indicator L x := by simp [indicator,marked]
  have allNonnegative (z : Grid) : 0 ≤ indicator L z := by cases h : L z <;> simp [indicator,h]
  exact mul_pos (by norm_num [dv,dx])
    (Finset.sum_pos' (fun z _ => allNonnegative z) ⟨x,Finset.mem_univ x,positiveAt⟩)

theorem original_transport_redistributes_field (C : Scalar) (u : Vector) :
    total (contextTransport C u) = 0 := by
  unfold total contextTransport
  rw [periodic_flux_sum,mul_zero]

theorem spatial_total_rate_from_original_source (G : Geometry) (s d : State)
    (t : ℝ) (ok : rhs G t s = some d) :
    ∃ rs, readRecords s = some rs ∧
      total (fun x => d.g x 3) = s.A * total (sourceKernel G t s rs) := by
  obtain ⟨rs,hrs,_,_,fieldRate⟩ := accepted_original_field_rate G s d t ok
  refine ⟨rs,hrs,?_⟩
  simp_rw [fieldRate]
  rw [total_affine, original_transport_redistributes_field, zero_add]

theorem unit_kernel_rate (G : Geometry) (s d : State) (t : ℝ) (ok : rhs G t s = some d)
    (unit : ∀ rs, readRecords s = some rs → total (sourceKernel G t s rs) = 1) :
    total (fun x => d.g x 3) = s.A := by
  obtain ⟨rs,hrs,eqn⟩ := spatial_total_rate_from_original_source G s d t ok
  rw [eqn,unit rs hrs,mul_one]

theorem positive_attachments_normalize_original_kernel (G : Geometry) (s : State)
    (t : ℝ) (rs : List (Fin 4 × Record)) (pos : ∀ i p, 0 < G.attach i p) :
    total (sourceKernel G t s rs) = 1 := by
  let intensity := fun i : Actor => (∑ j, ∑ k, s.responses i j k)/6 + (∑ j, s.relation j i 0)/6
  let a := fun i => Real.exp (intensity i) / ∑ j, Real.exp (intensity j)
  let w := fun p : Particle => ∑ i, G.attach i p * a i
  have ha (i) : 0 < a i := div_pos (Real.exp_pos _)
    (Finset.sum_pos (fun _ _ => Real.exp_pos _) Finset.univ_nonempty)
  have hw (p) : 0 < w p := Finset.sum_pos (fun i _ => mul_pos (pos i p) (ha i)) Finset.univ_nonempty
  have weights : (∑ p, (socialRates G t s rs).sourceWeights p) = 1 := by
    change (∑ p, w p / ∑ q, w q) = 1
    rw [← Finset.sum_div, div_self (ne_of_gt (Finset.sum_pos (fun p _ => hw p) Finset.univ_nonempty))]
  unfold total sourceKernel
  rw [← Finset.sum_div, Finset.sum_comm]
  simp_rw [← Finset.sum_mul, grid_weight_sum, one_mul]
  rw [weights]
  have volume : dv ≠ 0 := by norm_num [dv,dx]
  field_simp

theorem positive_attachments_see_a_marked_cell (G : Geometry) (s : State)
    (i : Actor) (L : Footprint) (x : Grid) (marked : L x = true)
    (pos : ∀ p, 0 < G.attach i p) : 0 < PaintCalibration.sensitivity G s i L := by
  have nonneg (z : Grid) : 0 ≤ indicator L z := by cases hz : L z <;> simp [indicator,hz]
  have inner (p : Particle) : 0 < ∑ z, R s.X p z * indicator L z := by
    apply Finset.sum_pos'
    · intro z _
      exact mul_nonneg (grid_weight_positive _ _ _).le (nonneg z)
    · exact ⟨x,Finset.mem_univ x, mul_pos (grid_weight_positive _ _ _) (by simp [indicator,marked])⟩
  exact Finset.sum_pos (fun p _ => mul_pos (pos p) (inner p)) Finset.univ_nonempty

theorem original_readout_affine (G : Geometry) (s : State) (i : Actor)
    (B : Scalar) (L : Footprint) (h : ℝ) :
    lineRead G s i (profile B L h) = lineRead G s i B + h * PaintCalibration.sensitivity G s i L := by
  have inner (p : Particle) :
      (∑ x, R s.X p x * profile B L h x) =
      (∑ x, R s.X p x * B x) + h * ∑ x, R s.X p x * indicator L x := by
    rw [Finset.mul_sum, ← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro x _
    unfold profile
    ring
  unfold PaintCalibration.sensitivity lineRead
  simp_rw [inner]
  rw [Finset.mul_sum, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro p _
  ring

theorem bounded_channel_for_profile (G : Geometry) (s : State) (i : Actor)
    (B : Scalar) (L : Footprint) (h : ℝ) :
    sensor G s i (profile B L h) =
      tanh ((lineRead G s i B + h * PaintCalibration.sensitivity G s i L) / 0.08) := by
  change tanh (lineRead G s i (profile B L h) / 0.08) = _
  rw [original_readout_affine]

theorem zero_sensitivity_erases_contrast (G : Geometry) (s : State) (i : Actor)
    (B : Scalar) (L : Footprint) (h k : ℝ) (blind : PaintCalibration.sensitivity G s i L = 0) :
    sensor G s i (profile B L h) = sensor G s i (profile B L k) := by
  simp only [bounded_channel_for_profile,blind,mul_zero,add_zero]

theorem calibrated_sensor_recovers_signed_contrast (G : Geometry) (s : State) (i : Actor)
    (B : Scalar) (L : Footprint) (h o : ℝ) (sees : PaintCalibration.sensitivity G s i L ≠ 0)
    (reading : sensor G s i (profile B L h) = o) :
    (0.04 * Real.log ((1+o)/(1-o)) - lineRead G s i B) / PaintCalibration.sensitivity G s i L = h := by
  rw [bounded_channel_for_profile] at reading
  rw [← reading, original_sensor_inverse]
  apply (div_eq_iff sees).mpr
  ring

theorem one_exact_reading_identifies_height (G : Geometry) (s : State) (i : Actor)
    (B : Scalar) (L : Footprint) (h k : ℝ) (sees : PaintCalibration.sensitivity G s i L ≠ 0)
    (same : sensor G s i (profile B L h) = sensor G s i (profile B L k)) :
    h = k := by
  let o := sensor G s i (profile B L k)
  have first := calibrated_sensor_recovers_signed_contrast G s i B L h o sees same
  have second := calibrated_sensor_recovers_signed_contrast G s i B L k o sees rfl
  exact first.symm.trans second

theorem opposite_fields_have_same_original_force (s : State) (f : Scalar) :
    forcing (withLineSignal s (fun x => -f x)) = forcing (withLineSignal s f) := by
  have gradNeg (x : Grid) (j : Axis) :
      centeredGradient (withLineSignal s (fun y => -f y)) x j =
        -centeredGradient (withLineSignal s f) x j := by
    simp [centeredGradient,withLineSignal]
    ring
  have equalNorm (x : Grid) :
      sqnorm (centeredGradient (withLineSignal s (fun y => -f y)) x) =
      sqnorm (centeredGradient (withLineSignal s f) x) := by
    unfold sqnorm
    apply Finset.sum_congr rfl
    intro j _
    rw [gradNeg]
    ring
  funext x
  simp only [forcing,equalNorm]

end
end HugV3.Source.PaintCalibrationVerified
