import V3JointFrameDefinitions
namespace HugV3.Source.JointFrameVerified
noncomputable section
attribute [local instance] Classical.propDecidable
open JointFrame Covariance Delay
open scoped BigOperators
set_option maxRecDepth 4096

theorem quarter_scale (a : ℝ) (v : Vec) :
    quarterVector (fun i => a*v i)=fun i => a*quarterVector v i := by
  funext i
  fin_cases i <;> simp [quarterVector]

theorem quarter_dot (u v : Vec) : dot (quarterVector u) (quarterVector v)=dot u v := by
  simp [dot,quarterVector,Fin.sum_univ_succ]
  ring

theorem quarter_norm (v : Vec) : sqnorm (quarterVector v)=sqnorm v := by
  simp [sqnorm,quarterVector,Fin.sum_univ_succ]
  ring

theorem grid_inverse (x : Grid) :
    forwardQuarterGrid (inverseQuarterGrid x)=x ∧ inverseQuarterGrid (forwardQuarterGrid x)=x := by
  constructor <;> funext i <;> fin_cases i <;> apply Fin.ext <;>
    simp [forwardQuarterGrid,inverseQuarterGrid,reflectedIndex] <;> omega

private def pullEquiv : Grid ≃ Grid :=
  ⟨inverseQuarterGrid,forwardQuarterGrid,fun x => (grid_inverse x).1,fun x => (grid_inverse x).2⟩

theorem grid_sum (f : Scalar) : (∑ x, scalarPull f x)=∑ x, f x := by
  exact Equiv.sum_comp pullEquiv f

private theorem pull_shift (x : Grid) (i : Axis) (n : ℕ) :
    inverseQuarterGrid (shifted x i n)=
      shifted (inverseQuarterGrid x) (![1,0,2] i) (if i=0 then (16-n%16)%16 else n) := by
  fin_cases i <;> funext j <;> fin_cases j <;> apply Fin.ext <;>
    simp [inverseQuarterGrid,reflectedIndex,shifted] <;> omega

theorem centered_gradient_covariant (s : State) (x : Grid) :
    centeredGradient (quarterState s) x=quarterVector (centeredGradient s (inverseQuarterGrid x)) := by
  funext j
  fin_cases j <;> simp [centeredGradient,quarterState,pull_shift,quarterVector] <;> ring

theorem force_amplitude_invariant (s : State) (x : Grid) :
    forceAmplitude (quarterState s) x=forceAmplitude s (inverseQuarterGrid x) := by
  simp only [forceAmplitude,centered_gradient_covariant,quarter_norm]

theorem original_force_recovered (s : State) : directedForce referenceDirection s=forcing s := by
  funext x i
  fin_cases i <;> simp [directedForce,referenceDirection,forceAmplitude,forcing]

theorem driving_direction_rotates : quarterVector referenceDirection=![0,1,0] := by
  funext i
  fin_cases i
  · change -(0:ℝ)=0
    ring
  · rfl
  · rfl

theorem joint_force_covariant (d : Vec) (s : State) :
    directedForce (quarterVector d) (quarterState s)=vectorPull (directedForce d s) := by
  funext x i
  change forceAmplitude (quarterState s) x*quarterVector d i=
    quarterVector (fun j => forceAmplitude s (inverseQuarterGrid x)*d j) i
  rw [force_amplitude_invariant,quarter_scale]

private theorem velocity_quarter (s : State) : velocity (quarterState s)=vectorPull (velocity s) := by
  funext x i
  fin_cases i <;> rfl

theorem force_work_density_invariant (d : Vec) (s : State) (x : Grid) :
    dot (velocity (quarterState s) x) (directedForce (quarterVector d) (quarterState s) x)=
    dot (velocity s (inverseQuarterGrid x)) (directedForce d s (inverseQuarterGrid x)) := by
  rw [velocity_quarter,joint_force_covariant]
  exact quarter_dot _ _

