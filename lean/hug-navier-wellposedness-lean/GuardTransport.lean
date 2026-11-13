import GuardTransportDefs

namespace HugNavierSingle.GuardTransport
noncomputable section
open Set MeasureTheory

/-- Both snapshots and the one test gradient are evaluated at the same point. -/
theorem transport_of_blend (a : ℝ) (left right : Fields) (g : ScalarField) (r : Point) :
    transportAt (sampleBlend a left right r) g r =
      (1 - a) * advection left g r + a * advection right g r := by
  unfold transportAt sampleBlend advection
  dsimp
  ring

/-- For a curve with velocity uRead, these are the material-rate expressions on
the two guard equations. Diffusion and each guard's own reaction are retained. -/
theorem directional_guard_rates (i : FieldInputs) (t : ℝ) (z : Fields)
    (p : ScalarField) (r uRead : Point) :
    (fieldRates i t z p).gAB r + transportAt uRead z.gAB r =
      (3/200) * laplacian z.gAB r + reactionAB z r + residual uRead z z.gAB r ∧
    (fieldRates i t z p).gBA r + transportAt uRead z.gBA r =
      (3/200) * laplacian z.gBA r + reactionBA z r + residual uRead z z.gBA r := by
  constructor <;>
    simp only [fieldRates, advection, transportAt, reactionAB, reactionBA, residual] <;> ring

/-- Split the two-history transport term used in the classical energy argument. -/
theorem advection_difference (z w : Fields) (f g : ScalarField) (r : Point) :
    advection z f r - advection w g r =
      z.ux r * (partialX f r - partialX g r) +
      z.uy r * (partialY f r - partialY g r) +
      residual (velocityAt z r) w g r := by
  unfold advection residual velocityAt
  dsimp
  ring

/-- Pointwise Young bound for the residual tested against a guard difference h.
A uniform gradient bound makes the right side a multiple of the difference energy. -/
theorem residual_energy_bound (uRead : Point) (z : Fields) (g : ScalarField)
    (r : Point) (h : ℝ) :
    |h * residual uRead z g r| ≤
      (((uRead.1 - z.ux r)^2 + (uRead.2 - z.uy r)^2) +
        h^2 * ((partialX g r)^2 + (partialY g r)^2)) / 2 := by
  let dx := uRead.1 - z.ux r
  let dy := uRead.2 - z.uy r
  let gx := partialX g r
  let gy := partialY g r
  change |h * (dx * gx + dy * gy)| ≤ ((dx^2 + dy^2) + h^2 * (gx^2 + gy^2)) / 2
  apply abs_le.mpr
  constructor
  · nlinarith only [sq_nonneg (dx + h * gx), sq_nonneg (dy + h * gy)]
  · nlinarith only [sq_nonneg (dx - h * gx), sq_nonneg (dy - h * gy)]

private lemma sliceX {f : ScalarField} (hf : ContDiff ℝ 1 f) (r : Point) :
    HasDerivAt (fun x => f (x,r.2)) (fderiv ℝ f r (1,0)) r.1 :=
  ((hf.differentiable one_ne_zero r).hasFDerivAt).comp_hasDerivAt r.1
    ((hasDerivAt_id r.1).prodMk (hasDerivAt_const r.1 r.2))

private lemma sliceY {f : ScalarField} (hf : ContDiff ℝ 1 f) (r : Point) :
    HasDerivAt (fun y => f (r.1,y)) (fderiv ℝ f r (0,1)) r.2 :=
  ((hf.differentiable one_ne_zero r).hasFDerivAt).comp_hasDerivAt r.2
    ((hasDerivAt_const r.2 r.1).prodMk (hasDerivAt_id r.2))

private lemma continuousX {f : ScalarField} (hf : ContDiff ℝ 1 f) : Continuous (partialX f) := by
  have eq : partialX f = fun r => fderiv ℝ f r (1,0) := funext fun r => (sliceX hf r).deriv
  rw [eq]
  exact (hf.continuous_fderiv_apply one_ne_zero).comp (continuous_id.prodMk continuous_const)

