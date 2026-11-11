# Can short routes become one complete tour?

Try joining paths without visiting any room twice. A connected graph can still contain a legal prefix that leaves no way to reach the last room.

[`MiraLocalChallenge.lean`](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalChallenge.lean) · [Package configuration](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/comparator.json) · [Sources and credits](../CREDITS.md) · [All challenge files](../README.md)

<details>
<summary>Source material for this challenge</summary>

Copyright © 2026 NousVolition. All rights reserved. The repository notice applies to material for which NousVolition holds copyright. Third-party material follows its own terms. [Copyright notice](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/LICENSE).

Primary files for this challenge. [Solution entry module](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalProofs.lean) · [MiraLocalDefinitions](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalDefinitions.lean) · [Statement and proof inputs](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/verification-inputs.json) · [Verification record](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/verification-report.json) · [Pinned libraries](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/lake-manifest.json).

</details>

## When can two simple routes be joined without revisiting a room?

`joining_preserves_no_repeats`

**Proof request**

Show that two paths append to a simple path when the second introduces only fresh vertices after the junction.

**Reading the result**

If the second route after its starting junction is disjoint from the first route, appending them creates no repeated vertex.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable {V : Type*} {G : SimpleGraph V} {a b c : V}
```

```lean
theorem joining_preserves_no_repeats (p : G.Walk a b) (q : G.Walk b c)
    (hp : p.IsPath) (hq : q.IsPath)
    (fresh : List.Disjoint p.support q.support.tail) : (p.append q).IsPath := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalChallenge.lean#L9-L11) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalProofs.lean#L8-L13)

## Do all routes built by the allowed joining rule stay simple?

`every_joined_route_is_a_path`

**Proof request**

Prove simplicity for every route built by the stipulated joining rule.

**Reading the result**

Applying the fresh-vertex condition at each join preserves the path property.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable {V : Type*} {G : SimpleGraph V} {a b c : V}
```

```lean
theorem every_joined_route_is_a_path (p : G.Walk a b) (h : Joined G p) :
    p.IsPath := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalChallenge.lean#L13-L14) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalProofs.lean#L15-L20)

## When is a joined route a tour of every chamber exactly once?

`joined_visits_every_chamber_once_iff_coverage`

**Proof request**

Prove that a joined route is Hamiltonian exactly when it covers every chamber.

**Reading the result**

Since joining already rules out repeats, visiting every chamber is precisely the remaining coverage condition.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable {V : Type*} {G : SimpleGraph V} {a b c : V}
```

```lean
theorem joined_visits_every_chamber_once_iff_coverage [DecidableEq V]
    (p : G.Walk a b) (h : Joined G p) :
    p.IsHamiltonian ↔ ∀ v, v ∈ p.support := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalChallenge.lean#L16-L18) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalProofs.lean#L22-L25)

## Can you certify coverage by counting steps?

`joined_length_sufficient`

**Proof request**

Deduce Hamiltonicity from the vertex count and length of the joined route.

**Reading the result**

In a finite graph a joined route with one fewer edge than there are vertices visits them all.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable {V : Type*} {G : SimpleGraph V} {a b c : V}
```

```lean
theorem joined_length_sufficient [DecidableEq V] [Fintype V]
    (p : G.Walk a b) (h : Joined G p) (size : p.length + 1 = Fintype.card V) :
    p.IsHamiltonian := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalChallenge.lean#L20-L22) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalProofs.lean#L27-L31)

## Can a stuck prefix have a nonempty simple extension?

`stuck_prefix_has_no_simple_extension`

**Proof request**

Show that a simple extension of the stuck prefix must have zero length.

**Reading the result**

Any such extension would have to leave the endpoint for a fresh vertex, which the stuck condition rules out.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable {V : Type*} {G : SimpleGraph V} {a b c : V}
```

```lean
theorem stuck_prefix_has_no_simple_extension (p : G.Walk a b) (h : Stuck p)
    (q : G.Walk b c) (simple : (p.append q).IsPath) : q.length = 0 := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalChallenge.lean#L24-L25) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalProofs.lean#L33-L44)

