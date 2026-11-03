import HugConstruction
namespace ActiveHug.Verified

theorem full_coupled_existence_uniqueness : ActiveHug.Full.FullCoupledExistenceUniqueness := by
  intro a b F initial hab hF hi
  obtain ⟨x,hx,hg⟩ := Full.full_exists hab F initial hF hi
  exact ⟨x,hx,fun other ho => Full.full_unique hab hF hi hx ho,
    Full.full_derivative hab hF hx,hg⟩

end ActiveHug.Verified
#print axioms ActiveHug.Verified.full_coupled_existence_uniqueness
