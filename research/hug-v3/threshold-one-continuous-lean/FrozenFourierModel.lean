import FrozenComplexModel
import FrozenField

namespace FrozenFourierModel
open FrozenComplexModel Complex

def frequency (i : Fin 11) : ℤ := (i.val : ℤ) - 5

structure Leaf where
  index : Fin 11
  re : ℤ
  im : ℤ
  deriving DecidableEq, Repr

structure Row where
  index : Fin 11
  leaves : List Leaf
  deriving DecidableEq, Repr

structure Block where
  index : Fin 11
  rows : List Row
  deriving DecidableEq, Repr

def Leaf.wave (i j : Fin 11) (l : Leaf) : FrozenField.Wave :=
  ⟨frequency i, frequency j, frequency l.index, l.re, l.im⟩

def flatten (bs : List Block) : List FrozenField.Wave :=
  bs.flatMap (fun b => b.rows.flatMap (fun r => r.leaves.map (Leaf.wave b.index r.index)))

noncomputable def phasor (θ : ℝ) : ℂ := Complex.exp ((θ : ℂ) * I)

noncomputable def coefficient (F : ℕ) (l : Leaf) : ℂ :=
  ((l.re : ℂ) + (l.im : ℂ) * I) / (F : ℂ)

noncomputable def leafValue (F : ℕ) (φ : Fin 3 → ℝ) (l : Leaf) : ℂ :=
  coefficient F l * phasor ((frequency l.index : ℝ) * φ 2)

noncomputable def rowValue (F : ℕ) (φ : Fin 3 → ℝ) (r : Row) : ℂ :=
  (r.leaves.map (leafValue F φ)).sum * phasor ((frequency r.index : ℝ) * φ 1)

noncomputable def blockValue (F : ℕ) (φ : Fin 3 → ℝ) (b : Block) : ℂ :=
  (b.rows.map (rowValue F φ)).sum * phasor ((frequency b.index : ℝ) * φ 0)

noncomputable def treeValue (F : ℕ) (φ : Fin 3 → ℝ) (bs : List Block) : ℂ :=
  (bs.map (blockValue F φ)).sum

noncomputable def spatialPhase (x : FrozenField.Point) (i : Fin 3) : ℝ :=
  2 * Real.pi * (x i + 1/2)

theorem phasor_add (a b : ℝ) : phasor (a+b) = phasor a * phasor b := by
  simp only [phasor, ofReal_add, add_mul, Complex.exp_add]

theorem wave_factor (F : ℕ) (i j : Fin 11) (l : Leaf) (x : FrozenField.Point) :
    (l.wave i j).value F x =
      (leafValue F (spatialPhase x) l *
        phasor ((frequency j : ℝ) * spatialPhase x 1) *
        phasor ((frequency i : ℝ) * spatialPhase x 0)).re := by
  have hp : (l.wave i j).phase x =
      (frequency l.index : ℝ) * spatialPhase x 2 +
      (frequency j : ℝ) * spatialPhase x 1 +
      (frequency i : ℝ) * spatialPhase x 0 := by
    simp only [Leaf.wave, FrozenField.Wave.phase, spatialPhase]
    ring
  have hz : leafValue F (spatialPhase x) l *
        phasor ((frequency j : ℝ) * spatialPhase x 1) *
        phasor ((frequency i : ℝ) * spatialPhase x 0) =
      coefficient F l * phasor ((l.wave i j).phase x) := by
    rw [hp, phasor_add, phasor_add]
    simp only [leafValue]
    ring
  rw [hz]
  simp only [coefficient, phasor, Complex.mul_re, Complex.exp_ofReal_mul_I_re,
    Complex.exp_ofReal_mul_I_im, FrozenField.Wave.value, Leaf.wave]
  simp [Complex.div_re, Complex.div_im, Complex.normSq_natCast]
  by_cases hF : F = 0
  · simp [hF]
  · have hf : (F : ℝ) ≠ 0 := by exact_mod_cast hF
    field_simp

