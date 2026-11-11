# Sources and reproduction scope

`plot_results.py` regenerates the PNG and SVG from the published tables with the versions in `requirements.txt`. Run it from a working copy with `python source/plot_results.py`. The published images preserve the original bytes.

`run_study.py`, `measure.py`, `compare_results.py` and `verify_comparisons.py` preserve the integration, trace and comparison algorithms for inspection. `model/` contains the sealed model implementations. They are archival code, not a complete standalone replay bundle: the original declarations, baseline state archive and full evolved arrays remain in the local archive. Stable `external-archives/` labels replace personal filesystem paths. No solver rerun using these public path substitutions is claimed.

The dependency-free `../verify.py` is the supported public recount. It checks the saved pair tables, numerical decisions, figure summary data and publication hashes. It does not execute these model sources, regenerate the fluid solution or run Lean.

AI-generated; dictated and directed by NousVolition.
