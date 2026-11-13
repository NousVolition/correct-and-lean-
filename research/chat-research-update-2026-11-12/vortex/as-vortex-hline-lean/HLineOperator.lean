import HLineCalculus
import NavierStokes.AxisymmetricResidual

noncomputable section
namespace SignedVortex.HLine
open NavierStokes NavierStokes.ProblemStatement NavierStokes.AxisymmetricFields
open scoped ContDiff

def forgetHeight : ProfilePoint →L[ℝ] Plane :=
  (ContinuousLinearMap.fst ℝ ℝ (ℝ × ℝ)).prod
    ((ContinuousLinearMap.fst ℝ ℝ ℝ).comp (ContinuousLinearMap.snd ℝ ℝ (ℝ × ℝ)))

def liftProfile (F : HLine.Profile) (p : ProfilePoint) := F (forgetHeight p)
def spin (F : HLine.Profile) := AxisymmetricResidual.velocity 0 (liftProfile (-ds F)) 0

def ell (F : HLine.Profile) (p : Plane) :=
  -dt (ds F) p + 4 * ds (ds F) p + 2*p.2 * ds (ds (ds F)) p

theorem lift_smooth {F : HLine.Profile} (hf : ContDiff ℝ ∞ F) :
    ContDiff ℝ ∞ (liftProfile F) := hf.comp forgetHeight.contDiff

private theorem lift_jac {F : HLine.Profile} (hf : ContDiff ℝ ∞ F) (p : ProfilePoint) :
    fderiv ℝ (liftProfile F) p = (fderiv ℝ F (forgetHeight p)).comp forgetHeight :=
  ((hf.differentiable (by simp) _).hasFDerivAt.comp p forgetHeight.hasFDerivAt).fderiv

theorem lift_ds {F : HLine.Profile} (hf : ContDiff ℝ ∞ F) :
    partialS (liftProfile F) = liftProfile (ds F) := by
  funext p; unfold partialS; rw [lift_jac hf]; rfl
theorem lift_dt {F : HLine.Profile} (hf : ContDiff ℝ ∞ F) :
    AxisymmetricResidual.partialT (liftProfile F) = liftProfile (dt F) := by
  funext p; unfold AxisymmetricResidual.partialT; rw [lift_jac hf]; rfl
theorem lift_dz {F : HLine.Profile} (hf : ContDiff ℝ ∞ F) :
    partialZ (liftProfile F) = 0 := by
  funext p; unfold partialZ; rw [lift_jac hf]
  change fderiv ℝ F (forgetHeight p) 0 = 0
  exact map_zero _

private theorem ds_neg (F : HLine.Profile) : ds (-F) = -ds F := by
  funext p; unfold ds; rw [fderiv_neg]; rfl
private theorem dt_neg (F : HLine.Profile) : dt (-F) = -dt F := by
  funext p; unfold dt; rw [fderiv_neg]; rfl

private theorem zero_s : partialS (0 : AxisymmetricFields.Profile) = 0 := by
  funext p; simp [partialS]
private theorem zero_z : partialZ (0 : AxisymmetricFields.Profile) = 0 := by
  funext p; simp [partialZ]
private theorem zero_t : AxisymmetricResidual.partialT (0 : AxisymmetricFields.Profile) = 0 := by
  funext p; simp [AxisymmetricResidual.partialT]

theorem axial_curl_is_spin {F : HLine.Profile} (hf : ContDiff ℝ ∞ F) (w : SpaceTime) :
    SpatialCurl.spatialCurl (AxisymmetricFields.potential 0 (liftProfile F)) w = spin F w := by
  have h := AxisymmetricResidual.velocity_from_potential_at (fun _ => 0) (liftProfile F) w.1 w.2
    (differentiableAt_const _) ((lift_smooth hf).differentiable (by simp) _)
  change AxisymmetricFields.velocity (fun _ => 0) (liftProfile F) (w.1,w.2) = _
  rw [h]
  have hb : AxisymmetricResidual.fromPotentialB 0 = 0 := by funext p; simp [AxisymmetricResidual.fromPotentialB,zero_z]
  have hu : AxisymmetricResidual.fromPotentialU 0 = 0 := by funext p; simp [AxisymmetricResidual.fromPotentialU,zero_s]
  have hφ : AxisymmetricResidual.fromPotentialF (liftProfile F) = liftProfile (-ds F) := by
    funext p; rw [AxisymmetricResidual.fromPotentialF,lift_ds hf]; rfl
  rw [show (fun _ : ProfilePoint => (0:ℝ)) = 0 from rfl,hb,hu,hφ]
  rfl

