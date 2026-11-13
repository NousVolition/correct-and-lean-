import ClosestPointGeometry
noncomputable section
def probeShape (c k z : ℝ) : ℝ := c * Real.sin (k * z)
example (c k z : ℝ) : HasDerivAt (probeShape c k) (c * (k * Real.cos (k * z))) z := by
  have h := (((hasDerivAt_id z).const_mul k).sin).const_mul c
  convert h using 1 <;> trace_state
#check hasDerivAt_id'
#check HasDerivAt.congr_of_eventuallyEq
#check HasDerivAt.congr
end
