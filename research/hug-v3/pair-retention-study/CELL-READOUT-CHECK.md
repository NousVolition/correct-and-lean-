# Controlled follow-up of the local accounting discrepancy

The original 40-cubed run failed the predeclared local-account tolerance. Its largest residual jump occurs in the saved interval 1.274–1.276, where A crosses a trilinear interpolation-cell face. That observation suggests a readout quadrature issue; it is not by itself a causal conclusion.

Repeat only the 40-cubed continuation from the same exact entry checkpoint, keeping every native fluid step unchanged. Integrate the local accounting terms along the solver's quadratic Heun dense output. Split the integral at the actual interpolation-cell crossings and use four-point Gaussian quadrature in each piece. Within one cell, the derivative of the trilinear readout along this path has degree at most seven. Do not adjust any tolerance, fluid equation, time step, initial state, event or output time.

Acceptance: all 17 native exit arrays and all 51 saved pair positions must be byte-identical to the original continuation; the same 1e-6 local budget criterion must be used. Preserve the original failed receipt. If the discrepancy disappears under this sole accounting change, classify that original discrepancy as a readout-integration artifact for this controlled repeat, not as physical loss. No continuum convergence or complete private-inventory claim follows.
