from pathlib import Path
import datetime,hashlib,json,shutil,zipfile
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'outputs/Same particle history'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
formal=json.loads((OUT/'Formal core verification.json').read_text())
assert formal['status']=='PASS'
assert sha(OUT/'lean/HistoryMatchCore.lean')==formal['source_sha256']
assert sha(OUT/'lean/HistoryMatchCore.olean')==formal['object_sha256']
assert sha(OUT/'lean/SIMSLatentReadout.lean')==formal['base_theorem_source_sha256']
assert sha(OUT/'lean/SIMSLatentReadout.olean')==formal['base_theorem_object_sha256']
for name in ['check_history_example.py','check_history_core.py','plot_history_example.py','package_history_example.py']:
    (OUT/'scripts').mkdir(exist_ok=True)
    shutil.copy2(ROOT/'work'/name,OUT/'scripts'/name)
verification=dict(
    result='Analytical existence construction; not an end-to-end formal fluid witness',
    formal_core_status=formal['status'],formal_core_statements=len(formal['axiom_reports']),
    formal_core_scope=formal['scope'],numerical_status='Illustration checked at two resolutions; not interval-certified',
    fully_formalized_fluid_witness=False,exact_parameter_decimal_enclosure=False,
    fresh_dependency_install_tested=False,
    created_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
    preservation='All new work is in this output folder and its dedicated work scripts. Original simulation and preceding proof packages were read only.')
(OUT/'Verification.json').write_text(json.dumps(verification,indent=2)+'\n',encoding='utf-8')
files=sorted(p for p in OUT.rglob('*') if p.is_file() and p.suffix!='.olean' and p.name!='Manifest.json')
manifest={str(p.relative_to(OUT)).replace('\\','/'):sha(p) for p in files}
(OUT/'Manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
archive=ROOT/'outputs/Same-particle-history.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
    for p in files+[OUT/'Manifest.json']:
        z.write(p,'Same particle history/'+str(p.relative_to(OUT)).replace('\\','/'))
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
    for relative,digest in manifest.items():
        assert hashlib.sha256(z.read('Same particle history/'+relative)).hexdigest()==digest
print(json.dumps(dict(archive=str(archive),bytes=archive.stat().st_size,files=len(files)+1,verification=verification),indent=2))