/-- Cartesian pressure-free momentum residual, including all three native spatial
second derivatives and the full nonlinear advection. -/
theorem radial_residual {F : HLine.Profile} (hf : ContDiff ℝ ∞ F) (t : ℝ) (x : Space) :
    let p : Plane := (t,radialEnergy x)
    navierStokesResidual (spin F) (fun _ => 0) t x =
      AxisymmetricResidual.pack (-(x 0)*(ds F p)^2 - x 1 * ell F p)
        (-(x 1)*(ds F p)^2 + x 0 * ell F p) 0 := by
  have hd := ds_smooth hf
  let φ := liftProfile (-ds F)
  have hc : AxisymmetricResidual.SliceC2 φ t := fun _ => (lift_smooth hd.neg).contDiffAt.of_le (by simp)
  have h0 : AxisymmetricResidual.SliceC2 0 t := fun _ => contDiffAt_const
  have hz : AxisymmetricResidual.SliceDifferentiable 0 t := fun _ => differentiableAt_const _
  change navierStokesResidual (AxisymmetricResidual.velocity 0 φ 0) (AxisymmetricResidual.pressure 0) t x = _
  rw [AxisymmetricResidual.navierStokesResidual_velocity h0 hc h0 hz]
  have hS : partialS φ = liftProfile (-ds (ds F)) :=
    (lift_ds (F := -(ds F)) hd.neg).trans (congrArg liftProfile (ds_neg _))
  have hSS : partialS (liftProfile (-ds (ds F))) = liftProfile (-ds (ds (ds F))) :=
    (lift_ds (F := -(ds (ds F))) (ds_smooth hd).neg).trans (congrArg liftProfile (ds_neg _))
  have hT : AxisymmetricResidual.partialT φ = liftProfile (-dt (ds F)) :=
    (lift_dt (F := -(ds F)) hd.neg).trans (congrArg liftProfile (dt_neg _))
  have hZ : partialZ φ = 0 := lift_dz hd.neg
  congr 1 <;> simp only [AxisymmetricResidual.residualRadial,AxisymmetricResidual.residualAngular,
    AxisymmetricResidual.residualAxial,AxisymmetricResidual.advectionRadial,
    AxisymmetricResidual.advectionAngular,AxisymmetricResidual.advectionAxial,
    AxisymmetricResidual.laplaceWeighted,AxisymmetricResidual.laplaceScalar,
    zero_s,zero_t,zero_z,hSS,hS,hT,hZ,Pi.zero_apply,zero_mul,mul_zero,zero_add,add_zero,sub_zero,neg_zero,
    zero_pow (by decide : 2 ≠ 0),zero_sub] <;>
    simp [ell,φ,liftProfile,forgetHeight,profilePoint] <;> ring

theorem loop_coords (d y : ℝ) :
    (loopPoint 0 1 d y) 0 = off d ∧ (loopPoint 0 1 d y) 1 = y ∧ (loopPoint 0 1 d y) 2 = 0 ∧
    (loopPoint 1 0 d y) 0 = y ∧ (loopPoint 1 0 d y) 1 = off d ∧ (loopPoint 1 0 d y) 2 = 0 := by
  simp [loopPoint,off,coordinateVector]

def lineValue (F : HLine.Profile) (o t d y : ℝ) :=
  -y * (sample (ds F) t d y)^2 + o * off d * ell F (t,shellEnergy (off d) y)

theorem radial_components {F : HLine.Profile} (hf : ContDiff ℝ ∞ F) (t d y : ℝ) :
    (navierStokesResidual (spin F) (fun _ => 0) t (loopPoint 0 1 d y)) 1 = lineValue F 1 t d y ∧
    (navierStokesResidual (spin F) (fun _ => 0) t (loopPoint 1 0 d y)) 0 = lineValue F (-1) t d y := by
  rcases loop_coords d y with ⟨h1,h2,_,h3,h4,_⟩
  rw [radial_residual hf,radial_residual hf]
  simp [AxisymmetricResidual.pack,coordinateVector,radialEnergy,shellEnergy,lineValue,sample,h1,h2,h3,h4,add_comm (y^2) ((off d)^2)]
  ring

end SignedVortex.HLine
