import CWChallenge

namespace HugV3.Source.CW
noncomputable section

theorem retained_velocity_work (s : State)
    (retained : ∀ i x, filt (fun y => velocity s y i) x=velocity s x i)
    (solenoidal : project (velocity s)=velocity s) :
    inner (velocity s) (weaver s (velocity s))= -heat s ∧
    inner (velocity s) (courier (velocity s))=0 := by sorry

end
end HugV3.Source.CW
