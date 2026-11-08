#!/usr/bin/env python3
"""Check local Lean solution imports, published receipts and theorem axioms."""
import argparse
import hashlib
import json
import re
import subprocess
import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LEAN = ROOT / "lean"
REPORT = "verification-report.json"
ALLOWED = {"propext", "Quot.sound", "Classical.choice"}
SCHEMA = json.loads(Path(__file__).with_name("verification-report.schema.json").read_text(encoding="utf-8"))
STATUSES = set(SCHEMA["$defs"]["check"]["enum"])
FIELDS = set(SCHEMA["required"])
NAME = re.compile(r"[^\W\d][\w']*(?:\.[^\W\d][\w']*)*")
FORBIDDEN = re.compile(r"(?<![\w'])(?:sorryAx|sorry|axiom|native_decide)(?![\w'])")
AXIOMS = re.compile(r"'([^']+)' (?:depends on axioms:\s*\[([^\]]*)\]|does not depend on any axioms)\.?\Z", re.S)


def read_json(path):
    return json.loads(path.read_text(encoding="utf-8-sig"))


def packages():
    return sorted(p for p in LEAN.iterdir() if p.is_dir() and (p / "lakefile.toml").is_file())


def check_inputs(pkg):
    files = read_json(pkg / "verification-inputs.json")["files"]
    if not isinstance(files, dict) or not files:
        raise ValueError(f"{pkg}: empty verification input manifest")
    for name, digest in files.items():
        path = (pkg / name).resolve()
        if not path.is_relative_to(pkg.resolve()) or not path.is_file():
            raise ValueError(f"{pkg}/{name}: missing or non-local verification input")
        if hashlib.sha256(path.read_bytes()).hexdigest() != digest:
            raise ValueError(f"{pkg}/{name}: verification input digest differs")


def config(pkg):
    cfg = read_json(pkg / "comparator.json")
    names = cfg["theorem_names"]
    if not isinstance(names, list) or not names or len(names) != len(set(names)):
        raise ValueError(f"{pkg.name}: expected distinct, nonempty theorem_names")
    for name in [cfg["solution_module"], cfg["challenge_module"], *names]:
        if not isinstance(name, str) or not NAME.fullmatch(name):
            raise ValueError(f"{pkg.name}: invalid Lean name {name!r}")
    if set(cfg["permitted_axioms"]) != ALLOWED or cfg.get("enable_nanoda") is not True:
        raise ValueError(f"{pkg.name}: unexpected proof-checking policy")
    return cfg


def header_tokens(source):
    # The Lean import header precedes declarations. Skip nested comments, including
    # newlines inside them, before looking for import commands.
    i = 0
    while i < len(source):
        if source[i].isspace():
            i += 1
        elif source.startswith("--", i):
            end = source.find("\n", i + 2)
            i = end if end >= 0 else len(source)
        elif source.startswith("/-", i):
            depth = 1
            i += 2
            while depth:
                marker = re.search(r"/-|-/", source[i:])
                if marker is None:
                    raise ValueError("unterminated Lean header comment")
                depth += 1 if marker.group() == "/-" else -1
                i += marker.end()
        else:
            match = NAME.match(source, i)
            if not match:
                yield source[i]
                i += 1
            else:
                yield match.group()
                i = match.end()


def imports(source):
    tokens = iter(header_tokens(source))
    token = next(tokens, None)
    while token in {"module", "prelude", "public", "private", "meta", "import"}:
        if token == "import":
            name = next(tokens, None)
            if name == "all":
                name = next(tokens, None)
            if not name or not NAME.fullmatch(name):
                raise ValueError(f"unsupported or missing Lean import: {name!r}")
            yield name
        token = next(tokens, None)


def solution_closure(pkg, cfg):
    lake = tomllib.loads((pkg / "lakefile.toml").read_text(encoding="utf-8-sig"))
    default_dir = lake.get("srcDir", ".")
    lib_dirs = {lib["name"]: pkg / lib.get("srcDir", default_dir) for lib in lake.get("lean_lib", [])}
    external = {"Init", "Lean", "Std", "Lake", "Mathlib", "Batteries", "Aesop", "Qq", "Plausible", "ProofWidgets"}
    stack = [cfg["solution_module"]]
    visited = {}
    while stack:
        mod = stack.pop()
        if mod in visited:
            continue
        root = mod.split(".", 1)[0]
        path = (lib_dirs.get(root, pkg / default_dir) / (mod.replace(".", "/") + ".lean")).resolve()
        if not path.is_relative_to(pkg.resolve()):
            raise ValueError(f"{pkg.name}: local module escapes package: {mod}")
        if not path.is_file():
            if mod != cfg["solution_module"] and root not in lib_dirs and root in external:
                continue
            raise ValueError(f"{pkg.name}: unresolved local import: {mod}")
        if mod == cfg["challenge_module"]:
            raise ValueError(f"{pkg.name}: reference challenge imported by solution: {mod}")
        source = path.read_text(encoding="utf-8-sig")
        visited[mod] = path
        for line_number, line in enumerate(source.splitlines(), 1):
            hit = FORBIDDEN.search(line)
            if hit:
                raise ValueError(f"{pkg.name}/{path.relative_to(pkg.resolve())}:{line_number}: forbidden token {hit.group()} in solution closure")
        stack.extend(imports(source))
    return visited


