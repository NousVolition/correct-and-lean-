import HugTools
namespace ActiveHug.Full
open Set Metric
open scoped NNReal
noncomputable section

def box (R y : ℝ) : ℝ := min R (max (-R) y)
def project (R : ℝ) (x : Vec) : Vec := fun j =>
  if j.val < 6 then box R (x j) else Hug.clip (x j)
def cutField (F R : ℝ → ℝ) (t : ℝ) (x : Vec) : Vec := field F t (project (R t) x)
def growth (M : ℝ) : ℝ := 100+5*M
def radius (a R0 M t : ℝ) : ℝ := R0*Real.exp (growth M*(t-a))

theorem clip01_bounds (y : ℝ) : Hug.UnitInterval (Hug.clip y) :=
  ⟨le_min (by norm_num) (le_max_left _ _), min_le_left _ _⟩
theorem box_bounds (R y : ℝ) (hR : 0 ≤ R) : -R ≤ box R y ∧ box R y ≤ R :=
  ⟨le_min (by linarith) (le_max_left _ _), min_le_left _ _⟩
theorem project_bounds (R : ℝ) (x : Vec) (hR : 1 ≤ R) :
    (∀ j, |project R x j| ≤ R) ∧ Admissible (project R x) := by
  constructor
  · intro j
    unfold project
    split_ifs with hj
    · exact abs_le.mpr (box_bounds R (x j) (by linarith))
    · obtain ⟨h0,h1⟩ := clip01_bounds (x j)
      rw [abs_of_nonneg h0]
      exact h1.trans hR
  · exact ⟨clip01_bounds (x 6),clip01_bounds (x 7)⟩

theorem project_identity {R : ℝ} {x : Vec}
    (hb : ∀ j, |x j| ≤ R) (hg : Admissible x) : project R x = x := by
  ext j
  unfold project
  split_ifs with hj
  · obtain ⟨hlo,hhi⟩ := abs_le.mp (hb j)
    simp [box, max_eq_right hlo, min_eq_right hhi]
  · have h : Hug.UnitInterval (x j) := by
      fin_cases j <;> simp_all [Admissible]
    simp [Hug.clip, max_eq_right h.1, min_eq_right h.2]

theorem project_lipschitz (R : ℝ) : LipschitzWith 1 (project R) := by
  apply LipschitzWith.of_dist_le_mul
  intro x y
  apply (dist_pi_le_iff (by positivity)).mpr
  intro j
  have h : dist (project R x j) (project R y j) ≤ dist (x j) (y j) := by
    unfold project
    split_ifs
    · simpa [box, min_comm, max_comm] using (((LipschitzWith.id.max_const (-R)).min_const R).dist_le_mul (x j) (y j))
    · simpa [Hug.clip, min_comm, max_comm] using (((LipschitzWith.id.max_const (0:ℝ)).min_const 1).dist_le_mul (x j) (y j))
  simpa using h.trans (dist_le_pi_dist x y j)

theorem project_path_continuous {a b : ℝ} {R : ℝ → ℝ} {x : ℝ → Vec}
    (hR : ContinuousOn R (Icc a b)) (hx : ContinuousOn x (Icc a b)) :
    ContinuousOn (fun t => project (R t) (x t)) (Icc a b) := by
  apply continuousOn_pi.mpr
  intro j
  unfold project
  split_ifs <;> simp only [box, Hug.clip] <;> fun_prop

theorem field_upper (M R f : ℝ) (x : Vec) (j : Fin 8)
    (hM : 0 ≤ M) (hR : 1 ≤ R) (hf : |f| ≤ M)
    (hx : ∀ k, |x k| ≤ R) (hg : Admissible x) (hj : j.val < 6)
    (he : x j = R) : field (fun _ => f) 0 x j ≤ growth M*R := by
  have h0 := abs_le.mp (hx 0)
  have h1 := abs_le.mp (hx 1)
  have h2 := abs_le.mp (hx 2)
  have h3 := abs_le.mp (hx 3)
  have h4 := abs_le.mp (hx 4)
  have h5 := abs_le.mp (hx 5)
  obtain ⟨hg6,hg7⟩ := hg
  have hf' := abs_le.mp hf
  have hMR : M ≤ M*R := by nlinarith
  have hpos : 0 ≤ R := by linarith
  have hs : 0 ≤ (x 0)^2*R := mul_nonneg (sq_nonneg _) hpos
  have hd : 0 ≤ (x 6+x 7)*R := mul_nonneg (add_nonneg hg6.1 hg7.1) hpos
  have hpa : x 6*(x 5-R) ≤ 0 := mul_nonpos_of_nonneg_of_nonpos hg6.1 (by linarith)
  have hpb : x 7*(x 4-R) ≤ 0 := mul_nonpos_of_nonneg_of_nonpos hg7.1 (by linarith)
  fin_cases j <;> norm_num at hj
  all_goals norm_num [field, encode, rhs, decode, protocol, stress, growth] at ⊢
  all_goals norm_num at he
  all_goals try rw [he]
  all_goals try nlinarith
  · change x 4 = R at he
    rw [he]
    nlinarith
  · change x 5 = R at he
    rw [he]
    nlinarith

theorem field_lower (M R f : ℝ) (x : Vec) (j : Fin 8)
    (hM : 0 ≤ M) (hR : 1 ≤ R) (hf : |f| ≤ M)
    (hx : ∀ k, |x k| ≤ R) (hg : Admissible x) (hj : j.val < 6)
    (he : x j = -R) : -(growth M*R) ≤ field (fun _ => f) 0 x j := by
  have h0 := abs_le.mp (hx 0)
  have h1 := abs_le.mp (hx 1)
  have h2 := abs_le.mp (hx 2)
  have h3 := abs_le.mp (hx 3)
  have h4 := abs_le.mp (hx 4)
  have h5 := abs_le.mp (hx 5)
  obtain ⟨hg6,hg7⟩ := hg
  have hf' := abs_le.mp hf
  have hMR : M ≤ M*R := by nlinarith
  have hpos : 0 ≤ R := by linarith
  have hs : 0 ≤ (x 0)^2*R := mul_nonneg (sq_nonneg _) hpos
  have hd : 0 ≤ (x 6+x 7)*R := mul_nonneg (add_nonneg hg6.1 hg7.1) hpos
  have hpa : 0 ≤ x 6*(x 5+R) := mul_nonneg hg6.1 (by linarith)
  have hpb : 0 ≤ x 7*(x 4+R) := mul_nonneg hg7.1 (by linarith)
  fin_cases j <;> norm_num at hj
  all_goals norm_num [field, encode, rhs, decode, protocol, stress, growth] at ⊢
  all_goals norm_num at he
  all_goals try rw [he]
  all_goals try nlinarith
  · change x 4 = -R at he
    rw [he]
    nlinarith
  · change x 5 = -R at he
    rw [he]
    nlinarith

end
end ActiveHug.Full
