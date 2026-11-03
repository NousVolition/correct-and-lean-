import OriginalAS

/- Actual proofs. Does not import FullChallenge, a reduced Hug ODE, or a
   discretized PDE. Every derivative in the model is a real derivative. -/
namespace HugNavierSingle.Verified
noncomputable section
open Set

lemma alongX {f : ScalarField} (hf : Differentiable ℝ f) (r : Point) :
    DifferentiableAt ℝ (fun x => f (x,r.2)) r.1 := by
  exact hf.differentiableAt.comp r.1
    (differentiableAt_id.prodMk (differentiableAt_const r.2))
lemma alongY {f : ScalarField} (hf : Differentiable ℝ f) (r : Point) :
    DifferentiableAt ℝ (fun y => f (r.1,y)) r.2 := by
  exact hf.differentiableAt.comp r.2
    ((differentiableAt_const r.1).prodMk differentiableAt_id)

lemma energy_partialX (z : Fields) (r : Point) (h : FirstSpatialRegularity z) :
    partialX (energy z) r = z.ux r*partialX z.ux r+z.uy r*partialX z.uy r+
      z.xA r*partialX z.xA r+z.xB r*partialX z.xB r+
      z.gAB r*partialX z.gAB r+z.gBA r*partialX z.gBA r := by
  rcases h with ⟨hu,hv,ha,hb,hg,hk⟩
  have hx := ((((((alongX hu r).hasDerivAt.pow 2).add
    ((alongX hv r).hasDerivAt.pow 2)).add ((alongX ha r).hasDerivAt.pow 2)).add
    ((alongX hb r).hasDerivAt.pow 2)).add ((alongX hg r).hasDerivAt.pow 2)).add
    ((alongX hk r).hasDerivAt.pow 2) |>.div_const 2
  simp only [Pi.pow_def, Pi.add_def] at hx
  change deriv (fun x => energy z (x,r.2)) r.1 = _
  rw [show (fun x => energy z (x,r.2)) =
      (fun x => ((z.ux (x,r.2))^2+(z.uy (x,r.2))^2+(z.xA (x,r.2))^2+
        (z.xB (x,r.2))^2+(z.gAB (x,r.2))^2+(z.gBA (x,r.2))^2)/2) from rfl,
    hx.deriv]
  simp only [partialX, Nat.cast_ofNat]
  ring

lemma energy_partialY (z : Fields) (r : Point) (h : FirstSpatialRegularity z) :
    partialY (energy z) r = z.ux r*partialY z.ux r+z.uy r*partialY z.uy r+
      z.xA r*partialY z.xA r+z.xB r*partialY z.xB r+
      z.gAB r*partialY z.gAB r+z.gBA r*partialY z.gBA r := by
  rcases h with ⟨hu,hv,ha,hb,hg,hk⟩
  have hy := ((((((alongY hu r).hasDerivAt.pow 2).add
    ((alongY hv r).hasDerivAt.pow 2)).add ((alongY ha r).hasDerivAt.pow 2)).add
    ((alongY hb r).hasDerivAt.pow 2)).add ((alongY hg r).hasDerivAt.pow 2)).add
    ((alongY hk r).hasDerivAt.pow 2) |>.div_const 2
  simp only [Pi.pow_def, Pi.add_def] at hy
  change deriv (fun y => energy z (r.1,y)) r.2 = _
  rw [show (fun y => energy z (r.1,y)) =
      (fun y => ((z.ux (r.1,y))^2+(z.uy (r.1,y))^2+(z.xA (r.1,y))^2+
        (z.xB (r.1,y))^2+(z.gAB (r.1,y))^2+(z.gBA (r.1,y))^2)/2) from rfl,
    hy.deriv]
  simp only [partialY, Nat.cast_ofNat]
  ring

theorem full_material_energy_balance (i : FieldInputs) (t : ℝ)
    (z : ℝ → Fields) (p : ℝ → ScalarField) (r : Point)
    (h : FieldDifferentialAt i z p t)
    (hs : FirstSpatialRegularity (z t)) :
    deriv (fun s => energy (z s) r) t + advection (z t) (energy (z t)) r =
      energyProduction i t (z t) (p t) r := by
  rcases h r with ⟨hu,hv,ha,hb,hg,hk⟩
  have ht := (((((hu.pow 2).add (hv.pow 2)).add (ha.pow 2)).add
    (hb.pow 2)).add (hg.pow 2)).add (hk.pow 2) |>.div_const 2
  simp only [Pi.pow_def, Pi.add_def] at ht
  rw [show (fun s => energy (z s) r) =
      (fun s => ((z s).ux r^2+(z s).uy r^2+(z s).xA r^2+
        (z s).xB r^2+(z s).gAB r^2+(z s).gBA r^2)/2) from rfl,
    ht.deriv]
  unfold advection
  rw [energy_partialX (z t) r hs, energy_partialY (z t) r hs]
  dsimp [fieldRates, energyProduction, reactionA, reactionB, reactionAB, reactionBA, advection]
  ring

