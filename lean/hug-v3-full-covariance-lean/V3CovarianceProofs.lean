import V3CovarianceDefinitions

namespace HugV3.Source.CovarianceVerified
noncomputable section
attribute [local instance] Classical.propDecidable
open Covariance Delay
open scoped BigOperators
set_option maxRecDepth 4096

@[simp] private theorem sg (ε) (s : State) : (signState ε s).g=s.g := rfl
@[simp] private theorem sx (ε) (s : State) : (signState ε s).X=s.X := rfl
@[simp] private theorem sm (ε) (s : State) : (signState ε s).m=s.m := rfl
@[simp] private theorem sb (ε) (s : State) : (signState ε s).b=s.b := rfl
@[simp] private theorem sA (ε) (s : State) : (signState ε s).A=s.A := rfl
@[simp] private theorem sl (ε) (s : State) : (signState ε s).ledger=s.ledger := rfl
@[simp] private theorem sw (ε) (s : State) : (signState ε s).writeWork=s.writeWork := rfl
@[simp] private theorem se (ε) (s : State) : (signState ε s).expression=s.expression := rfl
@[simp] private theorem sc (ε) (s : State) : (signState ε s).context=s.context := rfl
@[simp] private theorem sn (ε) (s : State) : (signState ε s).normCenter=s.normCenter := rfl
@[simp] private theorem sr (ε) (s : State) : (signState ε s).logRadius=s.logRadius := rfl
@[simp] private theorem srel (ε) (s : State) : (signState ε s).relation=s.relation := rfl
@[simp] private theorem sresp (ε) (s : State) : (signState ε s).responses=s.responses := rfl
@[simp] private theorem sa (ε) (s : State) : (signState ε s).association=s.association := rfl

private def signQ (ε : Particle → Bool) (p : Particle) : Mat :=
  if ε p then -eye else eye

private theorem mm_eye (F : Mat) : mm eye F=F := by
  funext i j
  simp [mm, eye, ite_mul]

private theorem mm_neg_left (Q F : Mat) : mm (-Q) F= -mm Q F := by
  funext i j
  simp [mm, Pi.neg_apply, neg_mul, Finset.sum_neg_distrib]

private theorem signed_as_matrix (ε) (F : Particle → Mat) :
    signedFabric ε F=fun p => mm (signQ ε p) (F p) := by
  funext p
  cases h : ε p <;> simp [signedFabric, signQ, h, mm_eye, mm_neg_left]

private theorem sign_as_rotation (ε) : signState ε=YMAudit.rotateFabric (signQ ε) := by
  funext s
  unfold signState YMAudit.rotateFabric
  rw [signed_as_matrix]

private theorem signQ_orthogonal (ε) (p : Particle) : YMAudit.Orthogonal (signQ ε p) := by
  unfold YMAudit.Orthogonal
  ext i j
  cases h : ε p <;> fin_cases i <;> fin_cases j <;>
    norm_num [signQ, h, eye, Matrix.mul_apply, Matrix.transpose_apply, Fin.sum_univ_succ]

private theorem green_signed (ε) (F : Particle → Mat) (p : Particle) :
    green (signedFabric ε F p)=green (F p) := by
  rw [signed_as_matrix]
  exact YMAuditVerified.green_objective _ _ (signQ_orthogonal ε p)

private theorem norm_signed (ε) (s : State) (p : Particle) :
    strainNorm ((signState ε s).F p)=strainNorm (s.F p) := by
  change strainNorm (signedFabric ε s.F p)=_
  simp only [strainNorm, green_signed]

private theorem strain_signed (ε) (s : State) (l : Cell) :
    fabricStrain (signState ε s).F l=fabricStrain s.F l := by
  rw [sign_as_rotation]
  exact YMAuditVerified.fabric_strain_objective s _ (signQ_orthogonal ε) l

private theorem read_signed (ε) (s : State) : readRecords (signState ε s)=readRecords s := by
  rw [sign_as_rotation]
  exact YMAuditVerified.decoded_records_frame_invariant s _

