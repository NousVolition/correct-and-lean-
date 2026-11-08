import CWProofs

namespace HugV3.Source.CW
noncomputable section
open scoped BigOperators
attribute [local instance] Classical.propDecidable
set_option maxHeartbeats 650000

private def coeffPair (a b : ℂ) : ℝ := a.re*b.re+a.im*b.im

private theorem coefficient_sample (f : Scalar) (k : Grid) (z : ℂ) :
    coeffPair (hat f k) z=∑ x, f x*(z*cis (phase k x)).re := by
  simp only [coeffPair,hat,Complex.re_sum,Complex.im_sum,Complex.mul_re,Complex.mul_im,
    cis,Complex.ofReal_re,Complex.ofReal_im,zero_mul,add_zero,sub_zero,Real.cos_neg,
    Real.sin_neg,Finset.sum_mul,← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro x _
  ring

private theorem inverse_duality (f : Scalar) (A : Grid → ℂ) :
    (∑ x, f x*realGrid A x)=(∑ k, coeffPair (hat f k) (A k))/4096 := by
  simp only [realGrid,Complex.div_ofNat_re,Complex.re_sum,← mul_div_assoc,Finset.mul_sum,
    ← Finset.sum_div,coefficient_sample]
  rw [Finset.sum_comm]

private theorem filter_adjoint (f g : Scalar) :
    (∑ x, f x*filt g x)=(∑ x, g x*filt f x) := by
  simp only [filt,inverse_duality]
  congr 1
  apply Finset.sum_congr rfl
  intro k _
  by_cases h : masked k
  · simp [h,coeffPair]
    ring
  · simp [h,coeffPair]

private def den (k : Grid) : ℝ := if sqnorm (wave k)=0 then 1 else sqnorm (wave k)
private def maskedHat (u : Vector) (k : Grid) (r : Axis) : ℂ :=
  if masked k then hat (fun x => u x r) k else 0
private def projectedCoeff (u : Vector) (k : Grid) (i : Axis) : ℂ :=
  maskedHat u k i-(wave k i : ℂ)*(∑ r, (wave k r : ℂ)*maskedHat u k r)/(den k:ℂ)
private def entry (k : Grid) (i j : Axis) : ℝ :=
  if masked k then (if j=i then 1 else 0)-wave k i*wave k j/den k else 0

private theorem matrix_expansion (u : Vector) (k : Grid) (i : Axis) :
    projectedCoeff u k i=∑ r, (entry k i r:ℂ)*hat (fun x => u x r) k := by
  by_cases h : masked k
  · have term (r : Axis) :
        (entry k i r:ℂ)*hat (fun x => u x r) k =
        (if r=i then hat (fun x => u x r) k else 0) -
        ((wave k i:ℂ)/(den k:ℂ))*((wave k r:ℂ)*hat (fun x => u x r) k) := by
      by_cases hr : r=i <;> simp [entry,h,hr] <;> ring
    simp only [term,Finset.sum_sub_distrib,← Finset.mul_sum]
    simp [projectedCoeff,maskedHat,h]
    ring
  · simp [projectedCoeff,maskedHat,entry,h]

private theorem entry_symm (k : Grid) (i j : Axis) : entry k i j=entry k j i := by
  by_cases hk : masked k <;> by_cases eq : i=j <;> simp [entry,hk,eq,Ne.symm,mul_comm]

private theorem pair_matrix (a : ℂ) (k : Grid) (i : Axis) (v : Vector) :
    coeffPair a (projectedCoeff v k i)=
      ∑ j, entry k i j*coeffPair a (hat (fun x => v x j) k) := by
  rw [matrix_expansion]
  simp only [coeffPair,Complex.re_sum,Complex.im_sum,Complex.mul_re,Complex.mul_im,
    Complex.ofReal_re,Complex.ofReal_im,zero_mul,sub_zero,add_zero,Finset.mul_sum,
    ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro j _
  ring

private theorem inner_axis_first (u v : Vector) :
    inner u v=(∑ i, ∑ x, u x i*v x i)/4096 := by
  unfold inner dot
  rw [Finset.sum_comm]

private theorem project_adjoint (u v : Vector) : inner u (project v)=inner v (project u) := by
  have expand (p q : Vector) : inner p (project q) =
      ((∑ k, ∑ i, coeffPair (hat (fun y => p y i) k) (projectedCoeff q k i))/4096)/4096 := by
    rw [inner_axis_first]
    change (∑ i, ∑ x, p x i*realGrid (fun k => projectedCoeff q k i) x)/4096=_
    simp only [inverse_duality,← Finset.sum_div]
    rw [Finset.sum_comm]
  rw [expand,expand]
  congr 2
  apply Finset.sum_congr rfl
  intro k _
  simp only [pair_matrix]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl (fun i _ => Finset.sum_congr rfl (fun j _ => ?_))
  rw [entry_symm k j i]
  unfold coeffPair
  ring

theorem retained_velocity_work (s : State)
    (retained : ∀ i x, filt (fun y => velocity s y i) x=velocity s x i)
    (solenoidal : project (velocity s)=velocity s) :
    inner (velocity s) (weaver s (velocity s))= -heat s ∧
    inner (velocity s) (courier (velocity s))=0 := by
  let u := velocity s
  have tested (v : Vector) : inner u (resolve v)=inner u v := by
    calc
      _ = inner u (project v) := by
        simp only [inner_axis_first]
        congr 1
        apply Finset.sum_congr rfl
        intro i _
        change (∑ x, u x i*filt (fun y => project v y i) x)=∑ x, u x i*project v x i
        rw [filter_adjoint (fun y => u y i) (fun y => project v y i)]
        apply Finset.sum_congr rfl
        intro x _
        rw [show filt (fun y => u y i) x=u x i from retained i x]
        exact mul_comm (project v x i) (u x i)
      _ = inner v (project u) := project_adjoint u v
      _ = inner u v := by rw [show project u=u from solenoidal,dot_pair_is_symmetric]
  constructor
  · change inner u (resolve (rawWeaver s u))= -heat s
    rw [tested]
    exact raw_weaver_work_is_minus_heat s
  · change inner u (resolve (rawCourier u u))=0
    rw [tested]
    simp only [inner,raw_courier_work_is_zero,Finset.sum_const_zero,zero_div]

end
end HugV3.Source.CW
