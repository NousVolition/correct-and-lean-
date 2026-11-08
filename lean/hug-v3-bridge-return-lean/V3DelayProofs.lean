import V3DelayDefinitions

namespace HugV3.Source.DelayVerified
noncomputable section
open Delay

theorem socialFrom_self (s : State) : socialFrom s s=s := by
  cases s
  rfl

theorem present_physical_blocks (present past : State) : SamePhysical (socialFrom present past) present := by
  exact ⟨rfl,rfl,rfl,rfl,rfl,rfl,rfl,rfl⟩

theorem buffered_social_blocks (present past : State) : SameSocial (socialFrom present past) past := by
  exact ⟨rfl,rfl,rfl,rfl,rfl,rfl,rfl⟩

theorem material_records_remain_present (present past : State) : readRecords (socialFrom present past)=readRecords present := by
  rfl

theorem zero_delay_recovers_original (G : Geometry) (t : ℝ) (s : State) : rhsDelayed G t s s=rhs G t s := by
  simp only [rhsDelayed,socialFrom_self]
  cases h : rhs G t s <;> simp [h,socialFrom_self]

theorem delay_preserves_current_physical_rate (G : Geometry) (t : ℝ) (present past d e : State)
    (hd : rhs G t present=some d) (he : rhs G t (socialFrom present past)=some e) :
    ∃ rate, rhsDelayed G t present past=some rate ∧ SamePhysical rate d := by
  refine ⟨socialFrom d e,?_,present_physical_blocks d e⟩
  simp [rhsDelayed,hd,he]

theorem delay_uses_buffered_social_rate (G : Geometry) (t : ℝ) (present past d e : State)
    (hd : rhs G t present=some d) (he : rhs G t (socialFrom present past)=some e) :
    ∃ rate, rhsDelayed G t present past=some rate ∧ SameSocial rate e := by
  refine ⟨socialFrom d e,?_,buffered_social_blocks d e⟩
  simp [rhsDelayed,hd,he]

theorem buffer_reads_strictly_past {τ t : ℝ} (hτ : 0<τ) : t-τ<t := by
  linarith

theorem history_zero_delay (G : Geometry) (history : ℝ → State) (t : ℝ) : rhsAlong G 0 history t=rhs G t (history t) := by
  simpa [rhsAlong] using zero_delay_recovers_original G t (history t)
end
end HugV3.Source.DelayVerified
