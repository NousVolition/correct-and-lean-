import V3OccupiedSpaceDefinitions

namespace HugV3.Source.OccupiedSpaceVerified
noncomputable section
attribute [local instance] Classical.propDecidable
open OccupiedSpace Set
open scoped BigOperators
set_option maxRecDepth 4096

theorem margin_is_original (s : State) (owner visitor : Actor) :
    guardMarginAt s owner visitor (s.expression visitor) = margin s owner visitor := by sorry

theorem region_matches_half_permission (s : State) (owner visitor : Actor) (z : Action) :
    z ∈ guardRegion s owner visitor ↔ (1/2 : ℝ) < sigmoid (guardMarginAt s owner visitor z/0.18) := by sorry

theorem soft_permission_positive (s : State) (owner visitor : Actor) (z : Action) :
    0 < sigmoid (guardMarginAt s owner visitor z/0.18) := by sorry

theorem region_contains_owners_center (s : State) (owner visitor : Actor) :
    s.normCenter owner ∈ guardRegion s owner visitor := by sorry

theorem same_audience_regions_overlap (s : State) (owner i j : Actor) :
    (guardRegion s owner i ∩ guardRegion s owner j).Nonempty := by sorry

theorem initial_zero_in_every_guard (G : Geometry) (owner visitor : Actor) :
    zeroAction ∈ guardRegion (initial G) owner visitor := by sorry

theorem initial_zero_in_every_whole_region (G : Geometry) (audience : Audience) (i : Actor) :
    zeroAction ∈ occupiedRegion (initial G) audience i := by sorry

theorem initial_exclusion_refuted (G : Geometry) (audience : Audience) :
    ¬ Exclusion (initial G) audience := by sorry

theorem full_hybrid_exclusion_refuted (tr : Trace) (hsol : Solves tr) (audience : Audience) :
    ¬ ExclusionThroughout tr audience := by sorry

theorem write_preserves_personal_pulley (G : Geometry) (s w : State) (record : Record)
    (hw : writeEvent G s record = some w) (i : Actor) : pulleyView w i = pulleyView s i := by sorry

theorem write_preserves_whole_regions (G : Geometry) (s w : State) (record : Record)
    (hw : writeEvent G s record = some w) (audience : Audience) (i : Actor) :
    occupiedRegion w audience i = occupiedRegion s audience i := by sorry

theorem boundary_preserves_whole_regions (q : ℕ) (s w : FullState)
    (hw : boundary q s = some w) (audience : Audience) (i : Actor) :
    occupiedRegion w.state audience i = occupiedRegion s.state audience i := by sorry

theorem boundary_preserves_exclusion_status (q : ℕ) (s w : FullState)
    (hw : boundary q s = some w) (audience : Audience) :
    Exclusion w.state audience ↔ Exclusion s.state audience := by sorry

theorem delay_uses_buffered_regions (present past : State) (audience : Audience) (i : Actor) :
    occupiedRegion (Delay.socialFrom present past) audience i = occupiedRegion past audience i := by sorry

theorem full_region_motion (tr : Trace) (hsol : Solves tr) (q : ℕ) (hq : q < 5)
    (t : ℝ) (ht : t ∈ Icc (time q) (time (q+1))) (owner visitor : Actor) (z : Action) :
    ∃ rate, rhs sourceGeometry t (tr.path q t).state = some rate ∧
      HasDerivWithinAt (fun τ => regionScore (tr.path q τ).state owner visitor z)
        (regionScoreRate (tr.path q t).state rate owner visitor z)
        (Icc (time q) (time (q+1))) t := by sorry

end
end HugV3.Source.OccupiedSpaceVerified