private theorem social_signed (ε) (G : Geometry) (t : ℝ) (s : State) (rs) :
    socialRates G t (signState ε s) rs=socialRates G t s rs := by
  rw [sign_as_rotation]
  exact YMAuditVerified.social_rates_frame_invariant G t s _ (signQ_orthogonal ε) rs

private theorem feature_signed (ε) (G : Geometry) (s : State) :
    memoryFeature G (signState ε s)=memoryFeature G s := by
  funext i j
  simp [memoryFeature, norm_signed]

private theorem weight_signed (ε) (G : Geometry) (s : State) (r : Record) :
    recordWeight G (signState ε s) r=recordWeight G s r := by
  simp [recordWeight, feature_signed]

private theorem exposure_signed (ε) (G : Geometry) (s : State) (rs) :
    exposure G (signState ε s) rs=exposure G s rs := by
  funext i j
  simp only [exposure, weight_signed]

private theorem fiber_signed (ε) (G : Geometry) (s : State) (p : Particle) (k : Direction) :
    fiber G (signState ε s) p k=if ε p then -fiber G s p k else fiber G s p k := by
  funext i
  cases h : ε p <;>
    simp [fiber, signState, signedFabric, h, Pi.neg_apply, neg_mul, Finset.sum_neg_distrib]

private theorem normfiber_signed (ε) (G : Geometry) (s : State) (p : Particle) (k : Direction) :
    sqnorm (fiber G (signState ε s) p k)=sqnorm (fiber G s p k) := by
  rw [fiber_signed]
  cases h : ε p <;> simp [h, sqnorm, Pi.neg_apply]

private theorem fiberstrain_signed (ε) (G : Geometry) (s : State) (p : Particle) (k : Direction) :
    fiberStrain G (signState ε s) p k=fiberStrain G s p k := by
  simp only [fiberStrain, normfiber_signed]

@[simp] private theorem velocity_signed (ε) (s : State) : velocity (signState ε s)=velocity s := rfl
@[simp] private theorem gradient_signed (ε) (s : State) :
    velocityGradient (signState ε s)=velocityGradient s := rfl
@[simp] private theorem particle_signed (ε) (s : State) :
    particleGradient (signState ε s)=particleGradient s := rfl
@[simp] private theorem viscous_signed (ε) (s : State) :
    viscousHeat (signState ε s)=viscousHeat s := rfl
@[simp] private theorem occupancy_signed (ε) (G : Geometry) (s : State) :
    occupancy G (signState ε s)=occupancy G s := rfl
@[simp] private theorem available_signed (ε) (G : Geometry) (s : State) :
    available G (signState ε s)=available G s := rfl
@[simp] private theorem forcing_signed (ε) (s : State) : forcing (signState ε s)=forcing s := rfl

theorem state_involution (ε : Particle → Bool) (s : State) :
    signState ε (signState ε s)=s := by
  have hf : signedFabric ε (signedFabric ε s.F)=s.F := by
    funext p
    cases h : ε p <;> simp [signedFabric, h]
  unfold signState
  simp only [hf]

theorem same_social_state (ε : Particle → Bool) (s : State) :
    SameSocial (signState ε s) s := by simp [SameSocial]

theorem material_stress_invariant (ε : Particle → Bool) (G : Geometry) (s : State) :
    materialStress G (signState ε s)=materialStress G s := by
  funext p i j
  simp only [materialStress, effective, sm, fiberstrain_signed, fiber_signed]
  cases h : ε p <;> simp [signState, signedFabric, h, Pi.neg_apply, neg_mul, mul_neg]

theorem fabric_stress_invariant (ε : Particle → Bool) (s : State) :
    fabricStress (signState ε s)=fabricStress s := by
  funext p i j
  simp only [fabricStress, strain_signed, sb]
  cases h : ε p <;> simp [signState, signedFabric, h, Pi.neg_apply, neg_mul, mul_neg]