theorem row_real_value (F : ℕ) (i : Fin 11) (r : Row) (x : FrozenField.Point) :
    FrozenField.value (r.leaves.map (Leaf.wave i r.index)) F x =
      (rowValue F (spatialPhase x) r * phasor ((frequency i : ℝ) * spatialPhase x 0)).re := by
  rcases r with ⟨j, ls⟩
  induction ls with
  | nil => simp [FrozenField.value, rowValue]
  | cons l ls ih =>
    simp only [List.map_cons, FrozenField.value, List.sum_cons] at *
    simp only [rowValue, List.map_cons, List.sum_cons, add_mul, Complex.add_re]
    rw [wave_factor]
    exact congrArg (fun z => (leafValue F (spatialPhase x) l *
      phasor ((frequency j : ℝ) * spatialPhase x 1) *
      phasor ((frequency i : ℝ) * spatialPhase x 0)).re + z) ih

theorem block_real_value (F : ℕ) (b : Block) (x : FrozenField.Point) :
    FrozenField.value (b.rows.flatMap (fun r => r.leaves.map (Leaf.wave b.index r.index))) F x =
      (blockValue F (spatialPhase x) b).re := by
  rcases b with ⟨i, rs⟩
  induction rs with
  | nil => simp [FrozenField.value, blockValue]
  | cons r rs ih =>
    simp only [List.flatMap_cons, FrozenField.value, List.map_append, List.sum_append] at *
    simp only [blockValue, List.map_cons, List.sum_cons, add_mul, Complex.add_re]
    rw [← row_real_value]
    exact congrArg (fun z => FrozenField.value (r.leaves.map (Leaf.wave i r.index)) F x + z) ih

theorem tree_real_value (F : ℕ) (bs : List Block) (x : FrozenField.Point) :
    FrozenField.value (flatten bs) F x = (treeValue F (spatialPhase x) bs).re := by
  induction bs with
  | nil => simp [flatten, FrozenField.value, treeValue]
  | cons b bs ih =>
    simp only [flatten, List.flatMap_cons, FrozenField.value, List.map_append, List.sum_append] at *
    simp only [treeValue, List.map_cons, List.sum_cons, Complex.add_re]
    rw [← block_real_value]
    exact congrArg (fun z => FrozenField.value
      (b.rows.flatMap (fun r => r.leaves.map (Leaf.wave b.index r.index))) F x + z) ih

theorem sum_map_models {α : Type*} {D : ℤ} (xs : List α) (m : α → Model) (f : α → ℝ → ℂ)
    (h : ∀ a ∈ xs, Models D (m a) (f a)) :
    Models D (FrozenComplexModel.sum (xs.map m)) (fun x => (xs.map (fun a => f a x)).sum) := by
  induction xs with
  | nil => simpa [FrozenComplexModel.sum] using const_models D 0 0
  | cons a xs ih =>
    have ha := h a (List.mem_cons_self)
    have ht := ih (fun b hb => h b (List.mem_cons_of_mem a hb))
    simpa only [List.map_cons, FrozenComplexModel.sum, List.sum_cons] using add_models ha ht

def coefficientModel (A : ℤ) (l : Leaf) : Model := Model.const (l.re * A) (l.im * A)

theorem coefficient_models {D A : ℤ} {F : ℕ} (hA : 0 < A) (hF : 0 < F)
    (hDA : D = (F : ℤ) * A) (l : Leaf) :
    Models D (coefficientModel A l) (fun _ => coefficient F l) := by
  have hd : (D : ℝ) = (F : ℝ) * A := by exact_mod_cast hDA
  have ha : (A : ℝ) ≠ 0 := by exact_mod_cast ne_of_gt hA
  have hf : (F : ℝ) ≠ 0 := by exact_mod_cast ne_of_gt hF
  convert const_models D (l.re * A) (l.im * A) using 1
  · rfl
  · funext x
    apply Complex.ext <;>
      simp [coefficient, Complex.div_re, Complex.div_im, Complex.normSq_natCast, hd] <;> field_simp

