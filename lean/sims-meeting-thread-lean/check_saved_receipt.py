"""Check that the distributed SIMS receipt covers the distributed proof inputs."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys

PACKAGE = Path(__file__).resolve().parent
EVIDENCE = PACKAGE / "evidence-linux"
REPORT = "verification-report.json"
ARTIFACT_FILES = {"axioms.json", "comparator.exit", "comparator.log",
                  "lake-build.exit", "lake-build.log", REPORT}


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def check():
    source = json.loads((EVIDENCE / "source.json").read_bytes())
    if digest(PACKAGE / "verification-inputs.json") != source["verification_inputs_sha256"]:
        raise ValueError("The saved CI receipt covers different proof inputs.")
    if set(source["files_sha256"]) != ARTIFACT_FILES:
        raise ValueError("The CI receipt must identify all six artifact files.")
    for name, expected in source["files_sha256"].items():
        path = PACKAGE / REPORT if name == REPORT else EVIDENCE / name
        if digest(path) != expected:
            raise ValueError(f"{name} differs from the saved CI artifact.")
    report = json.loads((PACKAGE / REPORT).read_bytes())
    checks = ("comparator", "lean_kernel", "nanoda", "lean_build")
    if any(report[name] != "PASS" for name in checks):
        raise ValueError("The recorded run did not pass all four checks.")

    # The repository checker verifies the actual bytes of the inputs, the
    # solution import closure, and the recorded outcomes against the logs.
    script = PACKAGE.parents[1] / "scripts/lean_package_report.py"
    subprocess.run([sys.executable, str(script), "check", str(PACKAGE)], check=True)
    config = json.loads((PACKAGE / "comparator.json").read_bytes())
    axioms = json.loads((EVIDENCE / "axioms.json").read_bytes())
    if len(axioms) != source["target_count"] or set(axioms) != set(config["theorem_names"]):
        raise ValueError("The CI axiom lists do not cover precisely the configured targets.")
    allowed = set(config["permitted_axioms"])
    if any(not isinstance(items, list) or not set(items) <= allowed for items in axioms.values()):
        raise ValueError("A saved axiom list is invalid for this package.")
    print(f"Verified {len(axioms)} target records from {source['run']}")


if __name__ == "__main__":
    check()
