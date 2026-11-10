import PrimeMeter.Recorded

namespace HugPrimeMeter

open Recorded

inductive Arm | alwaysOff | onUntil41

def receipt : Arm → Receipt
  | .alwaysOff => offReceipt
  | .onUntil41 => onReceipt

def rows : Arm → List TickRow
  | .alwaysOff => offRows
  | .onUntil41 => onRows

def residualChange (r : Receipt) : Int := r.four157.residual - r.three157.residual

end HugPrimeMeter
