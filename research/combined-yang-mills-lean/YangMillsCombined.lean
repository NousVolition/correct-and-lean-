import YangMillsInstance
import YangMillsCueTest

/-!
Combine the existing readJet definition with the explicit abelian potentials.

At every point of x_1 = 0, A = (-2, 0, 0, 0) and B = (-2, 0, x_1^2, 0)
have equal values and equal first partial derivatives in every component and
coordinate. Their second transverse derivatives in component 2 are 0 and 2,
respectively, and equal their respective residual components R_2.

The readJet test uses the straight transverse path p + t e_1. The input path is
truncated at order 1; the derivative order read is independently 0, 1, or 2.
The nonlinear test B_2 produces t^2 on the slice, even for that linear path.

Scope: explicit abelian potentials in Cartesian Euclidean four-space. B fails
the source-free equation. This does not construct two Yang-Mills solutions or
an admissible family for the upstream submission.

Attribution: curve and readJet were copied into YangMillsInstance from the
upstream Yang-Mills submission (see that file's header for the pinned source).
The instance file was the user's draft, compiled by Codex. The field pair is
recorded in YangMillsCueTest as an explicit test choice.
Combined theorem and checks: Codex (OpenAI), directed by NousVolition.
Imported mathematical source files are preserved unchanged. See CREDITS.md.
-/

set_option autoImplicit false
noncomputable section

namespace YangMillsCombined
open TwoMemoryTransport YangMillsCueTest

/-- Taylor data for the straight path p + t e_1. -/
def transverseJet (p : Point) (n : ℕ) : Point :=
  if n = 0 then p else if n = 1 then (fun i => if i = 1 then 1 else 0) else 0

/-- Read component 2 along the transverse path using the imported readJet. -/
def transverseReading (A : Potential) (p : Point) (n : ℕ) : ℝ :=
  YangMillsInstance.readJet YangMillsInstance.negate 1 n
    (fun q : Point × ℝ => A 2 q.1) YangMillsInstance.zeroInput (transverseJet p)

lemma transverse_curve (p : Point) (t : ℝ) :
    YangMillsInstance.curve (transverseJet p) 1 t =
      Function.update p 1 (p 1 + t) := by
  funext i
  by_cases hi : i = 1
  · subst i
    simp [YangMillsInstance.curve, transverseJet, Finset.sum_range_succ]
  · simp [YangMillsInstance.curve, transverseJet, Finset.sum_range_succ,
      Function.update, hi]

lemma transverse_reading_eq (A : Potential) (p : Point) (n : ℕ) :
    transverseReading A p n =
      iteratedDeriv n (fun t : ℝ => A 2 (Function.update p 1 (p 1 + t))) 0 := by
  simp only [transverseReading, YangMillsInstance.readJet, transverse_curve]

/-- All first partial derivatives of the original constant potential vanish. -/
lemma original_first_partial (i j : Fin 4) (p : Point) :
    partialDerivative i (potential j) p = 0 := by
  simp [partialDerivative, potential]

/-- The sole possibly nonzero first partial derivative is d_1 B_2 = 2 x_1. -/
lemma modified_first_partial (i j : Fin 4) (p : Point) :
    partialDerivative i (transversePotential j) p =
      if j = 2 ∧ i = 1 then 2 * p 1 else 0 := by
  fin_cases i <;> fin_cases j <;>
    simp [partialDerivative, transversePotential, potential, Function.update]

/-- Equality of the full component values and all first coordinate partials on the slice. -/
theorem values_and_first_partials_agree (p : Point) (h : p 1 = 0) :
    (∀ j, potential j p = transversePotential j p) ∧
    (∀ i j, partialDerivative i (potential j) p =
      partialDerivative i (transversePotential j) p) := by
  constructor
  · intro j
    exact (agree_on_slice p h j).symm
  · intro i j
    simp [original_first_partial, modified_first_partial, h]

lemma original_second_transverse (p : Point) :
    partialDerivative 1 (partialDerivative 1 (potential 2)) p = 0 := by
  simp [partialDerivative, potential]

lemma modified_second_transverse (p : Point) :
    partialDerivative 1 (partialDerivative 1 (transversePotential 2)) p = 2 := by
  have first : partialDerivative 1 (transversePotential 2) = fun q => 2 * q 1 := by
    funext q
    simp [modified_first_partial]
  rw [first]
  simp [partialDerivative, Function.update]

lemma original_reading (p : Point) (n : ℕ) : transverseReading potential p n = 0 := by
  simp [transverse_reading_eq, potential]

lemma modified_reading_on_slice (p : Point) (h : p 1 = 0) (n : ℕ) :
    transverseReading transversePotential p n =
      iteratedDeriv n (fun t : ℝ => t ^ 2) 0 := by
  simp [transverse_reading_eq, transversePotential, h]

/-- Exact readJet values: the value and slope agree; the second derivative separates the pair. -/
theorem readJet_zero_one_two (p : Point) (h : p 1 = 0) :
    transverseReading potential p 0 = 0 ∧
    transverseReading transversePotential p 0 = 0 ∧
    transverseReading potential p 1 = 0 ∧
    transverseReading transversePotential p 1 = 0 ∧
    transverseReading potential p 2 = 0 ∧
    transverseReading transversePotential p 2 = 2 := by
  simp [original_reading, modified_reading_on_slice p h,
    iteratedDeriv_succ, iteratedDeriv_zero]

/-- For these potentials the measured second derivative is exactly residual component 2. -/
theorem second_readings_are_residuals (p : Point) (h : p 1 = 0) :
    (transverseReading potential p 2 =
      partialDerivative 1 (partialDerivative 1 (potential 2)) p) ∧
    (transverseReading transversePotential p 2 =
      partialDerivative 1 (partialDerivative 1 (transversePotential 2)) p) ∧
    (transverseReading potential p 2 = yangMillsResidual potential 2 p) ∧
    (transverseReading transversePotential p 2 =
      yangMillsResidual transversePotential 2 p) := by
  have readings := readJet_zero_one_two p h
  simp only [original_reading, readings.2.2.2.2.2, original_second_transverse,
    modified_second_transverse, source_free, transverse_residual, and_self]

/-- Combined statement: identical values and first derivatives, but second transverse
readJet measurements reveal the distinct field-equation residuals. -/
theorem combined_observation_and_residual (p : Point) (h : p 1 = 0) :
    (∀ j, potential j p = transversePotential j p) ∧
    (∀ i j, partialDerivative i (potential j) p =
      partialDerivative i (transversePotential j) p) ∧
    transverseReading potential p 0 = transverseReading transversePotential p 0 ∧
    transverseReading potential p 1 = transverseReading transversePotential p 1 ∧
    (transverseReading potential p 2 =
      partialDerivative 1 (partialDerivative 1 (potential 2)) p) ∧
    (transverseReading transversePotential p 2 =
      partialDerivative 1 (partialDerivative 1 (transversePotential 2)) p) ∧
    (transverseReading potential p 2 = yangMillsResidual potential 2 p) ∧
    (transverseReading transversePotential p 2 =
      yangMillsResidual transversePotential 2 p) ∧
    yangMillsResidual potential 2 p = 0 ∧
    yangMillsResidual transversePotential 2 p = 2 ∧
    yangMillsResidual potential 2 p ≠ yangMillsResidual transversePotential 2 p := by
  obtain ⟨values, firsts⟩ := values_and_first_partials_agree p h
  obtain ⟨a0, b0, a1, b1, a2, b2⟩ := readJet_zero_one_two p h
  obtain ⟨da, db, ra, rb⟩ := second_readings_are_residuals p h
  refine ⟨values, firsts, a0.trans b0.symm, a1.trans b1.symm,
    da, db, ra, rb, source_free 2 p, transverse_residual p, ?_⟩
  rw [source_free, transverse_residual]
  norm_num

end YangMillsCombined
