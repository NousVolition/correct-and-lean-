import AppleFlowDefinitions

namespace HugV3.Source.AppleBand
noncomputable section
open scoped BigOperators NNReal
open Set
set_option maxHeartbeats 550000

/-- Each Fourier kernel is bounded and globally Lipschitz in the material point.
    The constants here prove existence; they need not be numerically sharp. -/
private def KernelBound (f : Vec → ℝ) : Prop :=
  ∃ c : ℝ, 0≤c ∧ (∀ z, |f z|≤c) ∧ ∀ x y, |f x-f y|≤c*‖x-y‖

private theorem kernel_const (a : ℝ) : KernelBound (fun _ => a) := by
  refine ⟨|a|,abs_nonneg _,fun _ => le_rfl,?_⟩
  intro x y
  simp only [sub_self,abs_zero]
  positivity

private theorem kernel_add {f g : Vec → ℝ} (hf : KernelBound f) (hg : KernelBound g) :
    KernelBound (fun z => f z+g z) := by
  obtain ⟨a,ha,fa,df⟩ := hf
  obtain ⟨b,hb,gb,dg⟩ := hg
  refine ⟨a+b,by positivity,fun z => (abs_add_le _ _).trans (add_le_add (fa z) (gb z)),?_⟩
  intro x y
  rw [show f x+g x-(f y+g y)=(f x-f y)+(g x-g y) by ring,add_mul]
  exact (abs_add_le _ _).trans (add_le_add (df x y) (dg x y))

private theorem kernel_mul {f g : Vec → ℝ} (hf : KernelBound f) (hg : KernelBound g) :
    KernelBound (fun z => f z*g z) := by
  obtain ⟨a,ha,fa,df⟩ := hf
  obtain ⟨b,hb,gb,dg⟩ := hg
  refine ⟨2*a*b,by positivity,?_,?_⟩
  · intro z
    rw [abs_mul]
    have h := mul_le_mul (fa z) (gb z) (abs_nonneg _) ha
    nlinarith only [h,mul_nonneg ha hb]
  · intro x y
    rw [show f x*g x-f y*g y=(f x-f y)*g x+f y*(g x-g y) by ring]
    calc
      _ ≤ |(f x-f y)*g x|+|f y*(g x-g y)| := abs_add_le _ _
      _ ≤ (a*‖x-y‖)*b+a*(b*‖x-y‖) := by
        simp only [abs_mul]
        exact add_le_add (mul_le_mul (df x y) (gb x) (abs_nonneg _) (by positivity))
          (mul_le_mul (fa y) (dg x y) (abs_nonneg _) ha)
      _ = _ := by ring

private theorem kernel_sum {ι : Type*} [DecidableEq ι] (S : Finset ι) (f : ι → Vec → ℝ)
    (hf : ∀ i, KernelBound (f i)) : KernelBound (fun z => ∑ i∈S, f i z) := by
  induction S using Finset.induction_on with
  | empty => simpa using kernel_const 0
  | insert i s hi ih => simpa [hi] using kernel_add (hf i) ih

private theorem kernel_prod {ι : Type*} [DecidableEq ι] (S : Finset ι) (f : ι → Vec → ℝ)
    (hf : ∀ i, KernelBound (f i)) : KernelBound (fun z => ∏ i∈S, f i z) := by
  induction S using Finset.induction_on with
  | empty => simpa using kernel_const 1
  | insert i s hi ih => simpa [hi] using kernel_mul (hf i) ih

private theorem cos_coordinate (w c : ℝ) (j : Axis) :
    KernelBound (fun z => Real.cos (w*(z j-c))) := by
  refine ⟨1+|w|,by positivity,fun z => (Real.abs_cos_le_one _).trans (by linarith [abs_nonneg w]),?_⟩
  intro x y
  have coord : |x j-y j|≤‖x-y‖ := by
    simpa only [Pi.sub_apply,Real.norm_eq_abs] using norm_le_pi_norm (x-y) j
  calc
    _ ≤ |w*(x j-c)-w*(y j-c)| := Real.abs_cos_sub_cos_le _ _
    _ = |w| * |x j-y j| := by rw [show w*(x j-c)-w*(y j-c)=w*(x j-y j) by ring,abs_mul]
    _ ≤ |w| * ‖x-y‖ := mul_le_mul_of_nonneg_left coord (abs_nonneg _)
    _ ≤ _ := by nlinarith only [norm_nonneg (x-y)]

