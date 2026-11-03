# Lean package index

These packages retain their individual model definitions, assumptions and histories. Read the verification report linked below before interpreting a successful build. The saved checks are historical evidence, not new runs performed during publication.

| Package | Recorded result | Evidence |
| --- | --- | --- |
| [as-lean](as-lean/) | PASS for 30 scoped claims; full coupled model remains unproved | [record](as-lean/verification-receipt.json) |
| [as-existence-lean](as-existence-lean/) | PASS | [record](as-existence-lean/verification-receipt.json) |
| [as-invariance-lean](as-invariance-lean/) | PASS | [record](as-invariance-lean/verification-receipt.json) |
| [hug-squeeze-lean](hug-squeeze-lean/) | PASS for 51 specified claims; full Hug system not certified | [record](hug-squeeze-lean/verification-report.json) |
| [hug-existence-lean](hug-existence-lean/) | PASS: exact frozen full coupled theorem | [record](hug-existence-lean/verification-report.json) |
| [hug-navier-bridge-lean](hug-navier-bridge-lean/) | PARTIAL: conditional compatibility verified; a full combined PDE/ODE system remains unspecified and unproved | [record](hug-navier-bridge-lean/verification-report.json) |
| [hug-navier-full-audit-lean](hug-navier-full-audit-lean/) | PARTIAL: corpus search and formal audit completed; full joint evolution remains unspecified and unproved | [record](hug-navier-full-audit-lean/verification-report.json) |
| [hug-navier-single-system-lean](hug-navier-single-system-lean/) | PARTIAL: whole source PDE formulation encoded and ten specific theorems verified; full existence and uniqueness are unproved. | [record](hug-navier-single-system-lean/verification-report.json) |
| [hug-navier-wellposedness-lean](hug-navier-wellposedness-lean/) | INCOMPLETE: requested full theorem not proved. | [record](hug-navier-wellposedness-lean/verification-report.json) |
| [hug-v3-proof-attempt](hug-v3-proof-attempt/) | INCOMPLETE_FULL_HUG_V3_EXISTENCE_UNIQUENESS_NOT_PROVED | [record](hug-v3-proof-attempt/verification-report.json) |
| [hug-v3-hybrid-lean](hug-v3-hybrid-lean/) | PARTIAL_CONDITIONAL_HYBRID_ASSEMBLY_VERIFIED_FULL_V3_THEOREM_UNPROVED | [record](hug-v3-hybrid-lean/verification-report.json) |
| [hug-v3-source-lean](hug-v3-source-lean/) | INCOMPLETE_FULL_HUG_V3_EXISTENCE_UNIQUENESS_NOT_PROVED | [record](hug-v3-source-lean/verification-report.json) |
| [hug-v3-transfer-lean](hug-v3-transfer-lean/) | PARTIAL: exact local transfer links verified; full finite-time transfer and full existence/uniqueness remain open. | [record](hug-v3-transfer-lean/verification-report.json) |
| [hug-v3-delay-lean](hug-v3-delay-lean/) | PASS: nine definition-level timing identities; DDE dynamics remain unproved | [record](hug-v3-delay-lean/verification-report.json) |
| [hug-v3-full-delay-proof](hug-v3-full-delay-proof/) | PARTIAL: full hybrid delayed existence and uniqueness remain UNPROVED | [record](hug-v3-full-delay-proof/verification-report.json) |
| [hug-v3-memory-rules-lean](hug-v3-memory-rules-lean/) | PARTIAL: existing memory and fixed-delay rules verified; variable timing, reconstructed episodes and anticipation cost remain unspecified | [record](hug-v3-memory-rules-lean/verification-report.json) |
| [hug-v3-clay-boundary-lean](hug-v3-clay-boundary-lean/) | PARTIAL: full existence and uniqueness remain unproved | [record](hug-v3-clay-boundary-lean/verification-report.json) |
| [hug-v3-yang-mills-audit-lean](hug-v3-yang-mills-audit-lean/) | PASS | [record](hug-v3-yang-mills-audit-lean/verification-report.json) |
| [hug-v3-gemini-review](hug-v3-gemini-review/) | PASS for 77 repaired supplied statements; full Hug v3 delayed hybrid existence/uniqueness remains unproved | [record](hug-v3-gemini-review/verification-report.json) |

Challenge files can contain intentional placeholders defining a target. An unfinished target is not a proof; use the package’s checked solution modules, permitted-axiom policy and verification report.
