from pathlib import Path
import hashlib, json, shutil, tomllib, zipfile
ROOT=Path('$USER_HOME/Documents/Codex/2026-11-10/lo')
OUT=ROOT/'outputs/Swirl without return'
OLD=ROOT/'outputs/Closest point ambiguity'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
new=['WindingField','WindingFluid','WindingCurve','WindingInstance']
old=['SIMSLatentReadout','ClosestPointGeometry','PeriodicNavierStokes']
rows=[]
for name in new:
    row=json.loads((OUT/(name+' verification.json')).read_text())
    assert row['status']=='PASS'
    assert sha(OUT/'lean'/(name+'.lean'))==row['source_sha256']
    assert sha(OUT/'lean'/(name+'.olean'))==row['object_sha256']
    assert set(row['axioms'])<={'propext','Classical.choice','Quot.sound'}
    rows.append(row)
retained=[]
previous=json.loads((OLD/'PeriodicNavierStokes verification.json').read_text())
for name in old:
    hashes=({'source_sha256':previous['base_theorem_source_sha256'],
             'object_sha256':previous['base_theorem_object_sha256']} if name=='SIMSLatentReadout'
            else json.loads((OLD/(name+' verification.json')).read_text()))
    for suffix,key in [('.lean','source_sha256'),('.olean','object_sha256')]:
        assert sha(OUT/'lean'/(name+suffix))==hashes[key]
        assert sha(OLD/'lean'/(name+suffix))==hashes[key]
    retained.append({'module':name,'source_sha256':hashes['source_sha256'],'object_sha256':hashes['object_sha256'],
                     'status':'prior successful check retained; hashes match'})
count=sum(len(r['axiom_reports']) for r in rows)
assert count==34
report=dict(status='PASS',principal_axiom_reports=count,new_modules=rows,retained_dependencies=retained,
    scope='Same closest-point reading and full vorticity at A; open line has a positive spatial swirl bound and never returns',
    observation={'time':'6/5','closest_point':['0','0','0'],'arclength':'0','distance':'1/4',
                 'vorticity':['0','4*pi*exp(-(3/200)*(4*pi)^2*(6/5))','0']},
    spatial_swirl_strength_lower_bound_relative_to_A='1/sqrt(2)',
    closure_proof='Irrational winding: any return would force sqrt(2) times a positive integer to be an integer',
    global_parameter='strictly increasing bijection from R to R; derivative relation to actual curl verified',
    geometry_persists_at_all_finite_fluid_times=True,
    external_force='zero',pressure='-squared Euclidean velocity norm / 2',
    previous_stationary_material_histories_preserved=False,
    original_data_and_proofs='read only; no simulation rerun',fresh_installation_tested=False)
(OUT/'Verification.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
scripts=OUT/'scripts'
scripts.mkdir(exist_ok=True)
for name in ['check_winding_example.py','plot_winding_example.py','package_winding_example.py']:
    shutil.copy2(ROOT/'work'/name,scripts/name)
shutil.copy2(OLD/'lean/lean-toolchain',OUT/'lean/lean-toolchain')
lakefile='''name = "swirl_without_return"
version = "0.1.0"
defaultTargets = ["WindingInstance"]

[[require]]
name = "mathlib"
git = "https://github.com/leanprover-community/mathlib4.git"
rev = "85e3a25e006c35636f0e53b0e9296caca2685bc0"
'''
for name in old+new:
    lakefile+='\n[[lean_lib]]\nname = "'+name+'"\n'
(OUT/'lean/lakefile.toml').write_text(lakefile,encoding='utf-8')
config=tomllib.loads(lakefile)
assert all((OUT/'lean'/(v['name']+'.lean')).is_file() for v in config['lean_lib'])
manifest=[]
for p in sorted(OUT.rglob('*')):
    if p.is_file() and p.name!='Manifest.json' and p.suffix not in ['.olean','.ilean','.c','.o']:
        manifest.append({'path':p.relative_to(OUT).as_posix(),'bytes':p.stat().st_size,'sha256':sha(p)})
(OUT/'Manifest.json').write_text(json.dumps({'files':manifest},indent=2)+'\n',encoding='utf-8')
archive=ROOT/'outputs/Swirl-without-return.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
    for entry in manifest:
        z.write(OUT/entry['path'],entry['path'])
    z.write(OUT/'Manifest.json','Manifest.json')
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
    for entry in manifest:
        assert hashlib.sha256(z.read(entry['path'])).hexdigest()==entry['sha256']
print(json.dumps({'status':'PASS','new_modules':len(rows),'principal_axiom_reports':count,
                  'packaged_files':len(manifest)+1,'zip_bytes':archive.stat().st_size,'archive':str(archive)},indent=2))
