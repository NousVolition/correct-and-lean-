"""Verify the checked-in replay receipt and its retained output files."""
from pathlib import Path
import csv
import hashlib
import json

HERE = Path(__file__).resolve().parent
EVIDENCE = HERE / 'evidence/linux-2026-11-12'

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def read(path):
    return json.loads(path.read_text(encoding='utf-8'))

def main():
    manifest = read(HERE / 'EVIDENCE-MANIFEST.json')
    for name, expected in manifest['files'].items():
        path = HERE / name
        assert path.is_file() and digest(path) == expected, name
    protocol = read(EVIDENCE / 'PROTOCOL.json')
    done = read(EVIDENCE / 'RUN-COMPLETE.json')
    results = read(EVIDENCE / 'comparison/RESULTS.json')
    assert protocol['runner_sha256'] == digest(HERE / 'replay.py')
    assert protocol['source_manifest_sha256'] == digest(HERE.parent / 'SOURCE-MANIFEST.json')
    assert results['protocol_sha256'] == digest(EVIDENCE / 'PROTOCOL.json')
    assert results['run_receipt_sha256'] == digest(EVIDENCE / 'RUN-COMPLETE.json')
    retained = 0
    for name, expected in done['output_hashes'].items():
        path = EVIDENCE / name
        if path.is_file():
            assert digest(path) == expected, name
            retained += 1
        else:
            assert name.endswith(('-final.npz', '/progress.json')), name
    assert retained == 9
    assert done['full_interval'] and done['arms'] == 7 and done['arm_steps'] == 640
    assert results['status'] == 'PASS' and all(results['acceptance'].values())
    for name, count in [('complex-mode-comparisons.csv', 164),
                        ('history-norm-comparisons.csv', 364),
                        ('fresh-controls.csv', 123),
                        ('endpoint-array-differences.csv', 119)]:
        with (EVIDENCE / 'comparison' / name).open(encoding='utf-8') as stream:
            rows = list(csv.DictReader(stream))
        assert len(rows) == count, name
        assert all(row.get('within_tolerance', 'True') == 'True' for row in rows), name
    print(f"PASS: {len(manifest['files'])} sealed replay evidence files; "
          f"{retained} retained run outputs; complete recorded comparisons.")

if __name__ == '__main__':
    main()
