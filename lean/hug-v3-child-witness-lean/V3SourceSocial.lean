import V3SourceMemory
namespace HugV3.Source
noncomputable section
attribute [local instance] Classical.propDecidable
open scoped BigOperators
open Finset

def intent : Actor → Fin 2 → ℝ :=
  ![![0.8,0.1],![-0.5,0.65],![0.15,0.6],![0.65,-0.35],![-0.5,-0.45],![-0.1,0.2]]
def home : Actor → Fin 2 → ℝ :=
  ![![0.9,0.1],![0.15,0.85],![0.5,0.5],![0.8,0.2],![0.4,0.6],![0.6,0.4]]
def recognitionBase : Actor → Fin 2 → ℝ :=
  ![![0.95,0.7],![0.25,0.85],![0.6,0.75],![0.65,0.3],![0.2,0.2],![0.4,0.4]]
def authorityBase : Actor → Fin 2 → ℝ :=
  ![![0.7,0.15],![0.2,0.98],![0.75,0.8],![0.4,0.25],![0.1,0.2],![0.25,0.35]]
def margin (s : State) (i j : Actor) : ℝ :=
  Real.exp (s.logRadius i j)-Real.sqrt (∑ k, (s.expression j k-s.normCenter i k)^2)
def room (t : ℝ) : Fin 2 → ℝ :=
  let middle := sigmoid ((t-1)/0.06)-sigmoid ((t-2)/0.06)
  ![0.85-0.7*middle,0.15+0.7*middle]
def memoryFeature (G : Geometry) (s : State) (i j : Actor) : Vec :=
  ![(s.context i 0+s.context j 0)/2,(s.context i 1+s.context j 1)/2,
    (tanh ((∑ p, G.attach i p*strainNorm (s.F p))/0.12)+
     tanh ((∑ p, G.attach j p*strainNorm (s.F p))/0.12))/2]
def recordChange (r : Record) (p : Particle) : ℝ :=
  Real.sqrt (∑ k : Fin 6, (if k.val<3 then 1 else 2)*(r.deltaE p k)^2)
def recordWeight (G : Geometry) (s : State) (r : Record) : ℝ :=
  let i := r.recipient
  let j := r.origin
  let feature : Vec := ![r.context 0,r.context 1,
    tanh (0.5*(∑ p, (G.attach i p+G.attach j p)*recordChange r p)/0.12)]
  let difference := fun k => feature k-memoryFeature G s i j k-0.15*tanh (s.association i j k)
  (r.endTime-r.startTime)*Real.exp (-sqnorm difference/(2*0.32^2))
def exposure (G : Geometry) (s : State) (records : List (Fin 4 × Record)) (i j : Actor) : ℝ :=
  (records.map fun pair => let r := pair.2
    if r.recipient=i ∧ r.origin=j ∧ (score r).isSome then recordWeight G s r else 0).sum
def memory (G : Geometry) (s : State) (records : List (Fin 4 × Record))
    (i j : Actor) (k : Fin 4) : ℝ :=
  (records.map fun pair => let r := pair.2
    if r.recipient=i ∧ r.origin=j then
      match score r with
      | none => 0
      | some y => recordWeight G s r* (![max y 0,max (-y) 0,r.recognition,r.authority] k)
    else 0).sum / (0.12+exposure G s records i j)
def observations (G : Geometry) (s : State) (i : Actor) : Vec :=
  ![tanh ((∑ p, G.attach i p*(∑ x, R s.X p x*s.g x 3))/0.08),
    tanh ((∑ p, G.attach i p*strainNorm (s.F p))/0.12),
    tanh ((∑ p, G.attach i p*(∑ x, R s.X p x*s.g x 4))/0.03)]
def utility (G : Geometry) (s : State) (records : List (Fin 4 × Record)) : ℝ :=
  0.35*(∑ i, ∑ j, (memory G s records i j 0-memory G s records i j 1))/30 -
  0.2*(∑ i, ∑ k, (s.expression i k-intent i k)^2)/6 +
  0.2*(∑ i, ∑ j, tanh (margin s i j/0.4)*mask i j)/30 +
  0.08*(∑ i, tanh (observations G s i 0))/6
def utilityBaseline : ℝ :=
  0.2*(∑ i, ∑ j, tanh ((0.72-Real.sqrt (∑ k, (intent j k-0.65*intent i k)^2))/0.4)*mask i j)/30

structure SocialRates where
  expression : Actor → Fin 2 → ℝ
  context : Actor → Fin 2 → ℝ
  normCenter : Actor → Fin 2 → ℝ
  logRadius : Actor → Actor → ℝ
  relation : Actor → Actor → Fin 3 → ℝ
  responses : Actor → Actor → Fin 7 → ℝ
  association : Actor → Actor → Fin 3 → ℝ
  utility : ℝ
  sourceWeights : Particle → ℝ

