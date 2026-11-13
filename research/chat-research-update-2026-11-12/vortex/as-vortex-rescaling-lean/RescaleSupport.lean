import RescaleFields

noncomputable section
namespace SignedVortex.Rescaled
open Set Filter MeasureTheory intervalIntegral NavierStokes NavierStokes.ProblemStatement
open NavierStokesR3.ParabolicScaling NavierStokesR3.ViscosityScaling
open scoped Topology

theorem width_pos {ν l : ℝ} (hν : 0 < ν) (hl : 0 < l) : 0 < width ν l :=
  div_pos (Real.sqrt_pos.mpr hν) hl
theorem zoom_pos {ν l : ℝ} (hν : 0 < ν) (hl : 0 < l) : 0 < zoom ν l :=
  div_pos hl (Real.sqrt_pos.mpr hν)

theorem zoom_mul_width {ν l : ℝ} (hν : 0 < ν) (hl : 0 < l) : zoom ν l * width ν l = 1 := by
  unfold zoom width; field_simp [hl.ne', (Real.sqrt_pos.mpr hν).ne']

theorem half_lt_zoom {ν l : ℝ} (hν : 0 < ν) (hl : 0 < l) (hfit : width ν l < 2) :
    1/2 < zoom ν l := by
  nlinarith [mul_lt_mul_of_pos_left hfit (zoom_pos hν hl),zoom_mul_width hν hl]

theorem scale_space (ν l : ℝ) (x : Space) :
    (Real.sqrt ν)⁻¹ • (l • x) = zoom ν l • x := by
  rw [smul_smul]; simp [zoom,div_eq_mul_inv,mul_comm]

private theorem scaled_coord {ν l : ℝ} (hν : 0 < ν) (hl : 0 < l) {x : Space} {i : Fin 3}
    (hw : |(zoom ν l • x) i| ≤ 1/4) : |x i| ≤ width ν l/4 := by
  change |zoom ν l * x i| ≤ 1/4 at hw
  rw [abs_mul,abs_of_pos (zoom_pos hν hl)] at hw
  calc |x i| = width ν l * (zoom ν l * |x i|) := by rw [←mul_assoc,mul_comm (width ν l),zoom_mul_width hν hl,one_mul]
       _ ≤ width ν l * (1/4) := mul_le_mul_of_nonneg_left hw (width_pos hν hl).le
       _ = width ν l /4 := by ring

theorem before_support {ν l : ℝ} (hν : 0 < ν) (hl : 0 < l) (a : ℕ → ℕ) :
    PeriodicLocalization.SupportedInCube (width ν l/4) (PeriodicPaper.beforeOne (compact ν l a)) := by
  apply PeriodicPaper.beforeOne_supported
  intro t ht x hx i
  by_cases hs : 0 ≤ clock l t
  · have hn : whole a (clock l t,zoom ν l • x) ≠ 0 := by
      intro hz
      apply hx
      simp [compact,velocity,pull,zeroBefore,scaledVelocity,rescale,hs,scale_space,hz]
    have hc : zoom ν l • x ∈ SpatialLocalization.supportCylinder := by
      by_contra ho
      exact hn (R3CompactCandidate.velocity_supported _ _ _ _ ho)
    exact scaled_coord hν hl (SpatialLocalization.supportCylinder_coordinate_bound hc i)
  · exfalso
    exact hx (by simp [compact,velocity,pull,zeroBefore,hs])

