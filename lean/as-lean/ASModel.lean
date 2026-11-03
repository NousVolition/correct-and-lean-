import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.MeasureTheory.Integral.IntervalIntegral.Basic
import Mathlib.Data.Fin.VecNotation

/-! E1-E16 of the frozen Monoxide-buildup register. One agent and one idea.
The seven coordinates are A, SSmoke, SClay, LSmokeToClay, LClayToSmoke,
zSmoke, zClay. No coordinate denotes another agent or a second idea.
Definitions below are the reference, not proof assumptions or definition holes.
-/
namespace SocialAS
noncomputable section
abbrev State := Fin 7 → ℝ
abbrev Meaning := Fin 2 → ℝ
def pos (x : ℝ) : ℝ := max x 0
def indicator (b : Bool) : ℝ := if b then 1 else 0

structure Parameters where
  gamma : ℝ
  kappa : ℝ
  baseline : ℝ
  decay : ℝ
  wSmokeClay : ℝ
  wClaySmoke : ℝ
  KSmoke : ℝ
  KClay : ℝ
  threshold : ℝ
  rStar : ℝ
  g : ℝ
  p0 : ℝ
  eta : ℝ
  beta : ℝ
  alpha : ℝ
  loadStar : ℝ
  meaningStar : ℝ
  chiMax : ℝ
  thetaMax : ℝ
  imposedForward : ℝ
  imposedReverse : ℝ
  refSmoke : ℝ
  refClay : ℝ

structure Inputs where
  utility : ℝ
  exposureForward : ℝ
  exposureReverse : ℝ
  adverseForward : Bool
  adverseReverse : Bool
  clearForward : ℝ
  clearReverse : ℝ
  clarifySmoke : ℝ
  clarifyClay : ℝ

def UnitInterval (x : ℝ) : Prop := 0 ≤ x ∧ x ≤ 1
def ParametersOK (p : Parameters) : Prop :=
  0 ≤ p.gamma ∧ 0 ≤ p.kappa ∧ 0 < p.decay ∧
  0 ≤ p.wSmokeClay ∧ 0 ≤ p.wClaySmoke ∧
  0 ≤ p.KSmoke ∧ 0 ≤ p.KClay ∧ p.KSmoke + p.KClay = 1 ∧
  0 ≤ p.threshold ∧ 0 < p.rStar ∧
  UnitInterval p.g ∧ UnitInterval p.p0 ∧ UnitInterval p.eta ∧ UnitInterval p.beta ∧
  0 ≤ p.alpha ∧ 0 < p.loadStar ∧ 0 < p.meaningStar ∧
  UnitInterval p.chiMax ∧ UnitInterval p.thetaMax ∧
  UnitInterval p.imposedForward ∧ UnitInterval p.imposedReverse ∧
  UnitInterval p.refSmoke ∧ UnitInterval p.refClay
def InputsOK (i : Inputs) : Prop :=
  0 ≤ i.exposureForward ∧ 0 ≤ i.exposureReverse ∧
  0 ≤ i.clearForward ∧ 0 ≤ i.clearReverse ∧
  0 ≤ i.clarifySmoke ∧ 0 ≤ i.clarifyClay
def StateOK (x : State) : Prop :=
  0 ≤ x 3 ∧ 0 ≤ x 4 ∧ UnitInterval (x 5) ∧ UnitInterval (x 6)
-- A and S remain signed. StateOK does not silently require their positivity.

-- E1, E2.
def accumulatedDrift (gamma utility baseline : ℝ) := gamma * (utility - baseline)
def source (p : Parameters) (x : State) : ℝ := p.kappa * x 0
-- E11 and E13; the positive loadStar hypothesis is required in theorems.
def saturation (L scale : ℝ) : ℝ := L / (L + scale)
def effect (gain L scale : ℝ) : ℝ := gain * saturation L scale
def chiForward (p : Parameters) (x : State) := effect p.chiMax (x 3) p.loadStar
def chiReverse (p : Parameters) (x : State) := effect p.chiMax (x 4) p.loadStar
def thetaForward (p : Parameters) (x : State) := effect p.thetaMax (x 3) p.loadStar
def thetaReverse (p : Parameters) (x : State) := effect p.thetaMax (x 4) p.loadStar
-- E3-E5, with source index second in w.
def exchange (w chi gap : ℝ) : ℝ := w * (gap - chi * pos gap)
def smokeDrift (p : Parameters) (x : State) : ℝ :=
  exchange p.wSmokeClay (chiReverse p x) (x 2 - x 1) +
  p.KSmoke * source p x - p.decay * x 1
