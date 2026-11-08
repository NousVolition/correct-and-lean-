import CWWork

namespace HugV3.Source.CW
noncomputable section
open scoped BigOperators
set_option maxHeartbeats 500000

private theorem resolve_sum (u v : Vector) :
    resolve (fun x i => u x i+v x i)=(fun x i => resolve u x i+resolve v x i) := by
  have addMix (p q : Vector) : mix 1 1 p q=(fun x i => p x i+q x i) := by
    funext x i; simp only [mix,one_mul]
  calc
    _ = resolve (mix 1 1 u v) := congrArg resolve (addMix u v).symm
    _ = mix 1 1 (resolve u) (resolve v) := resolve_mix 1 1 u v
    _ = _ := addMix _ _

theorem accepted_velocity_decomposes (G : Geometry) (s d : State) (t : ℝ)
    (accepted : rhs G t s=some d) (x : Grid) (i : Axis) :
    velocity d x i = courier (velocity s) x i+weaver s (velocity s) x i+
      resolve (otherForces G s) x i := by
  unfold rhs at accepted
  obtain ⟨rs,_,hr⟩ := Option.bind_eq_some_iff.mp accepted
  split at hr
  · rw [← Option.some.inj hr]
    have eqn : velocity (rhsFromRecords G t s rs) x i =
        resolve (fun y j => rawCourier (velocity s) (velocity s) y j+
          rawWeaver s (velocity s) y j+
          divergence (fun z k => fullStress G s z j k) y+forcing s y j) x i := by
      simp only [velocity,rhsFromRecords,dite_eq_left i.isLt]
      rfl
    rw [eqn]
    have regroup : (fun y j => rawCourier (velocity s) (velocity s) y j+
          rawWeaver s (velocity s) y j+divergence (fun z k => fullStress G s z j k) y+forcing s y j) =
        (fun y j => (rawCourier (velocity s) (velocity s) y j+rawWeaver s (velocity s) y j)+
                    otherForces G s y j) := by
      funext y j; unfold otherForces; ring
    rw [regroup,resolve_sum,resolve_sum]
    rfl
  · cases hr

private theorem courier_polynomial (e : ℝ) (u v : Vector) (x : Grid) (i : Axis) :
    courier (mix 1 e u v) x i = courier u x i+
      e*(transport v u x i+transport u v x i)+e^2*courier v x i := by
  simp only [courier,transport_mix_left,transport_mix_right,mix]
  ring

private theorem courier_derivative (u v : Vector) (x : Grid) (i : Axis) :
    HasDerivAt (fun e : ℝ => courier (mix 1 e u v) x i)
      (transport v u x i+transport u v x i) 0 := by
  simp_rw [courier_polynomial]
  have linearTerm := (hasDerivAt_id (0:ℝ)).mul_const (transport v u x i+transport u v x i)
  have quadraticTerm := ((hasDerivAt_id (0:ℝ)).pow 2).mul_const (courier v x i)
  convert ((hasDerivAt_const (0:ℝ) (courier u x i)).add linearTerm).add quadraticTerm using 1 <;>
    first | rfl | norm_num

private theorem weaver_derivative (s : State) (u v : Vector) (x : Grid) (i : Axis) :
    HasDerivAt (fun e : ℝ => weaver s (mix 1 e u v) x i) (weaver s v x i) 0 := by
  simp only [weaver_mix,mix,one_mul]
  convert (hasDerivAt_const (0:ℝ) (weaver s u x i)).add
    ((hasDerivAt_id (0:ℝ)).mul_const (weaver s v x i)) using 1 <;>
    first | rfl | norm_num

theorem bracket_as_velocity_derivative (s : State) (u : Vector) (x : Grid) (i : Axis) :
    HasDerivAt (fun e : ℝ => courier (mix 1 e u (weaver s u)) x i -
      weaver s (mix 1 e u (courier u)) x i) (directionalBracket s u x i) 0 :=
  (courier_derivative u (weaver s u) x i).sub (weaver_derivative s u (courier u) x i)

private theorem velocity_reversed (s : State) : velocity (reversed s)= -velocity s := by
  funext x i; simp [velocity,reversed,i.isLt]

private theorem same_weaver (s : State) (v : Vector) : weaver (reversed s) v=weaver s v := by
  rfl

private theorem minus_velocity (u : Vector) : mix (-1) 0 u u= -u := by
  funext x i; simp [mix]

private theorem minus_grad (f : Scalar) (x : Grid) (j : Axis) :
    grad (fun y => -f y) x j= -grad f x j := by
  simpa only [neg_one_mul,zero_mul,add_zero] using grad_mix (-1) 0 f f x j

