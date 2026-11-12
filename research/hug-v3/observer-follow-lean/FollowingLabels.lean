import OriginTracking

namespace FollowingLabels

/-- Disjoint initial cell origins, plus a later source. These are model context,
not separately owned contents of either observer. -/
structure Regions where
  near540only : Int
  near872only : Int
  shared : Int
  neither : Int
  added : Int
  deriving DecidableEq, Repr

def Regions.near540 (r : Regions) := r.near540only+r.shared
def Regions.near872 (r : Regions) := r.near872only+r.shared
def Regions.total (r : Regions) := r.near540only+r.near872only+r.shared+r.neither+r.added

theorem adding_overlapping_views_counts_shared_twice (r : Regions) :
    r.near540+r.near872 = r.total-r.neither-r.added+r.shared := by
  unfold Regions.near540 Regions.near872 Regions.total; omega

theorem shared_origin_belongs_to_both_view_definitions :
    (Regions.mk 0 0 7 0 0).near540 = 7 ∧
    (Regions.mk 0 0 7 0 0).near872 = 7 ∧
    (Regions.mk 0 0 7 0 0).total = 7 := by decide

structure LabelObservation where
  id : Nat
  insideView : Bool
  readout : Int
  deriving DecidableEq, Repr

theorem crossing_can_preserve_identity_and_readout :
    let before := LabelObservation.mk 540 true 7
    let after := LabelObservation.mk 540 false 7
    before.id = after.id ∧ before.readout = after.readout ∧
    before.insideView ≠ after.insideView := by decide

theorem same_identity_does_not_fix_the_readout :
    let before := LabelObservation.mk 872 false 7
    let after := LabelObservation.mk 872 true 9
    before.id = after.id ∧ before.readout ≠ after.readout := by decide

theorem positive_other_origin_makes_original_less_than_total
    (original other added total : Int)
    (balance : original+other+added=total) (newOrigin : 0<other+added) :
    original<total := by omega

theorem no_private_inventory_from_selected_observations
    (covered observed : Prop) (missing : ¬ covered) : ¬ (covered ∧ observed) := by
  intro both; exact missing both.1

end FollowingLabels
