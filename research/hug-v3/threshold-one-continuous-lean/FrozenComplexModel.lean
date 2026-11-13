import FrozenIntModel
import Mathlib.Analysis.Complex.Exponential
import Mathlib.Analysis.Complex.Trigonometric

namespace FrozenComplexModel
open FrozenIntPolynomial FrozenIntModel Complex

structure Model where
  re : FrozenIntModel.Model
  im : FrozenIntModel.Model

def Models (D : ℤ) (m : Model) (f : ℝ → ℂ) : Prop :=
  FrozenIntModel.Models D m.re (fun x => (f x).re) ∧
  FrozenIntModel.Models D m.im (fun x => (f x).im)

def Model.const (a b : ℤ) : Model :=
  ⟨FrozenIntModel.Model.exact [a], FrozenIntModel.Model.exact [b]⟩

theorem const_models (D a b : ℤ) : Models D (Model.const a b)
    (fun _ => (((a : ℝ) / D : ℝ) : ℂ) + (((b : ℝ) / D : ℝ) : ℂ) * I) := by
  constructor <;> intro x hx <;> simp [Model.const, FrozenIntModel.Model.exact, eval]

def Model.add (m n : Model) : Model := ⟨m.re.add n.re, m.im.add n.im⟩

theorem add_models {D : ℤ} {m n : Model} {f g : ℝ → ℂ}
    (hf : Models D m f) (hg : Models D n g) : Models D (m.add n) (fun x => f x + g x) := by
  exact ⟨FrozenIntModel.add_models hf.1 hg.1, FrozenIntModel.add_models hf.2 hg.2⟩

def Model.conj (m : Model) : Model := ⟨m.re, m.im.neg⟩

theorem conj_models {D : ℤ} {m : Model} {f : ℝ → ℂ} (hf : Models D m f) :
    Models D m.conj (fun x => (starRingEnd ℂ) (f x)) := by
  exact ⟨hf.1, FrozenIntModel.neg_models hf.2⟩

def Model.mul (D : ℤ) (hD : 0 < D) (degree : ℕ) (m n : Model) : Model :=
  ⟨(FrozenIntModel.Model.mul D hD degree m.re n.re).sub
     (FrozenIntModel.Model.mul D hD degree m.im n.im),
   (FrozenIntModel.Model.mul D hD degree m.re n.im).add
     (FrozenIntModel.Model.mul D hD degree m.im n.re)⟩

theorem mul_models {D : ℤ} (hD : 0 < D) (degree : ℕ) {m n : Model} {f g : ℝ → ℂ}
    (hf : Models D m f) (hg : Models D n g) :
    Models D (Model.mul D hD degree m n) (fun x => f x * g x) := by
  constructor
  · exact FrozenIntModel.sub_models (FrozenIntModel.mul_models hD degree hf.1 hg.1)
      (FrozenIntModel.mul_models hD degree hf.2 hg.2)
  · simpa only [Model.mul, Complex.mul_im, add_comm] using
      FrozenIntModel.add_models (FrozenIntModel.mul_models hD degree hf.1 hg.2)
        (FrozenIntModel.mul_models hD degree hf.2 hg.1)

def Model.pow (D : ℤ) (hD : 0 < D) (degree : ℕ) (m : Model) : ℕ → Model
  | 0 => Model.const D 0
  | n + 1 => Model.mul D hD degree (Model.pow D hD degree m n) m

theorem pow_models {D : ℤ} (hD : 0 < D) (degree : ℕ) {m : Model} {f : ℝ → ℂ}
    (hf : Models D m f) (n : ℕ) :
    Models D (Model.pow D hD degree m n) (fun x => f x ^ n) := by
  induction n with
  | zero =>
    have hd : (D : ℝ) ≠ 0 := by exact_mod_cast ne_of_gt hD
    simpa [Model.pow, hd] using const_models D D 0
  | succ n ih => simpa only [Model.pow, pow_succ] using mul_models hD degree ih hf

def Model.intPhase (D : ℤ) (hD : 0 < D) (degree : ℕ) (m : Model) : ℤ → Model
  | .ofNat n => Model.pow D hD degree m n
  | .negSucc n => (Model.pow D hD degree m (n+1)).conj

theorem intPhase_models {D : ℤ} (hD : 0 < D) (degree : ℕ) {m : Model} {θ : ℝ → ℝ}
    (hf : Models D m (fun x => Complex.exp ((θ x : ℂ) * I))) (k : ℤ) :
    Models D (Model.intPhase D hD degree m k)
      (fun x => Complex.exp (((k : ℝ) * θ x : ℝ) * I)) := by
  cases k with
  | ofNat n =>
    have h := pow_models hD degree hf n
    convert h using 1
    · rfl
    · funext x
      rw [← Complex.exp_nat_mul]
      congr 1
      push_cast
      change (n : ℂ) * (θ x : ℂ) * I = _
      ring
  | negSucc n =>
    have h := conj_models (pow_models hD degree hf (n+1))
    convert h using 1
    · rfl
    · funext x
      rw [← Complex.exp_nat_mul, ← Complex.exp_conj]
      simp only [Int.cast_negSucc, ofReal_neg, ofReal_add, ofReal_natCast, ofReal_one,
        ofReal_mul, map_mul, conj_ofReal, conj_I, Nat.cast_add, Nat.cast_one,
        map_add, map_one, map_natCast]
      congr 1
      ring

def sum : List Model → Model
  | [] => Model.const 0 0
  | m :: ms => m.add (sum ms)

theorem sum_models {D : ℤ} (ms : List Model) (fs : List (ℝ → ℂ))
    (h : List.Forall₂ (Models D) ms fs) :
    Models D (sum ms) (fun x => (fs.map (fun f => f x)).sum) := by
  induction h with
  | nil => simpa [sum] using const_models D 0 0
  | cons hf h ih => simpa only [sum, List.map_cons, List.sum_cons] using add_models hf ih

end FrozenComplexModel