## Do the example’s good local pieces really fit?

`good_local_units_join`

**Proof request**

Verify that the good example is assembled by the joining rule.

**Reading the result**

The explicit routes meet the join rule on the trap graph.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable {V : Type*} {G : SimpleGraph V} {a b c : V}
```

```lean
theorem good_local_units_join : Joined trapGraph goodRoute := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalChallenge.lean#L27) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalProofs.lean#L46-L52)

## Does that joined example finish the tour?

`good_complete_route`

**Proof request**

Verify that the good example is Hamiltonian.

**Reading the result**

Its support covers the graph and its vertices are distinct.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable {V : Type*} {G : SimpleGraph V} {a b c : V}
```

```lean
theorem good_complete_route : goodRoute.IsHamiltonian := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalChallenge.lean#L29) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalProofs.lean#L54-L56)

## Is failure in the trap caused by a disconnected map?

`trap_map_is_connected`

**Proof request**

Prove connectedness of the trap graph.

**Reading the result**

The listed graph is connected, as shown by paths between its vertices.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable {V : Type*} {G : SimpleGraph V} {a b c : V}
```

```lean
theorem trap_map_is_connected : trapGraph.Connected := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalChallenge.lean#L31) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalProofs.lean#L58-L65)

## Which route leads into the trap?

`trap_prefix_locally_valid`

**Proof request**

Verify simplicity and the exact vertex list of the trap prefix.

**Reading the result**

The prefix 0, 2, 1 has distinct vertices and is a valid path.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable {V : Type*} {G : SimpleGraph V} {a b c : V}
```

```lean
theorem trap_prefix_locally_valid : trapPrefix.IsPath ∧
    trapPrefix.support = [0,2,1] := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalChallenge.lean#L33-L34) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalProofs.lean#L67-L69)

## Which room does that valid prefix leave out?

`trap_prefix_stuck_and_incomplete`

**Proof request**

Prove that the prefix is stuck and misses vertex three.

**Reading the result**

Room three is missing, and the route is already stuck at its endpoint.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable {V : Type*} {G : SimpleGraph V} {a b c : V}
```

```lean
theorem trap_prefix_stuck_and_incomplete : Stuck trapPrefix ∧
    (3 : Fin 4) ∉ trapPrefix.support := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalChallenge.lean#L36-L37) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalProofs.lean#L71-L73)

## Could appending a more clever suffix still finish it?

`trap_prefix_cannot_be_completed_by_appending`

**Proof request**

Rule out a Hamiltonian route obtained by appending to that prefix.

**Reading the result**

Every nontrivial simple extension is blocked and the existing prefix lacks a room.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable {V : Type*} {G : SimpleGraph V} {a b c : V}
```

```lean
theorem trap_prefix_cannot_be_completed_by_appending (v : Fin 4)
    (q : trapGraph.Walk 1 v) : ¬ (trapPrefix.append q).IsHamiltonian := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalChallenge.lean#L39-L40) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalProofs.lean#L75-L81)

## Can two individually good pieces share a room in the wrong place?

`individual_units_can_overlap`

**Proof request**

Verify the simplicity and overlapping supports of the two displayed subroutes.

**Reading the result**

The two simple routes [0,1,2] and [2,1,3] revisit room one when joined.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable {V : Type*} {G : SimpleGraph V} {a b c : V}
```

```lean
theorem individual_units_can_overlap : overlapFirst.IsPath ∧ overlapLast.IsPath ∧
    overlapFirst.support = [0,1,2] ∧ overlapLast.support = [2,1,3] := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalChallenge.lean#L42-L43) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalProofs.lean#L83-L85)

## Why does their joined route fail?

`overlap_join_fails`

**Proof request**

Show that their concatenation is neither simple nor Hamiltonian.

**Reading the result**

The repeated vertex breaks simplicity and therefore also breaks the proposed visit-every-room-once property.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable {V : Type*} {G : SimpleGraph V} {a b c : V}
```

```lean
theorem overlap_join_fails : ¬ (overlapFirst.append overlapLast).IsPath ∧
    ¬ (overlapFirst.append overlapLast).IsHamiltonian := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalChallenge.lean#L45-L46) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalProofs.lean#L87-L90)

