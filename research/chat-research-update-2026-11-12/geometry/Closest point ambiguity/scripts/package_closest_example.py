"""Package only verified final modules; retain failed checks as diagnostics."""
from pathlib import Path
import hashlib, json, shutil, zipfile

ROOT=Path('$USER_HOME/Documents/Codex/2026-11-10/lo')
OUT=ROOT/'outputs/Closest point ambiguity'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
diagnostics=OUT/'diagnostics'
diagnostics.mkdir(exist_ok=True)
for relative in ['lean/DerivativeProbe.lean','DerivativeProbe verification.json']:
    src=OUT/relative
    dest=diagnostics/src.name
    assert src.resolve().is_relative_to(OUT.resolve())
    assert dest.resolve().is_relative_to(OUT.resolve())
    if src.exists():
        assert not dest.exists()
        shutil.move(src,dest)
rows=[]
for name in ['ClosestPointGeometry','PeriodicNavierStokes','Tick41ClosestPointInstance']:
    row=json.loads((OUT/(name+' verification.json')).read_text())
    assert row['status']=='PASS'
    assert sha(OUT/'lean'/(name+'.lean'))==row['source_sha256']
    assert sha(OUT/'lean'/(name+'.olean'))==row['object_sha256']
    assert set(row['axioms'])<={'propext','Classical.choice','Quot.sound'}
    rows.append(row)
count=sum(len(r['axiom_reports']) for r in rows)
assert count==20
verification=dict(status='PASS',principal_axiom_reports=count,new_modules=rows,
    scope='Exact same-reading closed/open pair for unforced periodic Navier-Stokes; not the saved Hug run',
    shared_observation={'time':'6/5','closest_point':['0','0','0'],'arclength':'0','distance':'1/4'},
    parameters={'viscosity':'3/200','wavenumber':'4*pi','closed_slope':'0','open_slope':'sqrt(2)'},
    original_data_and_proofs='read only; no simulation rerun',
    fresh_installation_tested=False)
(OUT/'Verification.json').write_text(json.dumps(verification,indent=2)+'\n',encoding='utf-8')
scripts=OUT/'scripts'
scripts.mkdir(exist_ok=True)
for name in ['check_closest_example.py','package_closest_example.py']:
    shutil.copy2(ROOT/'work'/name,scripts/name)
old=ROOT/'outputs/Ambiguity theorem checks/lean'
shutil.copy2(old/'lean-toolchain',OUT/'lean/lean-toolchain')
lakefile='''name = "closest_point_ambiguity"
version = "0.1.0"
defaultTargets = ["Tick41ClosestPointInstance"]

[[require]]
name = "mathlib"
git = "https://github.com/leanprover-community/mathlib4.git"
rev = "85e3a25e006c35636f0e53b0e9296caca2685bc0"

[[lean_lib]]
name = "SIMSLatentReadout"

[[lean_lib]]
name = "ClosestPointGeometry"

[[lean_lib]]
name = "PeriodicNavierStokes"

[[lean_lib]]
name = "Tick41ClosestPointInstance"
'''
(OUT/'lean/lakefile.toml').write_text(lakefile,encoding='utf-8')
import tomllib
configuration=tomllib.loads(lakefile)
assert configuration['defaultTargets']==['Tick41ClosestPointInstance']
assert all((OUT/'lean'/(lib['name']+'.lean')).is_file() for lib in configuration['lean_lib'])
manifest=[]
for p in sorted(OUT.rglob('*')):
    if p.is_file() and p.name!='Manifest.json' and p.suffix not in ['.olean','.ilean','.c','.o']:
        manifest.append({'path':str(p.relative_to(OUT)).replace('\\','/'),'bytes':p.stat().st_size,'sha256':sha(p)})
(OUT/'Manifest.json').write_text(json.dumps({'files':manifest},indent=2)+'\n',encoding='utf-8')
archive=ROOT/'outputs/Closest-point-ambiguity.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
    for entry in manifest:
        z.write(OUT/entry['path'],entry['path'])
    z.write(OUT/'Manifest.json','Manifest.json')
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
    for entry in manifest:
        assert hashlib.sha256(z.read(entry['path'])).hexdigest()==entry['sha256']
print(json.dumps({'status':'PASS','new_modules':len(rows),'principal_axiom_reports':count,
                  'packaged_files':len(manifest)+1,'zip_bytes':archive.stat().st_size,
                  'archive':str(archive)},indent=2))