theorem original_momentum_recovered (G : Geometry) (s : State) :
    momentumInFrame referenceDirection G s=momentumRate G s := by
  simp only [momentumInFrame,original_force_recovered]
  rfl

theorem original_full_rates_recovered (G : Geometry) (t : ℝ) (s : State) (rs) :
    ratesInFrame referenceDirection G t s rs=rhsFromRecords G t s rs := by
  simp only [ratesInFrame,original_force_recovered,original_momentum_recovered]
  rfl

theorem original_accepted_rates_recovered (G : Geometry) (t : ℝ) (s : State) :
    acceptedInFrame referenceDirection G t s=rhs G t s := by
  simp only [acceptedInFrame,original_full_rates_recovered]
  rfl

theorem non_driving_rates_unchanged (d : Vec) (G : Geometry) (t : ℝ) (s : State) (rs) :
    SameNonDrivingRates (ratesInFrame d G t s rs) (rhsFromRecords G t s rs) := by
  simp [SameNonDrivingRates,SameSocial,ratesInFrame,rhsFromRecords]

theorem force_work_ledger_invariant (d : Vec) (G : Geometry) (t : ℝ) (s : State) (rs) :
    (ratesInFrame (quarterVector d) G t (quarterState s) rs).ledger 1=
    (ratesInFrame d G t s rs).ledger 1 := by
  change (∑ x, dot (velocity (quarterState s) x)
    (directedForce (quarterVector d) (quarterState s) x))/4096=
    (∑ x, dot (velocity s x) (directedForce d s x))/4096
  simp_rw [force_work_density_invariant]
  rw [show (∑ x, dot (velocity s (inverseQuarterGrid x))
      (directedForce d s (inverseQuarterGrid x)))=
      ∑ x, dot (velocity s x) (directedForce d s x) from
        grid_sum (fun x => dot (velocity s x) (directedForce d s x))]

theorem green_spatially_invariant (F : Particle → Mat) (p : Particle) :
    green (quarterFabric F p)=green (F p) := by
  funext i j
  simp [green,quarterFabric,quarterVector,Fin.sum_univ_succ]
  ring

private theorem probe_exact (s : State) (l : Cell) : probeEstimate s l=s.b l := by
  unfold probeEstimate
  ring

theorem records_spatially_invariant (s : State) : readRecords (quarterState s)=readRecords s := by
  simp only [readRecords,slotBytes,probe_exact,quarterState]

private theorem strain_invariant (s : State) (p : Particle) :
    strainNorm ((quarterState s).F p)=strainNorm (s.F p) := by
  change strainNorm (quarterFabric s.F p)=_
  simp only [strainNorm,green_spatially_invariant]

theorem memory_feature_invariant (G : Geometry) (s : State) :
    memoryFeature G (quarterState s)=memoryFeature G s := by
  funext i j
  simp only [memoryFeature,strain_invariant]
  rfl

private theorem weight_invariant (G : Geometry) (s : State) (r : Record) :
    recordWeight G (quarterState s) r=recordWeight G s r := by
  simp only [recordWeight,memory_feature_invariant]
  rfl

private theorem exposure_invariant (G : Geometry) (s : State) (rs) :
    exposure G (quarterState s) rs=exposure G s rs := by
  funext i j
  simp only [exposure,weight_invariant]

theorem retrieval_invariant (G : Geometry) (s : State) (rs) :
    memory G (quarterState s) rs=memory G s rs := by
  funext i j k
  simp only [memory,weight_invariant,exposure_invariant]

theorem event_record_invariant (s : State) (startF : Particle → Mat) (id : Fin 3) :
    makeEvent (quarterState s) (quarterFabric startF) id=makeEvent s startF id := by
  have h : (quarterState s).F=quarterFabric s.F := rfl
  simp only [makeEvent,records_spatially_invariant,h,green_spatially_invariant]
  rfl

