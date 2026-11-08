import V3JointFrameDefinitions
namespace HugV3.Source.JointFrameVerified
noncomputable section
open JointFrame Covariance Delay
open scoped BigOperators
theorem quarter_scale (a : ℝ) (v : Vec) :
  quarterVector (fun i => a*v i)=fun i => a*quarterVector v i := by sorry
theorem quarter_dot (u v : Vec) : dot (quarterVector u) (quarterVector v)=dot u v := by sorry
theorem quarter_norm (v : Vec) : sqnorm (quarterVector v)=sqnorm v := by sorry
theorem grid_inverse (x : Grid) :
  forwardQuarterGrid (inverseQuarterGrid x)=x ∧ inverseQuarterGrid (forwardQuarterGrid x)=x := by sorry
theorem grid_sum (f : Scalar) : (∑ x, scalarPull f x)=∑ x, f x := by sorry
theorem centered_gradient_covariant (s : State) (x : Grid) :
  centeredGradient (quarterState s) x=quarterVector (centeredGradient s (inverseQuarterGrid x)) := by sorry
theorem force_amplitude_invariant (s : State) (x : Grid) :
  forceAmplitude (quarterState s) x=forceAmplitude s (inverseQuarterGrid x) := by sorry
theorem original_force_recovered (s : State) : directedForce referenceDirection s=forcing s := by sorry
theorem driving_direction_rotates : quarterVector referenceDirection=![0,1,0] := by sorry
theorem joint_force_covariant (d : Vec) (s : State) :
  directedForce (quarterVector d) (quarterState s)=vectorPull (directedForce d s) := by sorry
theorem force_work_density_invariant (d : Vec) (s : State) (x : Grid) :
  dot (velocity (quarterState s) x) (directedForce (quarterVector d) (quarterState s) x)=
  dot (velocity s (inverseQuarterGrid x)) (directedForce d s (inverseQuarterGrid x)) := by sorry
theorem original_momentum_recovered (G : Geometry) (s : State) :
  momentumInFrame referenceDirection G s=momentumRate G s := by sorry
theorem original_full_rates_recovered (G : Geometry) (t : ℝ) (s : State) (rs) :
  ratesInFrame referenceDirection G t s rs=rhsFromRecords G t s rs := by sorry
theorem original_accepted_rates_recovered (G : Geometry) (t : ℝ) (s : State) :
  acceptedInFrame referenceDirection G t s=rhs G t s := by sorry
theorem non_driving_rates_unchanged (d : Vec) (G : Geometry) (t : ℝ) (s : State) (rs) :
  SameNonDrivingRates (ratesInFrame d G t s rs) (rhsFromRecords G t s rs) := by sorry
theorem force_work_ledger_invariant (d : Vec) (G : Geometry) (t : ℝ) (s : State) (rs) :
  (ratesInFrame (quarterVector d) G t (quarterState s) rs).ledger 1=
  (ratesInFrame d G t s rs).ledger 1 := by sorry
theorem green_spatially_invariant (F : Particle → Mat) (p : Particle) :
  green (quarterFabric F p)=green (F p) := by sorry
theorem records_spatially_invariant (s : State) : readRecords (quarterState s)=readRecords s := by sorry
theorem memory_feature_invariant (G : Geometry) (s : State) :
  memoryFeature G (quarterState s)=memoryFeature G s := by sorry
theorem retrieval_invariant (G : Geometry) (s : State) (rs) :
  memory G (quarterState s) rs=memory G s rs := by sorry
theorem event_record_invariant (s : State) (startF : Particle → Mat) (id : Fin 3) :
  makeEvent (quarterState s) (quarterFabric startF) id=makeEvent s startF id := by sorry
theorem write_account_invariant (G : Geometry) (s : State) (target : Cell → ℝ) :
  writeAccount G (quarterState s) target=writeAccount G s target := by sorry
theorem write_equivariant_under_thermal_compatibility (h : ThermalFrameCompatibility)
  (G : Geometry) (s : State) (r : Record) :
  writeEvent G (quarterState s) r=(writeEvent G s r).map quarterState := by sorry
theorem capture_equivariant (id : Fin 3) (y : FullState) :
  capture id (quarterFull y)=quarterFull (capture id y) := by sorry
theorem buffer_commutes (present past : State) :
  socialFrom (quarterState present) (quarterState past)=quarterState (socialFrom present past) := by sorry
theorem original_delay_recovered (G : Geometry) (t : ℝ) (present past : State) :
  delayedInFrame referenceDirection G t present past=rhsDelayed G t present past := by sorry
theorem derivative_covariant (s : ℝ → State) (d : State) (I : Set ℝ) (t : ℝ)
  (h : StateHasDerivWithinAt s d I t) :
  StateHasDerivWithinAt (fun r => quarterState (s r)) (quarterState d) I t := by sorry
theorem continuity_covariant (s : ℝ → State) (I : Set ℝ) (h : ContinuousStateOn s I) :
  ContinuousStateOn (fun r => quarterState (s r)) I := by sorry
theorem kinematic_matrix_covariance (L F : Mat) :
  mm (conjugateQuarter L) (fun i j => quarterVector (fun k => F k j) i)=
  fun i j => quarterVector (fun k => mm L F k j) i := by sorry
theorem full_deformation_covariant_if_gradient_transforms (d : Vec) (G : Geometry)
  (t : ℝ) (s : State) (rs)
  (h : ∀ p, particleGradient (quarterState s) p=conjugateQuarter (particleGradient s p)) :
  (ratesInFrame (quarterVector d) G t (quarterState s) rs).F=
  (quarterState (ratesInFrame d G t s rs)).F := by sorry
theorem social_rates_invariant_if_observations_match (G : Geometry) (t : ℝ) (s : State) (rs)
  (h : observations G (quarterState s)=observations G s) :
  socialRates G t (quarterState s) rs=socialRates G t s rs := by sorry
end
end HugV3.Source.JointFrameVerified