theorem extra_conductivity_invariant (ε : Particle → Bool) (G : Geometry) (s : State) :
    extraConductivity G (signState ε s)=extraConductivity G s := by
  funext p i j
  simp only [extraConductivity, effective, sm, normfiber_signed, fiber_signed]
  cases h : ε p <;> simp [h, sqnorm, Pi.neg_apply, neg_div, mul_neg, neg_mul]

theorem fiber_rate_invariant (ε : Particle → Bool) (G : Geometry) (s : State) :
    fiberRate G (signState ε s)=fiberRate G s := by
  funext p k
  simp only [fiberRate, particle_signed, fiber_signed]
  cases h : ε p <;> simp [h, Pi.neg_apply, mul_neg, neg_mul]

private theorem raw_signed (ε) (G : Geometry) (s : State) :
    rawRate G (signState ε s)=rawRate G s := by
  funext p k a
  simp only [rawRate, fiber_rate_invariant]

private theorem sensitivity_signed (ε) (G : Geometry) (s : State) :
    sensitivity G (signState ε s)=sensitivity G s := by
  funext p k a
  simp only [sensitivity, sm, fiberstrain_signed]

private theorem power_signed (ε) (G : Geometry) (s : State) :
    rawPower G (signState ε s)=rawPower G s := by
  funext p
  simp only [rawPower, sensitivity_signed, raw_signed]

private theorem denominator_signed (ε) (G : Geometry) (s : State) :
    powerDenominator G (signState ε s)=powerDenominator G s := by
  funext p
  simp only [powerDenominator, available_signed, power_signed]

private theorem extraction_signed (ε) (G : Geometry) (s : State) :
    extraction G (signState ε s)=extraction G s := by
  funext x
  simp only [extraction, viscous_signed, occupancy_signed, sx, power_signed, denominator_signed]

private theorem fabric_heat_signed (ε) (s : State) : fabricHeat (signState ε s)=fabricHeat s := by
  funext p
  simp only [fabricHeat, strain_signed, sb]

private theorem release_signed (ε) (G : Geometry) (s : State) :
    releaseGrid G (signState ε s)=releaseGrid G s := by
  funext x
  simp only [releaseGrid, sx, fabric_heat_signed]

private theorem conductivity_signed (ε) (G : Geometry) (s : State) :
    conductivity G (signState ε s)=conductivity G s := by
  funext x i j
  simp only [conductivity, sx, extra_conductivity_invariant]

private theorem heatflux_signed (ε) (G : Geometry) (s : State) :
    heatFlux G (signState ε s)=heatFlux G s := by
  funext x i
  simp only [heatFlux, conductivity_signed, sg]

private theorem stress_signed (ε) (G : Geometry) (s : State) :
    fullStress G (signState ε s)=fullStress G s := by
  funext x i j
  simp only [fullStress, sx, material_stress_invariant, fabric_stress_invariant]

private theorem momentum_signed (ε) (G : Geometry) (s : State) :
    momentumRate G (signState ε s)=momentumRate G s := by
  simp only [momentumRate, gradient_signed, velocity_signed, stress_signed, forcing_signed]
  rfl

private theorem mm_signed (ε) (L F : Particle → Mat) :
    (fun p => mm (L p) (signedFabric ε F p))=
      signedFabric ε (fun p => mm (L p) (F p)) := by
  funext p i j
  cases h : ε p <;>
    simp [signedFabric, h, mm, Pi.neg_apply, mul_neg, Finset.sum_neg_distrib]

theorem full_rhs_equivariant (ε : Particle → Bool) (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) :
    rhsFromRecords G t (signState ε s) rs=signState ε (rhsFromRecords G t s rs) := by
  simp only [rhsFromRecords, social_signed, momentum_signed, sx, sg, sA, sb,
    velocity_signed, available_signed, denominator_signed, raw_signed, heatflux_signed,
    viscous_signed, extraction_signed, release_signed, strain_signed, particle_signed,
    forcing_signed]
  simp only [signState]
  rw [mm_signed]

