import TargetSolution
import Mathlib.Analysis.SpecialFunctions.SmoothTransition

noncomputable section
namespace SignedVortex.HLine
open Set Filter MeasureTheory intervalIntegral NavierStokes NavierStokes.ProblemStatement
open scoped ContDiff Topology

abbrev Plane := ℝ × ℝ
abbrev Profile := Plane → ℝ
def ds (F : Profile) (p : Plane) := fderiv ℝ F p (0,1)
def dt (F : Profile) (p : Plane) := fderiv ℝ F p (1,0)

/-- A smooth extension used to apply the axisymmetric calculus library. In the
tested collar its extra factor is identically one on an open neighborhood. -/
def radial (C h : ℝ) (p : Plane) :=
  Real.smoothTransition (512*p.2-1) * SmoothCutoffs.cutoff (32*p.2) *
    TailGaugePotential.heatPrimitive C h (p.1,p.2,(0:ℝ))

theorem radial_smooth (C h : ℝ) (hh : 0 < h) : ContDiff ℝ ∞ (radial C h) := by
  apply contDiff_iff_contDiffAt.mpr
  intro p
  by_cases hp : 0 < p.2
  · have h1 : ContDiffAt ℝ ∞ (fun q : Plane => Real.smoothTransition (512*q.2-1)) p :=
      Real.smoothTransition.contDiff.contDiffAt.comp p (by fun_prop)
    have h2 : ContDiffAt ℝ ∞ (fun q : Plane => SmoothCutoffs.cutoff (32*q.2)) p :=
      SmoothCutoffs.cutoff_contDiff.contDiffAt.comp p (by fun_prop)
    have h3 : ContDiffAt ℝ ∞ (fun q : Plane => TailGaugePotential.heatPrimitive C h (q.1,q.2,(0:ℝ))) p :=
      (TailGaugePotential.heatPrimitive_smoothAt C hh hp).comp p (by fun_prop)
    exact (h1.mul h2).mul h3
  · have hnb : ∀ᶠ q : Plane in 𝓝 p, q.2 < 1/512 :=
      continuous_snd.continuousAt.eventually_lt_const (by linarith)
    apply (contDiffAt_const (c := (0:ℝ))).congr_of_eventuallyEq
    filter_upwards [hnb] with q hq
    simp [radial, Real.smoothTransition.zero_of_nonpos (by linarith : 512*q.2-1 ≤ 0)]

theorem radial_eq (C h : ℝ) {t s : ℝ} (hs : 1/256 ≤ s) :
    radial C h (t,s) = SmoothCutoffs.cutoff (32*s) * TailGaugePotential.heatPrimitive C h (t,s,0) := by
  simp [radial, Real.smoothTransition.one_of_one_le (by linarith : 1 ≤ 512*s-1)]

theorem radial_zero (C h : ℝ) {t s : ℝ} (hs : 1/32 ≤ s) : radial C h (t,s) = 0 := by
  simp [radial,SmoothCutoffs.cutoff_zero_of_one_le (by linarith : 1 ≤ 32*s)]

theorem ds_smooth {F : Profile} (hF : ContDiff ℝ ∞ F) : ContDiff ℝ ∞ (ds F) :=
  (hF.fderiv_right (show ∞+1 ≤ ∞ by simp)).clm_apply contDiff_const
theorem dt_smooth {F : Profile} (hF : ContDiff ℝ ∞ F) : ContDiff ℝ ∞ (dt F) :=
  (hF.fderiv_right (show ∞+1 ≤ ∞ by simp)).clm_apply contDiff_const

theorem commute {F : Profile} (hF : ContDiff ℝ ∞ F) (p : Plane) :
    ds (dt F) p = dt (ds F) p := by
  have hD := (hF.fderiv_right (show ∞+1 ≤ ∞ by simp)).differentiable (by simp) p
  unfold ds dt
  rw [fderiv_clm_apply hD (differentiableAt_const _), fderiv_clm_apply hD (differentiableAt_const _)]
  simp only [fderiv_const_apply,zero_apply,ContinuousLinearMap.comp_apply,
    add_apply,ContinuousLinearMap.flip_apply,map_zero,zero_add]
  exact (hF.contDiffAt.isSymmSndFDerivAt (by simp)).eq _ _

def off (d : ℝ) := 1/4-d
def sample (F : Profile) (t d y : ℝ) := F (t,shellEnergy (off d) y)

theorem energy_d (d y : ℝ) : HasDerivAt (fun z => shellEnergy (off z) y) (-off d) d := by
  unfold off shellEnergy
  have hd := ((((hasDerivAt_const d (1/4:ℝ)).sub (hasDerivAt_id' d)).pow 2).add_const (y^2)).div_const (2:ℝ)
  change HasDerivAt (fun z : ℝ => ((1/4-z)^2 + y^2)/2) _ d at hd
  convert hd using 1
  simp [Pi.sub_apply]
  ring

theorem energy_y (x y : ℝ) : HasDerivAt (shellEnergy x) y y := by
  unfold shellEnergy
  have hd := (((hasDerivAt_id' y).pow 2).const_add (x^2)).div_const (2:ℝ)
  change HasDerivAt (fun z : ℝ => (x^2+z^2)/2) _ y at hd
  convert hd using 1
  simp

theorem sample_d {F : Profile} (hf : ContDiff ℝ ∞ F) (t d y : ℝ) :
    HasDerivAt (fun z => sample F t z y) (-off d * sample (ds F) t d y) d := by
  have hd := (hf.differentiable (by simp) (t,shellEnergy (off d) y)).hasFDerivAt.comp_hasDerivAt d
    ((hasDerivAt_const d t).prodMk (energy_d d y))
  have hp : ((0,-off d) : Plane) = (-off d) • (0,1) := by ext <;> simp
  rw [hp,map_smul] at hd
  exact hd

theorem sample_y {F : Profile} (hf : ContDiff ℝ ∞ F) (t d y : ℝ) :
    HasDerivAt (fun z => sample F t d z) (y * sample (ds F) t d y) y := by
  have hd := (hf.differentiable (by simp) (t,shellEnergy (off d) y)).hasFDerivAt.comp_hasDerivAt y
    ((hasDerivAt_const y t).prodMk (energy_y (off d) y))
  have hp : ((0,y) : Plane) = y • (0,1) := by ext <;> simp
  rw [hp,map_smul] at hd
  exact hd

theorem sample_t {F : Profile} (hf : ContDiff ℝ ∞ F) (t d y : ℝ) :
    HasDerivAt (fun z => sample F z d y) (sample (dt F) t d y) t :=
  (hf.differentiable (by simp) _).hasFDerivAt.comp_hasDerivAt t
    ((hasDerivAt_id' t).prodMk (hasDerivAt_const t (shellEnergy (off d) y)))

theorem sample_smooth {F : Profile} (hf : ContDiff ℝ ∞ F) (t : ℝ) :
    ContDiff ℝ ∞ (fun p : Plane => sample F t p.1 p.2) :=
  hf.comp (show ContDiff ℝ ∞ (fun p : Plane => (t,shellEnergy (off p.1) p.2)) by
    unfold shellEnergy off; fun_prop)

end SignedVortex.HLine
