#!/usr/bin/env python3
"""Reconstruct a recorded generic check from unchanged repository sources.

Requires the pinned Linux Lean/cache/tools listed in tools.json and an
unprivileged user with systemd-user and working Landrun isolation.
"""
import argparse,hashlib,json,os,shutil,subprocess,tempfile
from pathlib import Path
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('batch',choices=['energy-as','energy-hug','geometry-real','geometry-rational'])
    ap.add_argument('--repository',type=Path,required=True)
    ap.add_argument('--cache',type=Path,default=Path.home()/'verification')
    ap.add_argument('--lean-bin',type=Path,default=Path('/opt/lean-audit/lean-4.34.0-rc2-linux/bin'))
    ap.add_argument('--prepare-only',action='store_true')
    a=ap.parse_args();assert os.getuid()!=0,'Use an unprivileged Linux user'
    here=Path(__file__).resolve().parent; receipt=here/'generic'/a.batch
    freeze=json.loads((receipt/'reference-freeze.json').read_text())
    stage=Path(tempfile.mkdtemp(prefix='published-proof-replay-'))
    for name,locations in freeze['origins'].items():
        expected=freeze['files'][name]
        for relative in locations:
            p=a.repository/'research/chat-research-update-2026-11-12'/relative
            assert sha(p)==expected,relative
        shutil.copyfile(a.repository/'research/chat-research-update-2026-11-12'/locations[0],stage/name)
    for name in freeze['files']:
        if name not in freeze['origins']:
            shutil.copyfile(receipt/name,stage/name)
        assert sha(stage/name)==freeze['files'][name],name
    up=a.cache/'project';(stage/'.lake/packages').mkdir(parents=True)
    manifest=json.loads((stage/'lake-manifest.json').read_text())
    for item in manifest['packages']:
        if item['type']!='git':continue
        dep=up/'.lake/packages'/item['name']
        actual=subprocess.check_output(['git','-C',str(dep),'rev-parse','HEAD'],text=True).strip()
        assert actual==item['rev'],item['name']
        assert not subprocess.check_output(['git','-C',str(dep),'status','--porcelain']).strip(),item['name']
    for p in (up/'.lake/packages').iterdir():(stage/'.lake/packages'/p.name).symlink_to(p,target_is_directory=True)
    print('Prepared isolated project:',stage,flush=True)
    if a.prepare_only:return
    env=os.environ.copy();env.update(PATH=f'{a.cache}/bin:{a.lean_bin}:/usr/local/bin:/usr/bin:/bin',XDG_RUNTIME_DIR=f'/run/user/{os.getuid()}',DBUS_SESSION_BUS_ADDRESS=f'unix:path=/run/user/{os.getuid()}/bus')
    lake=a.cache/'bin/lake';evidence=stage/'evidence';evidence.mkdir()
    cmd=['systemd-run','--user','--wait','--pipe','--collect','--property=RestrictAddressFamilies=~AF_UNIX','-E','PATH='+env['PATH'],'-E','COMPARATOR_LANDRUN='+str(a.cache/'bin/landrun'),'-E','COMPARATOR_LEAN4EXPORT='+str(up/'.lake/packages/lean4export/.lake/build/bin/lean4export'),'-E','COMPARATOR_NANODA='+str(a.cache/'nanoda_lib/target/release/nanoda_bin'),'--working-directory='+str(stage),'--',str(lake),'env',str(up/'.lake/packages/Comparator/.lake/build/bin/comparator'),'comparator.json']
    results={}
    for name,args in [('comparator',cmd),('axioms',[str(lake),'env',str(a.lean_bin/'lean'),'FreshAxioms.lean']),('lake-build',[str(lake),'build'])]:
        with (evidence/(name+'.log')).open('w') as out:
            result=subprocess.run(args,cwd=stage,env=env,stdout=out,stderr=subprocess.STDOUT,timeout=10800)
        results[name]=result.returncode;print(name,result.returncode,flush=True)
    assert all(sha(stage/n)==h for n,h in freeze['files'].items()),'Input changed'
    (evidence/'exit-codes.json').write_text(json.dumps(results,indent=2)+'\n')
    raise SystemExit(0 if all(x==0 for x in results.values()) else 1)
if __name__=='__main__':main()
