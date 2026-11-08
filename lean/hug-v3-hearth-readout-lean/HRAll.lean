import HRProofs
import HRWitnessData

namespace HugV3.Source.HearthReadout
noncomputable section

theorem recorded_encounter_refutes_constant_ratio (z : Resolution) (r : Reading) :
    ¬ ∃ k : ℝ, readStored r (stored z .start)=k*(stored z .start).heat ∧
      readStored r (stored z .finish)=k*(stored z .finish).heat := by
  have unequal : readStored r (stored z .start)*(stored z .finish).heat≠
      readStored r (stored z .finish)*(stored z .start).heat := by
    cases z <;> cases r <;> norm_num [stored,readStored]
  rintro ⟨k,left,right⟩
  apply unequal
  rw [left,right]
  ring

end
end HugV3.Source.HearthReadout
