import V3SourceSystem
import Mathlib.Analysis.SpecialFunctions.ExpDeriv

namespace HugV3.Source.Transfer
noncomputable section
attribute [local instance] Classical.propDecidable
open scoped BigOperators

/-- A comparison of two full states. This changes one input state coordinate,
not the equations or the declared main initial condition. -/
def bumpCooperation (s : State) (student first : Actor) (δ : ℝ) : State :=
  { s with responses := fun i j k => s.responses i j k +
      if i=student ∧ j=first ∧ k=1 then δ else 0 }

/-- An observable of the existing guard. No new evolution law. -/
def guardSquared (s : State) (i j : Actor) : ℝ :=
  (Real.exp (s.logRadius i j))^2-∑ k, (s.expression j k-s.normCenter i k)^2

def guardSquaredRate (s d : State) (i j : Actor) : ℝ :=
  2*(Real.exp (s.logRadius i j))^2*d.logRadius i j-
    2*∑ k, (s.expression j k-s.normCenter i k)*(d.expression j k-d.normCenter i k)

def alignment (s : State) (student first second : Actor) : ℝ :=
  ∑ k, (s.expression second k-s.normCenter student k)*
    (s.expression first k-s.normCenter student k)

/-- Exact projections, used to expose the unchanged source components. -/
def normRate (s : State) (i : Actor) (k : Fin 2) : ℝ :=
  0.7*(0.6*intent i k+0.4*s.expression i k-s.normCenter i k)+
  (∑ j, (s.responses i j 1+s.responses i j 6-s.responses i j 4)*
    (s.expression j k-s.normCenter i k))/5

def expressionRate (s : State) (i : Actor) (k : Fin 2) : ℝ :=
  0.8*(intent i k-s.expression i k)+
  (∑ j, (s.responses i j 0+0.65*s.responses i j 1+0.8*s.responses i j 6-0.6*s.responses i j 2)*
    (s.expression j k-s.expression i k)/
    Real.sqrt (1+∑ l, (s.expression j l-s.expression i l)^2))/5+
  (∑ j, s.responses j i 4*(s.normCenter j k-s.expression i k))/5+
  ((∑ j, (s.responses i j 3+s.responses i j 5))/6)*(intent i k-s.expression i k)

def attention (s : State) (i j : Actor) : ℝ :=
  (0.15+0.85*Real.exp (-(∑ k, (s.context i k-s.context j k)^2)/0.35))*
    (0.3+0.7*s.relation i j 0)*(1-0.6*s.responses i j 5)*mask i j

def cooperationBase (s : State) (i j : Actor) : ℝ :=
  -0.9+1.7*s.relation i j 2+
    Real.exp (-(∑ k, (s.expression j k-s.expression i k)^2)/0.6)+
    0.6*s.responses i j 6-0.5*s.responses i j 2

end
end HugV3.Source.Transfer