private theorem one_weight (i : Fin 16) (j : Axis) : KernelBound (fun z => mechanical1D (z j) i) := by
  let c := (i.val:ℝ)/16-1/2
  let w := fun k : Fin 16 => 2*Real.pi*freq k
  let term := fun k (z : Vec) => if |freq k|<(16:ℝ)/3 then
    Real.cos (w k*(z j-c))*Real.exp (-(2*Real.pi*freq k*(7/200))^2/2) else 0
  have each (k : Fin 16) : KernelBound (term k) := by
    by_cases h : |freq k|<(16:ℝ)/3
    · simpa [term,h] using
        kernel_mul (cos_coordinate (w k) c j) (kernel_const (Real.exp (-(2*Real.pi*freq k*(7/200))^2/2)))
    · simpa [term,h] using kernel_const 0
  have eqn : (fun z : Vec => mechanical1D (z j) i) =
      (fun z => (1/16:ℝ)*(∑ k, term k z)) := by
    funext z
    have eqTerm (k : Fin 16) :
        (if |freq k|<(16:ℝ)/3 then Real.cos (2*Real.pi*(z j-((i.val:ℝ)/16-1/2))*freq k)*
          Real.exp (-(2*Real.pi*freq k*(7/200))^2/2) else 0)=term k z := by
      rw [show 2*Real.pi*(z j-((i.val:ℝ)/16-1/2))*freq k=w k*(z j-c) by dsimp [w,c]; ring]
    simp only [mechanical1D,eqTerm]
    ring
  rw [eqn]
  exact kernel_mul (kernel_const _) (kernel_sum Finset.univ term each)

private theorem point_weight (x : Grid) : KernelBound (fun z => ∏ j, mechanical1D (z j) (x j)) :=
  kernel_prod Finset.univ _ (fun j => one_weight (x j) j)

theorem continuous_grid_history_has_global_space_bounds {a b : ℝ} (u : ℝ → Vector)
    (hc : ContinuousOn u (Icc a b)) :
    ∃ L K : ℝ≥0, ∀ t∈Icc a b,
      (∀ z, ‖gridVelocity (u t) z‖≤(L:ℝ)) ∧ LipschitzWith K (gridVelocity (u t)) := by
  choose c nn abs_bound lip using point_weight
  obtain ⟨M₀,hM₀⟩ := isCompact_Icc.bddAbove_image hc.norm
  let M := max 0 M₀
  have hM : 0≤M := le_max_left _ _
  let D := M*∑ x, c x
  have hd : 0≤D := mul_nonneg hM (Finset.sum_nonneg fun x _ => nn x)
  refine ⟨⟨D,hd⟩,⟨D,hd⟩,?_⟩
  intro t ht
  have coeff (x : Grid) (i : Axis) : |u t x i|≤M := by
    have one : |u t x i|≤‖u t x‖ := by simpa only [Real.norm_eq_abs] using norm_le_pi_norm (u t x) i
    exact one.trans ((norm_le_pi_norm (u t) x).trans ((hM₀ (mem_image_of_mem _ ht)).trans (le_max_right _ _)))
  let w := fun (z : Vec) (x : Grid) => ∏ j, mechanical1D (z j) (x j)
  constructor
  · intro z
    apply (pi_norm_le_iff_of_nonneg hd).2
    intro i
    change ‖∑ x, w z x*u t x i‖≤D
    calc
      _ ≤ ∑ x, ‖w z x*u t x i‖ := norm_sum_le _ _
      _ ≤ ∑ x, c x*M := by
        exact Finset.sum_le_sum (fun x _ => by
          rw [Real.norm_eq_abs,abs_mul]
          exact mul_le_mul (abs_bound x z) (coeff x i) (abs_nonneg _) (nn x))
      _ = D := by simp only [D,← Finset.sum_mul]; ring
  · apply LipschitzWith.of_dist_le_mul
    intro z v
    rw [dist_eq_norm,dist_eq_norm]
    apply (pi_norm_le_iff_of_nonneg (mul_nonneg hd (norm_nonneg (z-v)))).2
    intro i
    change ‖(∑ x, w z x*u t x i)-(∑ x, w v x*u t x i)‖≤D*‖z-v‖
    rw [← Finset.sum_sub_distrib]
    calc
      _ ≤ ∑ x, ‖w z x*u t x i-w v x*u t x i‖ := norm_sum_le _ _
      _ ≤ ∑ x, c x*‖z-v‖*M := by
        apply Finset.sum_le_sum
        intro x _
        rw [← sub_mul,Real.norm_eq_abs,abs_mul]
        exact mul_le_mul (lip x z v) (coeff x i) (abs_nonneg _) (mul_nonneg (nn x) (norm_nonneg _))
      _ = D*‖z-v‖ := by simp only [D,← Finset.sum_mul]; ring

end
end HugV3.Source.AppleBand
