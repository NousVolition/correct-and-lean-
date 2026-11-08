import AppleExistenceDefinitions
import V3ClayProofs

namespace HugV3.Source.AppleExistence
noncomputable section
open Set Metric
open scoped BigOperators NNReal

set_option maxRecDepth 20000
set_option maxHeartbeats 1800000

theorem initial_read_is_empty (G : Geometry) : readRecords (initial G)=some [] := by
  classical
  have probe (l : Cell) : probeEstimate (initial G) l = -(1/50:ℝ) := by
    rw [ClayVerified.probe_recovers_cell]
    norm_num [initial]
  have margin : ∀ l, 1/200 ≤ |probeEstimate (initial G) l| := by
    intro l
    rw [probe]
    norm_num
  have bytes (slot : Fin 4) : (slotBytes (initial G) slot).all (· == 0) = true := by
    apply List.all_eq_true.mpr
    intro x hx
    obtain ⟨i,rfl⟩ := List.mem_ofFn.mp hx
    simp [probe]
  have empty (slot : Fin 4) : HugV3.Source.unpack (slotBytes (initial G) slot)=some none := by
    simp only [HugV3.Source.unpack,bytes,ite_true]
  simp only [readRecords,margin]
  simp [empty,List.ofFn_succ]

private theorem volume_nonneg (p : Particle) : 0 ≤ sourceGeometry.V p := by
  fin_cases p <;> change (0:ℝ) ≤ _ / _ <;> positivity

private theorem weight_nonneg (k : Direction) : 0 ≤ sourceGeometry.directionWeights k := by
  fin_cases k <;> change (0:ℝ) ≤ _ / _ <;> positivity

private theorem first_direction_component (k : Direction) : sourceGeometry.directions k 0 ≠ 0 := by
  fin_cases k <;> change (_ / _ : ℝ) ≠ 0 <;> norm_num

private theorem thermal_nonneg (z : ℝ) (i : Fin 16) : 0 ≤ thermal1D z i := by
  have gaussian (a : ℝ) : 0 ≤ gaussianImages a :=
    Finset.sum_nonneg (fun _ _ => (Real.exp_pos _).le)
  exact div_nonneg (gaussian _) (Finset.sum_nonneg (fun _ _ => gaussian _))

private theorem occupancy_nonneg (s : State) (x : Grid) : 0 ≤ occupancy sourceGeometry s x := by
  have kernel (p : Particle) : 0 ≤ R s.X p x :=
    Finset.prod_nonneg fun _ _ => thermal_nonneg _ _
  apply div_nonneg (Finset.sum_nonneg (fun p _ => mul_nonneg (kernel p) (volume_nonneg p)))
  norm_num [dv,dx]

theorem source_power_floor (s : State) (p : Particle) : (1/100000:ℝ) ≤ powerDenominator sourceGeometry s p := by
  have heat (x : Grid) : 0 ≤ viscousHeat s x := by
    unfold viscousHeat viscosity
    positivity
  have av : 0 ≤ available sourceGeometry s p := by
    apply Finset.sum_nonneg
    intro x _
    apply div_nonneg (mul_nonneg (Finset.prod_nonneg (fun _ _ => thermal_nonneg _ _)) (heat x))
    linarith [occupancy_nonneg s x]
  have raw : 0 ≤ rawPower sourceGeometry s p := by
    apply Finset.sum_nonneg
    intro k _
    apply Finset.sum_nonneg
    intro a _
    apply mul_nonneg
    · unfold sensitivity
      exact mul_nonneg (by positivity) (weight_nonneg k)
    · unfold rawRate
      positivity
  change (1/100000:ℝ) ≤ 0.00001 + 0.7*available sourceGeometry s p + rawPower sourceGeometry s p
  linarith

private theorem initial_fiber (p : Particle) (k : Direction) :
    sqnorm (fiber sourceGeometry (initial sourceGeometry) p k) ≠ 0 := by
  have coord (i : Axis) : fiber sourceGeometry (initial sourceGeometry) p k i = sourceGeometry.directions k i := by
    simp [fiber,initial,eye]
  have one := first_direction_component k
  have part : (fiber sourceGeometry (initial sourceGeometry) p k 0)^2 ≤
      sqnorm (fiber sourceGeometry (initial sourceGeometry) p k) :=
    Finset.single_le_sum (f:=fun j => (fiber sourceGeometry (initial sourceGeometry) p k j)^2)
      (fun _ _ => sq_nonneg _) (Finset.mem_univ 0)
  rw [coord] at part
  exact ne_of_gt (lt_of_lt_of_le (sq_pos_of_ne_zero one) part)

