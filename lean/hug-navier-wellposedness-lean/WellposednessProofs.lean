import EnergyEstimate
import WellposednessTargets
import GuardTransport
import GuardTransportTime

namespace HugNavierWellposedness.Verified
noncomputable section
open HugNavierSingle Set

theorem perturbation_regular (n : ℕ) :
    ContDiff ℝ ⊤ (perturbation n) ∧ Periodic (perturbation n) ∧
      Incompressible (nearby n) := by
  refine ⟨?_,?_,?_⟩
  · unfold perturbation
    fun_prop
  · intro r
    constructor
    · dsimp [perturbation]
      rw [mul_add,Real.cos_add_nat_mul_two_pi]
    · rfl
  · exact HugNavierSingle.Verified.source_initial_incompressible

theorem nearby_uniform_bound (n : ℕ) :
    UniformlyClose (nearby n) sourceInitial (1/(n:ℝ)^2) := by
  have hn : 0 ≤ (1:ℝ)/(n:ℝ)^2 := by positivity
  have hp (r : Point) : |perturbation n r| ≤ (1:ℝ)/(n:ℝ)^2 := by
    rw [perturbation,abs_mul,abs_of_nonneg hn]
    exact mul_le_of_le_one_right hn (Real.abs_cos_le_one _)
  intro r
  simpa only [nearby,sub_self,abs_zero,add_sub_cancel_left] using
    (show 0 ≤ (1:ℝ)/(n:ℝ)^2 ∧ 0 ≤ (1:ℝ)/(n:ℝ)^2 ∧
      |perturbation n r| ≤ (1:ℝ)/(n:ℝ)^2 ∧ 0 ≤ (1:ℝ)/(n:ℝ)^2 ∧
      0 ≤ (1:ℝ)/(n:ℝ)^2 ∧ 0 ≤ (1:ℝ)/(n:ℝ)^2 from
      ⟨hn,hn,hp r,hn,hn,hn⟩)

lemma dx_nearby (n : ℕ) (r : Point) :
    partialX (nearby n).xA r = -(3/20:ℝ)*Real.sin r.1-
      (1/(n:ℝ)^2)*(n:ℝ)*Real.sin ((n:ℝ)*r.1) := by
  have hb := (((hasDerivAt_id r.1).cos.const_mul (3/20)).const_add (-11/20)).add_const
    ((1/10)*Real.sin r.2)
  have hp := ((hasDerivAt_const_mul (x := r.1) (n:ℝ)).cos.const_mul (1/(n:ℝ)^2))
  have h := hb.add hp
  simp only [Pi.add_def,id_eq] at h
  change deriv (fun x => -11/20+(3/20)*Real.cos x+(1/10)*Real.sin r.2+
    (1/(n:ℝ)^2)*Real.cos ((n:ℝ)*x)) r.1 = _
  rw [h.deriv]
  ring

lemma dy_nearby (n : ℕ) (r : Point) :
    partialY (nearby n).xA r = (1/10:ℝ)*Real.cos r.2 := by
  have h := (((hasDerivAt_id r.2).sin.const_mul (1/10)).const_add
    (-11/20+(3/20)*Real.cos r.1)).add_const
    ((1/(n:ℝ)^2)*Real.cos ((n:ℝ)*r.1))
  simp only [id_eq] at h
  change deriv (fun y => -11/20+(3/20)*Real.cos r.1+(1/10)*Real.sin y+
    (1/(n:ℝ)^2)*Real.cos ((n:ℝ)*r.1)) r.2 = _
  rw [h.deriv]
  ring

lemma laplacian_nearby (n : ℕ) (r : Point) :
    laplacian (nearby n).xA r = -(3/20:ℝ)*Real.cos r.1-(1/10)*Real.sin r.2-
      (1/(n:ℝ)^2)*(n:ℝ)^2*Real.cos ((n:ℝ)*r.1) := by
  have hx := (((hasDerivAt_id r.1).sin.const_mul (-(3/20:ℝ))).sub
    ((hasDerivAt_const_mul (n:ℝ)).sin.const_mul ((1/(n:ℝ)^2)*(n:ℝ))))
  have hy := (hasDerivAt_id r.2).cos.const_mul (1/10)
  simp only [Pi.sub_def,id_eq] at hx hy
  unfold laplacian partialX partialY
  change deriv (fun x => partialX (nearby n).xA (x,r.2)) r.1+
    deriv (fun y => partialY (nearby n).xA (r.1,y)) r.2 = _
  simp_rw [dx_nearby,dy_nearby]
  rw [hx.deriv,hy.deriv]
  ring

lemma nearby_zero : nearby 0 = sourceInitial := by
  simp [nearby,perturbation]

theorem exact_rate_difference (n : ℕ) (hn : 0 < n) :
    rateDifference n = -(1/50:ℝ)-(3/2)*(1/(n:ℝ)^2) := by
  have hn0 : (n:ℝ) ≠ 0 := by exact_mod_cast hn.ne'
  unfold rateDifference
  rw [←nearby_zero]
  simp only [fieldRates, advection,dx_nearby,dy_nearby,laplacian_nearby]
  simp [baseInput,sourceInputs,nearby,sourceInitial,perturbation]
  field_simp <;> ring

theorem no_uniform_local_rate_bound : ¬ UniformLocalRateBound := by
  rintro ⟨radius,C,hr,hC,hbound⟩
  obtain ⟨n,hn⟩ := exists_nat_gt (max (1:ℝ) (1/radius+50*C+1))
  have hn1 : 1 < (n:ℝ) := lt_of_le_of_lt (le_max_left _ _) hn
  have hnr : 1/radius+50*C+1 < (n:ℝ) := lt_of_le_of_lt (le_max_right _ _) hn
  have hn0 : 0 < (n:ℝ) := by linarith
  have hnNat : 0 < n := by exact_mod_cast hn0
  have hs : 0 < (n:ℝ)^2 := sq_pos_of_pos hn0
  have hri : 0 < (1:ℝ)/radius := one_div_pos.mpr hr
  have hnr2 : 1/radius < (n:ℝ)^2 := by nlinarith
  have hnC : 50*C < (n:ℝ)^2 := by nlinarith
  have hsmall : (1:ℝ)/(n:ℝ)^2 < radius := by
    apply (div_lt_iff₀ hs).mpr
    have h := (div_lt_iff₀ hr).mp hnr2
    nlinarith
  have hb := hbound n hnNat hsmall
  rw [exact_rate_difference n hnNat] at hb
  have hd : 0 ≤ (1:ℝ)/(n:ℝ)^2 := by positivity
  rw [abs_of_neg (by linarith : -(1/50:ℝ)-(3/2)*(1/(n:ℝ)^2)<0)] at hb
  have hm := mul_le_mul_of_nonneg_right hb hs.le
  have he : ((1:ℝ)/(n:ℝ)^2)*(n:ℝ)^2=1 := div_mul_cancel₀ _ hs.ne'
  have hh : (1/50:ℝ)*(n:ℝ)^2+3/2 ≤ C := by
    calc
      (1/50:ℝ)*(n:ℝ)^2+3/2 =
        (-(-(1/50:ℝ)-(3/2)*(1/(n:ℝ)^2)))*(n:ℝ)^2 := by
          nlinarith [he]
      _ ≤ (C*(1/(n:ℝ)^2))*(n:ℝ)^2 := hm
      _ = C := by rw [mul_assoc,he,mul_one]
  linarith

end
end HugNavierWellposedness.Verified
