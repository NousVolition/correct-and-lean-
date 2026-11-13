import hashlib,json,subprocess
from pathlib import Path
from datetime import datetime,timezone
HERE=Path(__file__).resolve().parent
CACHE=Path('$USER_HOME/verification');UP=CACHE/'project'
LEAN=Path('/opt/lean-audit/lean-4.34.0-rc2-linux/bin/lean')
SRC=HERE.parent/'recent-research-publication-20261112/repository/research/chat-research-update-2026-11-12'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def git(p,*args):return subprocess.check_output(['git','-C',str(p),*args],text=True).strip()
before=json.loads((HERE/'environment.json').read_text());tools={}
for name,data in before['tools'].items():
    p=Path(data['path']);actual=sha(p);assert actual==data['sha256'],name
    tools[name]={'sha256':actual,'unchanged':True}
deps={}
manifest=json.loads((UP/'lake-manifest.json').read_text())
for item in manifest['packages']:
    if item['type']!='git':continue
    p=UP/'.lake/packages'/item['name']
    actual=git(p,'rev-parse','HEAD');status=git(p,'status','--porcelain')
    assert actual==item['rev'] and not status,item['name']
    deps[item['name']]={'commit':actual,'clean':True}
assert git(UP,'rev-parse','HEAD')=='f9e8bc5b38b6e212696e8a30e3e91517af887bbd'
assert not git(UP,'status','--porcelain')
inputs=json.loads((HERE/'private-generic/all-published-lean-inputs.json').read_text())['files']
assert all(sha(SRC/n)==h for n,h in inputs.items())
version=subprocess.check_output([str(LEAN),'--version'],text=True).strip()
assert '4.34.0-rc2' in version and '6a10ac8c22beadecabdbb0919c2b50214762f91d' in version
r={'checked_at_utc':datetime.now(timezone.utc).isoformat(),'status':'PASS','unchanged_lean_inputs':len(inputs),'tools':tools,'lean_version':version,'lean_binary_sha256':sha(LEAN),'dependency_pins_and_clean_sources':deps,'upstream_commit':git(UP,'rev-parse','HEAD'),'upstream_clean':True}
(HERE/'postflight.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r,indent=2))
