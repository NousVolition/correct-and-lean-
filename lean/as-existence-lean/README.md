# Full A/S existence and uniqueness

**PASS: the full seven-state existence-and-uniqueness theorem is proved.**
The native Lean build, fresh Linux build, Comparator reference comparison,
permitted-axiom check, Lean kernel replay, and independent nanoda check all
passed. This is new evidence for the full theorem, beyond the earlier 30
local claims. No equation or final theorem assumption was changed.

The exact target is `SocialAS.Verified.full_existence_uniqueness`, proving the
previously recorded proposition `SocialAS.Open.FullExistenceUniqueness`.
The original `ASModel.lean`, `ASOpenClaims.lean`, and E1–E16 equation register
are unchanged. The `Open` namespace is preserved as part of that reference;
the new theorem supplies its existence-and-uniqueness proof.

The model still concerns **one agent and one idea: “Giving someone space to
speak can change what I understand.”** Smoke and Clay are that agent's inward
positions. Monoxide remains the adverse social interaction mechanism.

## The claim, in ordinary language

Fix an interval [a,b], an admissible starting state, the existing coefficient
domains, and inputs satisfying the previously recorded boundedness and
regularity assumptions. Then a continuous evolution of all seven coordinates
exists, satisfies the original integral equations, and is unique on [a,b].
The seven coordinates are A, S_Smoke, S_Clay, L_forward, L_reverse, z_Smoke,
and z_Clay. Any other integral solution with those same inputs and initial
state agrees at every time in that interval.

This holds for any finite interval with a≤b, including a=b. It is not restricted
to the 12-unit numerical fixture, zero initial conditions, constant exposure,
or continuous forcing. A and S remain signed. The existing integral solution
convention handles the allowed input switches; ordinary differentiability at
every switching instant is not required.

“Unique” here means unique under the specified mathematical inputs. It does
not mean that a person's experience or understanding is predetermined without
those inputs being known.

## Proof argument

1. **An integral-equation existence theorem.** For a vector field F whose
   composition with every continuous path is integrable, and which is uniformly
   Lipschitz in the state with constant K, consider the Picard map
   P(x)(t)=x_initial+∫_a^t F(s,x(s)) ds on the complete space of continuous
   paths on [a,b]. Its n-th iterate has Lipschitz bound
   (K(b−a))^n/n!. This tends to zero, so some iterate is a contraction. Its
   unique fixed point is also the unique fixed point of P. This proves
   existence and uniqueness on the entire specified interval. The proof is
   in `Volterra.lean`; the factorial estimate follows the argument in the
   pinned mathlib Picard–Lindelöf implementation and is proved again for the
   more general integral-path hypotheses needed here.

2. **Experience and adverse history.** The exact `RegularInputs` assumptions
   imply integrability: bounded functions continuous outside a finite set are
   measurable and integrable on the compact interval. A has a prescribed
   integrable drift. Each L equation is linear in L, with bounded clearing
   coefficient, so the integral theorem applies. Nonnegative initial L and
   nonnegative exposure/clearing ensure L never becomes negative. This is
   proved directly for integral solutions: if a path became negative, take its
   last preceding zero; the drift is nonnegative throughout the subsequent
   negative segment, contradicting the integral equation. No derivative at
   a switch is needed. Consequently L+L_* stays positive.

3. **Smoke–Clay influence.** With A and both L paths fixed by step 2, both
   suppression coefficients are continuous and lie in [0,1]. The exchange
   function w[g−chi max(g,0)] is Lipschitz in g with bound 2|w|. The two-coordinate
   S field therefore has the uniform bound
   K_S=4(|w_Smoke,Clay|+|w_Clay,Smoke|)+|lambda|.
   Its value along any continuous S path is integrable. The integral theorem
   gives the unique S pair on [a,b]. No positivity assumption is imposed on S.

4. **Meaning.** With L and S fixed, the distortion coefficients and interaction
   rates are continuous. Distortion lies in [0,1], while 0≤k_cd≤w_cd. The meaning
   equations are affine in the two z coordinates. If M_S and M_C bound the
   absolute clarification rates, a uniform Lipschitz bound is
   K_z=2(w_Smoke,Clay+w_Clay,Smoke)+M_S+M_C.
   Switched clarification coefficients remain integrable along continuous
   paths. The same theorem supplies the unique meaning pair. This step does
   not assume in advance that future z values stay in [0,1].

