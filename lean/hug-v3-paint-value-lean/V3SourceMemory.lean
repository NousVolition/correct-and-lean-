import V3SourceCore
namespace HugV3.Source
noncomputable section
attribute [local instance] Classical.propDecidable
open scoped BigOperators
open Finset

structure Record where
  origin : Actor
  recipient : Actor
  eventID : Fin 15
  startTime : ℝ
  endTime : ℝ
  predecessors : ℤ
  observed : Option ℝ
  report : Option ℝ
  context : Fin 2 → ℝ
  recognition : ℝ
  authority : ℝ
  actions : Fin 7 → ℝ
  deltaE : Particle → Fin 6 → ℝ

def outcomeValid (v : Option ℝ) : Prop := ∀ x ∈ v, -1≤x ∧ x≤1
def score (r : Record) : Option ℝ := match r.observed, r.report with
  | none, none => none
  | some x, none => some x
  | none, some y => some y
  | some x, some y => some ((x+y)/2)
def roundEven (x : ℝ) : ℤ :=
  let k := Int.floor x
  if x-(k:ℝ)<1/2 then k else
  if x-(k:ℝ)>1/2 then k+1 else if k%2=0 then k else k+1
def quant (q x : ℝ) : Option ℤ :=
  let k := roundEven (x/q)
  if -32768≤k ∧ k≤32767 then some k else none
def intBytes (x : ℤ) : List ℕ :=
  let u := (x%65536).toNat
  [u%256, u/256]
def natLE (xs : List ℕ) (offset count : ℕ) : ℕ :=
  ((List.range count).map (fun k => xs[offset+k]?.getD 0 * 256^k)).sum
def signed16 (xs : List ℕ) (index : ℕ) : ℤ :=
  let v := natLE xs (2*index) 2
  if v<32768 then v else (v:ℤ)-65536
def crcBit (v : ℕ) : ℕ := cond (v%2 == 1) (Nat.xor (v/2) 3988292384) (v/2)
def crcByte (v byte : ℕ) : ℕ := (crcBit^[8]) (Nat.xor v byte)
def crc32 (xs : List ℕ) : ℕ := Nat.xor (xs.foldl crcByte 4294967295) 4294967295

def payload (r : Record) : Option (List ℕ) := do
  if r.origin=r.recipient ∨ ¬(0≤r.startTime ∧ r.startTime<r.endTime ∧
      0≤r.predecessors ∧ r.predecessors<32768 ∧ outcomeValid r.observed ∧ outcomeValid r.report)
    then none
  else
    let times ← [r.startTime,r.endTime].mapM (quant (1/1000))
    let outcomes ← [r.observed.getD 0,r.report.getD 0].mapM (quant (1/10000))
    let features ← ([r.context 0,r.context 1,r.recognition,r.authority] ++
      (List.ofFn r.actions)).mapM (quant (1/10000))
    let field ← ((List.ofFn fun p => List.ofFn (r.deltaE p)).flatten).mapM (quant (1/10000))
    let header : List ℤ := [1729,1,(r.origin.val:ℤ),(r.recipient.val:ℤ),(r.eventID.val:ℤ)] ++ times ++
      [r.predecessors,if r.observed.isSome then 1 else 0,if r.report.isSome then 1 else 0] ++ outcomes ++ features
    let body := (header++field).flatMap intBytes
    let crc := crc32 body
    return body ++ ((List.range 4).map fun k => (crc/256^k)%256)

def unpack (xs : List ℕ) : Option (Option Record) :=
  if xs.all (· == 0) then some none else
  let body := xs.take 4654
  let h := signed16 body
  if crc32 body ≠ natLE xs 4654 4 ∨ h 0≠1729 ∨ h 1≠1 then none else
  if ok : h 2≠h 3 ∧ 0≤h 2 ∧ h 2<6 ∧ 0≤h 3 ∧ h 3<6 ∧ 0≤h 4 ∧ h 4<15 then
    some (some {
      origin := ⟨(h 2).toNat, by omega⟩
      recipient := ⟨(h 3).toNat, by omega⟩
      eventID := ⟨(h 4).toNat, by omega⟩
      startTime := (h 5:ℝ)/1000
      endTime := (h 6:ℝ)/1000
      predecessors := h 7
      observed := if h 8=0 then none else some ((h 10:ℝ)/10000)
      report := if h 9=0 then none else some ((h 11:ℝ)/10000)
      context := fun j => (h (12+j.val):ℝ)/10000
      recognition := (h 14:ℝ)/10000
      authority := (h 15:ℝ)/10000
      actions := fun j => (h (16+j.val):ℝ)/10000
      deltaE := fun p j => (h (23+6*p.val+j.val):ℝ)/10000 })
  else none