theorem initial_full_rate_defined (t : ℝ) :
    rhs sourceGeometry t initialFull.state = some (rhsFromRecords sourceGeometry t initialFull.state []) := by
  change rhs sourceGeometry t (initial sourceGeometry) = some (rhsFromRecords sourceGeometry t (initial sourceGeometry) [])
  have domain : (∀ p k, sqnorm (fiber sourceGeometry (initial sourceGeometry) p k)≠0) ∧
      (∀ pair ∈ ([] : List (Fin 4 × Record)), outcomeValid pair.2.observed ∧ outcomeValid pair.2.report) ∧
      (∀ i j, 0.12+exposure sourceGeometry (initial sourceGeometry) [] i j≠0) ∧
      (∀ x, 1+occupancy sourceGeometry (initial sourceGeometry) x≠0) ∧
      (∀ p, powerDenominator sourceGeometry (initial sourceGeometry) p≠0) := by
    refine ⟨initial_fiber,by simp,?_,?_,?_⟩
    · intro i j
      norm_num [exposure]
    · intro x
      linarith [occupancy_nonneg (initial sourceGeometry) x]
    · intro p
      linarith [source_power_floor (initial sourceGeometry) p]
  simp [rhs,initial_read_is_empty,domain]

private theorem definitely_empty {s : State} (h : ∀ l : Cell, s.b l ≤ -(1/100:ℝ)) :
    readRecords s = some [] := by
  have negative (l : Cell) : probeEstimate s l ≤ -(1/100:ℝ) := by
    rw [ClayVerified.probe_recovers_cell]
    exact h l
  have margin : ∀ l, 1/200 ≤ |probeEstimate s l| := by
    intro l
    rw [abs_of_nonpos (by linarith [negative l])]
    linarith [negative l]
  have bytes (slot : Fin 4) : (slotBytes s slot).all (· == 0) = true := by
    apply List.all_eq_true.mpr
    intro x hx
    obtain ⟨i,rfl⟩ := List.mem_ofFn.mp hx
    have off (l : Cell) : ¬0<probeEstimate s l := by linarith [negative l]
    simp [off]
  have empty (slot : Fin 4) : HugV3.Source.unpack (slotBytes s slot)=some none := by
    simp only [HugV3.Source.unpack,bytes,ite_true]
  simp only [readRecords,margin]
  simp [empty,List.ofFn_succ]

private theorem absolute_directions (k : Direction) (i : Axis) : |sourceGeometry.directions k i| ≤ 1 := by
  fin_cases k <;> fin_cases i <;> change |(_/_:ℝ)| ≤ 1 <;> norm_num

private theorem first_large (k : Direction) : (1/5:ℝ) ≤ |sourceGeometry.directions k 0| := by
  fin_cases k <;> change (1/5:ℝ) ≤ |(_/_:ℝ)| <;> norm_num

private theorem fiber_near {s : State} (near : dist (pack s) (pack initialFull.state) ≤ (1/100:ℝ))
    (p : Particle) (k : Direction) : sqnorm (fiber sourceGeometry s p k) ≠ 0 := by
  let d := sourceGeometry.directions k
  have row (j : Axis) : |s.F p 0 j - eye 0 j| ≤ (1/100:ℝ) := by
    have h := (dist_pi_le_iff (by norm_num : (0:ℝ)≤1/100)).1 near (.fabric p 0 j)
    exact (Real.dist_eq _ _ ▸ h)
  have ident : (∑ j : Axis, eye 0 j*d j)=d 0 := by simp [eye]
  have diff : fiber sourceGeometry s p k 0 - d 0 = ∑ j, (s.F p 0 j-eye 0 j)*d j := by
    conv_lhs => rw [←ident]
    simp only [fiber,sub_mul,Finset.sum_sub_distrib]
    rfl
  have closeness : |fiber sourceGeometry s p k 0-d 0| ≤ (3/100:ℝ) := by
    rw [diff]
    calc
      _ ≤ ∑ j, |(s.F p 0 j-eye 0 j)*d j| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ _ : Axis, (1/100:ℝ) := by
        apply Finset.sum_le_sum
        intro j _
        rw [abs_mul]
        simpa only [mul_one] using mul_le_mul (row j) (absolute_directions k j) (abs_nonneg (d j)) (by norm_num)
      _ = _ := by norm_num
  have nonzero : fiber sourceGeometry s p k 0 ≠ 0 := by
    intro he
    rw [he,zero_sub,abs_neg] at closeness
    have lower : (1/5:ℝ) ≤ |d 0| := first_large k
    linarith
  have part : (fiber sourceGeometry s p k 0)^2 ≤ sqnorm (fiber sourceGeometry s p k) :=
    Finset.single_le_sum (f:=fun j => (fiber sourceGeometry s p k j)^2)
      (fun _ _ => sq_nonneg _) (Finset.mem_univ 0)
  exact ne_of_gt ((sq_pos_of_ne_zero nonzero).trans_le part)

