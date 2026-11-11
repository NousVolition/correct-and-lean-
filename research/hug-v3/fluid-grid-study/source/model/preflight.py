"""Local extension of the supplied declaration gate; validates before solver construction."""
from pathlib import Path
import json,hashlib,importlib.util,dataclasses
ROOT=Path(__file__).resolve().parent
ACTIVE=None
ALIASES={'dt':'max_dt','diffusion':'diffusivity','source_width':'h'}
def load(name):return json.loads((ROOT/name).read_text(encoding='utf8'))
def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def validator():
    path=ROOT/'reference_gate'/'run_manifest.py'
    spec=importlib.util.spec_from_file_location('provided_run_gate',path)
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    return module
def approve(name):
    global ACTIVE
    seal=load('source_seal.json')
    drift=[p for p,h in seal.items() if not (ROOT/p).is_file() or digest(ROOT/p)!=h]
    if drift:raise RuntimeError('Pre-run source drift refused: '+', '.join(drift))
    protocol=load('protocol.json')
    if name not in protocol['cases']:raise RuntimeError('Undeclared case refused')
    case=protocol['cases'][name]
    manifest=load('declarations/'+name+'.json')
    module=validator()
    errors=module.validate(manifest,register=module.load_register(ROOT/'equation_register.csv'),
                           chain=module.load_chain(ROOT/'study_chain.csv'),
                           bounds=module.load_bounds(ROOT/'parameter_bounds.json'))
    if errors:raise RuntimeError('Run declaration refused:\n'+'\n'.join(errors))
    if manifest['claims_corpus_validation']:raise RuntimeError('This added-law study cannot claim corpus validation')
    ACTIVE=(name,case,manifest)
    guard_config_dict(case['config'])
    return dict(case,manifest_sha256=digest(ROOT/'declarations'/(name+'.json')))
def guard_config_dict(config):
    if ACTIVE is None:raise RuntimeError('Approve a sealed declaration before creating a solver')
    name,case,manifest=ACTIVE
    if set(config)!=set(case['config']):raise RuntimeError('Undeclared configuration keys')
    allowed=case.get('unit_config_sweeps',{})
    for key,value in config.items():
        candidates=allowed.get(key,[case['config'][key]])
        if value not in candidates:raise RuntimeError('Runtime parameter drift: '+key)
    return True
def guard_config(config):return guard_config_dict(dataclasses.asdict(config))
if __name__=='__main__':
    import sys
    d=approve(sys.argv[1] if len(sys.argv)>1 else 'main')
    print(json.dumps(dict(status='accepted',case=ACTIVE[0],manifest_sha256=d['manifest_sha256'],claims_corpus_validation=False)))