5. **Reassemble the original equation.** `FullAssembly.lean` proves that the
   seven constructed paths satisfy `IntegralSolution` for the original
   `evolution` definition. It also projects any competing full solution into
   the same stages. Scalar uniqueness fixes A and both L paths, S uniqueness
   fixes both influence coordinates, and z uniqueness fixes both meaning
   coordinates. Therefore the entire competing trajectory agrees with the
   constructed one. `ASExistenceSolution.lean` applies this argument to the
   original quantified target.

The stage order is a proof of the existing dependency structure. No equation
was replaced, no extra agent or idea was introduced, and no new premise was
added to the final target. In particular, bounded inputs with switches were
not replaced by an easier continuous-input assumption.

## Scope that remains outside this theorem

- A proof that both meaning coordinates remain in [0,1] for all time is still
  outstanding. The load nonnegativity argument is now proved and used in this
  construction, but the complete earlier `FullStateInvariance` proposition
  has not been discharged.
- `FullSuppressionComparison`, comparing complete trajectories with suppression
  removed, remains unproved.
- This theorem concerns the seven-state continuous evolution. The encounter
  probabilities and H updates in E6–E10 are retained in `ASModel.lean`, but a
  repeated-encounter stochastic process and its event ordering are not supplied
  by this existence theorem. Uniqueness of an ODE does not make random encounter
  outcomes unique.
- Numerical error guarantees and empirical validation of the social variables
  remain separate tasks. This theorem is not evidence that measured social
  experience follows the candidate equations.

## Reference and checking arrangement

`ASExistenceChallenge.lean` contains the exact target with the intentional
challenge placeholder. `ASExistenceSolution.lean` supplies the proof without
importing that challenge. All supporting solution files contain proofs without
`sorry`, `admit`, new axioms, or unsafe declarations. The final theorem's axiom
report permits only `propext`, `Classical.choice`, and `Quot.sound`.

`existence-reference-freeze.json` preserves the original model, open-target
definition, exact challenge, equation register, protocol, and Lean toolchain.
`verification-inputs.json` hashes every source and configuration supplied to
the independent verification run. This prevents a later result from being
mistaken for a check of different equations or assumptions.

The dependency pins are Lean 4.34.0-rc2, mathlib
85e3a25e006c35636f0e53b0e9296caca2685bc0, and Comparator
19e111e2141cf333c7daff0f64c5f24acc91dd2e. The existing Linux checking tools and
trusted dependency cache are reused. The verification directory starts without
any compiled A/S solution. Comparator runs as the nonprivileged `nsverify`
user under real Landrun isolation with systemd's AF_UNIX restriction and
nanoda enabled. The ordinary Linux build follows the protected comparison.

The preceding 30-claim package and its evidence remain preserved separately in
`as-lean`. The new Comparator target is the full existence-and-uniqueness theorem;
its transitive proof dependencies are checked as part of that target.

Run `lake build` for the pinned package's ordinary build.
`build-native.ps1` uses the tools already installed in this Windows workspace.
`run-linux-check.sh` reproduces this machine's full checking route and requires
a fresh, nonexistent destination directory. The checking result and exact
evidence hashes are recorded in `verification-report.json`.

| Evidence | Location |
| --- | --- |
| Exact final theorem and axiom report command | `ASExistenceSolution.lean` |
| Protected reference statement | `ASExistenceChallenge.lean` |
| Native theorem build | `full-theorem-build.log`, `full-theorem-build.exit` |
| Fresh-source and pinned dependency preflight | `evidence-linux/preflight.json` |
| Comparator and both kernel acceptances | `evidence-linux/comparator.log` |
| Ordinary Linux build | `evidence-linux/lake-build.log` |
| Source/dependency preservation | `evidence-linux/postflight.json` |
| Final result and artifact hashes | `verification-report.json`, `package-manifest.json` |

The solution build reports two style warnings about unused typeclass arguments
in general continuity helper lemmas. It reports no proof holes or errors.
The separate challenge's intentional placeholder is not imported by the solution.
