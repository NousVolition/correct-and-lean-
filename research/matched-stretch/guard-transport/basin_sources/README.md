# Breathing basin solver sources

Run `python verify.py` here to check all five published file hashes and the exact function spans recorded for the original runs. The [publication map](publication-map.json) records both complete-file hashes for each solver. Four files match the originals byte for byte. In `startup.py` only line 13 changed. It now resolves the optional SciPy fallback relative to the source file. Every listed function retains its original bytes.

The `.runtime` folder is not part of the repository, so this line has no effect for a reader with SciPy installed. Without SciPy, an absent fallback directory cannot supply it. The historical launcher checks the **original** complete startup digest against the old receipt. The publication map documents the resulting difference for this portable copy.

The [original provenance record](basin-solver-provenance.original.json) is preserved byte for byte. The [annotated provenance](basin-solver-provenance.json) adds the dependency evidence. The four original launch commands set `PYTHONPATH` to the historical `.runtime` directory. Their environment's preflight printed SciPy **1.16.3** and NumPy **2.3.5**. Replaying the import search with that interpreter resolved SciPy in `.runtime` and NumPy in the interpreter's `Lib/site-packages`. The fallback in line 13 was unnecessary with that search path.

For the publication check we placed only the edited `startup.py` in a clean folder and imported it with isolated Python. Lines 2 and 5 import `Path` and `sys`. `ClosedDisk` loaded, `.runtime` was absent, and the fallback path was absent from `sys.path`. This clean-folder test used NumPy 2.3.5 and SciPy 1.18.1. It checks portability of the import independently of the historical versions.

In the original provenance, fields under `hug_v3_comparison_sources_only` and `display` describe separate comparisons and presentation code. The [withheld-field basin test](../README.md#withhold-a-basin-field) evaluates the two-dimensional trail export. The five sources here document the separate three-dimensional cylinder runs.
