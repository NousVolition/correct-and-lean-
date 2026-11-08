import AppleFlowDefinitions
import AppleBandProofs

namespace HugV3.Source.AppleBand
noncomputable section
open Set
set_option maxHeartbeats 550000

private theorem write_velocity (G : Geometry) (s e : State) (r : Record) (ok : writeEvent G s r=some e) :
    velocity e=velocity s := by
  unfold writeEvent at ok
  obtain ⟨rs,_,ok⟩ := Option.bind_eq_some_iff.mp ok
  split at ok
  · cases ok
  · obtain ⟨slot,_,ok⟩ := Option.bind_eq_some_iff.mp ok
    obtain ⟨bytes,_,ok⟩ := Option.bind_eq_some_iff.mp ok
    dsimp only at ok
    split at ok
    · cases ok
    · rw [←Option.some.inj ok]
      funext x i
      have ne : (⟨i.val,by omega⟩ : Fin 5)≠4 := by intro h; have h' := congrArg Fin.val h; simp at h'; omega
      simp [velocity,ne]

private theorem completion_velocity (i : Fin 3) (x y : FullState) (ok : completeEvent i x=some y) :
    velocity y.state=velocity x.state := by
  unfold completeEvent at ok
  obtain ⟨F,_,ok⟩ := Option.bind_eq_some_iff.mp ok
  obtain ⟨r,_,ok⟩ := Option.bind_eq_some_iff.mp ok
  obtain ⟨s,hw,ok⟩ := Option.bind_eq_some_iff.mp ok
  rw [←Option.some.inj ok]
  exact write_velocity _ _ _ _ hw

theorem accepted_boundary_keeps_velocity (n : ℕ) (x y : FullState) (ok : boundary n x=some y) :
    velocity y.state=velocity x.state := by
  match n with
  | 0 => rw [←show capture 0 x=y from Option.some.inj ok]; rfl
  | 1 => rw [←show capture 1 x=y from Option.some.inj ok]; rfl
  | 2 => exact completion_velocity 0 x y ok
  | 3 =>
    change (completeEvent 1 x).map (capture 2)=some y at ok
    cases h : completeEvent 1 x with
    | none => simp [h] at ok
    | some z =>
      rw [←show capture 2 z=y from by simpa [h] using ok]
      exact completion_velocity 1 x z h
  | 4 => exact completion_velocity 2 x y ok
  | n+5 => rw [show x=y from Option.some.inj ok]

theorem time_monotone : Monotone time := by
  apply monotone_nat_of_le_succ
  intro j
  match j with
  | 0 | 1 | 2 | 3 | 4 => norm_num [time]
  | n+5 => change (8/5:ℝ)≤8/5; exact le_rfl

def segVelocity (tr : Trace) (k : ℕ) (t : ℝ) : Vector := velocity (tr.path k t).state
def clipTime (k : ℕ) (t : ℝ) : ℝ := max (time k) (min t (time (k+1)))

private theorem clipped_mem (k : ℕ) (t : ℝ) : clipTime k t∈Icc (time k) (time (k+1)) :=
  ⟨le_max_left _ _,max_le (time_monotone (Nat.le_succ _)) (min_le_right _ _)⟩

private theorem clip_inside (k : ℕ) {t : ℝ} (h : t∈Icc (time k) (time (k+1))) :
    clipTime k t=t := by simp only [clipTime,min_eq_left h.2,max_eq_right h.1]

private theorem clip_before (k : ℕ) {t : ℝ} (h : t≤time k) : clipTime k t=time k := by
  exact max_eq_left ((min_le_left t (time (k+1))).trans h)

private theorem clip_after (k : ℕ) {t : ℝ} (h : time (k+1)≤t) : clipTime k t=time (k+1) := by
  simp only [clipTime,min_eq_right h,max_eq_right (time_monotone (Nat.le_succ _))]

private theorem clip_velocity_cont (tr : Trace) (solves : Solves tr) (k : ℕ) (hk : k<5) :
    Continuous (fun t => segVelocity tr k (clipTime k t)) := by
  have coord := (solves.2 k hk).2.1
  have clip_cont : Continuous (clipTime k) := by unfold clipTime; fun_prop
  apply continuous_pi; intro x
  apply continuous_pi; intro i
  have hv := coord.1 x (⟨i.val,by omega⟩ : Fin 5)
  exact (continuousOn_iff_continuous_domRestrict.mp hv).comp (clip_cont.subtype_mk (clipped_mem k))

/-- A continuous extension in time of the original velocities, joined without changing a segment value. -/
def joinedVelocity (tr : Trace) : ℕ → ℝ → Vector
  | 0,t => segVelocity tr 0 (clipTime 0 t)
  | n+1,t => joinedVelocity tr n t+(segVelocity tr (n+1) (clipTime (n+1) t)-segVelocity tr (n+1) (time (n+1)))

theorem joined_continuous (tr : Trace) (solves : Solves tr) (n : ℕ) (hn : n<5) :
    Continuous (joinedVelocity tr n) := by
  induction n with
  | zero => exact clip_velocity_cont tr solves 0 (by omega)
  | succ n ih =>
    exact (ih (by omega)).add ((clip_velocity_cont tr solves (n+1) hn).sub continuous_const)

private theorem adjacent (tr : Trace) (solves : Solves tr) (n : ℕ) (hn : n+1<5) :
    segVelocity tr n (time (n+1))=segVelocity tr (n+1) (time (n+1)) := by
  unfold segVelocity
  rw [(solves.2 (n+1) hn).1]
  exact (accepted_boundary_keeps_velocity _ _ _ (solves.2 n (by omega)).2.2.2.2).symm

private theorem prefix_agreement (tr : Trace) (solves : Solves tr) (n : ℕ) (hn : n<5) :
    (∀ k≤n, ∀ t∈Icc (time k) (time (k+1)), joinedVelocity tr n t=segVelocity tr k t) ∧
    (∀ t, time (n+1)≤t → joinedVelocity tr n t=segVelocity tr n (time (n+1))) := by
  induction n with
  | zero =>
    constructor
    · intro k hk t ht
      have : k=0 := by omega
      subst k
      simp only [joinedVelocity,clip_inside 0 ht]
    · intro t ht; simp only [joinedVelocity,clip_after 0 ht]
  | succ n ih =>
    obtain ⟨during,after⟩ := ih (by omega)
    have seam := adjacent tr solves n hn
    constructor
    · intro k hk t ht
      by_cases prior : k≤n
      · have early : t≤time (n+1) := ht.2.trans (time_monotone (by omega))
        simp only [joinedVelocity,clip_before (n+1) early,sub_self,add_zero,during k prior t ht]
      · have : k=n+1 := by omega
        subst k
        rw [joinedVelocity,clip_inside _ ht,after t ht.1,seam]
        abel
    · intro t ht
      have earlier : time (n+1)≤t := (time_monotone (Nat.le_succ (n+1))).trans ht
      rw [joinedVelocity,clip_after _ ht,after t earlier,seam]
      abel

theorem joined_equals_native (tr : Trace) (solves : Solves tr) (k : ℕ) (hk : k<5)
    (t : ℝ) (ht : t∈Icc (time k) (time (k+1))) :
    joinedVelocity tr 4 t=velocity (tr.path k t).state :=
  (prefix_agreement tr solves 4 (by omega)).1 k (by omega) t ht

end
end HugV3.Source.AppleBand
