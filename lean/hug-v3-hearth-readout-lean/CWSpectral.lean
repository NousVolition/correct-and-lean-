import CWDefinitions

namespace HugV3.Source.CW
noncomputable section
open scoped BigOperators
attribute [local instance] Classical.propDecidable
set_option maxHeartbeats 500000

private theorem hat_mix (a b : ℝ) (f g : Scalar) (k : Grid) :
    hat (fun x => a*f x+b*g x) k = (a:ℂ)*hat f k+(b:ℂ)*hat g k := by
  simp only [hat, Complex.ofReal_add, Complex.ofReal_mul, add_mul, mul_assoc,
    Finset.sum_add_distrib, ← Finset.mul_sum]

private theorem real_mix (a b : ℝ) (F G : Grid → ℂ) (x : Grid) :
    realGrid (fun k => (a:ℂ)*F k+(b:ℂ)*G k) x = a*realGrid F x+b*realGrid G x := by
  simp only [realGrid, add_mul, mul_assoc, Finset.sum_add_distrib, ← Finset.mul_sum,
    add_div, mul_div_assoc, Complex.add_re, Complex.mul_re, Complex.ofReal_re,
    Complex.ofReal_im, zero_mul, sub_zero]

theorem grad_mix (a b : ℝ) (f g : Scalar) (x : Grid) (j : Axis) :
    grad (fun y => a*f y+b*g y) x j=a*grad f x j+b*grad g x j := by
  let F (k : Grid) := Complex.I*(wave k j : ℂ)*hat f k
  let G (k : Grid) := Complex.I*(wave k j : ℂ)*hat g k
  change realGrid _ x=a*realGrid F x+b*realGrid G x
  rw [← real_mix]
  congr 1
  funext k
  rw [hat_mix]
  dsimp [F,G]
  ring

theorem filter_mix (a b : ℝ) (f g : Scalar) (x : Grid) :
    filt (fun y => a*f y+b*g y) x = a*filt f x+b*filt g x := by
  unfold filt
  rw [← real_mix]
  congr 1
  funext k
  by_cases kept : masked k <;> simp [kept,hat_mix]

private def mode (v : Vector) (k : Grid) (i : Axis) : ℂ :=
  if masked k then hat (fun z => v z i) k else 0
private def waveDot (v : Vector) (k : Grid) : ℂ :=
  ∑ i, (wave k i : ℂ)*mode v k i
private def projectedMode (v : Vector) (k : Grid) (i : Axis) : ℂ :=
  mode v k i - (wave k i : ℂ)*waveDot v k/((if sqnorm (wave k)=0 then 1 else sqnorm (wave k) : ℝ) : ℂ)

private theorem mode_mix (a b : ℝ) (u v : Vector) (k : Grid) (i : Axis) :
    mode (mix a b u v) k i=(a:ℂ)*mode u k i+(b:ℂ)*mode v k i := by
  by_cases h : masked k <;> simp [mode,h,mix,hat_mix]

private theorem waveDot_mix (a b : ℝ) (u v : Vector) (k : Grid) :
    waveDot (mix a b u v) k=(a:ℂ)*waveDot u k+(b:ℂ)*waveDot v k := by
  have term (i : Axis) : (wave k i : ℂ)*mode (mix a b u v) k i =
      (a:ℂ)*((wave k i : ℂ)*mode u k i)+(b:ℂ)*((wave k i : ℂ)*mode v k i) := by
    rw [mode_mix]; ring
  simp only [waveDot, term, Finset.sum_add_distrib, ← Finset.mul_sum]

theorem project_mix (a b : ℝ) (u v : Vector) (x : Grid) (i : Axis) :
    project (mix a b u v) x i=a*project u x i+b*project v x i := by
  change realGrid (fun k => projectedMode (mix a b u v) k i) x =
    a*realGrid (fun k => projectedMode u k i) x+b*realGrid (fun k => projectedMode v k i) x
  rw [← real_mix]
  congr 1
  funext k
  simp only [projectedMode,mode_mix,waveDot_mix]
  ring

theorem resolve_mix (a b : ℝ) (u v : Vector) :
    resolve (mix a b u v)=mix a b (resolve u) (resolve v) := by
  funext x i
  simp only [resolve,mix,project_mix,filter_mix]

private theorem gradient_mix (a b : ℝ) (u v : Vector) (x : Grid) (i j : Axis) :
    gridGradient (mix a b u v) x i j =
      a*gridGradient u x i j+b*gridGradient v x i j := grad_mix .. 

private theorem strain_mix (a b : ℝ) (u v : Vector) (x : Grid) (i j : Axis) :
    symm (gridGradient (mix a b u v) x) i j =
      a*symm (gridGradient u x) i j+b*symm (gridGradient v x) i j := by
  simp only [symm,gradient_mix]
  ring

private theorem curl_mix (a b : ℝ) (u v : Vector) (x : Grid) (i : Axis) :
    curl (mix a b u v) x i=a*curl u x i+b*curl v x i := by
  fin_cases i <;> simp [curl,gradient_mix] <;> ring

theorem transport_mix_left (a b : ℝ) (u v w : Vector) :
    transport (mix a b u v) w=mix a b (transport u w) (transport v w) := by
  unfold transport
  rw [← resolve_mix]
  congr 1
  funext x i
  fin_cases i <;> simp [rawCourier,cross,mix] <;> ring

theorem transport_mix_right (a b : ℝ) (u v w : Vector) :
    transport w (mix a b u v)=mix a b (transport w u) (transport w v) := by
  unfold transport
  rw [← resolve_mix]
  congr 1
  funext x i
  fin_cases i <;> simp [rawCourier,cross,curl_mix,mix] <;> ring

theorem weaver_mix (a b : ℝ) (s : State) (u v : Vector) :
    weaver s (mix a b u v)=mix a b (weaver s u) (weaver s v) := by
  unfold weaver
  rw [← resolve_mix]
  congr 1
  funext x i
  have stress (j : Axis) : (fun y => 2*viscosity s y*symm (gridGradient (mix a b u v) y) i j) =
      (fun y => a*(2*viscosity s y*symm (gridGradient u y) i j)+
                b*(2*viscosity s y*symm (gridGradient v y) i j)) := by
    funext y; rw [strain_mix]; ring
  simp only [rawWeaver,mix,divergence,stress,grad_mix,Finset.sum_add_distrib,← Finset.mul_sum]

end
end HugV3.Source.CW
