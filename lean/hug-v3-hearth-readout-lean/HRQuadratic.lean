import HRDefinitions
import CWSpectral

namespace HugV3.Source.HearthReadout
noncomputable section
open CW
open scoped BigOperators
set_option maxHeartbeats 600000

theorem substituted_velocity (s : State) (v : Vector) : velocity (atVelocity s v)=v := by
  funext x i
  simp [velocity,atVelocity,i.isLt]

theorem native_heat_form (s : State) (v : Vector) :
    heat (atVelocity s v)=thermalForm s v v := by
  have visc (x : Grid) : viscosity (atVelocity s v) x=viscosity s x := rfl
  have gradient (x : Grid) : velocityGradient (atVelocity s v) x=gridGradient v x := by
    change gridGradient (velocity (atVelocity s v)) x=gridGradient v x
    rw [substituted_velocity]
  simp only [heat,thermalForm,viscousHeat,visc,gradient,strainAt,pow_two]

theorem original_heat_form (s : State) :
    heat s=thermalForm s (velocity s) (velocity s) := by
  simp only [heat,thermalForm,viscousHeat,strainAt,pow_two]
  rfl

theorem thermal_symm (s : State) (u v : Vector) : thermalForm s u v=thermalForm s v u := by
  simp only [thermalForm,mul_comm]

private theorem strain_mix (a b : ℝ) (u v : Vector) (x : Grid) (i j : Axis) :
    strainAt (mix a b u v) x i j=a*strainAt u x i j+b*strainAt v x i j := by
  simp only [strainAt,symm,gridGradient,mix,grad_mix]
  ring

theorem thermal_mix_left (a b : ℝ) (s : State) (u v w : Vector) :
    thermalForm s (mix a b u v) w=a*thermalForm s u w+b*thermalForm s v w := by
  have term (x : Grid) (i j : Axis) : strainAt (mix a b u v) x i j*strainAt w x i j =
      a*(strainAt u x i j*strainAt w x i j)+b*(strainAt v x i j*strainAt w x i j) := by
    rw [strain_mix]; ring
  have row (x : Grid) (p q : ℝ) :
      2*viscosity s x*(a*p+b*q)=a*(2*viscosity s x*p)+b*(2*viscosity s x*q) := by ring
  simp only [thermalForm,term,Finset.sum_add_distrib,← Finset.mul_sum,row]
  ring

theorem thermal_mix_right (a b : ℝ) (s : State) (u v w : Vector) :
    thermalForm s w (mix a b u v)=a*thermalForm s w u+b*thermalForm s w v := by
  rw [thermal_symm s w _,thermal_mix_left,thermal_symm s u w,thermal_symm s v w]

theorem native_heat_polynomial (s : State) (u v : Vector) (e : ℝ) :
    heat (atVelocity s (mix 1 e u v))=thermalForm s u u+
      e*(2*thermalForm s u v)+e^2*thermalForm s v v := by
  rw [native_heat_form,thermal_mix_left,thermal_mix_right,thermal_mix_right,thermal_symm s v u]
  ring

theorem inner_mix_left (a b : ℝ) (u v w : Vector) :
    inner (mix a b u v) w=a*inner u w+b*inner v w := by
  have term (x : Grid) (i : Axis) : mix a b u v x i*w x i =
      a*(u x i*w x i)+b*(v x i*w x i) := by unfold mix; ring
  simp only [CW.inner,dot,term,Finset.sum_add_distrib,← Finset.mul_sum]
  ring

theorem inner_mix_right (a b : ℝ) (u v w : Vector) :
    inner w (mix a b u v)=a*inner w u+b*inner w v := by
  have symm' (p q : Vector) : CW.inner p q=CW.inner q p := by simp only [CW.inner,dot,mul_comm]
  rw [symm' w _,inner_mix_left,symm' u w,symm' v w]

theorem quadratic_derivative (A L Q : ℝ) :
    HasDerivAt (fun e : ℝ => A+e*L+e^2*Q) L 0 := by
  convert ((hasDerivAt_const (0:ℝ) A).add ((hasDerivAt_id (0:ℝ)).mul_const L)).add
    (((hasDerivAt_id (0:ℝ)).pow 2).mul_const Q) using 1 <;> first | rfl | norm_num

theorem thermal_positive (s : State) (v : Vector) : 0≤thermalForm s v v := by
  unfold thermalForm
  apply div_nonneg _ (by norm_num)
  apply Finset.sum_nonneg
  intro x _
  have pos : 0<viscosity s x := by unfold viscosity; positivity
  exact mul_nonneg (by positivity) (Finset.sum_nonneg (fun i _ =>
    Finset.sum_nonneg (fun j _ => mul_self_nonneg _)))

end
end HugV3.Source.HearthReadout