private theorem fabric_strain_invariant (s : State) (l : Cell) :
    fabricStrain (quarterState s).F l=fabricStrain s.F l := by
  simp [fabricStrain,quarterState,quarterVector,Fin.sum_univ_succ]
  ring

private theorem stored_invariant (G : Geometry) (s : State) (b : Cell → ℝ) :
    storedEnergy G (quarterState s) b=storedEnergy G s b := by
  simp only [storedEnergy,fabric_strain_invariant]

theorem write_account_invariant (G : Geometry) (s : State) (target : Cell → ℝ) :
    writeAccount G (quarterState s) target=writeAccount G s target := by
  simp only [writeAccount,stored_invariant,fabric_strain_invariant]
  rfl

private def deposit (G : Geometry) (s : State) (account : WriteAccount) : State :=
  { s with
    b := account.target
    g := fun x j => s.g x j + if j=4 then
      filt (fun x => (∑ p, R s.X p x*G.V p*account.heat p)/dv) x else 0
    writeWork := s.writeWork+account.work }

private theorem deposit_covariant (h : ThermalFrameCompatibility) (G : Geometry)
    (s : State) (account : WriteAccount) :
    deposit G (quarterState s) account=quarterState (deposit G s account) := by
  have hheat : (fun x => (∑ p, R (quarterState s).X p x*G.V p*account.heat p)/dv)=
      scalarPull (fun x => (∑ p, R s.X p x*G.V p*account.heat p)/dv) := by
    funext x
    simp only [quarterState,h.1,scalarPull]
  have hf := h.2 (fun x => (∑ p, R s.X p x*G.V p*account.heat p)/dv)
  unfold deposit
  simp only [hheat,hf]
  unfold quarterState
  congr 1
  funext x j
  fin_cases j <;> simp [velocity,quarterVector,scalarPull]

theorem write_equivariant_under_thermal_compatibility (h : ThermalFrameCompatibility)
    (G : Geometry) (s : State) (r : Record) :
    writeEvent G (quarterState s) r=(writeEvent G s r).map quarterState := by
  have ht : ∀ slot bytes, targetFabric (quarterState s) slot bytes=targetFabric s slot bytes :=
    fun _ _ => rfl
  unfold writeEvent
  simp only [records_spatially_invariant,ht,write_account_invariant]
  cases hr : readRecords s with
  | none => simp
  | some rs =>
    simp only [Option.bind_eq_bind,Option.bind_some]
    split
    · simp
    · cases hf : (List.ofFn (fun slot : Fin 4 => slot)).find?
        (fun slot => !(rs.any (fun r => r.1 == slot))) with
      | none => simp
      | some slot =>
        simp only [Option.bind_eq_bind,Option.bind_some]
        cases hb : payload r with
        | none => simp
        | some bytes =>
          simp only [Option.bind_eq_bind,Option.bind_some]
          split
          · simp
          · exact congrArg some (deposit_covariant h G s
              (writeAccount G s (targetFabric s slot bytes)))

theorem capture_equivariant (id : Fin 3) (y : FullState) :
    capture id (quarterFull y)=quarterFull (capture id y) := by
  have hu : Function.update (fun j => (y.starts j).map quarterFabric) id
      (some (quarterFabric y.state.F))=
      fun j => (Function.update y.starts id (some y.state.F) j).map quarterFabric := by
    funext j
    by_cases h : j=id <;> simp [Function.update_apply,h]
  unfold capture quarterFull
  exact congrArg (FullState.mk (quarterState y.state)) hu

theorem buffer_commutes (present past : State) :
    socialFrom (quarterState present) (quarterState past)=quarterState (socialFrom present past) := by rfl

theorem original_delay_recovered (G : Geometry) (t : ℝ) (present past : State) :
    delayedInFrame referenceDirection G t present past=rhsDelayed G t present past := by
  simp only [delayedInFrame,original_accepted_rates_recovered]
  rfl

