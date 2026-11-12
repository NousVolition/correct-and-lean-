# Sources and reproduction scope

Run `python -B source/plot_figures.py` from this package with the versions in `requirements.txt` to regenerate both figures from the public tables. The publication preserves the original PNG and SVG files; the adapted plotter changes imports and paths only.

`original/` preserves the actual refinement, meter, write-decoding and comparison algorithms for inspection. They expect the original local workspace layout and full field archives. They are not a standalone solver replay bundle. The unchanged solver, tracing and model sources are in the [earlier study](../../fluid-grid-study/source/README.md). Full field arrays and time-zero archives remain local, with hashes retained in `../local-output-inventory.json` and the original input receipts.

The supported public check is `python -B verify.py` from the package root. It recounts the published measurements, endpoint and interval decisions, meter arithmetic and recorded checksums; it does not recompute velocity fields, fluid integrations, gradient measurements, material decoding or Lean proofs. `publication-manifest.json` identifies the checked public bytes, and `recount.json` records the targets and resulting counts.

AI-generated; dictated and directed by NousVolition.
