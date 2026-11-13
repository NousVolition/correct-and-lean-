#!/usr/bin/env python3
"""Check published receipt integrity and its binding to unchanged Lean inputs.

This does NOT run Lean, Comparator or a numerical simulation. Those executions
are recorded in the dated logs. Run from any checkout containing this receipt.
"""
import hashlib,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def check(root=None):
    if root is None:
        root=next(p for p in HERE.parents if (p/'research/chat-research-update-2026-11-12').is_dir())
    inventory=json.loads((HERE/'receipt-manifest.json').read_text())
    for item in inventory['files']:
        p=HERE/item['path']
        assert p.is_file() and sha(p)==item['published_sha256'],item['path']
    inputs=json.loads((HERE/'inputs.json').read_text())
    for name,h in inputs['files'].items():
        p=root/'research/chat-research-update-2026-11-12'/name
        assert p.is_file() and sha(p)==h,name
    results=json.loads((HERE/'results.json').read_text())
    for item in results['current_checks']:
        assert item['status']=='PASS',item
        assert item['sources_unchanged'] is True,item
    originals=json.loads((HERE/'archived/results.json').read_text())
    expected={
        'energy/hug-lean-proofs/originals/FabricMemory.lean',
        'geometry/SIMS rational readout check/SIMSLatentReadout.lean',
    }
    actual={r['source'] for r in originals if r['exit']!=0}
    assert actual==expected,(actual,expected)
    assert all(r['source_unchanged'] for r in originals)
    assert json.loads((HERE/'supplemental/edge/record.json').read_text())['status']=='PASS'
    assert json.loads((HERE/'supplemental/geometry/record.json').read_text())['status']=='FAIL'
    print(f"PASS: {len(inventory['files'])} receipt files and {len(inputs['files'])} unchanged Lean inputs; two archived failures retained. No proof or simulation was rerun by this checker.")
if __name__=='__main__':check(Path(sys.argv[1]).resolve() if len(sys.argv)>1 else None)
