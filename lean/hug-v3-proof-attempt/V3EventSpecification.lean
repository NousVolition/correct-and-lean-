import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Topology.Order.LeftRightNhds
import Mathlib.Tactic

/-
Source-bound necessary conditions for the selected structural Hug v3.
This module is NOT a formalization of the full fluid RHS and NOT an
existence/uniqueness theorem. Its scope is deliberately explicit.

structural_hug.py:
  energy_force: stress = micro_k * (e - b)
  bits_from_probe: estimated = mean(loads - tractions / micro_k)
  target[free_slot] = rest_amplitude * (2 * bits - 1)
  empty/free slots decode to all-zero bytes, hence negative probe bits.
  run.py calls write_event at the scheduled endpoint (not a continuous stroke).
The mathematical interpretation here uses exact real arithmetic.
Floating-point rounding and decoder/source correspondence remain separate.
-/
namespace HugV3Event
noncomputable section
open Filter Set
open scoped Topology

def amplitude : ℝ := 1 / 50
def readMargin : ℝ := 1 / 4
def microK : ℝ := 1 / 25
def headerMagic : ℕ := 1729
def traction (k load b : ℝ) : ℝ := k * (load - b)
def inferredRestStrain (k load b : ℝ) : ℝ := load - traction k load b / k
def writtenBit (a : ℝ) (bit : Bool) : ℝ := a * (if bit then 1 else -1)

-- This is a condition on a successfully decoded empty slot coordinate,
-- not an invariant silently assumed for the entire V3 trajectory.
def ValidEmptyCoordinate (a margin b : ℝ) : Prop :=
  0 < a ∧ 0 < margin ∧ b ≤ -(margin * a)

-- A source event with a nonzero written header bit has these scalar limits.
-- Other coordinates of the full coupled state remain unrestricted here.
def EventWitness (f : ℝ → ℝ) (eventTime before a : ℝ) : Prop :=
  Tendsto f (𝓝[<] eventTime) (𝓝 before) ∧
  f eventTime = writtenBit a true ∧ before < 0 ∧ 0 < a

end
end HugV3Event
