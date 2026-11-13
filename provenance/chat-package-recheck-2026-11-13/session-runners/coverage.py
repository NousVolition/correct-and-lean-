"""Map every collected Lean source to fresh evidence or its explicit role."""
import hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
SRC=HERE.parent/'recent-research-publication-20261112/repository/research/chat-research-update-2026-11-12'
def read(p):return json.loads(p.read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
inputs=read(HERE/'private-generic/all-published-lean-inputs.json')['files'];mapped={}
for d in (HERE/'private-generic').iterdir():
    if not d.is_dir():continue
    r=read(d/'record.json');assert r['status']=='PASS'
    for module,paths in r['origins'].items():
        for p in paths:mapped[p]={'kind':'current module, fresh build and configured Comparator replay','status':'PASS','evidence':'generic/'+d.name+'/record.json','module_sha256':r['source_hashes'][module]}
for d in (HERE/'private-vortex').iterdir():
    if not d.is_dir():continue
    r=read(d/'record.json');assert r['status']=='PASS'
    package=r['package'];freeze=read(SRC/package/'reference-freeze.json')
    for name,h in freeze['files'].items():
        if name.endswith('.lean'):
            mapped[package+'/'+name]={'kind':'trusted original Challenge' if name.endswith('Challenge.lean') else 'current module in original frozen check','status':'REFERENCE' if name.endswith('Challenge.lean') else 'PASS','evidence':'vortex/'+d.name+'/record.json','module_sha256':h}
for r in read(HERE/'private-archived/results.json'):
    if r['role']=='archived original draft':mapped[r['source']]={'kind':'archived original, fresh Lean-only compilation','status':r['status'],'evidence':'archived/results.json','module_sha256':r['source_sha256']}
for d in (HERE/'private-supplemental').iterdir():
    if not d.is_dir():continue
    r=read(d/'record.json');mapped[r['source']]={'kind':r['role'],'status':r['status'],'evidence':'supplemental/'+d.name+'/record.json','module_sha256':r['source_sha256']}
for name,h in inputs.items():
    if name not in mapped:
        candidates=[p for p,v in mapped.items() if v['status']=='PASS' and v['module_sha256']==h]
        assert candidates,('Uncovered source',name)
        mapped[name]={'kind':'byte-identical retained proof-evidence copy; fresh equivalent module checked','status':'PASS_BY_IDENTITY','evidence':mapped[candidates[0]]['evidence'],'same_as':candidates[0],'module_sha256':h}
    assert mapped[name]['module_sha256']==h and sha(SRC/name)==h,name
assert set(mapped)==set(inputs)
record={'files':mapped,'count':len(mapped),'note':'Challenge modules are trusted specifications and may intentionally contain sorry. Archived/diagnostic failures are not accepted proofs. Configured declaration lists are recorded separately; source-file counts are not theorem counts.'}
(HERE/'coverage.json').write_text(json.dumps(record,indent=2)+'\n')
from collections import Counter
print(json.dumps(dict(Counter(x['status'] for x in mapped.values())),indent=2))