theorem accepted_rhs_equivariant (ε : Particle → Bool) (G : Geometry) (t : ℝ) (s : State) :
    rhs G t (signState ε s)=(rhs G t s).map (signState ε) := by
  unfold rhs
  simp only [read_signed, normfiber_signed, exposure_signed, occupancy_signed,
    denominator_signed, full_rhs_equivariant, Option.bind_eq_bind]
  cases hr : readRecords s with
  | none => simp
  | some rs =>
    simp only [Option.bind_some]
    split <;> simp_all

theorem event_record_invariant (ε : Particle → Bool) (s : State)
    (startF : Particle → Mat) (id : Fin 3) :
    makeEvent (signState ε s) (signedFabric ε startF) id=makeEvent s startF id := by
  rw [sign_as_rotation, signed_as_matrix]
  exact YMAuditVerified.event_record_frame_invariant s startF _ _
    (signQ_orthogonal ε) (signQ_orthogonal ε) id

theorem write_equivariant (ε : Particle → Bool) (G : Geometry) (s : State) (r : Record) :
    writeEvent G (signState ε s) r=(writeEvent G s r).map (signState ε) := by
  rw [sign_as_rotation]
  exact YMAuditVerified.memory_write_frame_equivariant G s _ (signQ_orthogonal ε) r

theorem capture_equivariant (ε : Particle → Bool) (id : Fin 3) (y : FullState) :
    capture id (signFull ε y)=signFull ε (capture id y) := by
  unfold capture signFull
  congr 1
  funext j
  by_cases h : j=id <;> simp [Function.update_apply, h, signState]

private def completeWith (G : Geometry) (id : Fin 3) (y : FullState) : Option FullState := do
  let startF ← y.starts id
  let record ← makeEvent y.state startF id
  let state ← writeEvent G y.state record
  return ⟨state, Function.update y.starts id none⟩