def evidence_status(evidence, cfg):
    def log(name):
        p = evidence / name
        return p.read_text(encoding="utf-8-sig", errors="replace") if p.is_file() else ""

    def exit_status(name, transcript, successful):
        code = log(name).strip()
        if not code:
            return "UNKNOWN" if transcript else "NOT_RUN"
        if not re.fullmatch(r"-?\d+", code):
            raise ValueError(f"{evidence}/{name}: invalid exit code")
        return ("PASS" if successful else "UNKNOWN") if int(code) == 0 else "FAIL"

    comp = log("comparator.log")
    exports = [line for line in comp.splitlines() if line.startswith("Exporting #[")
               and line.endswith(" from " + cfg["solution_module"])]
    expected = set(cfg["theorem_names"])
    matched = any(expected.issubset(set(line.split("#[", 1)[1].split("]", 1)[0].split(", "))) for line in exports)
    def kernel(success, start, refusal):
        if not matched:
            return "UNKNOWN" if comp else "NOT_RUN"
        if refusal in comp:
            return "FAIL"
        if success in comp:
            return "PASS"
        return "UNKNOWN" if start in comp else "NOT_RUN"

    build = log("lake-build.log")
    return {
        "comparator": exit_status("comparator.exit", comp, matched and "Your solution is okay!" in comp),
        "lean_kernel": kernel("Lean default kernel accepts the solution", "Running Lean default kernel on solution",
                              "Lean default kernel rejects the solution"),
        "nanoda": kernel("nanoda kernel accepts the solution", "Running nanoda kernel on solution",
                         "nanoda kernel rejected the solution"),
        "lean_build": exit_status("lake-build.exit", build, "Build completed successfully" in build),
    }


def validate_report(pkg):
    report = read_json(pkg / REPORT)
    if not isinstance(report, dict) or report.keys() != FIELDS:
        raise ValueError(f"{pkg.name}: report must contain exactly {sorted(FIELDS)}")
    if not isinstance(report["scope"], str) or not report["scope"].strip():
        raise ValueError(f"{pkg.name}: empty or invalid report scope")
    items = report["open_items"]
    if not isinstance(items, list) or not all(isinstance(v, str) and v.strip() for v in items):
        raise ValueError(f"{pkg.name}: open_items must be an array of nonempty strings")
    for name, status in evidence_status(pkg / "evidence-linux", config(pkg)).items():
        if report[name] not in STATUSES or report[name] != status:
            raise ValueError(f"{pkg.name}: {name} report={report[name]!r}, saved evidence={status}")
    return report


def check_axiom_lists(names, seen):
    if not isinstance(seen, dict) or set(seen) != set(names):
        raise ValueError("missing or unexpected #print axioms results")
    for name, used in seen.items():
        if not isinstance(used, list) or not all(isinstance(a, str) and a in ALLOWED for a in used):
            raise ValueError(f"{name} has a forbidden or malformed axiom list: {used}")


def audit_axioms(pkg, output=None):
    pkg = pkg.resolve()
    cfg = config(pkg)
    solution_closure(pkg, cfg)
    names = cfg["theorem_names"]
    program = "\n".join([f"import {cfg['solution_module']}",
                         *(f"#print axioms {n}" for n in names)]) + "\n"
    check = subprocess.run(["lake", "env", "lean", "--json", "--stdin"], cwd=pkg,
                           input=program, text=True, encoding="utf-8", capture_output=True)
    if check.returncode:
        raise ValueError(f"{pkg.name}: Lean failed ({check.returncode})\n{check.stdout}\n{check.stderr}")
    seen = {}
    for line in check.stdout.splitlines():
        message = json.loads(line)
        if message.get("severity") == "error":
            raise ValueError(f"{pkg.name}: {message.get('data')}")
        match = AXIOMS.fullmatch(str(message.get("data", "")).strip())
        if not match:
            continue
        name, axioms = match.groups()
        if name not in names or name in seen:
            raise ValueError(f"{pkg.name}: unexpected or duplicate #print axioms result: {name}")
        used = [a.strip() for a in axioms.split(",")] if axioms else []
        seen[name] = used
    check_axiom_lists(names, seen)
    if output is not None:
        output.write_text(json.dumps(seen, indent=2) + "\n", encoding="utf-8")
    print(f"{pkg.name}: {len(seen)} axiom lists checked")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    gate = sub.add_parser("check", help="check every solution closure and saved report, or one package")
    gate.add_argument("package", type=Path, nargs="?")
    ax = sub.add_parser("axioms", help="query Lean for every configured solution theorem")
    ax.add_argument("package", type=Path)
    ax.add_argument("--output", type=Path)
    receipt = sub.add_parser("ci-report", help="write a separate live report from this run's evidence")
    receipt.add_argument("package", type=Path)
    receipt.add_argument("evidence", type=Path)
    args = parser.parse_args()
    if args.command == "check":
        entries = [args.package] if args.package else packages()
        if not entries:
            raise ValueError("no Lean packages found")
        for pkg in entries:
            cfg = config(pkg)
            check_inputs(pkg)
            modules = solution_closure(pkg, cfg)
            validate_report(pkg)
            print(f"{pkg.name}: {len(modules)} local solution modules, {len(cfg['theorem_names'])} targets")
    elif args.command == "axioms":
        audit_axioms(args.package, args.output)
    else:
        saved = validate_report(args.package)
        current = evidence_status(args.evidence, config(args.package))
        report = {**current, "scope": saved["scope"], "open_items": saved["open_items"]}
        (args.evidence / REPORT).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
        if any(status != "PASS" for status in current.values()):
            raise ValueError(f"{args.package.name}: incomplete CI verification: {current}")
        check_axiom_lists(config(args.package)["theorem_names"], read_json(args.evidence / "axioms.json"))


if __name__ == "__main__":
    try:
        main()
    except (OSError, KeyError, ValueError) as problem:
        sys.exit(str(problem))
