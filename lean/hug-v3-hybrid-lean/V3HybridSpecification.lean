import HybridSpecification

/- A complete state-shape and event-schedule specification for the selected
   V3 source. The full differential RHS and codec are NOT yet bound to the
   law and action arguments below. This is not a hidden existence axiom. -/
namespace V3Hybrid
noncomputable section

abbrev Vector3 := Fin 3 → ℝ
abbrev Matrix3 := Fin 3 → Fin 3 → ℝ
def fabricSize (parcels capacity : ℕ) := capacity * (2 * (23 + 6 * parcels) + 4) * 8

structure NumericalState (grid parcels directions capacity : ℕ) where
  -- The five source grid coordinates are u_x,u_y,u_z,C,theta.
  gridFields : Fin grid → Fin grid → Fin grid → Fin 5 → ℝ
  position : Fin parcels → Vector3
  deformation : Fin parcels → Matrix3
  directionalRecords : Fin parcels → Fin directions → Fin 2 → ℝ
  fabric : Fin (fabricSize parcels capacity) → ℝ
  accumulator : ℝ
  ledgers : Fin 4 → ℝ
  writingWork : ℝ
  expression : Fin 6 → Fin 2 → ℝ
  context : Fin 6 → Fin 2 → ℝ
  normCenter : Fin 6 → Fin 2 → ℝ
  logRadius : Fin 6 → Fin 6 → ℝ
  relationship : Fin 6 → Fin 6 → Fin 3 → ℝ
  responses : Fin 6 → Fin 6 → Fin 7 → ℝ
  association : Fin 6 → Fin 6 → Fin 3 → ℝ

structure FullState (grid parcels directions capacity : ℕ) where
  numerical : NumericalState grid parcels directions capacity
  -- run.py captures F at event starts and consumes it at the matching end.
  starts : Fin 3 → Option (Fin parcels → Matrix3)

abbrev MainState := FullState 16 384 24 4
def sameAgent : String := "The same returning student"
def sameIdea : String := "Giving someone space to speak can change what I understand."

-- A mathematical bit pattern only. Proving this matches the complete source
-- probe/pack/unpack implementation is a separate correspondence obligation.
def bitPattern {I : Type*} (b : I → ℝ) : I → Bool := fun i => decide (0 < b i)

inductive Action
  | capture (event : Fin 3)
  | write (event : Fin 3)
  deriving DecidableEq, Repr

-- Exact rational reading of the source's decimal event times.
def time : ℕ → ℝ
  | 0 => 0
  | 1 => 1/5
  | 2 => 2/5
  | 3 => 4/5
  | 4 => 6/5
  | _ => 8/5

def actions : ℕ → List Action
  | 0 => [.capture 0]
  | 1 => [.capture 1]
  | 2 => [.write 0]
  | 3 => [.write 1, .capture 2]
  | 4 => [.write 2]
  | _ => []

-- 'write' must include record construction, validation, budget accounting,
-- the complete state update and removal of its start snapshot. A rejected
-- operation is none; it cannot silently become a successful next state.
def runActions {E : Type*} (op : Action → E → Option E) : List Action → E → Option E
  | [], s => some s
  | action :: rest, s => (op action s).bind (fun next => runActions op rest next)

def mainSystem (law : ℕ → (ℝ → MainState) → Prop)
    (admissible : ℕ → MainState → Prop) (op : Action → MainState → Option MainState) :
    Hybrid.System MainState :=
  ⟨time, law, admissible, fun k state => runActions op (actions k) state⟩

-- Initial capture is explicit. The theorem uses the resulting complete
-- initial state, not an unrecorded/reset copy of the numerical state.
def Initialized (op : Action → MainState → Option MainState)
    (raw initial : MainState) : Prop := runActions op (actions 0) raw = some initial

end
end V3Hybrid