theorem source_initial_incompressible : Incompressible sourceInitial := by
  intro r
  have h2x : HasDerivAt (fun x : ℝ => 2*x+r.2) 2 r.1 := by
    exact (hasDerivAt_const_mul (2:ℝ)).add_const r.2
  have h1x : HasDerivAt (fun x : ℝ => x-2*r.2) 1 r.1 := by
    simpa using (hasDerivAt_id r.1).sub_const (2*r.2)
  have h1y : HasDerivAt (fun y : ℝ => 2*r.1+y) 1 r.2 := by
    simpa using (hasDerivAt_id r.2).const_add (2*r.1)
  have h2y : HasDerivAt (fun y : ℝ => r.1-2*y) (-2) r.2 := by
    exact (hasDerivAt_const_mul (2:ℝ)).const_sub r.1
  have hu := (((hasDerivAt_id r.1).sin.mul_const (Real.cos r.2)).sub
    (h2x.sin.const_mul (1/4))).sub (h1x.cos.const_mul (3/10))
  have hv := (((hasDerivAt_id r.2).sin.const_mul (-Real.cos r.1)).add
    (h1y.sin.const_mul (1/2))).sub (h2y.cos.const_mul (3/20))
  simp only [Pi.sub_def, Pi.add_def, id_eq] at hu hv
  change deriv (fun x => sourceInitial.ux (x,r.2)) r.1+
    deriv (fun y => sourceInitial.uy (r.1,y)) r.2=0
  dsimp [sourceInitial]
  rw [hu.deriv,hv.deriv]
  ring

lemma rates_pressure_shift (i : FieldInputs) (t : ℝ) (z : Fields)
    (p : ScalarField) (c : ℝ) :
    fieldRates i t z (fun r => p r+c) = fieldRates i t z p := by
  simp only [fieldRates, partialX, partialY, deriv_add_const]

theorem full_pressure_gauge (i : FieldInputs) (a b : ℝ) (initial : Fields)
    (z : ℝ → Fields) (p : ℝ → ScalarField) (c : ℝ → ℝ)
    (h : FieldProblem i a b initial z p) :
    FieldProblem i a b initial z (fun t r => p t r+c t) := by
  rcases h with ⟨hi,hcont,hspace,hdiff⟩
  refine ⟨hi,hcont,?_,?_⟩
  · intro t ht
    rcases hspace t ht with ⟨hr,hper,hdiv⟩
    rcases hr with ⟨hu,hv,ha,hb,hg,hk,hp⟩
    rcases hper with ⟨pu,pv,pa,pb,pg,pk,pp⟩
    refine ⟨⟨hu,hv,ha,hb,hg,hk,hp.add contDiff_const⟩,
      ⟨pu,pv,pa,pb,pg,pk,?_⟩,hdiv⟩
    intro r
    exact ⟨congrArg (fun v => v+c t) (pp r).1,
      congrArg (fun v => v+c t) (pp r).2⟩
  · intro t ht
    simpa only [FieldDifferentialAt, rates_pressure_shift] using hdiff t ht

theorem full_pressure_not_unique (i : FieldInputs) (a b : ℝ) (initial : Fields)
    (z : ℝ → Fields) (p : ℝ → ScalarField)
    (h : FieldProblem i a b initial z p) :
    ∃ q, FieldProblem i a b initial z q ∧ q ≠ p := by
  refine ⟨(fun t r => p t r+1),full_pressure_gauge i a b initial z p (fun _ => 1) h,?_⟩
  intro heq
  have bad := congrArg (fun f : ℝ → ScalarField => f 0 (0,0)) heq
  linarith

lemma sigmoid_bounds (v : ℝ) : 0 < sigmoid v ∧ sigmoid v < 1 := by
  have he := Real.exp_pos (-v)
  constructor
  · exact one_div_pos.mpr (by linarith)
  · unfold sigmoid
    exact (div_lt_one (by linarith)).mpr (by linarith)

theorem guards_inward_at_spatial_boundaries (i : FieldInputs) (t : ℝ)
    (z : Fields) (p : ScalarField) (r : Point)
    (hxAB : partialX z.gAB r=0) (hyAB : partialY z.gAB r=0)
    (hxBA : partialX z.gBA r=0) (hyBA : partialY z.gBA r=0) :
    (z.gAB r=0 → 0 ≤ laplacian z.gAB r → 0 < (fieldRates i t z p).gAB r) ∧
    (z.gAB r=1 → laplacian z.gAB r ≤ 0 → (fieldRates i t z p).gAB r < 0) ∧
    (z.gBA r=0 → 0 ≤ laplacian z.gBA r → 0 < (fieldRates i t z p).gBA r) ∧
    (z.gBA r=1 → laplacian z.gBA r ≤ 0 → (fieldRates i t z p).gBA r < 0) := by
  have hab := sigmoid_bounds (-2/5+2*(z.xB r-z.xA r)+(1/2)*strainSquared z r)
  have hba := sigmoid_bounds (-2/5+2*(z.xA r-z.xB r)+(1/2)*strainSquared z r)
  dsimp [fieldRates, advection]
  rw [hxAB,hyAB,hxBA,hyBA]
  constructor
  · intro hz hl; rw [hz]; linarith [hab.1]
  constructor
  · intro hz hl; rw [hz]; linarith [hab.2]
  constructor
  · intro hz hl; rw [hz]; linarith [hba.1]
  · intro hz hl; rw [hz]; linarith [hba.2]

