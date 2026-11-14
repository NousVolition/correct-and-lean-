"""Run the record audit and fresh native Lean checks, preserving a portable receipt."""
import argparse
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
from check_records import check, lean_source, reject_corruptions
from inputs import HERE, canonical, digest, read

def verify(lean, work):
    rows, summaries = check()
    assert (HERE / "RecordedData.lean").read_bytes() == lean_source(rows)
    assert read(HERE / "results.json") == summaries
    refusals = reject_corruptions()
    version = subprocess.check_output([str(lean), "--version"], text=True, encoding="utf-8").strip()
    assert "version 4.34.0-rc2" in version
    modules = ("Evidence", "RecordedData", "Recorded")
    targets = []
    for module in ("Evidence", "Recorded"):
        source = (HERE / (module + ".lean")).read_text(encoding="utf-8")
        code = re.sub(r"/-.*?-/", "", source, flags=re.S)
        assert "/-" not in code and "-/" not in code, "Unsupported nested comment in the proof source scan."
        code = re.sub(r"--[^\n]*", "", code)
        assert not re.search(r"(?m)^\s*(?:axiom|unsafe|opaque)\s|\b(?:sorry|admit|native_decide|implemented_by)\b", code)
        namespace = "FixedTremble" + (".Recorded" if module == "Recorded" else "")
        targets += [namespace + "." + n for n in re.findall(r"(?m)^theorem (\w+)", source)]
    assert targets and len(set(targets)) == len(targets)
    filenames = [m + ".lean" for m in modules] + [
        "inputs.py", "protocol.json", "reports.json", "grades.json", "results.json",
        "check_records.py", "verify.py", "review.json", "SOURCES.md", "lakefile.toml", "lean-toolchain",
    ]
    sources = {name: digest((HERE / name).read_bytes()) for name in filenames}
    assert not work.exists(), "Use a fresh verification directory."
    work.mkdir(parents=True)
    for name in [m + ".lean" for m in modules] + ["lakefile.toml", "lean-toolchain"]:
        shutil.copyfile(HERE / name, work / name)
    audit = "\n".join(["import Evidence", "import Recorded", ""] + ["#print axioms " + t for t in targets]) + "\n"
    (work / "CheckAxioms.lean").write_text(audit, encoding="utf-8", newline="\n")
    env = dict(os.environ, LEAN_PATH=str(work), PATH=str(lean.parent) + os.pathsep + os.environ.get("PATH", ""))
    logs = {}
    for module in modules + ("CheckAxioms",):
        command = [str(lean), "-DwarningAsError=true"]
        if module != "CheckAxioms":
            command += ["-o", module + ".olean"]
        command += [module + ".lean"]
        result = subprocess.run(command, cwd=work, env=env, capture_output=True, text=True, encoding="utf-8", timeout=240)
        log = result.stdout + result.stderr
        (work / (module + ".log")).write_text(log, encoding="utf-8", newline="\n")
        assert result.returncode == 0, module + "\n" + log
        logs[module] = log
    axioms = {}
    for line in logs["CheckAxioms"].splitlines():
        match = re.fullmatch(r"'([^']+)' depends on axioms: \[(.*)\]", line.strip())
        if match:
            axioms[match[1]] = [x.strip() for x in match[2].split(",") if x.strip()]
        match = re.fullmatch(r"'([^']+)' does not depend on any axioms", line.strip())
        if match:
            axioms[match[1]] = []
    assert set(axioms) == set(targets), "Axiom reports do not cover every theorem."
    assert all(set(items) <= {"propext", "Quot.sound", "Classical.choice"} for items in axioms.values())
    lake = lean.with_name("lake.exe" if os.name == "nt" else "lake")
    result = subprocess.run([str(lake), "build"], cwd=work, env=env, capture_output=True, text=True, encoding="utf-8", timeout=240)
    (work / "lake-build.log").write_text(result.stdout + result.stderr, encoding="utf-8", newline="\n")
    assert result.returncode == 0, result.stdout + result.stderr
    assert all(digest((HERE / name).read_bytes()) == value for name, value in sources.items()), "A checked source changed during verification."
    receipt = {
        "status": "PASS", "version": version, "verified_at_utc": datetime.now(timezone.utc).isoformat(),
        "source_sha256": sources, "axioms": axioms, "target_count": len(targets),
        "records": {"sessions": 18, "turns": 144, "corruptions_rejected": refusals},
        "scope": "Recorded simulated reports and conditional observation theorems. The role generation, textual interpretation and witness truth are outside Lean.",
        "lake_build": "PASS", "lean_kernel": "PASS",
    }
    if os.environ.get("GITHUB_ACTIONS") == "true":
        receipt["execution_context"] = {
            "repository": os.environ["GITHUB_REPOSITORY"], "checkout_sha": os.environ["GITHUB_SHA"],
            "pull_request_head_sha": os.environ.get("PR_HEAD") or None, "event": os.environ["GITHUB_EVENT_NAME"],
            "run_id": int(os.environ["GITHUB_RUN_ID"]), "run_attempt": int(os.environ["GITHUB_RUN_ATTEMPT"]),
            "run_url": os.environ["GITHUB_SERVER_URL"] + "/" + os.environ["GITHUB_REPOSITORY"] + "/actions/runs/" + os.environ["GITHUB_RUN_ID"],
        }
    (work / "receipt.json").write_bytes(canonical(receipt))
    print("PASS", len(targets), "Lean targets; 18 sessions; 144 turns; eight altered records rejected.")
    if "execution_context" in receipt:
        print("BEGIN_FIXED_TREMBLE_RECEIPT")
        print(json.dumps(receipt, sort_keys=True))
        print("END_FIXED_TREMBLE_RECEIPT")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--lean", default=shutil.which("lean"))
    parser.add_argument("--work-dir", required=True)
    args = parser.parse_args()
    if not args.lean:
        parser.error("Provide the pinned Lean executable.")
    verify(Path(args.lean).resolve(), Path(args.work_dir).resolve())
