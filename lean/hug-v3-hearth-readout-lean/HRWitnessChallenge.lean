import HRChallenge
import HRWitnessData

namespace HugV3.Source.HearthReadout
noncomputable section

theorem recorded_encounter_refutes_constant_ratio (z : Resolution) (r : Reading) :
    ¬ ∃ k : ℝ, readStored r (stored z .start)=k*(stored z .start).heat ∧
      readStored r (stored z .finish)=k*(stored z .finish).heat := by sorry

end
end HugV3.Source.HearthReadout