/-- For this construction K includes its outer radius. Fitting the scaled K strictly
inside the centered unit cell is equivalent to the exact width condition below. -/
theorem support_fits_iff {ν l : ℝ} (hν : 0 < ν) (hl : 0 < l) :
    compactSet ν l ⊆ PeriodicPaper.fundamentalInterior ↔ width ν l < 2 := by
  constructor
  · intro H
    let x : Space := (1/4:ℝ) • coordinateVector 0
    have hx : x ∈ SpatialLocalization.supportCylinder := by
      have hn : (2 : Fin 3) ≠ 0 := by decide
      constructor <;> norm_num [x,SpatialLocalization.radialSquare,coordinateVector,hn]
    have hx' : l⁻¹ • (Real.sqrt ν • x) ∈ compactSet ν l :=
      ⟨_,⟨x,hx,rfl⟩,rfl⟩
    have hb := (H hx') (0:Fin 3)
    have he : (l⁻¹ • (Real.sqrt ν • x)) 0 = width ν l / 4 := by
      simp [x,coordinateVector,width,div_eq_mul_inv]; ring
    rw [he,abs_of_pos (div_pos (width_pos hν hl) (by norm_num))] at hb
    linarith
  · intro hf z hz i
    rcases hz with ⟨_,⟨x,hx,rfl⟩,rfl⟩
    have he : (l⁻¹ • (Real.sqrt ν • x)) i = width ν l * x i := by
      change l⁻¹ * (Real.sqrt ν * x i) = _
      unfold width; ring
    rw [he,abs_mul,abs_of_pos (width_pos hν hl)]
    calc width ν l * |x i| ≤ width ν l * (1/4) := mul_le_mul_of_nonneg_left
          (SpatialLocalization.supportCylinder_coordinate_bound hx i) (width_pos hν hl).le
         _ < 1/2 := by linarith

theorem zoom_line (ν l : ℝ) (hν : 0 < ν) (hl : 0 < l) (i j : Fin 3) (d y : ℝ) :
    zoom ν l • linePoint ν l i j d y = loopPoint i j d (zoom ν l * y) := by
  simp only [linePoint,loopPoint,smul_add,smul_smul]
  rw [← mul_assoc,zoom_mul_width hν hl,one_mul]
  rfl

theorem inner_line {ν l r d y : ℝ} {i j : Fin 3} (hij : i ≠ j)
    (hx : |width ν l * HLine.off d| < 1-r) (hy : |y| < 1-r) :
    linePoint ν l i j d y ∈ PeriodicLocalization.innerCube r := by
  intro k
  by_cases hi : k=i
  · subst k; simpa [linePoint,coordinateVector,hij] using hx
  · by_cases hj : k=j
    · subst k; simpa [linePoint,coordinateVector,Ne.symm hij] using hy
    · have h : (0:ℝ) < 1-r := (abs_nonneg y).trans_lt hy
      simpa [linePoint,coordinateVector,hi,hj] using h

theorem original_inner {d y : ℝ} {i j : Fin 3} (hij : i ≠ j)
    (hd : d ∈ Ioo (-(1/16):ℝ) (1/8)) (hy : y ∈ Icc (-(1/2):ℝ) (1/2)) :
    loopPoint i j d y ∈ PeriodicLocalization.innerCube (1/4) := by
  have hx : |1/4-d| < 1-(1/4:ℝ) := abs_lt.mpr ⟨by linarith [hd.2],by linarith [hd.1]⟩
  have hy' : |y| < 1-(1/4:ℝ) := abs_lt.mpr ⟨by linarith [hy.1],by linarith [hy.2]⟩
  have he : linePoint 1 1 i j d y = loopPoint i j d y := by simp [linePoint,width,loopPoint,HLine.off]
  rw [←he]
  apply inner_line hij _ hy'
  simpa [width,HLine.off] using hx

def originalSlice (a : ℕ → ℕ) (t : ℝ) (i j : Fin 3) (d y : ℝ) :=
  (navierStokesResidual (whole a) (fun _ => 0) t (loopPoint i j d y)) j

theorem slice_support (a : ℕ → ℕ) (t d : ℝ) {i j : Fin 3} (hij : i ≠ j) :
    Function.support (originalSlice a t i j d) ⊆ Icc (-(1/4):ℝ) (1/4) := by
  intro y hy
  by_contra bad
  have hy' : 1/4 < |y| := by
    by_contra hh; exact bad (abs_le.mp (le_of_not_gt hh))
  have hj : (loopPoint i j d y) j = y := by simp [loopPoint,coordinateVector,Ne.symm hij]
  have hnb : ∀ᶠ z : SpaceTime in 𝓝 (t,loopPoint i j d y), 1/4 < |z.2 j| := by
    apply (((AxisymmetricFields.projection j).continuous.comp continuous_snd).abs.continuousAt).eventually_const_lt
    change 1/4 < |(loopPoint i j d y) j|
    rwa [hj]
  have hzero : whole a =ᶠ[𝓝 (t,loopPoint i j d y)] (fun _ => 0) := by
    filter_upwards [hnb] with z hz
    apply R3CompactCandidate.velocity_supported
    intro h; exact (not_lt_of_ge (SpatialLocalization.supportCylinder_coordinate_bound h j)) hz
  have hr := ResidualRegularity.residual_eq_zero_of_eventually_zero
    (z := (t,loopPoint i j d y)) hzero (Filter.EventuallyEq.rfl (f := fun _ : SpaceTime => (0:ℝ)))
  exact hy (by simp only [originalSlice,hr]; rfl)

theorem compact_loop_is_old (a : ℕ → ℕ) (t : ℝ) {i j : Fin 3} (hij : i ≠ j) {d : ℝ}
    (hd : d ∈ Ioo (-(1/16):ℝ) (1/8)) :
    (∫ y in (-(1/2):ℝ)..1/2, originalSlice a t i j d y) =
      loopResidual (HLine.vortex a) t i j d := by
  apply intervalIntegral.integral_congr
  intro y hy
  rw [uIcc_of_le (by norm_num : (-(1/2):ℝ) ≤ 1/2)] at hy
  have hr := ResidualRegularity.residual_congr
    (R3CompactCandidate.velocity_locally_eq (LocalAngularGrowth.selectedPotential a)
      (LocalAngularGrowth.selectedDirect a) (t,loopPoint i j d y) (original_inner hij hd hy))
    (Filter.EventuallyEq.rfl (f := fun _ : SpaceTime => (0:ℝ)))
  exact (congrArg (fun v : Space => v j) hr).symm

end SignedVortex.Rescaled
