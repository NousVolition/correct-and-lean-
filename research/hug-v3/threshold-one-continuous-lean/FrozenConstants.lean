import FrozenPolynomial
import Mathlib.Analysis.Real.Pi.Bounds

namespace FrozenConstants
open FrozenPolynomial

def piLower : ℚ := 314159265358979323846 / 100000000000000000000
def piError : ℚ := 1 / 100000000000000000000

def piModel : Model := ⟨[piLower], piError, by norm_num [piError]⟩

theorem piModel_sound : Models piModel (fun _ => Real.pi) := by
  intro x _
  have hl := Real.pi_gt_d20
  have hu := Real.pi_lt_d20
  simp only [piModel, eval, mul_zero, add_zero]
  norm_num only [piLower, piError, Rat.cast_div, Rat.cast_ofNat, Rat.cast_one]
  rw [abs_le]
  constructor <;> linarith

def phaseModel (q : Poly) : Model :=
  (Model.exact [2]).mul (piModel.mul ((Model.exact q).add (Model.exact [1/2])))

theorem phaseModel_sound (q : Poly) :
    Models (phaseModel q) (fun x => 2 * Real.pi * (eval q x + 1/2)) := by
  have hq := add_models (exact_models q) (exact_models [1/2])
  have hp := mul_models piModel_sound hq
  have h := mul_models (exact_models [2]) hp
  simpa [phaseModel, eval, mul_assoc] using h

end FrozenConstants
