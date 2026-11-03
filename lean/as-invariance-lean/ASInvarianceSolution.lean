import CoupledMeaningBounds

namespace SocialAS.Verified

-- Exactly the previously recorded proposition, with no added premises.
theorem full_state_invariance : SocialAS.Open.FullStateInvariance := by
  unfold SocialAS.Open.FullStateInvariance
  intro p i a b initial trajectory hp hi hr hab hx hsol
  obtain ⟨st⟩ := SocialAS.Existence.construct_stages p i a b initial hp hi hr hab hx
  have hb := SocialAS.Invariance.stages_state_bounds st hp hi hr hab hx
  have heq := SocialAS.Existence.assemble_unique hab st trajectory hsol
  intro t ht
  rw [←heq ht]
  exact hb t ht

end SocialAS.Verified

#print axioms SocialAS.Verified.full_state_invariance
