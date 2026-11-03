import ScalarSubsystems
import InfluenceSubsystem
import MeaningSubsystem
import ASProofs

open Set MeasureTheory
open scoped NNReal
namespace SocialAS.Existence
noncomputable section

def aField (p : Parameters) (i : ℝ → Inputs) (t : ℝ) (_ : ℝ) : ℝ :=
  accumulatedDrift p.gamma (i t).utility p.baseline
def loadF (p : Parameters) (i : ℝ → Inputs) (t L : ℝ) : ℝ :=
  loadDrift p.alpha (i t).adverseForward (i t).exposureForward (i t).clearForward L
def loadR (p : Parameters) (i : ℝ → Inputs) (t L : ℝ) : ℝ :=
  loadDrift p.alpha (i t).adverseReverse (i t).exposureReverse (i t).clearReverse L
def chi (p : Parameters) (L : ℝ → ℝ) (t : ℝ) := effect p.chiMax (L t) p.loadStar
def theta (p : Parameters) (L : ℝ → ℝ) (t : ℝ) := effect p.thetaMax (L t) p.loadStar
def rateF (p : Parameters) (L : ℝ → ℝ) (S : ℝ → Pair) (t : ℝ) :=
  meaningRate p.wClaySmoke (chi p L t) (S t 0) p.meaningStar
def rateR (p : Parameters) (L : ℝ → ℝ) (S : ℝ → Pair) (t : ℝ) :=
  meaningRate p.wSmokeClay (chi p L t) (S t 1) p.meaningStar

def UniqueSol {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E] [CompleteSpace E]
    (F : ℝ → E → E) (a b : ℝ) (initial : E) (x : ℝ → E) : Prop :=
  Volterra.Solution F a b initial x ∧
    ∀ other, Volterra.Solution F a b initial other → EqOn other x (Icc a b)

structure Stages (p : Parameters) (i : ℝ → Inputs) (a b : ℝ) (initial : State) where
  A : ℝ → ℝ
  LF : ℝ → ℝ
  LR : ℝ → ℝ
  S : ℝ → Pair
  Z : ℝ → Pair
  hA : UniqueSol (aField p i) a b (initial 0) A
  hLF : UniqueSol (loadF p i) a b (initial 3) LF
  hLR : UniqueSol (loadR p i) a b (initial 4) LR
  hS : UniqueSol (sField p A (chi p LF) (chi p LR)) a b ![initial 1,initial 2] S
  hZ : UniqueSol (zField p i (rateF p LF S) (rateR p LR S) (theta p LF) (theta p LR))
    a b ![initial 5,initial 6] Z

theorem effect_continuousOn {a b gain scale : ℝ} {L : ℝ → ℝ}
    (hL : ContinuousOn L (Icc a b)) (hn : ∀ t ∈ Icc a b, 0 ≤ L t) (hs : 0 < scale) :
    ContinuousOn (fun t => effect gain (L t) scale) (Icc a b) := by
  unfold effect saturation
  apply ContinuousOn.mul continuousOn_const
  exact hL.div (hL.add continuousOn_const) (fun t ht => ne_of_gt (add_pos_of_nonneg_of_pos (hn t ht) hs))

theorem rate_continuousOn {a b w scale : ℝ} {c s : ℝ → ℝ}
    (hc : ContinuousOn c (Icc a b)) (hS : ContinuousOn s (Icc a b)) (hs : 0 < scale) :
    ContinuousOn (fun t => meaningRate w (c t) (s t) scale) (Icc a b) := by
  have hp : ContinuousOn (fun t => pos (s t)) (Icc a b) := by unfold pos; fun_prop
  unfold meaningRate
  apply ContinuousOn.div
  · exact ((continuousOn_const.sub hc).mul continuousOn_const).mul hp
  · exact continuousOn_const.add hp
  · intro t ht
    exact ne_of_gt (add_pos_of_pos_of_nonneg hs (le_max_right _ _))

