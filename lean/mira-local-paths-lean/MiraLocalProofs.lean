import MiraLocalDefinitions

/-! Proof bodies for the frozen path-composition audit. -/
namespace MiraLocal.Verified
open SimpleGraph
variable {V : Type*} {G : SimpleGraph V} {a b c : V}

theorem joining_preserves_no_repeats (p : G.Walk a b) (q : G.Walk b c)
    (hp : p.IsPath) (hq : q.IsPath)
    (fresh : List.Disjoint p.support q.support.tail) : (p.append q).IsPath := by
  apply Walk.IsPath.mk'
  rw [Walk.support_append]
  exact hp.support_nodup.append hq.support_nodup.tail fresh

theorem every_joined_route_is_a_path (p : G.Walk a b) (h : Joined G p) :
    p.IsPath := by
  induction h with
  | start => exact Walk.IsPath.mk' (by simp)
  | extend previous unit_path fresh ih =>
      exact joining_preserves_no_repeats _ _ ih unit_path fresh

theorem joined_visits_every_chamber_once_iff_coverage [DecidableEq V]
    (p : G.Walk a b) (h : Joined G p) :
    p.IsHamiltonian ↔ ∀ v, v ∈ p.support := by
  exact (every_joined_route_is_a_path p h).isHamiltonian_iff

theorem joined_length_sufficient [DecidableEq V] [Fintype V]
    (p : G.Walk a b) (h : Joined G p) (size : p.length + 1 = Fintype.card V) :
    p.IsHamiltonian := by
  apply Walk.isHamiltonian_iff_isPath_and_length_eq.mpr
  exact ⟨every_joined_route_is_a_path p h, by omega⟩

theorem stuck_prefix_has_no_simple_extension (p : G.Walk a b) (h : Stuck p)
    (q : G.Walk b c) (simple : (p.append q).IsPath) : q.length = 0 := by
  cases q with
  | nil => rfl
  | @cons x y z edge rest =>
      have nodup := simple.support_nodup
      rw [Walk.support_append] at nodup
      have fresh := nodup.disjoint
      have hy : y ∉ p.support := by
        intro hy
        exact (List.disjoint_left.mp fresh) hy (by simp)
      exact False.elim (h y hy edge)

theorem good_local_units_join : Joined trapGraph goodRoute := by
  have hp : goodFirst.IsPath := Walk.IsPath.mk' (by decide)
  have hq : goodLast.IsPath := Walk.IsPath.mk' (by decide)
  have hfirst : Joined trapGraph goodFirst := by
    have h := Joined.extend (Joined.start (G := trapGraph) 0) hp (by simp [goodFirst])
    simpa using h
  exact Joined.extend hfirst hq (by simp [goodFirst, goodLast])

theorem good_complete_route : goodRoute.IsHamiltonian := by
  exact (every_joined_route_is_a_path _ good_local_units_join).isHamiltonian_of_mem
    (by decide)

theorem trap_map_is_connected : trapGraph.Connected := by
  rw [SimpleGraph.connected_iff_exists_forall_reachable]
  refine ⟨2, ?_⟩
  intro v
  by_cases hv : v = 2
  · subst v; exact ⟨Walk.nil⟩
  · have hadj : trapGraph.Adj 2 v := ⟨Ne.symm hv, Or.inr (Or.inl rfl)⟩
    exact hadj.reachable

theorem trap_prefix_locally_valid : trapPrefix.IsPath ∧
    trapPrefix.support = [0,2,1] := by
  exact ⟨Walk.IsPath.mk' (by decide), rfl⟩

theorem trap_prefix_stuck_and_incomplete : Stuck trapPrefix ∧
    (3 : Fin 4) ∉ trapPrefix.support := by
  exact ⟨by unfold Stuck; decide, by decide⟩

theorem trap_prefix_cannot_be_completed_by_appending (v : Fin 4)
    (q : trapGraph.Walk 1 v) : ¬ (trapPrefix.append q).IsHamiltonian := by
  intro hh
  have hz := stuck_prefix_has_no_simple_extension trapPrefix
    trap_prefix_stuck_and_incomplete.1 q hh.isPath
  have hlen := hh.length_eq
  simp [hz, trapPrefix] at hlen

theorem individual_units_can_overlap : overlapFirst.IsPath ∧ overlapLast.IsPath ∧
    overlapFirst.support = [0,1,2] ∧ overlapLast.support = [2,1,3] := by
  exact ⟨Walk.IsPath.mk' (by decide), Walk.IsPath.mk' (by decide), rfl, rfl⟩

theorem overlap_join_fails : ¬ (overlapFirst.append overlapLast).IsPath ∧
    ¬ (overlapFirst.append overlapLast).IsHamiltonian := by
  have hn : ¬ (overlapFirst.append overlapLast).support.Nodup := by decide
  exact ⟨fun hp => hn hp.support_nodup, fun hh => hn hh.isPath.support_nodup⟩

theorem valid_prefix_without_coverage_not_complete : goodFirst.IsPath ∧
    ¬ goodFirst.IsHamiltonian := by
  refine ⟨Walk.IsPath.mk' (by decide), ?_⟩
  intro hh
  have hmissing : (3 : Fin 4) ∉ goodFirst.support := by decide
  exact hmissing (hh.mem_support 3)

theorem changing_environment_mixed_checks_not_snapshot : oldGraph.Adj 0 1 ∧
    newGraph.Adj 1 2 ∧ ¬ List.IsChain oldGraph.Adj [0,1,2] ∧
    ¬ List.IsChain newGraph.Adj [0,1,2] := by
  decide

theorem full_hug_interface_joins [DecidableEq V]
    (view : ChamberView V) (input : PersonEnvironment.HugInput)
    (p : (view input).Walk a b) (h : Joined (view input) p)
    (coverage : ∀ v, v ∈ p.support) : p.IsHamiltonian := by
  exact (joined_visits_every_chamber_once_iff_coverage p h).mpr coverage

theorem original_guard_is_unchanged (input : PersonEnvironment.HugInput)
    (receiver : HugV3.Source.Actor) :
    PersonEnvironment.originalGuard input receiver =
    HugV3.Source.margin input.fullState.state receiver input.person := by
  rfl

theorem original_retrieval_is_unchanged (G : HugV3.Source.Geometry)
    (input : PersonEnvironment.HugInput)
    (records : List (Fin 4 × HugV3.Source.Record))
    (origin : HugV3.Source.Actor) (channel : Fin 4) :
    PersonEnvironment.originalRetrieval G input records origin channel =
    HugV3.Source.memory G input.fullState.state records input.person origin channel := by
  rfl

end MiraLocal.Verified
