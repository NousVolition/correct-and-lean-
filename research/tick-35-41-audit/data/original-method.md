# Jump timing audit: declared method

User request: per-pair/per-grid first half-jump crossing times; compare 40³/48³;
save Pair 6 every native step from 1.178 through 1.186; apply 0.001 outside
transition windows; quantify the pending finest-grid time-step control.

The actual 40³/48³ runs are the threshold-0.015 breathing-on experiment, distinct
from the preceding threshold-1 figure. The user has been informed. Preserve all
25 original material A/B labels, the 0.375 and 0.75 forward-arc windows, all coupled
physics and native writes. The distance is from the A-started finite vorticity
curve to the carried B point, not a two-curve minimum.

Transition windows are declared from the original 0.002-spaced data, independently
of cross-grid errors: for each pair and arc window, locate each run's largest
positive adjacent rise. Include that bracket and a fixed 0.002 shoulder on each
side, clipped to [1.1,1.2]. The primary 40/48 timing and outside-window comparison
uses the union of their two windows. Do not widen windows to pass 0.001. Record
clipping at the right endpoint: that is a truncated observed rise, not an assured
completed transition. Other spatial comparisons use the same construction for
their two runs; individual historical-grid timing uses its own window.

Half-height is half the observed distance change between the stated window's
endpoints. Save those endpoint distances, the half-height, the first sampled
crossing and its native-time bracket. Interpolated crossing is linear within that
bracket and does not create sub-step resolving power. For 40/48 also check one
common absolute half-height (average of their two half-heights) so that the role
of differing endpoint levels is visible. Preserve the full unfiltered comparison
beside the conditional outside-window comparison.

Dense replay uses the exact original solver/runtime and original time-zero
initial arrays. It saves every native step from 1.1 through 1.2, including Pair 6's
requested subwindow. Reproduce each available original Fourier/observer sample
and the final full state; retain checkpoint files to avoid repeating this cost.
No interpolation of the sparse saved fields may be called a native solver step.

Late readouts at 1.2 use the before-write velocity and observer positions, as in
the archive. Final full-state checks use the after-write state. The discrete
write leaves positions and velocity unchanged at that instant but changes the
state supplying subsequent rates.

The original 48³/.00025 full-history control is already running in another
workspace. Do not duplicate it. Use its completed output for full-history time
error. A separate local half/quarter-step replay from a newly saved coarse
checkpoint may resolve the local shape; label its inherited initial-state error
and do not call it a full-history refinement.

Compare the original full-history step sizes on the same saved0.002 schedule
when estimating their timing difference. Do not compare a new dense0.0005
crossing estimate against a sparse0.002 estimate and call the difference time
integration error. Save first-sample detection times separately from interpolated
crossing estimates throughout.

Primary curve tracing: cubic Fourier grid192, arclength RK4 step1/1024. Control:
grid256, step1/2048. Retain native readout target0.00005. Direct-Fourier spot checks
are additional checks, not replacements for the full tracing comparison.

The first completed dense readout exposed a failure of that target at 40-cubed,
Pair5, time1.1805. This point is checked using direct Fourier evaluation with
arclength steps1/4096 and1/8192. Apply the same supplementary rule to any failing
48-grid native point. Preserve the original primary/control tables and failures.
An explicitly named analysis-direct-checked output may use the finer direct
value only when the two direct traces meet the original tracing target. Save its
effect on timing separately; never move the frozen transition windows.

Successive local time refinements are compared on matching output schedules as
well as on each run's native schedule. Keep the resulting integration effect
separate from the additional shift caused by denser interpolation samples.

User's later fine-error hypothesis is checked in mode_leakage.py. This finite
instantaneous test adds the observed40-minus48 field difference only in modes
9..15 to an otherwise identical48-grid state, at amplitudes1,1/2,1/4. Velocity,
carried field, temperature and their joint perturbation are tested separately;
the entire original coupled RHS remains active. Observe broad modes1..2,1..4,
and1..8. Check both the size of the rate change and its signed projection along
the existing broad error. A route between scales is not proof that it drives
historical growth. Use the saved1.178 state and tick41's after-write state; this
does not test backward reconstruction.

Pair 6 ramp/jump evidence: every native distance and increment, largest increment
as a share of the whole requested-window rise, first10/50/90% crossing brackets,
and 10–90% duration. A discrete argmin switch does not by itself establish a
discontinuous distance. Report what is resolved at the tested steps.

Original inputs and prior outputs remain read-only. Results are numerical for
this finite model; no new Lean or continuum theorem is claimed.

Completion note: both 201-sample native replays and all six local controls are
complete. The 48³ full-history half-step control is also complete, but its saved
0.002 schedule does not include the newly exposed extrema at 1.169, 1.195 or
1.1955. Direct Fourier checks at those locations confirm the spatial findings;
they do not substitute for a full-history time-step check at those times.
The frozen outside-window target fails for Pair 3. See report/Report.md and
report/independent-verification.json for the final results and verification.
