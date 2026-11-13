import FullAssembly

namespace SocialAS.Verified

theorem full_existence_uniqueness : SocialAS.Open.FullExistenceUniqueness := by
  unfold SocialAS.Open.FullExistenceUniqueness
  intro p i a b initial hp hi hr hab hx
  obtain ⟨st⟩ := SocialAS.Existence.construct_stages p i a b initial hp hi hr hab hx
  exact ⟨SocialAS.Existence.assemble st,
    SocialAS.Existence.assemble_solution hab st,
    SocialAS.Existence.assemble_unique hab st⟩

end SocialAS.Verified

#print axioms SocialAS.Verified.full_existence_uniqueness