private lemma continuousY {f : ScalarField} (hf : ContDiff ℝ 1 f) : Continuous (partialY f) := by
  have eq : partialY f = fun r => fderiv ℝ f r (0,1) := funext fun r => (sliceY hf r).deriv
  rw [eq]
  exact (hf.continuous_fderiv_apply one_ne_zero).comp (continuous_id.prodMk continuous_const)

private lemma cellIntegrable {f : ScalarField} (hf : Continuous f) : Integrable f cellMeasure := by
  rw [cellMeasure, cellAxis, Measure.prod_restrict, ← Measure.volume_eq_prod]
  exact (hf.continuousOn.integrableOn_compact (isCompact_Icc.prod isCompact_Icc)).mono_set
    (Set.prod_mono Ioc_subset_Icc_self Ioc_subset_Icc_self)

/-- The residual for either guard, integrated over one full periodic cell. -/
theorem integrated_residual_bound (z w : Fields) (g h : ScalarField) (M : ℝ)
    (zX : Continuous z.ux) (zY : Continuous z.uy)
    (wX : Continuous w.ux) (wY : Continuous w.uy) (hg : ContDiff ℝ 1 g) (hh : Continuous h)
    (gradient : ∀ r, (partialX g r)^2 + (partialY g r)^2 ≤ M^2) :
    |∫ r, h r * residual (velocityAt z r) w g r ∂cellMeasure| ≤
      ((∫ r, (z.ux r-w.ux r)^2 + (z.uy r-w.uy r)^2 ∂cellMeasure) +
        M^2 * ∫ r, (h r)^2 ∂cellMeasure) / 2 := by
  let d : ScalarField := fun r => (z.ux r-w.ux r)^2 + (z.uy r-w.uy r)^2
  have hd : Continuous d := ((zX.sub wX).pow 2).add ((zY.sub wY).pow 2)
  have he : Continuous (fun r => residual (velocityAt z r) w g r) :=
    ((zX.sub wX).mul (continuousX hg)).add ((zY.sub wY).mul (continuousY hg))
  have hm : Continuous (fun r => M^2 * h r^2) := continuous_const.mul (hh.pow 2)
  calc
    _ ≤ ∫ r, |h r * residual (velocityAt z r) w g r| ∂cellMeasure := abs_integral_le_integral_abs
    _ ≤ ∫ r, (d r + M^2 * h r^2)/2 ∂cellMeasure := by
      apply integral_mono (cellIntegrable (hh.mul he).abs) (cellIntegrable ((hd.add hm).div_const 2))
      intro r
      apply (residual_energy_bound (velocityAt z r) w g r (h r)).trans
      dsimp [d, velocityAt]
      nlinarith only [mul_nonneg (sq_nonneg (h r)) (sub_nonneg.mpr (gradient r))]
    _ = _ := by rw [integral_div, integral_add (cellIntegrable hd) (cellIntegrable hm), integral_const_mul]

private lemma axisFlux {F D : ℝ → ℝ} (hd : ∀ x, HasDerivAt F (D x) x)
    (hc : Continuous D) (hp : F (2*Real.pi) = F 0) : ∫ x, D x ∂cellAxis = 0 := by
  have h := intervalIntegral.integral_eq_sub_of_hasDerivAt
    (a := 0) (b := 2*Real.pi) (fun x _ => hd x) (hc.intervalIntegrable _ _)
  rw [intervalIntegral.integral_of_le (by positivity), hp, sub_self] at h
  exact h

