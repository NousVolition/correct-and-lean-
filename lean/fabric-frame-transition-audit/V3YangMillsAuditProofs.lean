import V3YangMillsAuditDefinitions
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Analysis.Calculus.Deriv.Mul

/-! Proofs about the unchanged full Hug v3 definitions. No challenge import,
replacement dynamics, admitted theorem or additional axiom is used. -/
namespace HugV3.Source.YMAuditVerified
noncomputable section
attribute [local instance] Classical.propDecidable
open YMAudit Delay
open scoped BigOperators
set_option maxRecDepth 4096

private theorem gram_objective (Q F : Mat) (hQ : Orthogonal Q) :
    (Matrix.of (mm Q F)).transpose * (Matrix.of (mm Q F)) =
    (Matrix.of F).transpose * (Matrix.of F) := by
  change (((Matrix.of Q) * (Matrix.of F)).transpose) *
    ((Matrix.of Q) * (Matrix.of F)) = _
  rw [Matrix.transpose_mul]
  calc
    _ = (Matrix.of F).transpose *
      (((Matrix.of Q).transpose * (Matrix.of Q)) * Matrix.of F) := by
        simp only [Matrix.mul_assoc]
    _ = _ := by rw [hQ, Matrix.one_mul]

theorem green_objective (Q F : Mat) (hQ : Orthogonal Q) :
    green (mm Q F)=green F := by
  have h := gram_objective Q F hQ
  funext i j
  change (((Matrix.of (mm Q F)).transpose *
      (Matrix.of (mm Q F))) i j-eye i j)/2 =
    (((Matrix.of F).transpose * (Matrix.of F)) i j-eye i j)/2
  rw [h]

theorem strain_norm_objective (Q F : Mat) (hQ : Orthogonal Q) :
    strainNorm (mm Q F)=strainNorm F := by
  simp only [strainNorm, green_objective Q F hQ]

private theorem norm_objective (Q : Mat) (v : Vec) (hQ : Orthogonal Q) :
    sqnorm (fun i => ∑ j, Q i j*v j)=sqnorm v := by
  have h := congrFun (congrFun (gram_objective Q (fun i _ => v i) hQ) 0) 0
  change (∑ i, (∑ j, Q i j*v j)*(∑ j, Q i j*v j))=(∑ i, v i*v i) at h
  simpa only [sqnorm, pow_two] using h

theorem fiber_strain_objective (G : Geometry) (s : State) (Q : Particle → Mat)
    (hQ : ∀ p, Orthogonal (Q p)) (p : Particle) (k : Direction) :
    fiberStrain G (rotateFabric Q s) p k=fiberStrain G s p k := by
  have hf : fiber G (rotateFabric Q s) p k =
      fun i => ∑ j, Q p i j*fiber G s p k j := by
    funext i
    simp only [fiber, rotateFabric, mm, Fin.sum_univ_succ]
    ring
  simp only [fiberStrain, hf, norm_objective _ _ (hQ p)]

theorem fabric_strain_objective (s : State) (Q : Particle → Mat)
    (hQ : ∀ p, Orthogonal (Q p)) (l : Cell) :
    fabricStrain (rotateFabric Q s).F l=fabricStrain s.F l := by
  have h := congrFun (congrFun (gram_objective (Q (point l)) (s.F (point l)) (hQ _))
    (axis l)) (axis l)
  change (∑ i, mm (Q (point l)) (s.F (point l)) i (axis l) *
    mm (Q (point l)) (s.F (point l)) i (axis l))=
    (∑ i, s.F (point l) i (axis l)*s.F (point l) i (axis l)) at h
  simp only [← pow_two] at h
  simpa only [fabricStrain, rotateFabric] using congrArg (fun z : ℝ => (z-1)/2) h

private theorem probe_exact (s : State) (l : Cell) : probeEstimate s l=s.b l := by
  unfold probeEstimate
  ring

theorem decoded_records_frame_invariant (s : State) (Q : Particle → Mat) :
    readRecords (rotateFabric Q s)=readRecords s := by
  simp only [readRecords, slotBytes, probe_exact, rotateFabric]

private theorem feature_frame_invariant (G : Geometry) (s : State) (Q : Particle → Mat)
    (hQ : ∀ p, Orthogonal (Q p)) :
    memoryFeature G (rotateFabric Q s)=memoryFeature G s := by
  have hn : ∀ p, strainNorm ((rotateFabric Q s).F p)=strainNorm (s.F p) :=
    fun p => strain_norm_objective _ _ (hQ p)
  funext i j
  simp only [memoryFeature, hn]
  rfl

theorem observations_frame_invariant (G : Geometry) (s : State) (Q : Particle → Mat)
    (hQ : ∀ p, Orthogonal (Q p)) :
    observations G (rotateFabric Q s)=observations G s := by
  have hn : ∀ p, strainNorm ((rotateFabric Q s).F p)=strainNorm (s.F p) :=
    fun p => strain_norm_objective _ _ (hQ p)
  funext i
  simp only [observations, hn]
  rfl

