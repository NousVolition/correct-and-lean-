import CWSpectral

namespace HugV3.Source.CW
noncomputable section
open scoped BigOperators
set_option maxHeartbeats 600000

private def kernelTerm (k x y : Grid) (j : Axis) : ℝ :=
  wave k j * (Real.sin (phase k y)*Real.cos (phase k x) -
               Real.cos (phase k y)*Real.sin (phase k x))

private theorem term_real (k x y : Grid) (j : Axis) :
    (Complex.I*(wave k j : ℂ)*cis (-phase k y)*cis (phase k x)).re=kernelTerm k x y j := by
  simp [cis,Complex.mul_re,Complex.mul_im,kernelTerm]
  ring

private theorem gradient_kernel (f : Scalar) (x : Grid) (j : Axis) :
    grad f x j = (∑ k, ∑ y, f y*kernelTerm k x y j)/4096 := by
  have oneMode (k : Grid) :
      Complex.I*(wave k j : ℂ)*hat f k*cis (phase k x) =
      ∑ y, (f y : ℂ)*(Complex.I*(wave k j : ℂ)*cis (-phase k y)*cis (phase k x)) := by
    simp only [hat,Finset.mul_sum,Finset.sum_mul]
    apply Finset.sum_congr rfl
    intro y _
    ring
  have scaleRe (r : ℝ) (z : ℂ) : ((r:ℂ)*z).re=r*z.re := by simp [Complex.mul_re]
  simp only [grad,realGrid,oneMode,Complex.div_ofNat_re,Complex.re_sum,scaleRe,term_real]

theorem spectral_integration_by_parts (f g : Scalar) (j : Axis) :
    (∑ x, f x*grad g x j) = -(∑ x, g x*grad f x j) := by
  have expand (a b : Scalar) :
      (∑ x, a x*grad b x j) = (∑ x, ∑ k, ∑ y, a x*b y*kernelTerm k x y j)/4096 := by
    simp_rw [gradient_kernel,← mul_div_assoc,Finset.mul_sum,← Finset.sum_div]
    simp only [mul_assoc]
  rw [expand,expand,← neg_div]
  congr 1
  calc
    (∑ x : Grid, ∑ k : Grid, ∑ y : Grid, f x*g y*kernelTerm k x y j) =
        ∑ k : Grid, ∑ x : Grid, ∑ y : Grid, f x*g y*kernelTerm k x y j := Finset.sum_comm
    _ = ∑ k : Grid, ∑ y : Grid, ∑ x : Grid, f x*g y*kernelTerm k x y j := by
      apply Finset.sum_congr rfl
      intro k _; exact Finset.sum_comm
    _ = ∑ y : Grid, ∑ k : Grid, ∑ x : Grid, f x*g y*kernelTerm k x y j := Finset.sum_comm
    _ = -(∑ y : Grid, ∑ k : Grid, ∑ x : Grid, g y*f x*kernelTerm k y x j) := by
      simp_rw [← Finset.sum_neg_distrib]
      refine Finset.sum_congr rfl (fun y _ => Finset.sum_congr rfl (fun k _ =>
        Finset.sum_congr rfl (fun x _ => ?_)))
      unfold kernelTerm
      ring

private theorem strain_contract (L : Mat) (ν : ℝ) :
    (∑ i, ∑ j, (2*ν*symm L i j)*L i j)=2*ν*(∑ i, ∑ j, (symm L i j)^2) := by
  have transposed : (∑ i, ∑ j, (2*ν*symm L i j)*L i j) =
      ∑ i, ∑ j, (2*ν*symm L i j)*L j i := by
    rw [Finset.sum_comm]
    refine Finset.sum_congr rfl (fun i _ => Finset.sum_congr rfl (fun j _ => ?_))
    simp only [symm]
    ring
  have twice : (∑ i, ∑ j, (2*ν*symm L i j)*L i j) +
      (∑ i, ∑ j, (2*ν*symm L i j)*L j i) = 2*(2*ν*(∑ i, ∑ j, (symm L i j)^2)) := by
    simp only [← Finset.sum_add_distrib,Finset.mul_sum]
    refine Finset.sum_congr rfl (fun i _ => Finset.sum_congr rfl (fun j _ => ?_))
    unfold symm
    ring
  linarith

theorem raw_weaver_work_is_minus_heat (s : State) :
    inner (velocity s) (rawWeaver s (velocity s)) = -heat s := by
  let u := velocity s
  let T (x : Grid) (i j : Axis) := 2*viscosity s x*symm (gridGradient u x) i j
  have component (i j : Axis) : (∑ x, u x i*grad (fun y => T y i j) x j) =
      -(∑ x, T x i j*gridGradient u x i j) := spectral_integration_by_parts _ _ _
  change (∑ x, ∑ i, u x i*(∑ j, grad (fun y => T y i j) x j))/4096 =
      -((∑ x, viscousHeat s x)/4096)
  rw [← neg_div]; congr 1
  calc
    _ = ∑ x : Grid, ∑ i : Axis, ∑ j : Axis, u x i*grad (fun y => T y i j) x j := by
      simp only [Finset.mul_sum]
    _ = ∑ i : Axis, ∑ j : Axis, ∑ x : Grid, u x i*grad (fun y => T y i j) x j := by
      rw [Finset.sum_comm]
      exact Finset.sum_congr rfl (fun _ _ => Finset.sum_comm)
    _ = -(∑ i : Axis, ∑ j : Axis, ∑ x : Grid, T x i j*gridGradient u x i j) := by
      simp_rw [component,Finset.sum_neg_distrib]
    _ = -(∑ x : Grid, ∑ i : Axis, ∑ j : Axis, T x i j*gridGradient u x i j) := by
      congr 1
      symm
      rw [Finset.sum_comm]
      exact Finset.sum_congr rfl (fun _ _ => Finset.sum_comm)
    _ = _ := by
      congr 1
      exact Finset.sum_congr rfl (fun x _ => strain_contract (gridGradient u x) (viscosity s x))

theorem raw_courier_work_is_zero (u : Vector) (x : Grid) :
    dot (u x) (rawCourier u u x)=0 := by
  simp [dot,rawCourier,cross,Fin.sum_univ_succ]
  ring

end
end HugV3.Source.CW