def cellAt (slot : Fin 4) (bit : Fin 37264) : Cell :=
  ⟨slot.val*37264+bit.val, by omega⟩
def probeEstimate (s : State) (l : Cell) : ℝ :=
  let e := fabricStrain s.F l
  let lo := e-1/1000
  let hi := e+1/1000
  ((lo-((1/25)*(lo-s.b l))/(1/25))+(hi-((1/25)*(hi-s.b l))/(1/25)))/2
def slotBytes (s : State) (slot : Fin 4) : List ℕ :=
  List.ofFn fun byte : Fin 4658 => ∑ bit : Fin 8,
    if 0<probeEstimate s (cellAt slot ⟨byte.val*8+bit.val, by omega⟩) then 2^bit.val else 0
def readRecords (s : State) : Option (List (Fin 4 × Record)) := do
  if ¬(∀ l, 1/200≤|probeEstimate s l|) then none else
    let rows ← (List.ofFn (fun slot : Fin 4 => slot)).mapM fun slot => do
      let r ← unpack (slotBytes s slot)
      return r.map (fun record => (slot,record))
    return rows.filterMap id

def bitsOfPayload (xs : List ℕ) (i : ℕ) : ℝ :=
  if (xs[i/8]?.getD 0 / 2^(i%8))%2=0 then -1/50 else 1/50
def targetFabric (s : State) (slot : Fin 4) (xs : List ℕ) (l : Cell) : ℝ :=
  if l.val/37264=slot.val then bitsOfPayload xs (l.val%37264) else s.b l
def storedEnergy (G : Geometry) (s : State) (b : Cell → ℝ) : ℝ :=
  ∑ l, G.V (point l)*localWeight l*fabricEnergy (fabricStrain s.F l) (b l)

structure WriteAccount where
  target : Cell → ℝ
  heat : Particle → ℝ
  work : ℝ
  requiredBudget : ℝ

def writeAccount (G : Geometry) (s : State) (target : Cell → ℝ) : WriteAccount :=
  let d := fun l => target l-s.b l
  let heat := fun p => ∑ l, if point l=p then localWeight l*(1/20)*(d l)^2/(1/50) else 0
  let diss := ∑ p, G.V p*heat p
  let wt := fun l => G.V (point l)*localWeight l
  let e := fun l => fabricStrain s.F l
  let c₁ := (∑ l, wt l*fabricGradient (e l) (s.b l)*d l)+diss
  let c₂ := ∑ l, wt l*((1/2)*(1/25)+(1/500)*(3*(s.b l)^2-(1/50)^2)/(2*(1/50)^4))*(d l)^2
  let c₃ := ∑ l, wt l*(1/500)*s.b l*(d l)^3/(1/50)^4
  let c₄ := ∑ l, wt l*(1/500)*(d l)^4/(4*(1/50)^4)
  { target := target, heat := heat
    work := storedEnergy G s target-storedEnergy G s s.b+diss
    requiredBudget := max c₁ 0 + max c₂ 0 + max c₃ 0 + max c₄ 0 }

def writeEvent (G : Geometry) (s : State) (record : Record) : Option State := do
  let records ← readRecords s
  if records.any (fun r => r.2.eventID == record.eventID) then none else
    let free ← (List.ofFn (fun slot : Fin 4 => slot)).find? fun slot =>
      !(records.any (fun r => r.1 == slot))
    let bytes ← payload record
    let account := writeAccount G s (targetFabric s free bytes)
    if account.requiredBudget>1/50 ∨ account.work<0 then none else
      let heatGrid := fun x => (∑ p, R s.X p x*G.V p*account.heat p)/dv
      return { s with
        b := account.target
        g := fun x j => s.g x j + if j=4 then filt heatGrid x else 0
        writeWork := s.writeWork+account.work }

end
end HugV3.Source