private theorem compose_optional_maps {α β γ δ : Type}
    (input : Option α) (f f' : α → Option β) (g g' : β → Option γ)
    (r r' : γ → δ) (a : α → α) (c : γ → γ) (d : δ → δ)
    (hf : ∀ x, f' (a x)=f x) (hg : ∀ x, g' x=(g x).map c)
    (hr : ∀ x, r' (c x)=d (r x)) :
    ((input.map a).bind fun x => (f' x).bind fun y =>
      (g' y).bind fun z => some (r' z)) =
    (input.bind fun x => (f x).bind fun y => (g y).bind fun z => some (r z)).map d := by
  cases input with
  | none => rfl
  | some x =>
    simp only [Option.map_some, Option.bind_some, hf]
    cases f x with
    | none => rfl
    | some y =>
      simp only [Option.bind_some, hg]
      cases g y <;> simp [hr]

private theorem completeWith_equivariant (ε : Particle → Bool) (G : Geometry)
    (id : Fin 3) (y : FullState) :
    completeWith G id (signFull ε y)=(completeWith G id y).map (signFull ε) := by
  have hu : Function.update (fun j => (y.starts j).map (signedFabric ε)) id none =
      fun j => ((Function.update y.starts id none) j).map (signedFabric ε) := by
    funext j
    by_cases h : j=id <;> simp [Function.update_apply, h]
  have hfinish : ∀ z : State,
      (FullState.mk (signState ε z)
        (Function.update (fun j => (y.starts j).map (signedFabric ε)) id none)) =
      signFull ε (FullState.mk z (Function.update y.starts id none)) := by
    intro z
    unfold signFull
    rw [hu]
  exact compose_optional_maps (y.starts id)
    (fun F => makeEvent y.state F id) (fun F => makeEvent (signState ε y.state) F id)
    (writeEvent G y.state) (writeEvent G (signState ε y.state))
    (fun z => FullState.mk z (Function.update y.starts id none))
    (fun z => FullState.mk z
      (Function.update (fun j => (y.starts j).map (signedFabric ε)) id none))
    (signedFabric ε) (signState ε) (signFull ε)
    (fun F => event_record_invariant ε y.state F id)
    (fun r => write_equivariant ε G y.state r) hfinish

theorem complete_event_equivariant (ε : Particle → Bool) (id : Fin 3) (y : FullState) :
    completeEvent id (signFull ε y)=(completeEvent id y).map (signFull ε) := by
  exact completeWith_equivariant ε sourceGeometry id y

theorem all_boundaries_equivariant (ε : Particle → Bool) (k : ℕ) (y : FullState) :
    boundary k (signFull ε y)=(boundary k y).map (signFull ε) := by
  match k with
  | 0 => simp [boundary, capture_equivariant]
  | 1 => simp [boundary, capture_equivariant]
  | 2 => simp [boundary, complete_event_equivariant]
  | 3 => simp [boundary, complete_event_equivariant, Option.map_map, Function.comp_def,
      capture_equivariant]
  | 4 => simp [boundary, complete_event_equivariant]
  | k+5 => rfl

theorem buffer_commutes (ε : Particle → Bool) (present past : State) :
    socialFrom (signState ε present) (signState ε past)=signState ε (socialFrom present past) := by rfl

theorem delayed_rhs_equivariant (ε : Particle → Bool) (G : Geometry) (t : ℝ)
    (present past : State) :
    rhsDelayed G t (signState ε present) (signState ε past)=
      (rhsDelayed G t present past).map (signState ε) := by
  unfold rhsDelayed
  rw [buffer_commutes]
  simp only [accepted_rhs_equivariant, Option.bind_eq_bind]
  cases hp : rhs G t present <;> cases hq : rhs G t (socialFrom present past) <;>
    simp [buffer_commutes]

theorem delayed_history_equivariant (ε : Particle → Bool) (G : Geometry) (τ t : ℝ)
    (history : ℝ → State) :
    rhsAlong G τ (fun r => signState ε (history r)) t=
      (rhsAlong G τ history t).map (signState ε) := by
  exact delayed_rhs_equivariant ε G t (history t) (history (t-τ))

theorem derivative_covariant (ε : Particle → Bool) (s : ℝ → State) (d : State)
    (I : Set ℝ) (t : ℝ) (h : StateHasDerivWithinAt s d I t) :
    StateHasDerivWithinAt (fun r => signState ε (s r)) (signState ε d) I t := by
  rcases h with ⟨hg,hX,hF,hm,hb,hA,hl,hw,he,hc,hn,hr,hrel,hresp,ha⟩
  refine ⟨hg,hX,?_,hm,hb,hA,hl,hw,he,hc,hn,hr,hrel,hresp,ha⟩
  intro p i j
  cases hε : ε p
  · simpa [signState, signedFabric, hε] using hF p i j
  · simp only [signState, signedFabric, hε, ite_true, Pi.neg_apply]
    exact (hF p i j).neg

theorem continuity_covariant (ε : Particle → Bool) (s : ℝ → State) (I : Set ℝ)
    (h : ContinuousStateOn s I) :
    ContinuousStateOn (fun r => signState ε (s r)) I := by
  rcases h with ⟨hg,hX,hF,hm,hb,hA,hl,hw,he,hc,hn,hr,hrel,hresp,ha⟩
  refine ⟨hg,hX,?_,hm,hb,hA,hl,hw,he,hc,hn,hr,hrel,hresp,ha⟩
  intro p i j
  cases hε : ε p
  · simpa [signState, signedFabric, hε] using hF p i j
  · simp only [signState, signedFabric, hε, ite_true, Pi.neg_apply]
    exact (hF p i j).neg

theorem delayed_segment_covariant (ε : Particle → Bool) (G : Geometry) (τ : ℝ)
    (history : ℝ → State) (I : Set ℝ) (h : DelayedSegment G τ history I) :
    DelayedSegment G τ (fun t => signState ε (history t)) I := by
  refine ⟨continuity_covariant ε history I h.1,?_⟩
  intro t ht
  obtain ⟨d,hd,hder⟩ := h.2 t ht
  refine ⟨signState ε d,?_,derivative_covariant ε history d I t hder⟩
  rw [delayed_history_equivariant, hd]
  rfl

theorem original_solution_predicate (tr : Trace) :
    SolvesFrom initialFull tr ↔ Solves tr := by rfl

theorem full_trace_covariant (ε : Particle → Bool) (y₀ : FullState) (tr : Trace)
    (h : SolvesFrom y₀ tr) :
    SolvesFrom (signFull ε y₀) (signTrace ε tr) := by
  refine ⟨congrArg (signFull ε) h.1,?_⟩
  intro k hk
  rcases h.2 k hk with ⟨hs,hc,hm,hd,hb⟩
  refine ⟨congrArg (signFull ε) hs,continuity_covariant ε _ _ hc,?_,?_,?_⟩
  · intro t ht
    change (fun id => ((tr.path k t).starts id).map (signedFabric ε))=
      (fun id => ((tr.after k).starts id).map (signedFabric ε))
    rw [hm t ht]
  · intro t ht
    obtain ⟨d,hr,hder⟩ := hd t ht
    refine ⟨signState ε d,?_,derivative_covariant ε _ d _ t hder⟩
    change rhs sourceGeometry t (signState ε (tr.path k t).state)=_
    rw [accepted_rhs_equivariant,hr]
    rfl
  · change boundary (k+1) (signFull ε (tr.path k (time (k+1))))=_
    rw [all_boundaries_equivariant,hb]
    rfl

theorem initial_reversal_is_not_fixed :
    signFull (fun _ => true) initialFull ≠ initialFull := by
  intro h
  have he := congrArg (fun y : FullState => y.state.F (0:Particle) 0 0) h
  norm_num [signFull, signState, signedFabric, initialFull, capture, initial, eye] at he

theorem forcing_has_fixed_direction (s : State) (x : Grid) :
    forcing s x 1=0 ∧ forcing s x 2=0 := by simp [forcing]

theorem gradient_witness_norm (G : Geometry) :
    sqnorm (centeredGradient (gradientWitness G) zeroGrid)=1 := by
  norm_num [sqnorm, centeredGradient, gradientWitness, zeroGrid, shifted, dx,
    Fin.sum_univ_succ]

theorem witness_force_nonzero (G : Geometry) :
    forcing (gradientWitness G) zeroGrid 0<0 := by
  have hq : 0<Real.sqrt (1+0.003^2)-Real.sqrt (0.015^2+0.003^2) := by
    apply sub_pos.mpr
    apply Real.sqrt_lt_sqrt <;> norm_num
  have ha : 0<activation (Real.sqrt (1+0.003^2)-Real.sqrt (0.015^2+0.003^2)) := by
    rw [activation, if_pos hq]
    exact mul_pos hq (Real.exp_pos _)
  change -0.16*activation (Real.sqrt (sqnorm (centeredGradient (gradientWitness G) zeroGrid)+0.003^2)-
    Real.sqrt (0.015^2+0.003^2))<0
  rw [gradient_witness_norm]
  exact mul_neg_of_neg_of_pos (by norm_num) ha

theorem quarter_turn_force_not_covariant (G : Geometry) :
    forcing (quarterState (gradientWitness G)) zeroGrid ≠
      quarterVector (forcing (gradientWitness G) (inverseQuarterGrid zeroGrid)) := by
  have hz : inverseQuarterGrid zeroGrid=zeroGrid := by
    funext j
    fin_cases j <;> norm_num [inverseQuarterGrid, zeroGrid, reflectedIndex]
  intro h
  have he := congrFun h (1:Axis)
  change 0=forcing (gradientWitness G) (inverseQuarterGrid zeroGrid) 0 at he
  rw [hz] at he
  linarith [witness_force_nonzero G]

end
end HugV3.Source.CovarianceVerified
