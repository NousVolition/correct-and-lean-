# What the residual-write example measures

The user identified this distinction: `residual_write.py` writes an externally supplied residual of **0 or 2** into one existing word, then compares the resulting write heat. With quantum 0.0001, the codes are **0 and 20000**. The latter has **five one-bits**. The changed word changes five target cells; the checksum can change other targets. The actual cost uses the weighted squared distance from each cell's prior state, not merely a count of ones.

The [saved table](hug-residual-write-at-zero.csv) separates word heat, checksum heat and the rest of the record. Total heat changes by **3.0784848723e−11**: approximately **2.0096341722e−11** from the word and **1.0688507001e−11** from the checksum. The rest is identical. Both checksums have 13 one-bits, but their cell positions and prior values need not agree, so an equal count need not mean equal heat.

This is an **encoding comparison**, not a numerical test of the field equation whose two residual values motivated the inputs. It is a separate historical tick-23/time-0.8 example. The script is preserved unchanged for inspection; its upstream sealed setup is not bundled here, and it was not rerun in this publication. [Read-only source review](source-review.json) records the script/table hashes and exact decimal comparison. It is outside the 56 heat-follow-up Lean targets.

In the threshold-1 follow-up, halving the step changes all three checksums while deposited heat differs by at most 0.00610%. That establishes sensitivity of exact record identity alongside close agreement of these measured heat totals in this test. It does not establish grid convergence, identify which payload words changed, or show that heat is insensitive to every numerical change.

Interpretation directed by NousVolition; explanatory text AI-generated. Existing source and historical results are retained.
