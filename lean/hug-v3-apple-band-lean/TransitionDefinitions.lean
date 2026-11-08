import V3YangMillsAuditDefinitions
import Mathlib

namespace HugV3.Source.FrameTransition
noncomputable section
open YMAudit

/-- The generator expressed in the target frame, for the convention F_target = Q F_source. -/
def frameRate (Q dQ L : Mat) : Mat := mm (dQ+mm Q L) (Matrix.of Q).transpose

def fabricPath (L F : ℝ → Mat) (I : Set ℝ) : Prop :=
  ∀ t ∈ I, MatrixDerivWithin F (mm (L t) (F t)) I t

/-- A concrete fabric trajectory for the diagonal generator used in the portfolio witness. -/
def stretch (t : ℝ) : Mat :=
  ![![Real.exp t,0,0],![0,Real.exp (-t),0],![0,0,1]]

end
end HugV3.Source.FrameTransition