theorem viscosity_and_stress_dissipation (z : Fields) (r : Point)
    (ha : z.gAB r ∈ Icc (0:ℝ) 1) (hb : z.gBA r ∈ Icc (0:ℝ) 1) :
    viscosity z r ∈ Icc (1/50:ℝ) (1/10) ∧
    stressXX z r*partialX z.ux r+stressYY z r*partialY z.uy r+
      stressXY z r*(partialY z.ux r+partialX z.uy r)=2*viscosity z r*strainSquared z r ∧
    0 ≤ 2*viscosity z r*strainSquared z r := by
  have hv : viscosity z r ∈ Icc (1/50:ℝ) (1/10) := by
    dsimp [viscosity]
    constructor <;> linarith [ha.1,ha.2,hb.1,hb.2]
  refine ⟨hv,?_,?_⟩
  · dsimp [stressXX,stressYY,stressXY,strainSquared]; ring
  · have hs : 0 ≤ strainSquared z r := by unfold strainSquared; positivity
    exact mul_nonneg (mul_nonneg (by norm_num) (le_trans (by norm_num) hv.1)) hs

lemma partialX_mul (f g : ScalarField) (r : Point)
    (hf : Differentiable ℝ f) (hg : Differentiable ℝ g) :
    partialX (fun x => f x*g x) r = partialX f r*g r+f r*partialX g r :=
  deriv_mul (alongX hf r) (alongX hg r)
lemma partialY_mul (f g : ScalarField) (r : Point)
    (hf : Differentiable ℝ f) (hg : Differentiable ℝ g) :
    partialY (fun x => f x*g x) r = partialY f r*g r+f r*partialY g r :=
  deriv_mul (alongY hf r) (alongY hg r)

theorem full_variable_stress_divergence (z : Fields) (r : Point)
    (hnu : Differentiable ℝ (viscosity z))
    (ha : Differentiable ℝ (partialX z.ux))
    (hb : Differentiable ℝ (partialY z.ux))
    (hc : Differentiable ℝ (partialX z.uy)) :
    partialX (stressXX z) r+partialY (stressXY z) r =
      2*(partialX (viscosity z) r)*(partialX z.ux r)+
      2*viscosity z r*partialX (partialX z.ux) r+
      partialY (viscosity z) r*(partialY z.ux r+partialX z.uy r)+
      viscosity z r*(partialY (partialY z.ux) r+partialY (partialX z.uy) r) := by
  have hxx := (((alongX hnu r).hasDerivAt.const_mul 2).mul (alongX ha r).hasDerivAt).deriv
  have hxy := ((alongY hnu r).hasDerivAt.mul
    ((alongY hb r).hasDerivAt.add (alongY hc r).hasDerivAt)).deriv
  simp only [Pi.mul_def, Pi.add_def] at hxx hxy
  change deriv (fun x => 2*viscosity z (x,r.2)*partialX z.ux (x,r.2)) r.1+
    deriv (fun y => viscosity z (r.1,y)*(partialY z.ux (r.1,y)+partialX z.uy (r.1,y))) r.2 = _
  rw [hxx,hxy]
  dsimp only [partialX,partialY]
  ring

end
end HugNavierSingle.Verified

namespace OriginalAS.Verified
noncomputable section

theorem original_memory_derivative (p : Parameters) (U : ℝ → ℝ)
    (hU : Continuous U) (t : ℝ) :
    HasDerivAt (memory p U) (p.gamma*(U t-p.baseline)) t := by
  have hc : Continuous (fun s => p.gamma*(U s-p.baseline)) :=
    continuous_const.mul (hU.sub continuous_const)
  exact intervalIntegral.integral_hasDerivAt_right (hc.intervalIntegrable 0 t)
    hc.aestronglyMeasurable.stronglyMeasurableAtFilter hc.continuousAt

theorem original_pressure_gauge {n : ℕ} (p : Parameters) (response : ℝ → ℝ)
    (direction : Fin n) (U : ℝ → ℝ) (K : Scalar n) (x0 : Point n)
    (domain : Set (Point n)) (z : ℝ → Fields n) (pressure : ℝ → Scalar n)
    (c : ℝ → ℝ) (t : ℝ)
    (h : FullDifferentialAt p response direction U K x0 domain z pressure t) :
    FullDifferentialAt p response direction U K x0 domain z
      (fun s x => pressure s x+c s) t := by
  simpa only [FullDifferentialAt, rates, coordinatePartial, deriv_add_const] using h

theorem normalized_momentum_equivalent (rho mu sigma dt conv gradP lap a ek : ℝ)
    (hr : rho ≠ 0) :
    (dt+conv=-(gradP/rho)+(mu/rho)*lap-(sigma/rho)*a*ek) ↔
    (rho*(dt+conv)=-gradP+mu*lap-sigma*a*ek) := by
  field_simp

end
end OriginalAS.Verified
