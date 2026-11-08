import AppleFlowChallenge

namespace HugV3.Source.AppleBand
noncomputable section
open scoped NNReal

theorem band_on_the_embedded_skin_at_each_time {tr : Trace} {R : ℝ≥0} {φ : Vec × ℝ → Vec}
    (flow : MaterialFlowAcross tr R φ) (big : 1≤R) (t : ℝ) (ht : t∈Set.Icc (time 0) (time 5)) :
    Topology.IsEmbedding (fun z : referenceSkin => φ ((z:Vec),t)) ∧
    ContractsOn ((fun z : Vec => φ (z,t)) '' referenceSkin)
      (fun b => φ (equator b,t)) (φ (north,t)) := by sorry

end
end HugV3.Source.AppleBand
