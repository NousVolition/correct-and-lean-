import FrozenIntModel
import Mathlib.Analysis.Real.Pi.Bounds

namespace FrozenDyadicConstants
open FrozenIntPolynomial FrozenIntModel

def denominator : ℤ := 1606938044258990275541962092341162602522202993782792835301376

theorem denominator_positive : 0 < denominator := by decide

def piNumerator : ℤ := 5048344754617993871973410141242436836214643421488662971535368

def piError : ℤ := 16069380442589902755419620923411626025223

def piModel : Model := ⟨[piNumerator], piError, by decide⟩

theorem pi_models : Models denominator piModel (fun _ => Real.pi) := by
  intro x hx
  have hl := Real.pi_gt_d20
  have hu := Real.pi_lt_d20
  simp only [piModel, eval, mul_zero, add_zero]
  norm_num only [piNumerator, piError, denominator, Int.cast_ofNat]
  rw [abs_le]
  constructor <;> linarith

def halfModel : Model := Model.exact [denominator / 2]

theorem half_models : Models denominator halfModel (fun _ => (1/2 : ℝ)) := by
  intro x hx
  norm_num [halfModel, Model.exact, eval, denominator]

def twoModel : Model := Model.exact [2 * denominator]

theorem two_models : Models denominator twoModel (fun _ => (2 : ℝ)) := by
  intro x hx
  norm_num [twoModel, Model.exact, eval, denominator]

def phaseModel (degree : ℕ) (q : Poly) : Model :=
  Model.mul denominator denominator_positive degree twoModel
    (Model.mul denominator denominator_positive degree piModel ((Model.exact q).add halfModel))

theorem phase_models (degree : ℕ) (q : Poly) : Models denominator (phaseModel degree q)
    (fun x => 2 * Real.pi * (eval q x / denominator + 1/2)) := by
  have hq := add_models (exact_models denominator q) half_models
  have hp := mul_models denominator_positive degree pi_models hq
  have h := mul_models denominator_positive degree two_models hp
  simpa only [phaseModel, mul_assoc] using h

end FrozenDyadicConstants
