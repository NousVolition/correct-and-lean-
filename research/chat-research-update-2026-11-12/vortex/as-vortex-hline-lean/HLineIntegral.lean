import HLineOperator

noncomputable section
namespace SignedVortex.HLine
open Set Filter MeasureTheory intervalIntegral NavierStokes
open scoped ContDiff Topology

def avg (f : ℝ → ℝ) := ∫ y in (-(1/2):ℝ)..1/2, f y
def moment (F : Profile) (t d : ℝ) := avg (sample F t d)
def coeff (F : Profile) (t d : ℝ) :=
  -off d * moment (dt (ds F)) t d + 3*off d*moment (ds (ds F)) t d +
    (off d)^3 * moment (ds (ds (ds F))) t d

private theorem diff_avg (F G : ℝ → ℝ → ℝ) (z : ℝ)
    (hF : Continuous F.uncurry) (hG : Continuous G.uncurry)
    (hD : ∀ u y, HasDerivAt (fun v => F v y) (G u y) u) :
    HasDerivAt (fun u => avg (F u)) (avg (G z)) z := by
  obtain ⟨B,hB⟩ := (isCompact_Icc.prod isCompact_Icc :
    IsCompact (Icc (z-1) (z+1) ×ˢ Icc (-(1/2):ℝ) (1/2))).exists_bound_of_continuousOn hG.continuousOn
  apply (intervalIntegral.hasDerivAt_integral_of_dominated_loc_of_deriv_le
    (F := F) (F' := G) (bound := fun _ => B) (s := Ioo (z-1) (z+1))
    (Ioo_mem_nhds (by linarith) (by linarith)) _ _ _ _ intervalIntegrable_const _).2
  · exact Eventually.of_forall fun u => (hF.comp (continuous_const.prodMk continuous_id)).aestronglyMeasurable
  · exact (hF.comp (continuous_const.prodMk continuous_id)).intervalIntegrable _ _
  · exact (hG.comp (continuous_const.prodMk continuous_id)).aestronglyMeasurable
  · apply Eventually.of_forall
    intro y hy u hu
    rw [uIoc_of_le (show (-(1/2):ℝ) ≤ 1/2 by norm_num)] at hy
    exact hB (u,y) ⟨⟨hu.1.le,hu.2.le⟩,hy.1.le,hy.2⟩
  · exact Eventually.of_forall fun y _ u _ => hD u y

private theorem off_hasDerivAt (d : ℝ) : HasDerivAt off (-1) d := by
  change HasDerivAt (fun v : ℝ => 1/4-v) (-1) d
  exact (hasDerivAt_id' d).const_sub (1/4:ℝ)

theorem moment_d {F : Profile} (hf : ContDiff ℝ ∞ F) (t d : ℝ) :
    HasDerivAt (moment F t) (-off d * moment (ds F) t d) d := by
  have h := diff_avg (sample F t) (fun u y => -off u * sample (ds F) t u y) d
    (sample_smooth hf t).continuous
    (show Continuous (fun p : Plane => -off p.1 * sample (ds F) t p.1 p.2) from
      (show Continuous (fun p : Plane => -off p.1) by unfold off; fun_prop).mul (sample_smooth (ds_smooth hf) t).continuous)
    (sample_d hf t)
  unfold avg at h; rw [intervalIntegral.integral_const_mul] at h; exact h

theorem moment_t {F : Profile} (hf : ContDiff ℝ ∞ F) (t d : ℝ) :
    HasDerivAt (fun u => moment F u d) (moment (dt F) t d) t := by
  apply diff_avg (fun u y => sample F u d y) (fun u y => sample (dt F) u d y)
  · exact hf.continuous.comp (show Continuous (fun p : Plane => (p.1,shellEnergy (off d) p.2)) by
      unfold shellEnergy; fun_prop)
  · exact (dt_smooth hf).continuous.comp (show Continuous (fun p : Plane => (p.1,shellEnergy (off d) p.2)) by
      unfold shellEnergy; fun_prop)
  · exact fun u y => sample_t hf u d y

theorem moment_dd {F : Profile} (hf : ContDiff ℝ ∞ F) (t d : ℝ) :
    deriv (deriv (moment F t)) d = moment (ds F) t d + (off d)^2 * moment (ds (ds F)) t d := by
  rw [show deriv (moment F t) = fun u => -off u * moment (ds F) t u from funext fun u => (moment_d hf t u).deriv]
  have h := ((off_hasDerivAt d).neg.mul (moment_d (ds_smooth hf) t d)).deriv
  change deriv (fun z => -off z * moment (ds F) t z) d = _ at h
  rw [h]; simp only [Pi.neg_apply]; ring

private theorem sample_native (C h t d y : ℝ) (hd : d < 1/8) :
    sample (radial C h) t d y = shellWeight (off d) y * shellPrimitive C h t (off d) y := by
  have hx : 1/8 < off d := by unfold off; linarith
  have hs : 1/256 ≤ shellEnergy (off d) y := by
    unfold shellEnergy; nlinarith [sq_nonneg y,sq_nonneg (off d-1/8)]
  unfold sample; rw [radial_eq _ _ hs]
  simp only [shellWeight,shellPrimitive]; congr 2; unfold shellEnergy; ring

theorem moment_native (C h t d : ℝ) (hd : d < 1/8) :
    moment (radial C h) t d = shellTrace C h t (off d) := by
  unfold moment avg shellTrace
  simp_rw [sample_native C h t d _ hd]

private theorem native_time (C h t d : ℝ) (hh : 0 < h) (hd : d < 1/8) :
    shellTime C h t (off d) = moment (dt (radial C h)) t d := by
  have eq := funext (fun u : ℝ => moment_native C h u d hd)
  have h1 := (moment_t (radial_smooth C h hh) t d).deriv
  rw [eq] at h1
  rw [←h1, (shell_time_is_derivative C h t (off d) hh (by unfold off; linarith)).deriv]

theorem defect_deriv (C h t : ℝ) (hh : 0 < h) {d : ℝ} (hd : d < 1/8) :
    deriv (fun z => shellTime C h t (1/4-z) -
      deriv (deriv (fun v => shellTrace C h t (1/4-v))) z) d = coeff (radial C h) t d := by
  let F := radial C h
  have hf := radial_smooth C h hh
  have hnb : ∀ᶠ z in 𝓝 d, z < 1/8 := gt_mem_nhds hd
  have hval (z : ℝ) (hz : z < 1/8) : deriv (deriv (fun v => shellTrace C h t (1/4-v))) z =
      moment (ds F) t z + (off z)^2 * moment (ds (ds F)) t z := by
    have hloc : (fun v => shellTrace C h t (1/4-v)) =ᶠ[𝓝 z] moment F t :=
      (gt_mem_nhds hz).mono fun v hv => (moment_native C h t v hv).symm
    exact hloc.deriv.deriv_eq.trans (moment_dd hf t z)
  have eq : (fun z => shellTime C h t (1/4-z) - deriv (deriv (fun v => shellTrace C h t (1/4-v))) z) =ᶠ[𝓝 d]
      (fun z => moment (dt F) t z - (moment (ds F) t z + (off z)^2*moment (ds (ds F)) t z)) := by
    filter_upwards [hnb] with z hz
    exact congrArg₂ (fun m n : ℝ => m-n) (native_time C h t z hh hz) (hval z hz)
  rw [eq.deriv_eq]
  have hdif := ((moment_d (dt_smooth hf) t d).sub
    ((moment_d (ds_smooth hf) t d).add (((off_hasDerivAt d).pow 2).mul
      (moment_d (ds_smooth (ds_smooth hf)) t d)))).deriv
  change deriv (fun z => moment (dt F) t z - (moment (ds F) t z + (off z)^2*moment (ds (ds F)) t z)) d = _ at hdif
  rw [hdif]
  have hcomm : ds (dt F) = dt (ds F) := funext (commute hf)
  rw [hcomm]; unfold coeff; dsimp only [F,Pi.pow_apply]; ring

private theorem avg_add {f g : ℝ → ℝ} (hf : Continuous f) (hg : Continuous g) :
    avg (fun y => f y+g y) = avg f + avg g :=
  intervalIntegral.integral_add (hf.intervalIntegrable _ _) (hg.intervalIntegrable _ _)

private theorem avg_mul (c : ℝ) (f : ℝ → ℝ) : avg (fun y => c*f y) = c*avg f :=
  intervalIntegral.integral_const_mul _ _

private theorem ds2_zero_far (C h t s : ℝ) (hs : 1/32 < s) :
    ds (ds (radial C h)) (t,s) = 0 := by
  have hnb : ∀ᶠ p : Plane in 𝓝 (t,s), 1/32 < p.2 :=
    (show ContinuousAt (fun p : Plane => p.2) (t,s) from continuous_snd.continuousAt).eventually_const_lt hs
  have hE : radial C h =ᶠ[𝓝 (t,s)] (0 : Profile) := hnb.mono fun p hp => radial_zero _ _ hp.le
  have h1 : ds (radial C h) =ᶠ[𝓝 (t,s)] (0 : Profile) := by
    filter_upwards [hE.eventuallyEq_nhds] with p hp
    simpa [ds] using congrArg (fun l : Plane →L[ℝ] ℝ => l (0,1)) hp.fderiv_eq
  simpa [ds] using congrArg (fun l : Plane →L[ℝ] ℝ => l (0,1)) h1.fderiv_eq

theorem integrated_line (C h t d o : ℝ) (hh : 0 < h) :
    avg (lineValue (radial C h) o t d) = o * coeff (radial C h) t d := by
  let F := radial C h
  let X := off d
  let B := sample (ds F) t d
  let T := sample (dt (ds F)) t d
  let D := sample (ds (ds F)) t d
  let E := sample (ds (ds (ds F))) t d
  have hf : ContDiff ℝ ∞ F := radial_smooth C h hh
  have sc (A : Profile) (hA : ContDiff ℝ ∞ A) : Continuous (sample A t d) :=
    (sample_smooth hA t).continuous.comp (continuous_const.prodMk continuous_id)
  have hB := sc _ (ds_smooth hf); have hT := sc _ (dt_smooth (ds_smooth hf))
  have hD := sc _ (ds_smooth (ds_smooth hf)); have hE := sc _ (ds_smooth (ds_smooth (ds_smooth hf)))
  have odd : avg (fun y => -y*(B y)^2) = 0 := by
    have sym (y : ℝ) : B (-y) = B y := by simp [B,sample,shellEnergy]
    let n := fun y : ℝ => -y * (B y)^2
    have hi := intervalIntegral.integral_comp_neg (f := n)
      (a := (-(1/2):ℝ)) (b := 1/2)
    have turn : (fun y => n (-y)) = fun y => -n y := by
      funext y; dsimp [n]; rw [sym]; ring
    rw [turn,intervalIntegral.integral_neg,neg_neg] at hi
    change (∫ y in (-(1/2):ℝ)..1/2, n y) = 0; linarith
  have boundary : avg (fun y => D y + y^2 * E y) = 0 := by
    have der (y : ℝ) : HasDerivAt (fun y => y * D y) (D y + y^2 * E y) y := by
      have he := ((hasDerivAt_id' y).mul (sample_y (ds_smooth (ds_smooth hf)) t d y))
      change HasDerivAt (fun v => v*D v) (1*D y+y*(y*E y)) y at he
      convert he using 1; ring
    have hcont : Continuous (fun y => D y + y^2 * E y) := hD.add ((continuous_id.pow 2).mul hE)
    have hz (y : ℝ) (hy : y^2 = 1/4) : D y = 0 := by
      apply ds2_zero_far; unfold shellEnergy; rw [hy]; nlinarith [sq_nonneg (off d)]
    unfold avg
    rw [intervalIntegral.integral_eq_sub_of_hasDerivAt (fun y _ => der y) (hcont.intervalIntegrable _ _),
      hz (1/2) (by norm_num),hz (-(1/2)) (by norm_num)]; ring
  let L := fun y => (-X)*T y + (3*X)*D y + X^3*E y
  have hL : Continuous L := ((continuous_const.mul hT).add (continuous_const.mul hD)).add (continuous_const.mul hE)
  have hN : Continuous (fun y => -y*(B y)^2) := continuous_id.neg.mul (hB.pow 2)
  have hG : Continuous (fun y => D y + y^2*E y) := hD.add ((continuous_id.pow 2).mul hE)
  have split : lineValue F o t d = fun y => -y*(B y)^2 + (o*L y + (o*X)*(D y+y^2*E y)) := by
    funext y
    simp only [lineValue,ell,sample,L,B,T,D,E,shellEnergy,X]; ring
  have valL : avg L = coeff F t d := by
    unfold L; rw [avg_add (f := fun y => -X*T y+3*X*D y) (g := fun y => X^3*E y)
      ((continuous_const.mul hT).add (continuous_const.mul hD)) (continuous_const.mul hE),
      avg_add (f := fun y => -X*T y) (g := fun y => 3*X*D y)
        (continuous_const.mul hT) (continuous_const.mul hD),avg_mul,avg_mul,avg_mul]
    rfl
  change avg (lineValue F o t d) = _
  rw [split,avg_add (f := fun y => -y*(B y)^2) (g := fun y => o*L y + (o*X)*(D y+y^2*E y))
    hN ((continuous_const.mul hL).add (continuous_const.mul hG)),
    avg_add (f := fun y => o*L y) (g := fun y => (o*X)*(D y+y^2*E y))
      (continuous_const.mul hL) (continuous_const.mul hG),avg_mul,avg_mul,odd,boundary,valL]
  ring

end SignedVortex.HLine
