import HRQuadratic
import CWBalance

namespace HugV3.Source.HearthReadout
noncomputable section
open CW
open scoped BigOperators
set_option maxHeartbeats 650000

theorem accepted_work_and_heat_ledgers (G : Geometry) (s d : State) (t : ℝ) (h : rhs G t s=some d) :
    d.ledger 1=CW.inner (velocity s) (forcing s) ∧
    d.ledger 3=heat s-(∑ x, extraction G s x)/4096+(∑ x, releaseGrid G s x)/4096 := by
  unfold rhs at h
  obtain ⟨rs,_,hr⟩ := Option.bind_eq_some_iff.mp h
  split at hr
  · rw [← Option.some.inj hr]
    refine ⟨rfl,?_⟩
    change (∑ x, (viscousHeat s x-extraction G s x+releaseGrid G s x))/4096=_
    simp only [heat,Finset.sum_add_distrib,Finset.sum_sub_distrib]
    ring
  · cases hr

theorem ordered_heat_derivative (s : State) :
    HasDerivAt (fun e : ℝ => heat (atVelocity s (mix 1 e (velocity s) (ordered s)))) (heatReading s) 0 := by
  simp_rw [native_heat_polynomial]
  exact quadratic_derivative _ _ _

theorem ordered_kinetic_derivative (s : State) :
    HasDerivAt (fun e : ℝ => kinetic (mix 1 e (velocity s) (ordered s))) (workReading s) 0 := by
  let u := velocity s
  let v := ordered s
  have poly (e : ℝ) : kinetic (mix 1 e u v)=kinetic u+e*CW.inner u v+e^2*kinetic v := by
    simp only [kinetic,inner_mix_left,inner_mix_right]
    rw [dot_pair_is_symmetric v u]
    ring
  change HasDerivAt (fun e : ℝ => kinetic (mix 1 e u v)) (CW.inner u v) 0
  simp_rw [poly]
  exact quadratic_derivative _ _ _

private theorem neg_mix (v : Vector) : mix (-1) 0 v v= -v := by
  funext x i; simp [mix]

theorem changing_order (s : State) :
    2*thermalForm s (velocity s) (-ordered s)= -heatReading s ∧
    CW.inner (velocity s) (-ordered s)= -workReading s ∧
    heat (atVelocity s (-ordered s))=bracketHeat s := by
  rw [← neg_mix (ordered s),native_heat_form]
  simp only [thermal_mix_right,thermal_mix_left,inner_mix_right,neg_one_mul,zero_mul,add_zero,
    neg_neg,neg_zero,heatReading,workReading,bracketHeat,mul_neg,true_and]

private theorem thermal_cauchy (s : State) (u v : Vector) :
    (thermalForm s u v)^2≤thermalForm s u u*thermalForm s v v := by
  let A := thermalForm s u u
  let Q := thermalForm s v v
  let r := thermalForm s u v
  have Apos : 0≤A := thermal_positive s u
  have Qpos : 0≤Q := thermal_positive s v
  have nonneg (a b : ℝ) : 0≤a^2*A+2*a*b*r+b^2*Q := by
    have h := thermal_positive s (mix a b u v)
    simp only [thermal_mix_left,thermal_mix_right,thermal_symm s v u] at h
    dsimp [A,Q,r]
    linarith only [h]
  change r^2≤A*Q
  by_contra! fail
  have gap : A*Q-r^2<0 := by linarith
  by_cases hQ : 0<Q
  · have bad := mul_neg_of_pos_of_neg hQ gap
    nlinarith only [nonneg Q (-r),bad]
  · by_cases hA : 0<A
    · have bad := mul_neg_of_pos_of_neg hA gap
      nlinarith only [nonneg (-r) A,bad]
    · have az : A=0 := le_antisymm (le_of_not_gt hA) Apos
      have qz : Q=0 := le_antisymm (le_of_not_gt hQ) Qpos
      have rp := nonneg 1 1
      have rn := nonneg 1 (-1)
      rw [az,qz] at rp rn fail
      have rz : r=0 := by nlinarith only [rp,rn]
      rw [rz] at fail
      norm_num at fail

theorem signed_heat_bound (s : State) : (heatReading s)^2≤4*heat s*bracketHeat s := by
  rw [original_heat_form]
  unfold heatReading bracketHeat
  nlinarith only [thermal_cauchy s (velocity s) (ordered s)]

theorem zero_heat_has_zero_signed_response (s : State) (h : heat s=0) : heatReading s=0 := by
  have bound := signed_heat_bound s
  rw [h] at bound
  nlinarith [sq_nonneg (heatReading s)]

private theorem retained_mix (a b : ℝ) {u v : Vector} (hu : retained u) (hv : retained v) :
    retained (mix a b u v) := by
  constructor
  · intro i x
    simp only [mix,filter_mix,hu.1,hv.1]
  · funext x i
    simpa only [hu.2,hv.2,mix] using project_mix a b u v x i