private theorem weight_frame_invariant (G : Geometry) (s : State) (Q : Particle → Mat)
    (hQ : ∀ p, Orthogonal (Q p)) (r : Record) :
    recordWeight G (rotateFabric Q s) r=recordWeight G s r := by
  simp only [recordWeight, feature_frame_invariant G s Q hQ]
  rfl

private theorem exposure_frame_invariant (G : Geometry) (s : State) (Q : Particle → Mat)
    (hQ : ∀ p, Orthogonal (Q p)) (rs : List (Fin 4 × Record)) :
    exposure G (rotateFabric Q s) rs=exposure G s rs := by
  funext i j
  simp only [exposure, weight_frame_invariant G s Q hQ]

theorem retrieval_frame_invariant (G : Geometry) (s : State) (Q : Particle → Mat)
    (hQ : ∀ p, Orthogonal (Q p)) (rs : List (Fin 4 × Record)) :
    memory G (rotateFabric Q s) rs=memory G s rs := by
  funext i j k
  simp only [memory, weight_frame_invariant G s Q hQ, exposure_frame_invariant G s Q hQ]

private theorem utility_frame_invariant (G : Geometry) (s : State) (Q : Particle → Mat)
    (hQ : ∀ p, Orthogonal (Q p)) (rs : List (Fin 4 × Record)) :
    utility G (rotateFabric Q s) rs=utility G s rs := by
  simp only [utility, retrieval_frame_invariant G s Q hQ,
    observations_frame_invariant G s Q hQ]
  rfl

theorem social_rates_frame_invariant (G : Geometry) (t : ℝ) (s : State)
    (Q : Particle → Mat) (hQ : ∀ p, Orthogonal (Q p)) (rs : List (Fin 4 × Record)) :
    socialRates G t (rotateFabric Q s) rs=socialRates G t s rs := by
  simp only [socialRates, retrieval_frame_invariant G s Q hQ,
    observations_frame_invariant G s Q hQ, utility_frame_invariant G s Q hQ,
    margin]
  rfl

private theorem successful_rhs (G : Geometry) (t : ℝ) (s d : State)
    (h : rhs G t s=some d) :
    ∃ rs, readRecords s=some rs ∧ d=rhsFromRecords G t s rs := by
  unfold rhs at h
  obtain ⟨rs, hr, hd⟩ := Option.bind_eq_some_iff.mp h
  split at hd
  · exact ⟨rs,hr,(Option.some.inj hd).symm⟩
  · cases hd

theorem accepted_rhs_social_frame_invariant (G : Geometry) (t : ℝ) (s d e : State)
    (Q : Particle → Mat) (hQ : ∀ p, Orthogonal (Q p))
    (hd : rhs G t s=some d) (he : rhs G t (rotateFabric Q s)=some e) :
    SameSocial e d := by
  obtain ⟨rs,hr,rfl⟩ := successful_rhs G t s d hd
  obtain ⟨zs,hz,rfl⟩ := successful_rhs G t (rotateFabric Q s) e he
  rw [decoded_records_frame_invariant, hr] at hz
  cases Option.some.inj hz
  simp only [SameSocial, rhsFromRecords, social_rates_frame_invariant G t s Q hQ,
    and_self]

theorem event_record_frame_invariant (s : State) (startF : Particle → Mat)
    (Q R : Particle → Mat) (hQ : ∀ p, Orthogonal (Q p))
    (hR : ∀ p, Orthogonal (R p)) (id : Fin 3) :
    makeEvent (rotateFabric Q s) (fun p => mm (R p) (startF p)) id=
    makeEvent s startF id := by
  have hg : ∀ p, green ((rotateFabric Q s).F p)=green (s.F p) :=
    fun p => green_objective _ _ (hQ p)
  have hs : ∀ p, green (mm (R p) (startF p))=green (startF p) :=
    fun p => green_objective _ _ (hR p)
  simp only [makeEvent, decoded_records_frame_invariant, hg, hs]
  rfl

private theorem stored_frame_invariant (G : Geometry) (s : State) (Q : Particle → Mat)
    (hQ : ∀ p, Orthogonal (Q p)) (b : Cell → ℝ) :
    storedEnergy G (rotateFabric Q s) b=storedEnergy G s b := by
  simp only [storedEnergy, fabric_strain_objective s Q hQ]

theorem write_account_frame_invariant (G : Geometry) (s : State) (Q : Particle → Mat)
    (hQ : ∀ p, Orthogonal (Q p)) (target : Cell → ℝ) :
    writeAccount G (rotateFabric Q s) target=writeAccount G s target := by
  simp only [writeAccount, stored_frame_invariant G s Q hQ,
    fabric_strain_objective s Q hQ]
  rfl

