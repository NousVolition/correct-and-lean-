# Development and reference history

The 20 challenge statements were frozen before the solution proofs were written. Their file has not changed. All six original source modules, the saved delay definitions, dependency manifest and toolchain file remain byte-identical to the baseline copies.

Reference revision 1 contained an audit-only matrix-notation error in the definition of `Orthogonal`: a type ascription did not make Lean select matrix multiplication. Revision 2 uses `Matrix.of` to specify that same intended matrix product. The old freeze and old audit definition are retained. No source equation or theorem statement was weakened. Revision 2 was frozen before the proof-body builds proceeded.

Proof development needed explicit function extensionality, a staged simplification of the rotation comparison, matrix-entry normalization, and the derivative addition/multiplication imports. The memory-write proof needed the installed Lean version's `Option.bind_eq_bind` followed by `Option.bind_some`; an attempted `Option.some_bind` name did not exist. The failed logs are retained. After the non-progressing bind attempts, the actual library declarations were inspected rather than continuing guessed rewrites.

The first attempt to inspect those library declarations was blocked when automatic approval review reached a usage limit. After the user asked to continue, the same authorized read succeeded. This execution interruption did not establish a mathematical result. The final development build is `dev-verified-bind-lemma.log`; it passed all 20 targets and reported two harmless unused-simplification-argument warnings.

The fresh verification uses a new check directory without precompiled solution objects, pinned clean dependencies, non-root Landrun isolation, Comparator and nanoda. Its logs and exit codes determine the final result. No additional test reruns are needed after a successful fresh check unless an input changes or a concrete unresolved issue is found.
