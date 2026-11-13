"""Verify the published files and every recorded solver function, without loading the solver."""
import hashlib
import json
from pathlib import Path

root = Path(__file__).resolve().parent
record = json.loads((root / "basin-solver-provenance.original.json").read_bytes())
current = json.loads((root / "basin-solver-provenance.json").read_bytes())
mapping = json.loads((root / "publication-map.json").read_bytes())["files"]
if {k:v for k,v in current.items() if k != "original_environment"} != record or set(mapping) != set(record["simulation_sources"]):
    raise ValueError("Publication and original source records disagree")
count = 0
for name, source in record["simulation_sources"].items():
    data = (root / name).read_bytes()
    if hashlib.sha256(data).hexdigest() != mapping[name]["published_sha256"]:
        raise ValueError(f"Published file digest differs for {name}")
    if source["file_sha256"] != mapping[name]["original_sha256"]:
        raise ValueError(f"Original receipt digest differs for {name}")
    if name != "startup.py" and source["file_sha256"] != mapping[name]["published_sha256"]:
        raise ValueError(f"Unexpected difference from original for {name}")
    lines = data.splitlines(keepends=True)
    for function, span in source["functions"].items():
        part = b"".join(lines[span["first_line"]-1:span["last_line"]])
        if hashlib.sha256(part).hexdigest() != span["raw_source_sha256"]:
            raise ValueError(f"Function digest differs for {name}::{function}")
        count += 1
print(f"{len(mapping)} published files and {count} original function spans verified.")