theorem derivative_covariant (s : ℝ → State) (d : State) (I : Set ℝ) (t : ℝ)
    (h : StateHasDerivWithinAt s d I t) :
    StateHasDerivWithinAt (fun r => quarterState (s r)) (quarterState d) I t := by
  rcases h with ⟨hg,hX,hF,hm,hb,hA,hl,hw,he,hc,hn,hr,hrel,hresp,ha⟩
  refine ⟨?_,?_,?_,hm,hb,hA,hl,hw,he,hc,hn,hr,hrel,hresp,ha⟩
  · intro x k
    fin_cases k
    · change HasDerivWithinAt (fun r => -(s r).g (inverseQuarterGrid x) 1)
        (-d.g (inverseQuarterGrid x) 1) I t
      exact (hg (inverseQuarterGrid x) 1).neg
    · exact hg (inverseQuarterGrid x) 0
    · exact hg (inverseQuarterGrid x) 2
    · exact hg (inverseQuarterGrid x) 3
    · exact hg (inverseQuarterGrid x) 4
  · intro p i
    fin_cases i
    · exact (hX p 1).neg
    · exact hX p 0
    · exact hX p 2
  · intro p i j
    fin_cases i
    · exact (hF p 1 j).neg
    · exact hF p 0 j
    · exact hF p 2 j

theorem continuity_covariant (s : ℝ → State) (I : Set ℝ) (h : ContinuousStateOn s I) :
    ContinuousStateOn (fun r => quarterState (s r)) I := by
  rcases h with ⟨hg,hX,hF,hm,hb,hA,hl,hw,he,hc,hn,hr,hrel,hresp,ha⟩
  refine ⟨?_,?_,?_,hm,hb,hA,hl,hw,he,hc,hn,hr,hrel,hresp,ha⟩
  · intro x k
    fin_cases k
    · exact (hg (inverseQuarterGrid x) 1).neg
    · exact hg (inverseQuarterGrid x) 0
    · exact hg (inverseQuarterGrid x) 2
    · exact hg (inverseQuarterGrid x) 3
    · exact hg (inverseQuarterGrid x) 4
  · intro p i
    fin_cases i
    · exact (hX p 1).neg
    · exact hX p 0
    · exact hX p 2
  · intro p i j
    fin_cases i
    · exact (hF p 1 j).neg
    · exact hF p 0 j
    · exact hF p 2 j

theorem kinematic_matrix_covariance (L F : Mat) :
    mm (conjugateQuarter L) (fun i j => quarterVector (fun k => F k j) i)=
    fun i j => quarterVector (fun k => mm L F k j) i := by
  funext i j
  fin_cases i <;> fin_cases j <;>
    simp [conjugateQuarter,mm,YMAudit.quarterTurn,quarterVector,Fin.sum_univ_succ] <;> ring

theorem full_deformation_covariant_if_gradient_transforms (d : Vec) (G : Geometry)
    (t : ℝ) (s : State) (rs)
    (h : ∀ p, particleGradient (quarterState s) p=conjugateQuarter (particleGradient s p)) :
    (ratesInFrame (quarterVector d) G t (quarterState s) rs).F=
    (quarterState (ratesInFrame d G t s rs)).F := by
  funext p
  change mm (particleGradient (quarterState s) p)
    (fun i j => quarterVector (fun k => s.F p k j) i)=_
  rw [h p]
  exact kinematic_matrix_covariance _ _

theorem social_rates_invariant_if_observations_match (G : Geometry) (t : ℝ) (s : State) (rs)
    (h : observations G (quarterState s)=observations G s) :
    socialRates G t (quarterState s) rs=socialRates G t s rs := by
  have hu : utility G (quarterState s) rs=utility G s rs := by
    simp only [utility,retrieval_invariant,h]
    rfl
  simp only [socialRates,retrieval_invariant,h,hu,margin]
  rfl

end
end HugV3.Source.JointFrameVerified
