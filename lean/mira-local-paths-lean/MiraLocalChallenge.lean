import MiraLocalDefinitions

/-! Frozen reference statements. Placeholders belong only to this Comparator challenge.
The independently checked solution must not import this file. -/
namespace MiraLocal.Verified
open SimpleGraph
variable {V : Type*} {G : SimpleGraph V} {a b c : V}

theorem joining_preserves_no_repeats (p : G.Walk a b) (q : G.Walk b c)
    (hp : p.IsPath) (hq : q.IsPath)
    (fresh : List.Disjoint p.support q.support.tail) : (p.append q).IsPath := by sorry

theorem every_joined_route_is_a_path (p : G.Walk a b) (h : Joined G p) :
    p.IsPath := by sorry

theorem joined_visits_every_chamber_once_iff_coverage [DecidableEq V]
    (p : G.Walk a b) (h : Joined G p) :
    p.IsHamiltonian ↔ ∀ v, v ∈ p.support := by sorry

theorem joined_length_sufficient [DecidableEq V] [Fintype V]
    (p : G.Walk a b) (h : Joined G p) (size : p.length + 1 = Fintype.card V) :
    p.IsHamiltonian := by sorry

theorem stuck_prefix_has_no_simple_extension (p : G.Walk a b) (h : Stuck p)
    (q : G.Walk b c) (simple : (p.append q).IsPath) : q.length = 0 := by sorry

theorem good_local_units_join : Joined trapGraph goodRoute := by sorry

theorem good_complete_route : goodRoute.IsHamiltonian := by sorry

theorem trap_map_is_connected : trapGraph.Connected := by sorry

theorem trap_prefix_locally_valid : trapPrefix.IsPath ∧
    trapPrefix.support = [0,2,1] := by sorry

theorem trap_prefix_stuck_and_incomplete : Stuck trapPrefix ∧
    (3 : Fin 4) ∉ trapPrefix.support := by sorry

theorem trap_prefix_cannot_be_completed_by_appending (v : Fin 4)
    (q : trapGraph.Walk 1 v) : ¬ (trapPrefix.append q).IsHamiltonian := by sorry

theorem individual_units_can_overlap : overlapFirst.IsPath ∧ overlapLast.IsPath ∧
    overlapFirst.support = [0,1,2] ∧ overlapLast.support = [2,1,3] := by sorry

theorem overlap_join_fails : ¬ (overlapFirst.append overlapLast).IsPath ∧
    ¬ (overlapFirst.append overlapLast).IsHamiltonian := by sorry

theorem valid_prefix_without_coverage_not_complete : goodFirst.IsPath ∧
    ¬ goodFirst.IsHamiltonian := by sorry

theorem changing_environment_mixed_checks_not_snapshot : oldGraph.Adj 0 1 ∧
    newGraph.Adj 1 2 ∧ ¬ List.IsChain oldGraph.Adj [0,1,2] ∧
    ¬ List.IsChain newGraph.Adj [0,1,2] := by sorry

theorem full_hug_interface_joins [DecidableEq V]
    (view : ChamberView V) (input : PersonEnvironment.HugInput)
    (p : (view input).Walk a b) (h : Joined (view input) p)
    (coverage : ∀ v, v ∈ p.support) : p.IsHamiltonian := by sorry

theorem original_guard_is_unchanged (input : PersonEnvironment.HugInput)
    (receiver : HugV3.Source.Actor) :
    PersonEnvironment.originalGuard input receiver =
    HugV3.Source.margin input.fullState.state receiver input.person := by sorry

theorem original_retrieval_is_unchanged (G : HugV3.Source.Geometry)
    (input : PersonEnvironment.HugInput)
    (records : List (Fin 4 × HugV3.Source.Record))
    (origin : HugV3.Source.Actor) (channel : Fin 4) :
    PersonEnvironment.originalRetrieval G input records origin channel =
    HugV3.Source.memory G input.fullState.state records input.person origin channel := by sorry

end MiraLocal.Verified
