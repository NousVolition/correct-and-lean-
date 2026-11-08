import V3SourceSystem
import Mathlib.Analysis.Calculus.MeanValue
import Mathlib.Topology.Order.IntermediateValue

namespace HugV3.Source
noncomputable section
open Set

/-- A proposed invariant for the unchanged model, not a new force or read rule.
The actual read threshold remains 1/200. -/
def ClayBuffer (s : State) : Prop := ∀ l, (3/500:ℝ) ≤ |s.b l|

end
end HugV3.Source