theorem initial_ball_full_rate_defined (t : ℝ) (s : State)
    (near : dist (pack s) (pack initialFull.state) ≤ (1/100:ℝ)) :
    rhs sourceGeometry t s=some (rhsFromRecords sourceGeometry t s []) := by
  have empty : readRecords s=some [] := by
    apply definitely_empty
    intro l
    have h := (dist_pi_le_iff (by norm_num : (0:ℝ)≤1/100)).1 near (.cell l)
    change dist (s.b l) (-1/50:ℝ) ≤ 1/100 at h
    rw [Real.dist_eq,abs_le] at h
    linarith [h.2]
  have domain : (∀ p k, sqnorm (fiber sourceGeometry s p k)≠0) ∧
      (∀ pair ∈ ([] : List (Fin 4 × Record)), outcomeValid pair.2.observed ∧ outcomeValid pair.2.report) ∧
      (∀ i j, 0.12+exposure sourceGeometry s [] i j≠0) ∧
      (∀ x, 1+occupancy sourceGeometry s x≠0) ∧
      (∀ p, powerDenominator sourceGeometry s p≠0) := by
    refine ⟨fiber_near near,by simp,?_,?_,?_⟩
    · intro i j
      norm_num [exposure]
    · intro x
      linarith [occupancy_nonneg s x]
    · intro p
      linarith [source_power_floor s p]
  simp [rhs,empty,domain]

private theorem nearest_one {v : ℝ} (lo : 1/2<v) (hi : v<3/2) : roundEven v=1 := by
  by_cases h : v<1
  · have fl : ⌊v⌋ = (0:ℤ) := Int.floor_eq_iff.mpr (by push_cast; constructor <;> linarith)
    simp only [roundEven,fl,Int.cast_zero,sub_zero,ite_eq_right (not_lt.mpr lo.le),ite_eq_left lo]
    norm_num
  · have fl : ⌊v⌋ = (1:ℤ) := Int.floor_eq_iff.mpr (by push_cast; constructor <;> linarith)
    have fraction : v-(1:ℝ)<1/2 := by linarith
    simp only [roundEven,fl,Int.cast_one,ite_eq_left fraction]

theorem rounding_seam_switches_fabric_bit (ε : ℝ) (hε : 0<ε) (small : ε<(1/10000:ℝ)) :
    quant (1/10000) (1/20000)=some 0 ∧ quant (1/10000) (1/20000+ε)=some 1 ∧
    bitsOfPayload (intBytes 1) 0-bitsOfPayload (intBytes 0) 0=(1/25:ℝ) := by
  have rounded : roundEven ((1/20000+ε)/(1/10000))=1 := by
    apply nearest_one <;> linarith
  refine ⟨?_,?_,?_⟩
  · norm_num [quant,roundEven]
  · unfold quant
    rw [rounded]
    norm_num
  · norm_num [intBytes,bitsOfPayload]


private theorem zero_between {x y c r : ℝ} (hx : dist x c ≤ r) (hy : dist y c ≤ r)
    (sx : x<0) (sy : 0<y) : dist (0:ℝ) c ≤ r := by
  rw [Real.dist_eq,abs_le] at hx hy ⊢
  constructor <;> linarith [hx.1,hy.2]

theorem opposite_codes_preclude_one_domain_ball (c x y : Coordinates) (r : ℝ≥0) (l : Cell)
    (hx : x∈closedBall c (r:ℝ)) (hy : y∈closedBall c (r:ℝ))
    (negative : x (.cell l)<0) (positive : 0<y (.cell l)) :
    ∃ z∈closedBall c (r:ℝ), ∀ t, rhs sourceGeometry t (unpack z)=none := by
  classical
  let i : Coordinate := .cell l
  let z := Function.update c i (0:ℝ)
  have xc := (dist_pi_le_iff r.2).1 hx i
  have yc := (dist_pi_le_iff r.2).1 hy i
  have hn : x i<0 := negative
  have hp : 0<y i := positive
  have key : dist (0:ℝ) (c i)≤r := zero_between xc yc hn hp
  have zi : z i=0 := Function.update_self _ _ _
  refine ⟨z,(dist_pi_le_iff r.2).2 ?_,?_⟩
  · intro j
    by_cases h : j=i
    · subst j
      rw [zi]
      exact key
    · simpa only [z,Function.update_of_ne h,dist_self] using r.2
  · intro t
    have cell : probeEstimate (unpack z) l=0 := by
      rw [ClayVerified.probe_recovers_cell]
      exact zi
    have bad : ¬∀ j, 1/200≤|probeEstimate (unpack z) j| := by
      intro h
      have at_cell := h l
      rw [cell,abs_zero] at at_cell
      norm_num at at_cell
    have read_none : readRecords (unpack z)=none := by
      simp only [readRecords,ite_eq_left bad]
    simp [rhs,read_none]

theorem recorded_cell_precludes_one_domain_ball (c x y : Coordinates) (r : ℝ≥0)
    (hx : x∈closedBall c (r:ℝ)) (hy : y∈closedBall c (r:ℝ))
    (main : x (.cell 42320)=(-5756669002346905/288230376151711744:ℝ))
    (half : y (.cell 42320)=(5757349591092827/288230376151711744:ℝ)) :
    ∃ z∈closedBall c (r:ℝ), ∀ t, rhs sourceGeometry t (unpack z)=none := by
  apply opposite_codes_preclude_one_domain_ball c x y r 42320 hx hy
  · rw [main]
    norm_num
  · rw [half]
    norm_num

end
end HugV3.Source.AppleExistence
