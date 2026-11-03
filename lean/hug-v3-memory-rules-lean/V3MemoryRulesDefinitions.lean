import V3DelayDefinitions

/-! Read-only observables for the unchanged full Hug v3 source. No rate, event,
history-selection, or writing rule is added or replaced. -/
namespace HugV3.Source.MemoryRules
noncomputable section
open scoped BigOperators

def cueDifference (G : Geometry) (s : State) (r : Record) : Vec :=
  let feature : Vec := ![r.context 0,r.context 1,
    tanh (0.5*(∑ p, (G.attach r.recipient p+G.attach r.origin p)*recordChange r p)/0.12)]
  fun k => feature k-memoryFeature G s r.recipient r.origin k-
    0.15*tanh (s.association r.recipient r.origin k)

def cueDistanceSquared (G : Geometry) (s : State) (r : Record) : ℝ :=
  sqnorm (cueDifference G s r)

end
end HugV3.Source.MemoryRules
