# Mathlib attribution

`FrozenODE.lean` includes a modified adaptation of the proof of
`IsPicardLindelof.exists_eq_forall_mem_Icc_hasDerivWithinAt` from
[Mathlib/Analysis/ODE/ExistUnique.lean at the pinned revision](https://github.com/leanprover-community/mathlib4/blob/85e3a25e006c35636f0e53b0e9296caca2685bc0/Mathlib/Analysis/ODE/ExistUnique.lean).
The adaptation retains the continuity and closed-ball conclusions of the same
Picard construction and adds the candidate-tube and minimum lemmas.

Copyright (c) 2026 Winston Yin. All rights reserved.
Authors: Winston Yin.

`FrozenODE.lean` is distributed under the Apache License, Version 2.0; the full
license is retained in [LICENSE-MATHLIB](LICENSE-MATHLIB). This third-party
license exception takes precedence over the repository's general notice for
that file. Other original package material remains under the repository notice.
Mathlib and its dependencies retain their respective licenses. No LeanCert
source or Arb-generated theorem is included in the published proof package.
