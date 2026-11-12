# Pair 25: finite origin records

**77 checked statements, local Lean Lean (version 4.34.0-rc2, x86_64-w64-windows-gnu, commit 6a10ac8c22beadecabdbb0919c2b50214762f91d, Release).** See the separate [simulation report](../pair-origin-study/README.md) for measurement scope.

`OriginTracking.lean` supplies finite classification and account rules. `RecordedOrigins.lean` checks complete primary-window membership histories, wider-union observer histories and departing/arriving IDs, material-field changes, full shared memory bytes, and exact recorded decimal accounts. The primary observation convention is two moving radius-0.075 spheres; the wider union uses radius 0.10, and context accounts also cover radius 0.05. Neither the window geometry nor the fluid evolution is proved by Lean.

The source certificate matches 3924 primary histories (1050324 membership bits), 2772 wider observer histories (741972 membership bits), 2409 full payload comparisons, 459 window accounts, 918 point accounts, and 1152 material-field records. The material-field table is derived by the independent saved-state recount. All decimal literals use a common power-of-ten denominator; tolerance checks are exact integer checks of recorded decimal numbers.

The [receipt](receipt.json) lists all proof-input hashes, all targets and each target's axiom dependencies. No added axioms, `sorry`, or `native_decide` are used. Standard Lean axioms are reported rather than concealed.

Run `python check_certificate.py --self-test`, then `python verify_lean.py --lean <path-to-lean-4.34.0-rc2>`. NumPy is needed for saved-data matching. The simulation is not rerun by these checks. The six refusal tests alter independent evidence types and require rejection.

Proof-input fingerprint: `14ac08d8c253bb37d0dea90c27ba97c0c354e4a4fd5192444b9735e15555e9f1`.

These proofs do not establish microscopic ownership, all-physical-content retention, continuous-time residence, or continuum convergence. Published earlier receipts remain historical and unchanged.

AI-generated; dictated and directed by NousVolition.

The original local receipt is preserved byte-for-byte. The separate [GitHub proof receipt](../pair-origin-study/github-lean-receipt.json) identifies the published revision, exact input fingerprint, 77 targets and fresh Linux check. Comparator and nanoda are not used for this package.