def clayDrift (p : Parameters) (x : State) : ℝ :=
  exchange p.wClaySmoke (chiForward p x) (x 1 - x 2) +
  p.KClay * source p x - p.decay * x 2
def roleS (x : State) : Fin 2 → ℝ := ![x 1, x 2]
def roleK (p : Parameters) : Fin 2 → ℝ := ![p.KSmoke, p.KClay]
def roleW (p : Parameters) : Fin 2 → ℝ := ![p.wSmokeClay, p.wClaySmoke]
def incomingChi (p : Parameters) (x : State) : Fin 2 → ℝ :=
  ![chiReverse p x, chiForward p x]
def generalSDrift (p : Parameters) (x : State) (c : Fin 2) : ℝ :=
  (∑ d : Fin 2, if d = c then 0 else
    exchange (roleW p c) (incomingChi p x c) (roleS x d - roleS x c)) +
  roleK p c * source p x - p.decay * roleS x c
-- E12.
def loadDrift (alpha : ℝ) (h : Bool) (exposure clear L : ℝ) : ℝ :=
  alpha * indicator h * exposure - clear * L
-- E14-E16.
def receivedMeaning (theta z imposed : ℝ) : ℝ := (1 - theta) * z + theta * imposed
def meaningRate (w chi S scale : ℝ) : ℝ := (1 - chi) * w * pos S / (scale + pos S)
def meaningDrift (rate received z clarify reference : ℝ) : ℝ :=
  rate * (received - z) + clarify * (reference - z)
def smokeMeaningDrift (p : Parameters) (i : Inputs) (x : State) : ℝ :=
  meaningDrift (meaningRate p.wSmokeClay (chiReverse p x) (x 2) p.meaningStar)
    (receivedMeaning (thetaReverse p x) (x 6) p.imposedReverse)
    (x 5) i.clarifySmoke p.refSmoke
def clayMeaningDrift (p : Parameters) (i : Inputs) (x : State) : ℝ :=
  meaningDrift (meaningRate p.wClaySmoke (chiForward p x) (x 1) p.meaningStar)
    (receivedMeaning (thetaForward p x) (x 5) p.imposedForward)
    (x 6) i.clarifyClay p.refClay
def evolution (p : Parameters) (i : Inputs) (x : State) : State :=
  ![accumulatedDrift p.gamma i.utility p.baseline,
    smokeDrift p x, clayDrift p x,
    loadDrift p.alpha i.adverseForward i.exposureForward i.clearForward (x 3),
    loadDrift p.alpha i.adverseReverse i.exposureReverse i.clearReverse (x 4),
    smokeMeaningDrift p i x, clayMeaningDrift p i x]
-- E6-E8. Probabilities are kernels at a specified encounter/state.
def activation (clay threshold : ℝ) : ℝ := pos (clay - threshold)
def opportunityActivation (g r : ℝ) : ℝ := g * r
def opening (g p0 r rStar : ℝ) : ℝ := g * (p0 + (1 - p0) * r / (rStar + r))
def registration (eta z challenge : ℝ) : ℝ := eta * (1 - z * challenge)
def conditionalRegistration (eta z challenge : ℝ) (B : Bool) : ℝ :=
  registration eta z challenge * indicator B
-- Joint branches: (false,false), (true,false), (true,true).
-- The omitted (false,true) branch has weight zero.
def branches (p q : ℝ) : Fin 3 → ℝ := ![1-p, p*(1-q), p*q]
-- E9-E10. M denotes potential received content at this specified encounter;
-- the false branch never requires content to update H.
def information (C : Bool) (M H : Meaning) : Meaning :=
  fun j => indicator C * (M j - H j)
def update (beta : ℝ) (C : Bool) (H M : Meaning) : Meaning :=
  fun j => H j + beta * information C M H j
def Simplex (H : Meaning) : Prop := (∀ j, 0 ≤ H j) ∧ (∑ j, H j) = 1

/- The time convention is integral, permitting continuous states with
piecewise input/repair switches. It changes no right-hand side in E1-E16.
This defines what a solution must satisfy; it is not an existence theorem. -/
def IntegralSolution (p : Parameters) (i : ℝ → Inputs) (t0 T : ℝ)
    (initial : State) (trajectory : ℝ → State) : Prop :=
  ContinuousOn trajectory (Set.Icc t0 T) ∧ trajectory t0 = initial ∧
  (∀ j t, t ∈ Set.Icc t0 T →
    IntervalIntegrable (fun s => evolution p (i s) (trajectory s) j) MeasureTheory.volume t0 t) ∧
  (∀ j t, t ∈ Set.Icc t0 T → trajectory t j = initial j +
    ∫ s in t0..t, evolution p (i s) (trajectory s) j)

end
end SocialAS