/-- Common transport contributes zero guard energy over the full periodic square. -/
theorem common_transport_cancels (z : Fields) (h : ScalarField)
    (hx : ContDiff ℝ 1 z.ux) (hy : ContDiff ℝ 1 z.uy) (hh : ContDiff ℝ 1 h)
    (px : Periodic z.ux) (py : Periodic z.uy) (ph : Periodic h) (div : Incompressible z) :
    (∫ r, h r * advection z h r ∂cellMeasure) = 0 := by
  let _ : SFinite cellAxis := by unfold cellAxis; infer_instance
  let fx : ScalarField := fun r => (partialX z.ux r * (h r)^2)/2 + z.ux r * h r * partialX h r
  let fy : ScalarField := fun r => (partialY z.uy r * (h r)^2)/2 + z.uy r * h r * partialY h r
  have cx : Continuous fx := (((continuousX hx).mul (hh.continuous.pow 2)).div_const 2).add
    ((hx.continuous.mul hh.continuous).mul (continuousX hh))
  have cy : Continuous fy := (((continuousY hy).mul (hh.continuous.pow 2)).div_const 2).add
    ((hy.continuous.mul hh.continuous).mul (continuousY hh))
  have sx (y : ℝ) : ∫ x, fx (x,y) ∂cellAxis = 0 := by
    apply axisFlux (F := fun x => z.ux (x,y) * (h (x,y))^2/2)
    · intro x
      have u := (sliceX hx (x,y)).differentiableAt.hasDerivAt
      have g := (sliceX hh (x,y)).differentiableAt.hasDerivAt
      have hu : HasDerivAt (fun a => z.ux (a,y)) (partialX z.ux (x,y)) x := u
      have hh' : HasDerivAt (fun a => h (a,y)) (partialX h (x,y)) x := g
      have deriv := (hu.mul (hh'.pow 2)).div_const 2
      rw [show fx (x,y) = (partialX z.ux (x,y) * (h (x,y))^2 +
        z.ux (x,y) * (2 * h (x,y) * partialX h (x,y)))/2 by dsimp [fx]; ring]
      simpa only [Pi.mul_apply, Pi.pow_apply, Nat.cast_ofNat, Nat.reduceSub, pow_one] using deriv
    · exact cx.comp (continuous_id.prodMk continuous_const)
    · have a := (px (0,y)).1
      have b := (ph (0,y)).1
      simp at a b
      rw [a,b]
  have sy (x : ℝ) : ∫ y, fy (x,y) ∂cellAxis = 0 := by
    apply axisFlux (F := fun y => z.uy (x,y) * (h (x,y))^2/2)
    · intro y
      have u := (sliceY hy (x,y)).differentiableAt.hasDerivAt
      have g := (sliceY hh (x,y)).differentiableAt.hasDerivAt
      have hu : HasDerivAt (fun b => z.uy (x,b)) (partialY z.uy (x,y)) y := u
      have hh' : HasDerivAt (fun b => h (x,b)) (partialY h (x,y)) y := g
      have deriv := (hu.mul (hh'.pow 2)).div_const 2
      rw [show fy (x,y) = (partialY z.uy (x,y) * (h (x,y))^2 +
        z.uy (x,y) * (2 * h (x,y) * partialY h (x,y)))/2 by dsimp [fy]; ring]
      simpa only [Pi.mul_apply, Pi.pow_apply, Nat.cast_ofNat, Nat.reduceSub, pow_one] using deriv
    · exact cy.comp (continuous_const.prodMk continuous_id)
    · have a := (py (x,0)).2
      have b := (ph (x,0)).2
      simp at a b
      rw [a,b]
  have sum : (fun r => h r * advection z h r) = fun r => fx r + fy r := by
    funext r
    dsimp [fx,fy,advection]
    nlinarith only [mul_eq_zero_of_left (div r) ((h r)^2)]
  rw [sum, integral_add (cellIntegrable cx) (cellIntegrable cy)]
  rw [show (∫ r, fx r ∂cellMeasure) = 0 by
        rw [cellMeasure, integral_prod_symm fx (cellIntegrable cx)]
        simp_rw [sx]; simp,
      show (∫ r, fy r ∂cellMeasure) = 0 by
        rw [cellMeasure, integral_prod fy (cellIntegrable cy)]
        simp_rw [sy]; simp]
  norm_num

end
end HugNavierSingle.GuardTransport
