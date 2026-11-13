import EnergyAccounting
import Mathlib.Analysis.SpecialFunctions.Sqrt

/-! Necessary storage identities for the original fixed-direction coupling.
These are conditional calculus results. The spatial material-gradient transport
identity is explained in the accompanying derivation, not asserted as a new
formal PDE theorem here. No constitutive or gravitational law is added.
-/
set_option autoImplicit false
noncomputable section
open scoped BigOperators
namespace StorageRequirements

def magnitude {n : ℕ} (g : Fin n → ℝ) : ℝ := Real.sqrt (∑ i, (g i)^2)

theorem magnitude_rate {n : ℕ} (g : ℝ → Fin n → ℝ) (h : Fin n → ℝ) (t : ℝ)
    (hg : ∀ i, HasDerivAt (fun s => g s i) (h i) t)
    (hpos : 0 < ∑ i, (g t i)^2) :
    HasDerivAt (fun s => magnitude (g s)) ((∑ i, g t i*h i)/magnitude (g t)) t := by
  have hs : HasDerivAt (fun s => ∑ i, (g s i)^2) (∑ i, 2*g t i*h i) t := by
    simpa [Pi.pow_apply] using
      HasDerivAt.fun_sum (u := Finset.univ) (fun i _ => (hg i).pow 2)
  have hd := hs.sqrt (ne_of_gt hpos)
  have htwo : (∑ i, 2*g t i*h i) = 2*(∑ i, g t i*h i) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i _
    ring
  have hn : Real.sqrt (∑ i, (g t i)^2) ≠ 0 := ne_of_gt (Real.sqrt_pos.mpr hpos)
  have heq : ((∑ i, 2*g t i*h i)/(2*Real.sqrt (∑ i, (g t i)^2))) =
      (∑ i, g t i*h i)/Real.sqrt (∑ i, (g t i)^2) := by
    rw [htwo]
    field_simp
  rw [heq] at hd
  exact hd

/- If h = grad(Q) - (grad u)^T g, this separates source/diffusion
   and deformation contributions to the activation rate. -/
theorem gradient_transport_contraction {n : ℕ} (g Q : Fin n → ℝ)
    (L : Fin n → Fin n → ℝ) :
    (∑ i, g i*(Q i-∑ j, L j i*g j)) =
      (∑ i, g i*Q i) - ∑ i, ∑ j, g i*L j i*g j := by
  simp_rw [mul_sub, Finset.mul_sum, Finset.sum_sub_distrib]
  congr 1
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro j _
  ring

theorem activation_height_residual {n : ℕ} (g : ℝ → Fin n → ℝ) (h : Fin n → ℝ)
    (response E X : ℝ → ℝ) (sigma threshold slope v t : ℝ)
    (hg : ∀ i, HasDerivAt (fun s => g s i) (h i) t)
    (hpos : 0 < ∑ i, (g t i)^2)
    (ha : HasDerivAt response slope (magnitude (g t)-threshold))
    (hX : HasDerivAt X v t)
    (hE : HasDerivAt E (-sigma*response (magnitude (g t)-threshold)*v) t) :
    HasDerivAt (fun s => E s+sigma*response (magnitude (g s)-threshold)*X s)
      (sigma*X t*slope*((∑ i, g t i*h i)/magnitude (g t))) t := by
  have hm := (magnitude_rate g h t hg hpos).sub_const threshold
  have hr := ha.comp t hm
  convert hE.fun_add ((hr.const_mul sigma).fun_mul hX) using 1 <;>
    first | rfl | (simp only [Function.comp_apply]; ring)

/- Matching the force at fixed activation determines the x dependence of
   EVERY differentiable two-variable candidate, up to a function of activation. -/
theorem force_match_determines_storage (V : ℝ → ℝ → ℝ) (sigma : ℝ)
    (hV : ∀ x a, HasDerivAt (fun y => V y a) (sigma*a) x) (x a : ℝ) :
    V x a = sigma*a*x + V 0 a := by
  have hd : ∀ z, HasDerivAt (fun y => V y a-sigma*a*y) 0 z := by
    intro z
    convert (hV z a).fun_sub ((hasDerivAt_id z).const_mul (sigma*a)) using 1 <;>
      first | rfl | ring
  have he := is_const_of_deriv_eq_zero (fun z => (hd z).differentiableAt)
    (fun z => (hd z).deriv) x 0
  change V x a-sigma*a*x = V 0 a-sigma*a*0 at he
  linarith

theorem required_activation_conjugate (V : ℝ → ℝ → ℝ) (sigma : ℝ)
    (hV : ∀ x a, HasDerivAt (fun y => V y a) (sigma*a) x)
    (x a dC : ℝ) (hC : HasDerivAt (fun b => V 0 b) dC a) :
    HasDerivAt (fun b => V x b) (sigma*x+dC) a := by
  have he : (fun b => V x b) = fun b => sigma*b*x+V 0 b := by
    funext b
    exact force_match_determines_storage V sigma hV x b
  rw [he]
  convert (((hasDerivAt_id a).const_mul sigma).mul_const x).fun_add hC using 1 <;>
    first | rfl | ring

/- This excludes only a differentiable V(x,a) whose two rates can vary
   independently and whose activation changes have no energy transfer. It is
   not a no-go theorem for a constrained trajectory or an enlarged history. -/
theorem no_storage_with_unpaid_independent_activation (V : ℝ → ℝ → ℝ) (sigma : ℝ)
    (hs : sigma ≠ 0)
    (hx : ∀ x a, HasDerivAt (fun y => V y a) (sigma*a) x)
    (ha : ∀ x a, HasDerivAt (fun b => V x b) 0 a) : False := by
  have hd := required_activation_conjugate V sigma hx 1 0 0 (ha 0 0)
  have he := hd.unique (ha 1 0)
  apply hs
  linarith

end StorageRequirements
