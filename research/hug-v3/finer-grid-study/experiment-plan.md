# Finer fluid grids through prime tick 41

Declared before running or interpreting the new refinements, 11 November 2026.

Question: do the finite-window gaps for the same 25 material A/B pairs settle when the actual fluid grid is refined beyond 32³? Prime tick 41 is model time 1.2; all integrations start at time zero. Gap comparisons cover all 51 common times from tick 37 to tick 41 (1.1–1.2), including the endpoint separately.

Run matrix: 40³ at dt=0.0005, 48³ at dt=0.0005, and 48³ at dt=0.00025. Compare spatial changes 24→32 (historical), 32→40, and 40→48 at the identical dt=0.0005. The final halving of dt checks time sensitivity on the finest grid. This is a finite extension; a remaining failure is a result, not permission to keep refining until a pass appears.

Keep the threshold-0.015 breathing-on, 801-marker experiment, the initial Fourier polynomial, event schedule, physical parameters, 384 material quadrature points and original solver equations. The added breathing drive belongs to this particular experiment; it does not redefine the author's intended unforced system. Initialize from the same saved time-zero state, never an evolved coarser solution. Reuse the saved material labels and their verified inverse/forward map. No re-selection of particles may enter the primary same-pair conclusion.

Reuse the previously verified runner read-only. A wrapper changes only the output directory and adds passive progress reporting around its unchanged step method. Retain its documented rounding of Fourier mode labels for refined grids. Preserve all original inputs and prior results byte-for-byte, verifying their recorded hashes before and after the extension. Recalculate event writes from each evolving solution and report any payload changes.

Acceptance criteria are unchanged: maximum absolute same-pair gap difference ≤0.001 cube lengths, maximum over time/window of the median absolute same-pair difference ≤0.0005, and decreasing successive spatial differences. Report values for both forward windows, 0.375 and 0.75, not only aggregate medians. Also report each pair, final-time differences, initial mismatch, gap growth, closest-arclength changes and boundary minima. A stable distance does not establish stable minimizer identity or a closed path.

Use the earlier primary readout (Fourier interpolation grid192, RK4 arclength step 1/1024) and control (grid256, step 1/2048) for every new run at all 51 times. Target maximum tracing sensitivity ≤0.00005. Check direct-Fourier endpoint and worst-discrepancy cases if affordable; any unresolved readout sensitivity must qualify the gap conclusion. If the declared control fails, report that failure before considering any further readout change.

Check full history, finite states, source seals, fixed labels, matched initial conditions, unchanged event times, divergence/context mass residuals (1e-10), energy accounting, determinant error and positive temperature. Compare final velocity/vorticity fields and use the prior 1%/5% relative L2 targets as separate diagnostics; these do not substitute for pair-gap agreement. Keep scalar spectra complete when making field comparisons.

Deliver saved arrays, per-pair tables, a concise report and a quantitative diagram. The new measurements remain local unless separately published. Existing Lean proofs and their historical receipts remain unchanged: they checked the nested-window rule and earlier recorded decimals, not this fluid simulation, convergence, closure or reconnection.

AI-generated; dictated and directed by NousVolition.

## Meter addition requested while the integrations were running

The user asked to use helpful newer meter ticks. Preserve the running integrations and add readouts from their saved records: the 13 original prime labels 2–41, with both sides of writes at 11/23/41; and direct-Fourier local vorticity/rotation/strain at A and B at the 51 saved late times. Intermediate samples remain labelled by model time, not invented prime ticks. Join these measurements to the same-pair gaps and compare their grid sensitivity. This is diagnostic context, not a change to the predeclared gap acceptance test or a causal attribution.

Fresh PR14 inspection found the same head 877b2b7b. Its meter extends through labels59/157 in a separate 401-marker energy-history experiment; those records are not input to the present 801-marker refinement. The older fixed-potential Yang–Mills residual is identically zero by construction and cannot diagnose these grid changes. Local slope-at-A and carried-vorticity records in the prime-tick chat likewise retain their own run and tangent-map scope; do not transfer their numbers to finer grids. No new integrations beyond tick41 are declared by this readout addition.