def socialRates (G : Geometry) (t : ℝ) (s : State)
    (records : List (Fin 4 × Record)) : SocialRates :=
  let r := s.responses
  let B := s.relation
  let e := s.expression
  let obs := observations G s
  let mem := memory G s records
  let help := fun i j => mem i j 0
  let harm := fun i j => mem i j 1
  let permit := fun i j => sigmoid (margin s i j/0.18)
  let delta := fun i j k => e j k-e i k
  let dist2 := fun i j => ∑ k, (delta i j k)^2
  let agreement := fun i j => Real.exp (-dist2 i j/0.6)
  let contextSimilarity := fun i j => Real.exp (-(∑ k, (s.context i k-s.context j k)^2)/0.35)
  let attention := fun i j => (0.15+0.85*contextSimilarity i j)*(0.3+0.7*B i j 0)*
    (1-0.6*r i j 5)*mask i j
  let incoming := fun i j => r j i 4
  let targets := fun i j =>
    ![sigmoid (-0.7+1.8*B i j 0+0.7*B i j 2+help i j-harm i j+0.4*permit i j-0.7*r i j 3),
      sigmoid (-0.9+1.7*B i j 2+agreement i j+help i j-harm i j+0.6*r i j 6-0.5*r i j 2),
      sigmoid (-1.4+B i j 0+1.1*(1-B i j 2)+0.8*(1-agreement i j)+harm i j-help i j-0.6*r i j 6),
      sigmoid (-1.4+incoming i j+harm i j+(1-permit i j)+0.3*obs i 1-0.5*r i j 6),
      sigmoid (-1.7+1.8*B j i 1+0.9*(1-permit i j)+0.7*r i j 2-0.8*B i j 2),
      sigmoid (-1.8+harm i j+incoming i j+0.5*(1-permit i j)+0.35*obs i 1-help i j),
      sigmoid (-1.2+B i j 2+harm i j*B i j 2+0.6*r i j 1-0.7*r i j 2+0.2*obs i 2)]
  let pull := fun i j => r i j 0+0.65*r i j 1+0.8*r i j 6-0.6*r i j 2
  let proofB := fun j k => (∑ i, B i j k)/6
  let targetB := fun i j =>
    ![sigmoid (3*((∑ k, s.context i k*recognitionBase j k)-0.5)+0.7*proofB j 0+
         0.8*(r i j 0+r i j 2)+help i j-0.5*harm i j),
      sigmoid (3*((∑ k, s.context i k*authorityBase j k)-0.5)+0.7*proofB j 1+
         0.8*incoming i j-0.8*r i j 3+0.5*mem i j 3),
      sigmoid (1.4*agreement i j-1+1.5*help i j-1.5*harm i j+
         r i j 1+r i j 6-r i j 2-incoming i j)]
  let ctxDiff := fun i j k => s.context i k-s.context j k
  let intensity := fun i => (∑ j, ∑ k, r i j k)/6+(∑ j, B j i 0)/6
  let actuator := fun i => Real.exp (intensity i)/(∑ j, Real.exp (intensity j))
  let rawWeights := fun p => ∑ i, G.attach i p*actuator i
  { expression := fun i k => 0.8*(intent i k-e i k)+
      (∑ j, pull i j*delta i j k/Real.sqrt (1+dist2 i j))/5+
      (∑ j, incoming i j*(s.normCenter j k-e i k))/5+
      ((∑ j, (r i j 3+r i j 5))/6)*(intent i k-e i k)
    context := fun i k => 2*(0.6*home i k+0.4*room t k-s.context i k)+
      (∑ j, (-(r i j 0+r i j 1)*ctxDiff i j k+
        r i j 5*2*s.context i k*(ctxDiff i j k-(∑ l, s.context i l*ctxDiff i j l))))/5
    normCenter := fun i k => 0.7*(0.6*intent i k+0.4*e i k-s.normCenter i k)+
      (∑ j, (r i j 1+r i j 6-r i j 4)*(e j k-s.normCenter i k))/5
    logRadius := fun i j => 1.8*(Real.log (0.55+0.45*sigmoid
      (1.4*B i j 2+help i j-harm i j+r i j 6-r i j 4-0.3*obs i 0))-s.logRadius i j)
    relation := fun i j k => 2*(targetB i j k*mask i j-B i j k)
    responses := fun i j k => 4*(targets i j k*attention i j-r i j k)
    association := fun i j k => 1.5*(2*(help i j-harm i j)*
      tanh ((![delta i j 0,delta i j 1,obs j 1-obs i 1]) k)-s.association i j k)
    utility := pulse t+0.8*(utility G s records-utilityBaseline)
    sourceWeights := fun p => rawWeights p/(∑ q, rawWeights q) }

end
end HugV3.Source
