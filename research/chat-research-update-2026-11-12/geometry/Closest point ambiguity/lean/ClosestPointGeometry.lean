import SIMSLatentReadout

/-!
Exact geometry on the unit periodic cube. A line is closed only if it returns
after some strictly positive parameter, modulo an integer vector. No finite
miss is used as a substitute for this property.
-/
set_option autoImplicit false
set_option maxHeartbeats 2000000

namespace ClosestPointExample
noncomputable section

abbrev Point := Fin 3 → ℝ
def markerA : Point := ![0, 0, 0]
def markerB : Point := ![0, 0, 1 / 4]
def direction (a : ℝ) : Point := ![a, 1, 0]
def line (a r : ℝ) : Point := ![a * r, r, 0]
def speed (a : ℝ) : ℝ := Real.sqrt (a ^ 2 + 1)
def arc (a s : ℝ) : Point := line a (s / speed a)
def traceLength : ℝ := 3 / 4

def Closed (a : ℝ) : Prop :=
  ∃ r : ℝ, 0 < r ∧ ∃ n : Fin 3 → ℤ, ∀ i, line a r i = (n i : ℝ)

theorem speed_positive (a : ℝ) : 0 < speed a := by
  unfold speed
  exact Real.sqrt_pos.2 (by positivity)

theorem speed_squared (a : ℝ) : speed a ^ 2 = a ^ 2 + 1 := by
  exact Real.sq_sqrt (by positivity)

theorem arc_starts_at_A (a : ℝ) : arc a 0 = markerA := by
  simp [arc, line, markerA]

theorem arc_unit_tangent (a : ℝ) :
    (a / speed a) ^ 2 + (1 / speed a) ^ 2 = 1 := by
  have hn : speed a ≠ 0 := ne_of_gt (speed_positive a)
  field_simp
  exact (speed_squared a).symm

theorem arc_derivative (a s : ℝ) (i : Fin 3) :
    HasDerivAt (fun v => arc a v i) (direction a i / speed a) s := by
  fin_cases i <;> simp [arc, line, direction]
  · simpa [id, div_eq_mul_inv] using ((hasDerivAt_id s).div_const (speed a)).const_mul a
  · simpa using (hasDerivAt_id s).div_const (speed a)
  · exact hasDerivAt_const s 0

theorem zero_line_is_closed : Closed 0 := by
  refine ⟨1, by norm_num, ![0, 1, 0], ?_⟩
  intro i
  fin_cases i <;> norm_num [line]

theorem sqrt_two_line_is_open : ¬ Closed (Real.sqrt 2) := by
  rintro ⟨r, hr, n, hn⟩
  have hy : r = (n 1 : ℝ) := by simpa [line] using hn 1
  have hx : Real.sqrt 2 * r = (n 0 : ℝ) := by simpa [line] using hn 0
  have nr : (n 1 : ℝ) ≠ 0 := by linarith
  have rational : Real.sqrt 2 = (((n 0 : ℚ) / (n 1 : ℚ) : ℚ) : ℝ) := by
    push_cast
    apply (eq_div_iff nr).2
    simpa [← hy] using hx
  exact irrational_sqrt_two.ne_rat _ rational

/-- Squared distance to a particular periodic image of B. -/
def imageDistanceSq (p : Point) (n : Fin 3 → ℤ) : ℝ :=
  (p 0 - markerB 0 - n 0) ^ 2 +
  (p 1 - markerB 1 - n 1) ^ 2 +
  (p 2 - markerB 2 - n 2) ^ 2

theorem vertical_image_bound (n : ℤ) : (1 / 4 : ℝ) ^ 2 ≤ (-1 / 4 - n) ^ 2 := by
  by_cases hn : n < 0
  · have hn' : (n : ℝ) ≤ -1 := by exact_mod_cast (show n ≤ -1 by omega)
    have h : 0 ≤ (-1 / 4 - (n : ℝ) - 1 / 4) * (-1 / 4 - (n : ℝ) + 1 / 4) :=
      mul_nonneg (by linarith) (by linarith)
    nlinarith
  · have hn' : (0 : ℝ) ≤ n := by exact_mod_cast (show 0 ≤ n by omega)
    have h : 0 ≤ ((1 / 4 : ℝ) + n - 1 / 4) * (1 / 4 + n + 1 / 4) :=
      mul_nonneg (by linarith) (by linarith)
    nlinarith

