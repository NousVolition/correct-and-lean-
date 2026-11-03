import V3DelayDefinitions

namespace HugV3.Source.DelayVerified
noncomputable section
open Delay

theorem socialFrom_self (s : State) : socialFrom s s=s := by sorry

theorem present_physical_blocks (present past : State) : SamePhysical (socialFrom present past) present := by sorry

theorem buffered_social_blocks (present past : State) : SameSocial (socialFrom present past) past := by sorry

theorem material_records_remain_present (present past : State) : readRecords (socialFrom present past)=readRecords present := by sorry

theorem zero_delay_recovers_original (G : Geometry) (t : ℝ) (s : State) : rhsDelayed G t s s=rhs G t s := by sorry

theorem delay_preserves_current_physical_rate (G : Geometry) (t : ℝ) (present past d e : State)
    (hd : rhs G t present=some d) (he : rhs G t (socialFrom present past)=some e) :
    ∃ rate, rhsDelayed G t present past=some rate ∧ SamePhysical rate d := by sorry

theorem delay_uses_buffered_social_rate (G : Geometry) (t : ℝ) (present past d e : State)
    (hd : rhs G t present=some d) (he : rhs G t (socialFrom present past)=some e) :
    ∃ rate, rhsDelayed G t present past=some rate ∧ SameSocial rate e := by sorry

theorem buffer_reads_strictly_past {τ t : ℝ} (hτ : 0<τ) : t-τ<t := by sorry

theorem history_zero_delay (G : Geometry) (history : ℝ → State) (t : ℝ) : rhsAlong G 0 history t=rhs G t (history t) := by sorry
end
end HugV3.Source.DelayVerified
