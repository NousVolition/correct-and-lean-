import hashlib
import io
import json
import sys
import tempfile
import unittest
import zipfile
import zlib
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import check_public_paths as privacy
import lean_package_report as audit


class PackageChecks(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        self.pkg = Path(temp.name)
        self.cfg = {"solution_module": "Solution", "challenge_module": "Challenge", "theorem_names": ["T"],
                    "enable_nanoda": True, "permitted_axioms": sorted(audit.ALLOWED)}
        self.write("comparator.json", json.dumps(self.cfg))
        self.write("lakefile.toml", 'name="example"\n[[lean_lib]]\nname="Defs"\nsrcDir="src"\n')
        self.write("Solution.lean", "module\npublic import Defs.Core\nimport Mathlib.Tactic\n")
        self.write("src/Defs/Core.lean", "/- outer /- import FalseName -/ still inside -/\nimport Leaf\n")
        self.write("Leaf.lean", "def value := 5\n")
        self.write("Challenge.lean", "theorem T : True := by sorry\n")

    def write(self, name, value):
        dest = self.pkg / name
        dest.parent.mkdir(exist_ok=True, parents=True)
        dest.write_text(value, encoding="utf8")
        return dest

    def test_nested_local_imports_and_reference(self):
        self.assertEqual(set(audit.solution_closure(self.pkg, self.cfg)), {"Solution", "Defs.Core", "Leaf"})

    def test_forbidden_tokens_at_depth_and_in_comments(self):
        for token in ("sorry", "axiom", "native_decide", "sorryAx"):
            with self.subTest(token=token):
                self.write("Leaf.lean", f"-- {token}\n")
                with self.assertRaisesRegex(ValueError, f"forbidden token {token}"):
                    audit.solution_closure(self.pkg, self.cfg)

    def test_marker_text_in_longer_identifier_is_allowed(self):
        self.write("Leaf.lean", "theorem axiomatic : True := True.intro\n")
        audit.solution_closure(self.pkg, self.cfg)

    def test_challenge_dependency_is_rejected(self):
        self.write("Leaf.lean", "import Challenge\n")
        with self.assertRaisesRegex(ValueError, "challenge imported"):
            audit.solution_closure(self.pkg, self.cfg)

    def test_unknown_dependency_is_rejected(self):
        self.write("Leaf.lean", "private meta import Absent\n")
        with self.assertRaisesRegex(ValueError, "unresolved local import"):
            audit.solution_closure(self.pkg, self.cfg)

    def test_malformed_import_fails_closed(self):
        self.write("Leaf.lean", "import «escaped header»\n")
        with self.assertRaisesRegex(ValueError, "unsupported or missing"):
            audit.solution_closure(self.pkg, self.cfg)

    def test_input_digests(self):
        digest = hashlib.sha256((self.pkg / "Leaf.lean").read_bytes()).hexdigest()
        self.write("verification-inputs.json", json.dumps({"files": {"Leaf.lean": digest}}))
        audit.check_inputs(self.pkg)
        self.write("Leaf.lean", "def value := 6")
        with self.assertRaisesRegex(ValueError, "digest differs"):
            audit.check_inputs(self.pkg)

    def test_lean_reports_empty_and_allowed_axioms(self):
        self.cfg["theorem_names"] = ["T", "S"]
        self.write("comparator.json", json.dumps(self.cfg))
        output = self.pkg / "axioms.json"
        messages = ["'T' does not depend on any axioms", "'S' depends on axioms: [propext, Classical.choice]"]
        with patch.object(audit.subprocess, "run") as run:
            run.return_value.returncode = 0
            run.return_value.stdout = "\n".join(json.dumps({"data": msg}) for msg in messages)
            audit.audit_axioms(self.pkg, output)
            self.assertIn("#print axioms S", run.call_args.kwargs["input"])
        self.assertEqual(audit.read_json(output), {"T": [], "S": ["propext", "Classical.choice"]})

    def test_missing_extra_and_forbidden_axioms_fail(self):
        for results in [{}, {"T": [], "extra": []}, {"T": ["sorryAx"]}, {"T": ["privateOracle"]}]:
            with self.subTest(results=results), self.assertRaises(ValueError):
                audit.check_axiom_lists(["T"], results)

    def test_reports_require_matching_exports_and_real_exit_records(self):
        empty = audit.evidence_status(self.pkg, self.cfg)
        self.assertEqual(set(empty.values()), {"NOT_RUN"})
        self.write("comparator.log", "Exporting #[X] from Solution\nYour solution is okay!\n")
        self.write("comparator.exit", "0\n")
        self.assertEqual(audit.evidence_status(self.pkg, self.cfg)["comparator"], "UNKNOWN")
        self.write("comparator.log", "Exporting #[T] from Solution\nRunning nanoda kernel on solution\n"
                   "nanoda kernel rejected the solution\n")
        self.write("comparator.exit", "1\n")
        status = audit.evidence_status(self.pkg, self.cfg)
        self.assertEqual((status["comparator"], status["nanoda"], status["lean_kernel"]),
                         ("FAIL", "FAIL", "NOT_RUN"))

    def test_baseline_report_cannot_claim_success_without_evidence(self):
        report = dict.fromkeys(("comparator", "lean_kernel", "nanoda", "lean_build"), "NOT_RUN")
        report.update(scope="one target", open_items=[])
        self.write(audit.REPORT, json.dumps(report))
        self.assertEqual(audit.validate_report(self.pkg), report)
        report["comparator"] = "PASS"
        self.write(audit.REPORT, json.dumps(report))
        with self.assertRaisesRegex(ValueError, "saved evidence"):
            audit.validate_report(self.pkg)


class PublicPaths(unittest.TestCase):
    def test_home_syntax_and_urls(self):
        home = b"/" + b"home" + b"/scientist/file"
        win = b"D:" + b"\\Users" + b"\\someone\\file"
        wsl = b"/mnt/c/" + b"Users/" + b"someone/file"
        for data in (home, win, win.replace(b"\\", b"\\\\"), home.decode().encode("utf-16le"), wsl):
            self.assertTrue(privacy.contains_path(data))
        self.assertFalse(privacy.contains_path(b"https://api.github.com/users/github"))
        self.assertFalse(privacy.contains_path(b"$HOME/verification/bin/landrun"))

    def test_inspects_document_and_pdf_contents(self):
        data = b"/" + b"home" + b"/researcher/file"
        doc = io.BytesIO()
        with zipfile.ZipFile(doc, "w", zipfile.ZIP_DEFLATED) as zipped:
            zipped.writestr("word/document.xml", data)
        self.assertTrue(privacy.check_content(Path("note.docx"), doc.getvalue()))
        pdf = b"<< /Filter /FlateDecode >>\nstream\n" + zlib.compress(data) + b"\nendstream"
        self.assertTrue(privacy.check_content(Path("note.pdf"), pdf))


if __name__ == "__main__":
    unittest.main()
