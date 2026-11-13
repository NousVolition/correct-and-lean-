# Which loop makes the melody return?

The étude lets us hear a zero and a nonzero reading in turn. In the proof, both requirements refer to **one complete loop on the same vortex at the same instant**. The earlier theorem guarantees an inward offset but does not select the offset drawn in the picture. These checks hold the time and the construction fixed and vary the loop’s position. [Earlier two-loop proof](../as-vortex-rescaling-lean/RescaleForcing.lean) · [Meaning of the loop integrals](EdgeControlStatements.lean)

## Move the loop across the edge

Take the selected periodic vortex at any positive viscosity and a sufficiently late time before \(t=1\). Write \(d=0\) for its cutoff edge in the original offset coordinates. Positive \(d\) moves the loop inward by a physical distance \((\sqrt{\nu}/\ell)d\) in the final unit box. [OpenAI’s pinned periodic construction](https://github.com/openai/NavierStokesAndEuler/blob/f9e8bc5b38b6e212696e8a30e3e91517af887bbd/NavierStokes/PeriodicPaperTheorem.lean#L92-L103)

| Loop placement | What the equations give |
|---|---|
| Just outside, for example \(d=-1/32\) | Both transverse integrals are exactly zero. There is also an independent proof directly from the support of the velocity and the periodic copies. That proof works throughout the presingular evolution. |
| Exactly at the edge, \(d=0\) | Both transverse integrals are exactly zero throughout the late-time window. Smoothness lets the vanishing outside reach the boundary. |
| Strictly inside, in any strip of positive width \(b\) | For every tolerance \(\varepsilon>0\), there is a loop in that strip with \(0<|I_y|<\varepsilon\). The other orientation at the same inward offset reads \(I_x=-I_y\). |

For example, choose \(b=1/100\) of the box width and \(\varepsilon=10^{-6}\) in loop-integral units. Some loop less than that distance inside has a nonzero reading smaller than one millionth. Those two numbers specify the test. The result is an existence bound and gives no decimal value of \(d\) or of the reading. The witness may change with time, width and tolerance. [Same-time theorem for the actual periodic field](EdgeControlProofs.lean) · [Exterior control from support alone](EdgeControlExterior.lean) · [Lean check of the concrete test](examples/SpecificProbe.lean)

## Keep one loop fixed and advance the clock

The score first plays the A/S prediction and then the vortex prediction for the same late instant. There is also a genuine time comparison within the vortex itself. OpenAI uses the clock \(\ell^2(t-1)+1\) and extends the source velocity by zero before that clock reaches zero. Since \(\ell>1\), all the loop readings vanish on the nonempty early interval \(0<t<1-\ell^{-2}\). This follows by taking the actual time, advection and diffusion terms in a neighborhood where the periodized velocity vanishes. [Pinned clock and velocity](https://github.com/openai/NavierStokesAndEuler/blob/f9e8bc5b38b6e212696e8a30e3e91517af887bbd/NavierStokes/R3/ParabolicDefinitions.lean#L11-L19) · [Early-time proof](time-check/TemporalProofs.lean)

Now choose any sufficiently late time and one of its proved nonzero offsets. Keep that **one spatial loop** fixed and inspect it over the early interval. It was silent throughout that interval, and it is nonzero at the chosen later time. The loop can depend on which later time you select. This establishes an early silence followed by a later signal. A nonzero → zero → nonzero sequence on one named loop, its switching times and its amplitude remain open. [Exact quantifiers](time-check/TemporalStatements.lean) · [Fixed-loop proof](time-check/TemporalProofs.lean)

## Why there must be a nonzero reading

Let \(J(d)\) be the integral of the native cutoff heat potential along the transverse line and let \(Q(d)\) be its time derivative at the fixed time. The viscosity-one edge signal is \(G(d)=\partial_d[Q(d)-J''(d)]\). The previous corpus audit proves that \(J\) is positive immediately inside, and that \(|Q|\le M|J|\) on the strip for some finite \(M\). At the edge \(J(0)=J'(0)=0\). [Trace positivity and time bound](../as-signed-vortex-lean/TraceSolution.lean)

Suppose an entire inward interval were silent. Then \(G=0\) on it, so \(Q-J''\) would be constant. Its value at the edge is zero. This would give \(|J''|\le M|J|\) throughout the interval. Starting from \(J(0)=J'(0)=0\), Grönwall’s inequality forces \(J=0\) on that interval, contradicting the proved positivity. This works for every positive interval width. Continuity makes the nonzero readings arbitrarily faint near the edge. The transfer to the final box multiplies the signal by the positive factor \(\ell^2\nu\). [Native proof](EdgeControlNative.lean) · [Previous transfer proof](../as-vortex-rescaling-lean/RescaleLoops.lean)

For a signed A/S force along \(x\), its \(y\)-component is exactly zero, and periodic pressure contributes zero over a closed \(y\)-loop. Even a faint nonzero reading on that same loop rules out exact reproduction of this velocity. The equation and its signed response are imported from the previous audited packages. [Signed matching test](../as-vortex-rescaling-lean/RescaleForcing.lean)

## What further testing would answer

A quantitative test would fix the selected candidate, viscosity, compression, physical time and offset. It would evaluate the full loop integral there with an error interval that excludes zero. For a claim that the signal returns after falling silent, it would keep that offset fixed at three ordered times, establish exact silence at the middle time, and certify nonzero readings on either side. A reading rounded to zero can miss a genuine signal. An oblique force with two nonzero horizontal components also requires a different directional test. The pitches and playback times in the étude are compositional choices.

## Verification

Both isolated replays passed. Comparator matched six spatial statements and, in a separate configuration, two temporal statements. Lean’s default kernel and nanoda accepted both exports. Each standalone build exited successfully, and every named statement depends only on `propext`, `Classical.choice` and `Quot.sound`. The numerical-bound example received a separate Lean check and is excluded from the eight-target count. The signed A/S force, the three earlier proof packages and the pinned upstream sources passed their input integrity checks. [Spatial verification record](verification-report.json) · [Time verification record](time-check/verification-report.json) · [Spatial Comparator log](evidence/comparator.log) · [Time Comparator log](time-check/evidence/comparator.log) · [Concrete example output](examples/lean.log)
