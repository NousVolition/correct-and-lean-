import V3ClayChallenge

namespace HugV3.Source.ClayVerified
noncomputable section
open Set
open scoped BigOperators

/-- This is conditional on an existing full solution and a deformation bound;
neither premise is asserted or proved by this reference statement. -/
theorem clay_buffer_through_full_hybrid (tr : Trace) (hsol : Solves tr)
    (hF : ∀ k<5, ∀ t ∈ Ico (time k) (time (k+1)), ∀ l : Cell,
      (∑ i, ((tr.path k t).state.F (point l) i (axis l))^2) ≤ (2:ℝ)) :
    (∀ k≤5, ClayBuffer (tr.after k).state) ∧
    ∀ k<5, ∀ t ∈ Icc (time k) (time (k+1)), ClayBuffer (tr.path k t).state := by sorry

theorem decoded_records_fixed_along_full_hybrid (tr : Trace) (hsol : Solves tr) :
    ∀ k<5, ∀ t ∈ Icc (time k) (time (k+1)),
      readRecords (tr.path k t).state = readRecords (tr.after k).state := by sorry

end
end HugV3.Source.ClayVerified