## Is a good prefix already a full tour?

`valid_prefix_without_coverage_not_complete`

**Proof request**

Exhibit a valid first path that does not cover the graph.

**Reading the result**

The explicit first piece is simple but lacks coverage.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable {V : Type*} {G : SimpleGraph V} {a b c : V}
```

```lean
theorem valid_prefix_without_coverage_not_complete : goodFirst.IsPath ∧
    ¬ goodFirst.IsHamiltonian := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalChallenge.lean#L48-L49) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalProofs.lean#L92-L97)

## Can two valid edge checks from different moments be mistaken for one route?

`changing_environment_mixed_checks_not_snapshot`

**Proof request**

Verify the two local edges and rule out a whole chain in either individual snapshot.

**Reading the result**

One graph has the first edge and another has the second. Neither single graph contains the whole displayed chain.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable {V : Type*} {G : SimpleGraph V} {a b c : V}
```

```lean
theorem changing_environment_mixed_checks_not_snapshot : oldGraph.Adj 0 1 ∧
    newGraph.Adj 1 2 ∧ ¬ List.IsChain oldGraph.Adj [0,1,2] ∧
    ¬ List.IsChain newGraph.Adj [0,1,2] := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalChallenge.lean#L51-L53) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalProofs.lean#L99-L102)

## How can a full Hug input certify a completed route?

`full_hug_interface_joins`

**Proof request**

Derive a Hamiltonian route under the full-input joining and coverage assumptions.

**Reading the result**

With the stipulated snapshot, joining and coverage hypotheses, the route in that graph is Hamiltonian.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable {V : Type*} {G : SimpleGraph V} {a b c : V}
```

```lean
theorem full_hug_interface_joins [DecidableEq V]
    (view : ChamberView V) (input : PersonEnvironment.HugInput)
    (p : (view input).Walk a b) (h : Joined (view input) p)
    (coverage : ∀ v, v ∈ p.support) : p.IsHamiltonian := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalChallenge.lean#L55-L58) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalProofs.lean#L104-L108)

## Which guard does the interface read?

`original_guard_is_unchanged`

**Proof request**

Identify the guard wrapper with the original margin at the supplied state.

**Reading the result**

Its wrapper evaluates the original Hug margin for the selected person and receiver.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable {V : Type*} {G : SimpleGraph V} {a b c : V}
```

```lean
theorem original_guard_is_unchanged (input : PersonEnvironment.HugInput)
    (receiver : HugV3.Source.Actor) :
    PersonEnvironment.originalGuard input receiver =
    HugV3.Source.margin input.fullState.state receiver input.person := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalChallenge.lean#L60-L63) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalProofs.lean#L110-L114)

## Which memory does the interface retrieve?

`original_retrieval_is_unchanged`

**Proof request**

Identify the retrieval wrapper with the original memory at the supplied state.

**Reading the result**

Its wrapper calls the original memory on the chosen full state, person, origin and channel.

<details>
<summary>Exact Lean statement</summary>

Shared declarations in this source file

```lean
variable {V : Type*} {G : SimpleGraph V} {a b c : V}
```

```lean
theorem original_retrieval_is_unchanged (G : HugV3.Source.Geometry)
    (input : PersonEnvironment.HugInput)
    (records : List (Fin 4 × HugV3.Source.Record))
    (origin : HugV3.Source.Actor) (channel : Fin 4) :
    PersonEnvironment.originalRetrieval G input records origin channel =
    HugV3.Source.memory G input.fullState.state records input.person origin channel := by sorry
```

</details>

[Reference statement](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalChallenge.lean#L65-L70) · [Proof](https://github.com/NousVolition/hug-sims-lean-proofs/blob/9ae6be1d8c7959047af1726bf3dd0a3a3a46fb54/lean/mira-local-paths-lean/MiraLocalProofs.lean#L116-L122)