theorem construct_stages (p : Parameters) (i : ℝ → Inputs) (a b : ℝ) (initial : State)
    (hp : ParametersOK p) (hi : ∀ t ∈ Icc a b, InputsOK (i t))
    (hr : SocialAS.Open.RegularInputs i a b) (hab : a ≤ b) (hx : StateOK initial) :
    Nonempty (Stages p i a b initial) := by
  rcases hp with ⟨hgamma,hkappa,hd,hwR,hwF,hKS,hKC,hKsum,hthreshold,hrstar,
    hg,hp0,heta,hbeta,halpha,hls,hms,hchi,htheta,himF,himR,hrefS,hrefC⟩
  rcases hr with ⟨hu,heF,heR,hcF,hcR,hzS,hzC⟩
  obtain ⟨MF,hmF⟩ := hcF.bound
  obtain ⟨MR,hmR⟩ := hcR.bound
  have hAf : IntervalIntegrable (fun t => accumulatedDrift p.gamma (i t).utility p.baseline) volume a b :=
    ((hu.intervalIntegrable hab).sub intervalIntegrable_const).const_mul p.gamma
  obtain ⟨A,hA⟩ := linear_exists_unique hab
    (fun t => accumulatedDrift p.gamma (i t).utility p.baseline) (fun _ => 0) (initial 0)
    hAf intervalIntegrable_const 0 (by simp)
  have hA' : UniqueSol (aField p i) a b (initial 0) A := by
    change UniqueSol (fun t (_ : ℝ) => accumulatedDrift p.gamma (i t).utility p.baseline) a b (initial 0) A
    simpa only [UniqueSol,zero_mul,sub_zero] using hA
  have heFi : IntervalIntegrable (fun t => p.alpha*indicator (i t).adverseForward*(i t).exposureForward) volume a b := by
    simpa only [mul_assoc] using (heF.intervalIntegrable hab).const_mul p.alpha
  have heRi : IntervalIntegrable (fun t => p.alpha*indicator (i t).adverseReverse*(i t).exposureReverse) volume a b := by
    simpa only [mul_assoc] using (heR.intervalIntegrable hab).const_mul p.alpha
  obtain ⟨LF,hLF⟩ := linear_exists_unique hab _ _ (initial 3) heFi (hcF.intervalIntegrable hab) MF hmF
  obtain ⟨LR,hLR⟩ := linear_exists_unique hab _ _ (initial 4) heRi (hcR.intervalIntegrable hab) MR hmR
  have hLF' : UniqueSol (loadF p i) a b (initial 3) LF := hLF
  have hLR' : UniqueSol (loadR p i) a b (initial 4) LR := hLR
  have hFn : ∀ t ∈ Icc a b, 0 ≤ LF t := by
    apply linear_solution_nonnegative hab hLF.1 hx.1
    · intro t ht
      have hi0 : 0 ≤ indicator (i t).adverseForward := by cases (i t).adverseForward <;> norm_num [indicator]
      exact mul_nonneg (mul_nonneg halpha hi0) (hi t ht).1
    · intro t ht
      exact (hi t ht).2.2.1
  have hRn : ∀ t ∈ Icc a b, 0 ≤ LR t := by
    apply linear_solution_nonnegative hab hLR.1 hx.2.1
    · intro t ht
      have hi0 : 0 ≤ indicator (i t).adverseReverse := by cases (i t).adverseReverse <;> norm_num [indicator]
      exact mul_nonneg (mul_nonneg halpha hi0) (hi t ht).2.1
    · intro t ht
      exact (hi t ht).2.2.2.1
  have hCF : ContinuousOn (chi p LF) (Icc a b) := effect_continuousOn hLF.1.1 hFn hls
  have hCR : ContinuousOn (chi p LR) (Icc a b) := effect_continuousOn hLR.1.1 hRn hls
  have hTF : ContinuousOn (theta p LF) (Icc a b) := effect_continuousOn hLF.1.1 hFn hls
  have hTR : ContinuousOn (theta p LR) (Icc a b) := effect_continuousOn hLR.1.1 hRn hls
  have hbCF : ∀ t ∈ Icc a b, UnitInterval (chi p LF t) :=
    fun t ht => SocialAS.Verified.effect_bounds _ _ _ hchi (hFn t ht) hls
  have hbCR : ∀ t ∈ Icc a b, UnitInterval (chi p LR t) :=
    fun t ht => SocialAS.Verified.effect_bounds _ _ _ hchi (hRn t ht) hls
  have hbTF : ∀ t ∈ Icc a b, UnitInterval (theta p LF t) :=
    fun t ht => SocialAS.Verified.effect_bounds _ _ _ htheta (hFn t ht) hls
  have hbTR : ∀ t ∈ Icc a b, UnitInterval (theta p LR t) :=
    fun t ht => SocialAS.Verified.effect_bounds _ _ _ htheta (hRn t ht) hls
  obtain ⟨S,hS⟩ := sfield_exists_unique hab p A (chi p LF) (chi p LR) ![initial 1,initial 2]
    hA'.1.1 hCF hCR hbCF hbCR
  have hSc0 : ContinuousOn (fun t => S t 0) (Icc a b) := (continuous_apply 0).comp_continuousOn hS.1.1
  have hSc1 : ContinuousOn (fun t => S t 1) (Icc a b) := (continuous_apply 1).comp_continuousOn hS.1.1
  have hkF : ContinuousOn (rateF p LF S) (Icc a b) := rate_continuousOn hCF hSc0 hms
  have hkR : ContinuousOn (rateR p LR S) (Icc a b) := rate_continuousOn hCR hSc1 hms
  have hbkF : ∀ t ∈ Icc a b, 0 ≤ rateF p LF S t ∧ rateF p LF S t ≤ p.wClaySmoke :=
    fun t ht => SocialAS.Verified.meaning_rate_bounds _ _ _ _ hwF (hbCF t ht) hms
  have hbkR : ∀ t ∈ Icc a b, 0 ≤ rateR p LR S t ∧ rateR p LR S t ≤ p.wSmokeClay :=
    fun t ht => SocialAS.Verified.meaning_rate_bounds _ _ _ _ hwR (hbCR t ht) hms
  obtain ⟨Z,hZ⟩ := zfield_exists_unique hab p i (rateF p LF S) (rateR p LR S)
    (theta p LF) (theta p LR) ![initial 5,initial 6] ⟨p.wClaySmoke,hwF⟩ ⟨p.wSmokeClay,hwR⟩
    hkF hkR hTF hTR hbkF hbkR hbTF hbTR hzS hzC
  exact ⟨⟨A,LF,LR,S,Z,hA',hLF',hLR',hS,hZ⟩⟩

end
end SocialAS.Existence
