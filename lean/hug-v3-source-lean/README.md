# Hug v3 concrete source transcription

**Full existence and uniqueness are not proved.** Start with `PROOF_STATUS.md` for the precise result, correspondence limitations and remaining work.

The proposed full system is in `V3SourceSystem.lean`. It references concrete definitions for the complete coupled main rates and memory writes. `FullExistenceUniqueness` is the requested but unproved proposition. No segment-solvability or segment-uniqueness assumptions have been inserted into that proposition to make it pass.

`V3SourceProofs.lean` contains nine completed component proofs. Comparator's exact scope is recorded in `comparator.json`; the fresh Linux evidence is under `evidence-linux`. It does not certify the full existence-and-uniqueness proposition.

The selected source is copied byte-for-byte under `sources`, with its source seal. `source-map.json` links 39 original function locations to the proposed Lean definitions and labels the correspondence as unproved. `geometry-export.json` identifies the approved constructor export. The same student and idea remain metadata, with no new empirical actor mapping.

The source-defined main fixture has a 16³ grid, 384 material points, 24 directional records per point, four structural slots, six actors and the full state dictionary. These are the chosen source's dimensions; no reduction to two meaning states is used. Arithmetic in the mathematical model is real arithmetic; floating-point program equivalence is a separate obligation.

The pinned toolchain and dependencies are in `lean-toolchain`, `lakefile.toml` and `lake-manifest.json`. Use `lake build V3SourceProofs` for the package. `run-linux-check.sh` reproduces the recorded check in this workstation's installed verification environment and requires a fresh destination directory; its helper paths are environment-specific.

All earlier packages and all 21 original sealed source files remain unchanged. The preserved invalid first reference is a pre-proof syntax history, not an alternate passing proof. The valid reference revision and all compared inputs are identified by hashes.