def leafModel (D : ℤ) (hD : 0 < D) (degree : ℕ) (A : ℤ)
    (P : Fin 3 → Fin 11 → Model) (l : Leaf) : Model :=
  Model.mul D hD degree (coefficientModel A l) (P 2 l.index)

def rowModel (D : ℤ) (hD : 0 < D) (degree : ℕ) (A : ℤ)
    (P : Fin 3 → Fin 11 → Model) (r : Row) : Model :=
  Model.mul D hD degree (FrozenComplexModel.sum (r.leaves.map (leafModel D hD degree A P))) (P 1 r.index)

def blockModel (D : ℤ) (hD : 0 < D) (degree : ℕ) (A : ℤ)
    (P : Fin 3 → Fin 11 → Model) (b : Block) : Model :=
  Model.mul D hD degree (FrozenComplexModel.sum (b.rows.map (rowModel D hD degree A P))) (P 0 b.index)

def treeModel (D : ℤ) (hD : 0 < D) (degree : ℕ) (A : ℤ)
    (P : Fin 3 → Fin 11 → Model) (bs : List Block) : Model :=
  FrozenComplexModel.sum (bs.map (blockModel D hD degree A P))

theorem leaf_models {D A : ℤ} {F : ℕ} (hD : 0 < D) (degree : ℕ) (hA : 0 < A) (hF : 0 < F)
    (hDA : D = (F : ℤ) * A) {P : Fin 3 → Fin 11 → Model} {φ : ℝ → Fin 3 → ℝ}
    (hP : ∀ i k, Models D (P i k) (fun x => phasor ((frequency k : ℝ) * φ x i))) (l : Leaf) :
    Models D (leafModel D hD degree A P l) (fun x => leafValue F (φ x) l) :=
  mul_models hD degree (coefficient_models hA hF hDA l) (hP 2 l.index)

theorem row_models {D A : ℤ} {F : ℕ} (hD : 0 < D) (degree : ℕ) (hA : 0 < A) (hF : 0 < F)
    (hDA : D = (F : ℤ) * A) {P : Fin 3 → Fin 11 → Model} {φ : ℝ → Fin 3 → ℝ}
    (hP : ∀ i k, Models D (P i k) (fun x => phasor ((frequency k : ℝ) * φ x i))) (r : Row) :
    Models D (rowModel D hD degree A P r) (fun x => rowValue F (φ x) r) := by
  apply mul_models hD degree _ (hP 1 r.index)
  exact sum_map_models r.leaves _ _ (fun l _ => leaf_models hD degree hA hF hDA hP l)

theorem block_models {D A : ℤ} {F : ℕ} (hD : 0 < D) (degree : ℕ) (hA : 0 < A) (hF : 0 < F)
    (hDA : D = (F : ℤ) * A) {P : Fin 3 → Fin 11 → Model} {φ : ℝ → Fin 3 → ℝ}
    (hP : ∀ i k, Models D (P i k) (fun x => phasor ((frequency k : ℝ) * φ x i))) (b : Block) :
    Models D (blockModel D hD degree A P b) (fun x => blockValue F (φ x) b) := by
  apply mul_models hD degree _ (hP 0 b.index)
  exact sum_map_models b.rows _ _ (fun r _ => row_models hD degree hA hF hDA hP r)

theorem tree_models {D A : ℤ} {F : ℕ} (hD : 0 < D) (degree : ℕ) (hA : 0 < A) (hF : 0 < F)
    (hDA : D = (F : ℤ) * A) {P : Fin 3 → Fin 11 → Model} {q : ℝ → FrozenField.Point}
    (hP : ∀ i k, Models D (P i k) (fun x => phasor ((frequency k : ℝ) * spatialPhase (q x) i)))
    (bs : List Block) :
    FrozenIntModel.Models D (treeModel D hD degree A P bs).re
      (fun x => FrozenField.value (flatten bs) F (q x)) := by
  have h := sum_map_models bs _ _ (fun b _ => block_models hD degree hA hF hDA hP b)
  simpa only [tree_real_value, treeModel, treeValue] using h.1

end FrozenFourierModel
