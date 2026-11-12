import Mathlib.Analysis.SpecialFunctions.ExpDeriv

namespace ViscousTimeReversal

noncomputable def reverseTime (T : ℝ) (f : ℝ → ℝ) (t : ℝ) : ℝ := f (T - t)

-- For a Laplacian eigenmode with eigenvalue -q, q is the squared wave number.
noncomputable def forwardFactor (ν q t : ℝ) : ℝ := Real.exp (-(ν * q) * t)

noncomputable def backwardFactor (ν q t : ℝ) : ℝ := Real.exp ((ν * q) * t)

noncomputable def viscousRate (ν q a : ℝ) : ℝ := -(ν * q) * a

noncomputable def eulerIncrement (h rate : ℝ) : ℝ := h * rate

end ViscousTimeReversal