private theorem budgets (s : State) (v : Vector) (hv : retained v) :
    CW.inner v (weaver s v)= -thermalForm s v v ∧ CW.inner v (courier v)=0 := by
  have vel := substituted_velocity s v
  have budget := retained_velocity_work (atVelocity s v) (by rw [vel]; exact hv.1)
    (by rw [vel]; exact hv.2)
  rw [vel,native_heat_form] at budget
  exact budget

private theorem transport_variation (s : State) (u w : Vector) (hu : retained u) (hw : retained w) :
    CW.inner u (transport w u)+CW.inner u (transport u w)= -CW.inner w (courier u) := by
  have plus := (budgets s (mix 1 1 u w) (retained_mix 1 1 hu hw)).2
  have minus := (budgets s (mix 1 (-1) u w) (retained_mix 1 (-1) hu hw)).2
  simp only [courier,transport_mix_left,transport_mix_right,inner_mix_left,inner_mix_right] at plus minus
  have wc := (budgets s w hw).2
  unfold courier at wc ⊢
  linarith only [plus,minus,wc]

private theorem weaver_variation (s : State) (u v : Vector) (hu : retained u) (hv : retained v) :
    CW.inner u (weaver s v)+CW.inner v (weaver s u)= -2*thermalForm s u v := by
  have plus := (budgets s (mix 1 1 u v) (retained_mix 1 1 hu hv)).1
  simp only [weaver_mix,inner_mix_left,inner_mix_right,thermal_mix_left,thermal_mix_right,
    thermal_symm s v u] at plus
  linarith only [plus,(budgets s u hu).1,(budgets s v hv).1]

theorem work_is_heat_response_along_courier (s : State) (hu : retained (velocity s))
    (hc : retained (courier (velocity s))) (hw : retained (weaver s (velocity s))) :
    workReading s=2*thermalForm s (velocity s) (courier (velocity s)) := by
  let u := velocity s
  let c := courier u
  let w := weaver s u
  have b : ordered s=mix 1 1 (transport w u) (mix 1 (-1) (transport u w) (weaver s c)) := by
    funext x i; simp only [ordered,directionalBracket,mix,u,c,w]; ring
  change CW.inner u (ordered s)=2*thermalForm s u c
  rw [b,inner_mix_right,inner_mix_right]
  have tv := transport_variation s u w hu hw
  have wv := weaver_variation s u c hu hc
  have flip := dot_pair_is_symmetric w c
  change CW.inner u (transport w u)+CW.inner u (transport u w)= -CW.inner w c at tv
  linarith only [tv,wv,flip]

private theorem reversed_velocity (s : State) : velocity (reversed s)= -velocity s := by
  funext x i; simp [velocity,reversed,i.isLt]

private theorem reversed_bracket (s : State) : ordered (reversed s)=ordered s := by
  obtain ⟨hc,hw,_⟩ := reversed_native_roles s
  have sameWeaver (v : Vector) : weaver (reversed s) v=weaver s v := rfl
  funext x i
  simp only [ordered,directionalBracket]
  simp only [hw,hc]
  simp only [sameWeaver,reversed_velocity]
  rw [← neg_mix (velocity s),← neg_mix (weaver s (velocity s))]
  simp only [transport_mix_left,transport_mix_right,mix,zero_mul,neg_one_mul,add_zero,neg_neg]

theorem velocity_reversal (s : State) :
    ordered (reversed s)=ordered s ∧ heatReading (reversed s)= -heatReading s ∧
    workReading (reversed s)= -workReading s ∧ heat (reversed s)=heat s := by
  have form (u v : Vector) : thermalForm (reversed s) u v=thermalForm s u v := rfl
  refine ⟨reversed_bracket s,?_,?_,(pairing_reverses_and_heat_agrees s).2⟩
  · rw [heatReading,form,reversed_bracket,reversed_velocity,← neg_mix (velocity s),thermal_mix_left]
    simp [heatReading]
  · rw [workReading,reversed_bracket,reversed_velocity,← neg_mix (velocity s),inner_mix_left]
    simp [workReading]

theorem nonzero_signed_reading_excludes_shared_multiplier (s : State) (h : heatReading s≠0) :
    ¬ ∃ k : ℝ, heatReading s=k*heat s ∧ heatReading (reversed s)=k*heat (reversed s) := by
  rintro ⟨k,base,other⟩
  obtain ⟨_,sign,_,unchanged⟩ := velocity_reversal s
  rw [sign,unchanged] at other
  exact h (by linarith)

theorem encounter_multiplier_criterion {T : Type} (H L : T → ℝ) (a : T) (ha : H a≠0) :
    (∃ k : ℝ, ∀ t, L t=k*H t) ↔ ∀ t, L t*H a=L a*H t := by
  constructor
  · rintro ⟨k,h⟩ t
    rw [h t,h a]; ring
  · intro h
    refine ⟨L a/H a,fun t => ?_⟩
    field_simp [ha]
    nlinarith only [h t]

end
end HugV3.Source.HearthReadout
