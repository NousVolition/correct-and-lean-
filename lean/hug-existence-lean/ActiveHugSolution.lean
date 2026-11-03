import HugBarrier
namespace ActiveHug.Verified
open ActiveHug Set MeasureTheory

theorem protocol_physical : Physical protocol := by norm_num [Physical, protocol]

theorem sigmoid_bounds (z : ℝ) : 0 < sigmoid z ∧ sigmoid z < 1 := by
  have he := Real.exp_pos (-z)
  have hd : 0 < 1+Real.exp (-z) := by linarith
  exact ⟨one_div_pos.mpr hd, (div_lt_iff₀ hd).mpr (by linarith)⟩

theorem strain_nonnegative (p : Parameters) (s : State) : 0 ≤ strainSignal p s := by
  unfold strainSignal
  positivity

theorem guard_points_inward (tau z : ℝ) (ht : 0 < tau) :
    0 < guardRate tau z 0 ∧ guardRate tau z 1 < 0 := by
  obtain ⟨h0,h1⟩ := sigmoid_bounds z
  constructor
  · exact div_pos (by simpa using h0) ht
  · exact div_neg_of_neg_of_pos (sub_neg.mpr h1) ht

private theorem complement_solution {F : ℝ → ℝ → ℝ} {a b x0 : ℝ} {x : ℝ → ℝ}
    (hx : IntegralSolution F a b x0 x) :
    IntegralSolution (fun t y => -F t (1-y)) a b (1-x0) (fun t => 1-x t) := by
  refine ⟨continuousOn_const.sub hx.1, by change 1-x a = 1-x0; rw [hx.2.1], ?_, ?_⟩
  · apply hx.2.2.1.neg.congr
    intro t ht
    change -F t (x t) = -F t (1-(1-x t))
    rw [sub_sub_cancel]
  · intro t ht
    simp only [sub_sub_cancel, intervalIntegral.integral_neg]
    rw [hx.2.2.2 t ht]
    ring

theorem guard_interval_invariant {a b g0 tau : ℝ} {z g : ℝ → ℝ}
    (hab : a ≤ b) (ht : 0 < tau) (h0 : Hug.UnitInterval g0)
    (hsol : IntegralSolution (fun t y => guardRate tau (z t) y) a b g0 g) :
    ∀ t ∈ Icc a b, Hug.UnitInterval (g t) := by
  have hlo : ∀ t ∈ Icc a b, 0 ≤ g t := by
    apply Barrier.solution_nonnegative hab hsol h0.1
    intro t _ y hy
    exact div_nonneg (by linarith [(sigmoid_bounds (z t)).1]) ht.le
  have hhi : ∀ t ∈ Icc a b, 0 ≤ 1-g t := by
    apply Barrier.solution_nonnegative hab (complement_solution hsol) (sub_nonneg.mpr h0.2)
    intro t _ y hy
    apply neg_nonneg.mpr
    exact div_nonpos_of_nonpos_of_nonneg (by linarith [(sigmoid_bounds (z t)).2]) ht.le
  exact fun t ht => ⟨hlo t ht, by linarith [hhi t ht]⟩

theorem energy_nonnegative (p : Parameters) (s : State) (hp : Physical p) :
    0 ≤ energy p s := by
  obtain ⟨hm,hk,hV,hL,hGM,hGK,hEM,hEK,hc,hQ,ht⟩ := hp
  unfold energy
  positivity

theorem energy_chain_identity (p : Parameters) (F : ℝ) (s : State) (hp : Physical p) :
    energyChain p s (rhs p F s) = energyBalance p F s := by
  obtain ⟨hm,hk,hV,hL,hGM,hGK,hEM,hEK,hc,hQ,ht⟩ := hp
  simp only [energyChain, rhs, energyBalance, materialLoss, guardLoss]
  field_simp
  <;> ring

theorem energy_derivative (p : Parameters) (F : ℝ) (q v u w : ℝ → ℝ)
    (xA xB gAB gBA t : ℝ) (hp : Physical p) :
    let s : State := ⟨q t,v t,u t,w t,xA,xB,gAB,gBA⟩
    HasDerivAt q (rhs p F s).q t → HasDerivAt v (rhs p F s).v t →
    HasDerivAt u (rhs p F s).u t → HasDerivAt w (rhs p F s).w t →
    HasDerivAt (fun r => energy p ⟨q r,v r,u r,w r,xA,xB,gAB,gBA⟩)
      (energyBalance p F s) t := by
  dsimp only
  intro hq hv hu hw
  let s : State := ⟨q t,v t,u t,w t,xA,xB,gAB,gBA⟩
  have hs := (((hq.div_const p.length).sub hu).sub hw).const_mul p.gm
  have h := ((((hv.pow 2).const_mul p.mass).div_const 2).add
    (((hq.pow 2).const_mul p.stiffness).div_const 2)).add
    (((hs.pow 2).const_mul p.volume).div_const (2*p.gm))
  have hh := h.add (((hu.pow 2).const_mul (p.volume*p.gk)).div_const 2)
  change HasDerivAt _ (energyBalance p F s) t
  rw [←energy_chain_identity p F s hp]
  apply hh.congr_deriv
  dsimp [energyChain, stress, s]
  ring

