"""Read-only check that fluid refinement did not change material settings or events."""
import hashlib,json
from datetime import datetime,timezone
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def load(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
old=ROOT/'work/heat-follow/inputs/declared-source'
baseline=load(old/'protocol.json')['cases']['threshold_1'];rows=[]
for n in [16,24,32,40]:
 folder=HERE/f'declared-n{n}';case=load(folder/'protocol.json')['cases'][f'heat_grid_n{n}']
 assert case['config']['n']==n and case['config']['threshold']==1
 assert {k:v for k,v in case['config'].items() if k!='n'}=={k:v for k,v in baseline['config'].items() if k!='n'}
 assert case['events']==baseline['events']
 pyfiles={p.relative_to(folder).as_posix():sha(p) for p in folder.rglob('*.py')}
 for rel,digest in pyfiles.items():assert sha(old/rel)==digest
 rows.append({'grid':n,'all_non_grid_configuration_equal':True,'event_schedule_equal':True,'native_python_files_unchanged':pyfiles})
result={'status':'PASS','verified_utc':datetime.now(timezone.utc).isoformat(),'read_only_check':True,'runs':rows,'original_protocol_sha256':sha(old/'protocol.json'),'input_manifest_sha256':sha(HERE/'inputs.json'),'scope':'Native Python sources, all non-grid configuration values and event schedules. The separately documented passive observer index override is in run_grid.py. Actual integration steps are verified from saved rows after completion.'}
(HERE/'configuration-audit.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'status':'PASS','grids':len(rows),'native_python_files_per_grid':len(rows[0]['native_python_files_unchanged']),'all_other_config_and_events_equal':True}))