theorem all_images_all_line_points (a r : ℝ) (n : Fin 3 → ℤ) :
    (1 / 4 : ℝ) ^ 2 ≤ imageDistanceSq (line a r) n := by
  change (1 / 4 : ℝ) ^ 2 ≤ (a * r - 0 - (n 0 : ℝ)) ^ 2 +
    (r - 0 - (n 1 : ℝ)) ^ 2 + (0 - 1 / 4 - (n 2 : ℝ)) ^ 2
  have hz := vertical_image_bound (n 2)
  nlinarith [sq_nonneg (a * r - (n 0 : ℝ)), sq_nonneg (r - (n 1 : ℝ))]

theorem A_attains_bound : imageDistanceSq markerA (fun _ => 0) = (1 / 4 : ℝ) ^ 2 := by
  unfold imageDistanceSq
  norm_num only [Int.cast_zero]
  change (0 - 0 - (0 : ℝ)) ^ 2 + (0 - 0 - 0) ^ 2 + (0 - 1 / 4 - 0) ^ 2 = _
  norm_num

structure Reading where
  point : Point
  arclength : ℝ
  distance : ℝ

/-- The point is on the finite forward trace, attains the torus minimum, and
uses the earliest parameter among equal minima. Comparison with every integer
image implements the ordinary nearest-image distance on the periodic cube. -/
def ValidReading (a : ℝ) (o : Reading) : Prop :=
  0 ≤ o.arclength ∧ o.arclength ≤ traceLength ∧
  o.point = arc a o.arclength ∧ 0 ≤ o.distance ∧
  (∃ n, imageDistanceSq o.point n = o.distance ^ 2) ∧
  (∀ s, 0 ≤ s → s ≤ traceLength → ∀ n,
    o.distance ^ 2 ≤ imageDistanceSq (arc a s) n) ∧
  (∀ s, 0 ≤ s → s ≤ traceLength →
    (∃ n, imageDistanceSq (arc a s) n = o.distance ^ 2) → o.arclength ≤ s)

def observe (_a : ℝ) : Reading := ⟨markerA, 0, 1 / 4⟩

/-- The constant output is proved to be the actual geometric reading. -/
theorem observation_is_valid (a : ℝ) : ValidReading a (observe a) := by
  refine ⟨by norm_num [observe], by norm_num [observe, traceLength], ?_,
    by norm_num [observe], ?_, ?_, ?_⟩
  · exact (arc_starts_at_A a).symm
  · exact ⟨fun _ => 0, A_attains_bound⟩
  · intro s _ _ n
    exact all_images_all_line_points a (s / speed a) n
  · intro s hs _ _
    exact hs

def closedProperty (a : ℝ) : Bool := by
  classical
  exact decide (Closed a)

theorem same_closest_point_reading : observe 0 = observe (Real.sqrt 2) := rfl

theorem opposite_closure_values :
    closedProperty 0 = true ∧ closedProperty (Real.sqrt 2) = false := by
  simp [closedProperty, zero_line_is_closed, sqrt_two_line_is_open]

theorem no_exact_closest_point_reader :
    ¬ ∃ reader : Reading → Bool, ∀ a, reader (observe a) = closedProperty a := by
  apply SIMSLatentReadout.no_exact_reader_of_ambiguous_observation
    observe closedProperty 0 (Real.sqrt 2) same_closest_point_reading
  rw [opposite_closure_values.1, opposite_closure_values.2]
  decide

#print axioms arc_unit_tangent
#print axioms arc_derivative
#print axioms zero_line_is_closed
#print axioms sqrt_two_line_is_open
#print axioms all_images_all_line_points
#print axioms observation_is_valid
#print axioms no_exact_closest_point_reader

end
end ClosestPointExample