private theorem heat_reversed (s : State) (x : Grid) : viscousHeat (reversed s) x=viscousHeat s x := by
  have strain (i j : Axis) :
      symm (velocityGradient (reversed s) x) i j= -symm (velocityGradient s x) i j := by
    simp only [symm,velocityGradient,velocity_reversed,Pi.neg_apply,minus_grad]
    ring
  have viscosity_agrees : viscosity (reversed s) x=viscosity s x := rfl
  simp only [viscousHeat,strain,even_two.neg_pow,viscosity_agrees]

theorem reversed_native_roles (s : State) :
    courier (velocity (reversed s))=courier (velocity s) ∧
    weaver (reversed s) (velocity (reversed s))= -weaver s (velocity s) ∧
    (∀ x, viscousHeat (reversed s) x=viscousHeat s x) := by
  rw [velocity_reversed,← minus_velocity (velocity s)]
  refine ⟨?_,?_,heat_reversed s⟩
  · funext x i
    simp only [courier,transport_mix_left,transport_mix_right,mix,zero_mul,neg_one_mul,add_zero,neg_neg]
  · rw [same_weaver,weaver_mix,minus_velocity]

theorem pairing_reverses_and_heat_agrees (s : State) :
    pairing (reversed s)= -pairing s ∧ heat (reversed s)=heat s := by
  obtain ⟨hc,hw,hh⟩ := reversed_native_roles s
  constructor
  · simp only [pairing,hc,hw,inner,dot,Pi.neg_apply,mul_neg,Finset.sum_neg_distrib,neg_div]
  · simp only [heat,hh]

theorem no_common_coefficient_at_nonzero_pair (s : State) (nonzero : pairing s≠0) :
    ¬ ∃ k : ℝ, pairing s=k*heat s ∧ pairing (reversed s)=k*heat (reversed s) := by
  rintro ⟨k,hs,hr⟩
  obtain ⟨hp,hh⟩ := pairing_reverses_and_heat_agrees s
  rw [hp,hh] at hr
  exact nonzero (by linarith)

theorem dot_pair_is_symmetric (u v : Vector) : inner u v=inner v u := by
  simp only [inner,dot,mul_comm]

theorem coefficient_at_single_state (s : State) (positive : 0<heat s) (k : ℝ) :
    pairing s=k*heat s ↔ k=pairing s/heat s := by
  rw [eq_div_iff positive.ne']
  exact eq_comm

theorem initial_state_does_not_identify_coefficient (G : Geometry) :
    pairing (initial G)=0 ∧ heat (initial G)=0 ∧
    ∀ k : ℝ, pairing (initial G)=k*heat (initial G) := by
  have velZero : velocity (initial G)=0 := by
    funext x i
    have h : (⟨i.val, by omega⟩ : Fin 5)≠4 := by intro he; have := congrArg Fin.val he; simp at this; omega
    simp [initial,velocity,h]
  have mixZero : mix 0 0 (0 : Vector) 0=0 := by funext x i; simp [mix]
  have cZero : courier 0=0 := by
    unfold courier
    calc
      transport 0 0 = transport (mix 0 0 0 0) 0 := by rw [mixZero]
      _ = 0 := by rw [transport_mix_left]; funext x i; simp [mix]
  have pZero : pairing (initial G)=0 := by simp [pairing,velZero,cZero,inner,dot]
  have gZero (x : Grid) (j : Axis) : grad (fun _ => (0:ℝ)) x j=0 := by
    simpa using grad_mix 0 0 (fun _ => 0) (fun _ => 0) x j
  have hZero : heat (initial G)=0 := by
    simp [heat,viscousHeat,symm,velocityGradient,velZero,gZero]
  simp [pZero,hZero]

theorem same_accepted_rate_allows_any_wizard_entry (G : Geometry) (s d : State) (t k : ℝ)
    (accepted : rhs G t s=some d) :
    ∃ M : CommutatorMatrix, M.CentralHearth ∧
    M.κ Wizard.courier.toFin Wizard.weaver.toFin=k ∧
    M.κ Wizard.weaver.toFin Wizard.courier.toFin= -k ∧ rhs G t s=some d := by
  refine ⟨pairMatrix k,?_,?_,?_,accepted⟩
  · intro j
    simp [pairMatrix,Wizard.toFin]
  · simp [pairMatrix,Wizard.toFin]
  · simp [pairMatrix,Wizard.toFin]

end
end HugV3.Source.CW
