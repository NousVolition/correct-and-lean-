import V3ClayProofs

namespace HugV3.Source.ClayVerified
noncomputable section
open Set
open scoped BigOperators

private theorem checkpoint_increasing (k : ℕ) (hk : k<5) : time k < time (k+1) := by
  interval_cases k <;> norm_num [time]

/-- Preservation along a full solution, conditional on the stated deformation
bound. This is not an existence or uniqueness theorem. -/
theorem clay_buffer_through_full_hybrid (tr : Trace) (hsol : Solves tr)
    (hF : ∀ k<5, ∀ t ∈ Ico (time k) (time (k+1)), ∀ l : Cell,
      (∑ i, ((tr.path k t).state.F (point l) i (axis l))^2) ≤ (2:ℝ)) :
    (∀ k≤5, ClayBuffer (tr.after k).state) ∧
    ∀ k<5, ∀ t ∈ Icc (time k) (time (k+1)), ClayBuffer (tr.path k t).state := by
  have segment : ∀ k<5, ClayBuffer (tr.after k).state →
      ∀ t ∈ Icc (time k) (time (k+1)), ClayBuffer (tr.path k t).state := by
    intro k hk hstart
    have part := hsol.2 k hk
    apply clay_buffer_preserved_on_segment
    · exact part.2.1.2.2.2.2.1
    · intro l t ht
      obtain ⟨d,hrhs,hd⟩ := part.2.2.2.1 t ⟨ht.1,ht.2.le⟩
      have coord := hd.2.2.2.2.1 l
      change HasDerivWithinAt (fun τ => (tr.path k τ).state.b l) (d.b l)
        (Icc (time k) (time (k+1))) t at coord
      rw [Verified.rhs_fabric_equation sourceGeometry t (tr.path k t).state d hrhs l] at coord
      exact (coord.mono (Icc_subset_Icc ht.1 le_rfl)).mono_of_mem_nhdsWithin
        (Icc_mem_nhdsGE ht.2)
    · exact fun l t ht => hF k hk t ht l
    · simpa only [part.1] using hstart
  have after : ∀ k, k≤5 → ClayBuffer (tr.after k).state := by
    intro k
    induction k with
    | zero =>
      intro _
      rw [hsol.1]
      exact initial_clay_buffer sourceGeometry
    | succ k ih =>
      intro hk5
      have hk : k<5 := by omega
      have hpath := segment k hk (ih (by omega))
      exact boundary_preserves_clay_buffer (k+1) (tr.path k (time (k+1)))
        (tr.after (k+1))
        (hpath (time (k+1)) (right_mem_Icc.mpr (checkpoint_increasing k hk).le))
        (hsol.2 k hk).2.2.2.2
  exact ⟨after,fun k hk => segment k hk (after k (by omega))⟩

theorem decoded_records_fixed_along_full_hybrid (tr : Trace) (hsol : Solves tr) :
    ∀ k<5, ∀ t ∈ Icc (time k) (time (k+1)),
      readRecords (tr.path k t).state = readRecords (tr.after k).state := by
  intro k hk
  have part := hsol.2 k hk
  have hr : ∀ t ∈ Icc (time k) (time (k+1)),
      ∃ records, readRecords (tr.path k t).state = some records := by
    intro t ht
    obtain ⟨d,hrhs,_⟩ := part.2.2.2.1 t ht
    obtain ⟨records,hread,_⟩ := Verified.rhs_accumulator_equation
      sourceGeometry t (tr.path k t).state d hrhs
    exact ⟨records,hread⟩
  intro t ht
  have h := decoded_records_fixed_on_segment (fun t => (tr.path k t).state)
    (time k) (time (k+1)) part.2.1.2.2.2.2.1 hr t ht
  simpa only [part.1] using h

end
end HugV3.Source.ClayVerified