theorem material_loss_nonnegative (p : Parameters) (s : State) (hp : Physical p) :
    0 ≤ materialLoss p s := by
  obtain ⟨hm,hk,hV,hL,hGM,hGK,hEM,hEK,hc,hQ,ht⟩ := hp
  unfold materialLoss
  positivity

theorem guard_loss_nonnegative (p : Parameters) (s : State) (hc : 0 ≤ p.damping)
    (ha : 0 ≤ s.gAB) (hb : 0 ≤ s.gBA) : 0 ≤ guardLoss p s := by
  unfold guardLoss
  positivity

theorem passive_unforced_energy_rate (p : Parameters) (s : State) (hp : Physical p)
    (ha : p.gain = 0) (hb : p.saturation = 0) (hgA : 0 ≤ s.gAB) (hgB : 0 ≤ s.gBA) :
    energyBalance p 0 s ≤ 0 := by
  have hm := material_loss_nonnegative p s hp
  have hg := guard_loss_nonnegative p s hp.2.2.2.2.2.2.2.2.1 hgA hgB
  simp only [energyBalance, ha, hb, zero_mul, sub_self, zero_add]
  linarith

theorem active_energy_can_increase :
    energyBalance protocol 0 ⟨0,1/10000,0,0,-11/20,7/20,1/2,1/2⟩ = 1/5000000000 := by
  norm_num [energyBalance, protocol, materialLoss, guardLoss, stress]

theorem participant_difference_closes (p : Parameters) (F : ℝ) (s : State)
    (ha : p.weightAB = 1) (hb : p.weightBA = 1) :
    (rhs p F s).xB-(rhs p F s).xA = differenceRate p (s.xB-s.xA) (s.gAB+s.gBA) := by
  simp only [rhs, differenceRate, ha, hb]
  ring

theorem directional_guard_sum (p : Parameters) (F : ℝ) (s : State) :
    (rhs p F s).gAB+(rhs p F s).gBA =
    (sigmoid (targetAB p s)+sigmoid (targetBA p s)-(s.gAB+s.gBA))/p.tau := by
  simp only [rhs, guardRate]
  ring

theorem shared_directional_sum_equal (p : Parameters) (F : ℝ) (s : State) :
    sharedGuardRate p s s.gAB+sharedGuardRate p s s.gBA =
    (rhs p F s).gAB+(rhs p F s).gBA := by
  simp only [rhs, guardRate, sharedGuardRate]
  ring

theorem zero_damper_recovers_old_acceleration (p : Parameters) (F : ℝ) (s : State) :
    (rhs {p with damping := 0} F s).v =
    (F+(p.gain-p.saturation*s.q^2)*s.v-p.stiffness*s.q-p.volume/p.length*stress p s)/p.mass := by
  simp [rhs, stress]

theorem display_shear_reversible (q length x y : ℝ) :
    displayShear (-q) length (displayShear q length x y).1 (displayShear q length x y).2 = (x,y) := by
  ext <;> dsimp [displayShear] <;> ring

theorem display_preserves_height (q length x y : ℝ) : (displayShear q length x y).2 = y := rfl

theorem capped_source_bound (cap k A : ℝ) (hc : 0 ≤ cap) :
    |cappedSource cap k A| ≤ cap := by
  rw [cappedSource, abs_mul, abs_of_nonneg hc]
  exact mul_le_of_le_one_right hc (le_of_lt (Real.abs_tanh_lt_one _))

theorem capped_source_sign_reverse (cap k A : ℝ) :
    cappedSource cap k (-A) = -cappedSource cap k A := by
  unfold cappedSource
  rw [show k*(-A)/cap = -(k*A/cap) by ring, Real.tanh_neg]
  ring

theorem pair_off_below_centre (k sign height amplitude own partner : ℝ) (hh : height ≤ 0) :
    pairExchange k sign height amplitude own partner = 0 := by
  simp [pairExchange, max_eq_right hh]

theorem paired_exchange_cancels (k sign height amplitude x y : ℝ) :
    pairExchange k sign height amplitude x y + pairExchange k sign height amplitude y x = 0 := by
  unfold pairExchange
  rw [show (x-y)/amplitude = -((y-x)/amplitude) by ring, Real.tanh_neg]
  ring

theorem response_exactly_off (excess epsilon : ℝ) (hq : excess ≤ 0) : exactOff excess epsilon = 0 := by
  simp [exactOff, hq]

theorem sign_reversal_same_force (coefficient gradient threshold epsilon : ℝ) :
    gradientForce coefficient (-gradient) threshold epsilon = gradientForce coefficient gradient threshold epsilon := by
  simp [gradientForce]

end ActiveHug.Verified
