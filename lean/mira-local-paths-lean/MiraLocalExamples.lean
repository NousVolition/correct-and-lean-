import MiraLocalProofs

open MiraLocal

-- Concrete route data; these are graph examples, not simulated human encounters.
#eval goodRoute.support.map Fin.val
#eval trapPrefix.support.map Fin.val
#eval (overlapFirst.append overlapLast).support.map Fin.val
#eval goodFirst.support.map Fin.val
instance : Decidable (Stuck trapPrefix) := by unfold Stuck; infer_instance
#eval decide (Stuck trapPrefix)

#print axioms MiraLocal.Verified.joined_visits_every_chamber_once_iff_coverage
#print axioms MiraLocal.Verified.trap_prefix_cannot_be_completed_by_appending
#print axioms MiraLocal.Verified.full_hug_interface_joins