theorem memory_write_frame_equivariant (G : Geometry) (s : State) (Q : Particle → Mat)
    (hQ : ∀ p, Orthogonal (Q p)) (r : Record) :
    writeEvent G (rotateFabric Q s) r=(writeEvent G s r).map (rotateFabric Q) := by
  have ht : ∀ slot bytes, targetFabric (rotateFabric Q s) slot bytes=targetFabric s slot bytes :=
    fun _ _ => rfl
  unfold writeEvent
  simp only [decoded_records_frame_invariant, ht, write_account_frame_invariant G s Q hQ]
  cases hr : readRecords s with
  | none => simp
  | some rs =>
    simp only [Option.bind_eq_bind, Option.bind_some]
    split
    · simp
    · cases hf : (List.ofFn (fun slot : Fin 4 => slot)).find?
        (fun slot => !(rs.any (fun r => r.1 == slot))) with
      | none => simp
      | some slot =>
        simp only [Option.bind_eq_bind, Option.bind_some]
        cases hb : payload r with
        | none => simp
        | some bytes =>
          simp only [Option.bind_eq_bind, Option.bind_some]
          split
          · simp
          · rfl

private theorem exposure_list_permutation (G : Geometry) (s : State)
    (rs zs : List (Fin 4 × Record)) (h : rs.Perm zs) :
    exposure G s rs=exposure G s zs := by
  funext i j
  exact (h.map _).sum_eq

theorem retrieval_ignores_list_order (G : Geometry) (s : State)
    (rs zs : List (Fin 4 × Record)) (h : rs.Perm zs) :
    memory G s rs=memory G s zs := by
  funext i j k
  unfold memory
  rw [exposure_list_permutation G s rs zs h]
  congr 1
  exact (h.map _).sum_eq

private theorem utility_list_permutation (G : Geometry) (s : State)
    (rs zs : List (Fin 4 × Record)) (h : rs.Perm zs) :
    utility G s rs=utility G s zs := by
  simp only [utility, retrieval_ignores_list_order G s rs zs h]

private theorem social_list_permutation (G : Geometry) (t : ℝ) (s : State)
    (rs zs : List (Fin 4 × Record)) (h : rs.Perm zs) :
    socialRates G t s rs=socialRates G t s zs := by
  simp only [socialRates, retrieval_ignores_list_order G s rs zs h,
    utility_list_permutation G s rs zs h]

theorem full_rate_ignores_list_order (G : Geometry) (t : ℝ) (s : State)
    (rs zs : List (Fin 4 × Record)) (h : rs.Perm zs) :
    rhsFromRecords G t s rs=rhsFromRecords G t s zs := by
  simp only [rhsFromRecords, social_list_permutation G t s rs zs h]

theorem actual_deformation_component (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (p : Particle) :
    (rhsFromRecords G t s rs).F p=mm (particleGradient s p) (s.F p) := by
  rfl

theorem deformation_product_rule (Q F : ℝ → Mat) (dQ dF : Mat) (I : Set ℝ) (t : ℝ)
    (hQ : MatrixDerivWithin Q dQ I t) (hF : MatrixDerivWithin F dF I t) :
    MatrixDerivWithin (fun τ => mm (Q τ) (F τ))
      (mm dQ (F t)+mm (Q t) dF) I t := by
  intro i j
  have h := HasDerivWithinAt.fun_sum (u := Finset.univ)
    (fun k _ => (hQ i k).mul (hF k j))
  simpa only [mm, Pi.add_apply, Pi.mul_apply, Finset.sum_add_distrib] using h

theorem actual_full_rhs_frame_defect (G : Geometry) (t : ℝ) (s : State)
    (rs : List (Fin 4 × Record)) (Q : Particle → Mat) (dQ : Mat) (p : Particle) :
    mm dQ (s.F p)+mm (Q p) ((rhsFromRecords G t s rs).F p)-
      (rhsFromRecords G t (rotateFabric Q s) rs).F p=
    mm (dQ+mm (Q p) (particleGradient s p)-mm (particleGradient s p) (Q p))
      (s.F p) := by
  change mm dQ (s.F p)+mm (Q p) (mm (particleGradient s p) (s.F p))-
      mm (particleGradient s p) (mm (Q p) (s.F p))= _
  funext i j
  simp only [mm, Pi.add_apply, Pi.sub_apply, Fin.sum_univ_succ]
  ring

theorem quarter_turn_is_orthogonal : Orthogonal quarterTurn := by
  unfold Orthogonal
  ext i j
  fin_cases i <;> fin_cases j <;>
    norm_num [quarterTurn, Matrix.mul_apply, Matrix.transpose_apply, Fin.sum_univ_succ]

theorem explicit_nonzero_frame_defect :
    frameDefect quarterTurn 0 diagonalRate eye 0 1=2 := by
  norm_num [frameDefect, quarterTurn, diagonalRate, eye, mm, Fin.sum_univ_succ]

theorem naive_rotation_covariance_fails :
    ¬(∀ Q L F : Mat, Orthogonal Q → mm Q (mm L F)=mm L (mm Q F)) := by
  intro h
  have he := congrFun (congrFun (h quarterTurn diagonalRate eye quarter_turn_is_orthogonal) 0) 1
  norm_num [quarterTurn, diagonalRate, eye, mm, Fin.sum_univ_succ] at he

end
end HugV3.Source.YMAuditVerified
