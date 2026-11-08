import AppleBandDefinitions

namespace HugV3.Source.AppleBand
noncomputable section
open scoped BigOperators NNReal

def gridVelocity (u : Vector) (z : Vec) : Vec :=
  fun i => ∑ x, (∏ j, mechanical1D (z j) (x j))*u x i

/-- An observation of the given trace. Each segment uses its own actual full-state velocity. -/
def MaterialFlowAcross (tr : Trace) (R : ℝ≥0) (φ : Vec × ℝ → Vec) : Prop :=
  ContinuousOn φ (Metric.closedBall 0 (R:ℝ) ×ˢ Set.Icc (time 0) (time 5)) ∧
  (∀ z ∈ Metric.closedBall 0 (R:ℝ), φ (z,time 0)=z) ∧
  (∀ k<5, ∀ z ∈ Metric.closedBall 0 (R:ℝ), ∀ t∈Set.Icc (time k) (time (k+1)),
    HasDerivWithinAt (fun τ => φ (z,τ))
      (materialVelocity (tr.path k t).state (φ (z,t))) (Set.Icc (time k) (time (k+1))) t) ∧
  (∀ t∈Set.Icc (time 0) (time 5), Set.InjOn (fun z => φ (z,t)) (Metric.closedBall 0 (R:ℝ))) ∧
  (∀ p : Particle, (tr.path 0 (time 0)).state.X p∈Metric.closedBall 0 (R:ℝ) →
    ∀ k<5, ∀ t∈Set.Icc (time k) (time (k+1)),
      φ ((tr.path 0 (time 0)).state.X p,t)=(tr.path k t).state.X p)

end
end HugV3.Source.AppleBand
