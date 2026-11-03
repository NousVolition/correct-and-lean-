# Correction register — proof revision 2

The model is `hug-structural-memory-v3`. Its 21 sealed source files, coefficients, initialization and event schedule are unchanged. The source attachment is retained in the testing packet. These corrections concern mathematical assertions about those equations; they are not edits to the equations or an implementation of new reader checks.

| ID | Original issue | Correction in proof.md | Nature of change |
| --- | --- | --- | --- |
| R01 | CRC/header parsing was treated as sufficient for the complete RHS to be defined. | Section 2 requires successful parsing, nonnegative decoded durations and present outcomes in [-1,1]. | Explicit theorem-domain restriction; no codec or RHS edit. |
| R02 | Inferred analog rest strain was called locally constant. | Lemma 1 retains estimated b = b; only bits, CRC status and records are constant. | Corrects a false proof claim; incorporates the user's later table. |
| R03 | A neighborhood restricting only b and F was called a compact full-state ball. | Lemma 1 constructs a full-state radius r = min(1,rho_b,rho_F)/4 and uses its closed radius-2r ball. | Corrected local proof neighborhood. |
| R04 | Full spectral gradient was assigned the dealiased bound 2 pi n/sqrt(3). | Section 3 uses pi sqrt(3) n on the full space and states the smaller bound only on the dealiased subspace. | Corrected derived estimate; no filtering added. |
| R05 | The transport estimate used an unproved L-infinity contraction of face interpolation. | Section 3 gives an L2-based product bound with the finite-grid coefficients shown. | Corrected analytical justification and bound. |
| R06 | The three-image Gaussian seam value used exponents 1,9,25 with unit multiplicity. | Section 4 uses 2 exp(-1/(8w²)) + exp(-9/(8w²)). | Corrected algebra; source kernel unchanged. |
| R07 | A quotient-difference numerator was identically zero. | Section 4 uses [f(x)-f(y)-r(y)(Z(x)-Z(y))]/Z(x) and bounds it. | Corrected algebra; source normalization unchanged. |
| R08 | The existence argument did not explicitly keep a local interval before the next jump. | Section 7 chooses h below the next checkpoint, h M < r and h L < 1, and gives the contraction construction. | Completed local-existence proof with its time scope. |
| R09 | Event notation reused the same pre-event state for every ending event and misstated shared-checkpoint order. | Section 8 composes writes sequentially on their current states, removes ended snapshots, then captures new starts. | Faithful statement of existing runner order. |
| R10 | Heun was presented as a map on the whole valid domain. | Section 9 specifies a sufficient stage domain and requires valid outputs for repeated steps. | Partial-map qualification; step formula unchanged. |
| R11 | Quantization was described by absolute value <= 32767. | Section 8 states the actual range -32768 through 32767 and retains all write checks. | Exact source-range statement, preserving the source's extra negative endpoint. |
| R12 | Completeness/uniqueness wording could be read as existence through 1.6 or a full Lean certificate. | Scope and Theorem 2 state conditional hybrid uniqueness, with continuation and successful writes explicit. | Claim boundary, not an assumed solution or a reduced equation. |

The state remains 193,122-dimensional. No fields, histories, social channels, heat, structural write work or event-start snapshots were discarded. All source input constants and the main [0,1.6] interval remain in force. No triangle equations or triangle test results are used as v3 evidence.

The complete corrected argument is in [proof.md](proof.md), with editable [LaTeX](proof.tex). The testing packet distinguishes newly executed checks from historical results, finite examples from universal arguments, and document rendering from mathematical correctness.
