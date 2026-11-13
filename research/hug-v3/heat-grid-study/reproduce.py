"""Recount or plot saved evidence, or run a new simulation in a separate workspace."""
import argparse,json,shutil,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
TAGS=['n16_dt0p002','n24_dt0p002','n32_dt0p002','n40_dt0p002','n40_dt0p001']
p=argparse.ArgumentParser()
p.add_argument('action',choices=['recount','plot','simulate'])
p.add_argument('--run',choices=TAGS,help='Recount one saved run only')
p.add_argument('--scratch',type=Path,default=HERE/'reproduction/scratch')
a=p.parse_args()
scratch=a.scratch.resolve()
assert scratch!=HERE and not HERE.is_relative_to(scratch),'Scratch must not replace the study or its parent'
work=scratch/'work/heat-grid';out=scratch/'outputs/heat-grid'
assert not scratch.exists(),'Use a new scratch directory; existing evidence is never overwritten'
shutil.copytree(HERE/'reproduction/work/heat-grid',work)
def run(*args):subprocess.run([sys.executable,*map(str,args)],check=True)
if a.action=='simulate':
    manifest=json.loads((work/'inputs.json').read_text())
    (work/'inputs.json').write_text(json.dumps({k.replace('\\','/'):v for k,v in manifest.items()},indent=2)+'\n')
    for n in [16,24,32,40]:run(work/'run_grid.py','pilot','--n',n)
    for tag in TAGS:
        n,dt=tag[1:].split('_dt');run(work/'run_grid.py','run','--n',n,'--dt',dt.replace('p','.'))
elif a.action=='recount':
    selected=[a.run] if a.run else TAGS
    for tag in selected:
        dest=out/tag;dest.mkdir(parents=True)
        receipt=json.loads((HERE/tag/'receipt.json').read_text())
        for filename in ['receipt.json',*receipt['files_sha256']]:
            target=dest/filename;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(HERE/tag/filename,target)
        run(work/'analyze_grid.py','--run',tag)
        assert json.loads((dest/'analysis.json').read_text())==json.loads((HERE/tag/'analysis.json').read_text()),'Recount differs: '+tag
    if not a.run:
        run(work/'analyze_grid.py')
        assert json.loads((out/'analysis.json').read_text())==json.loads((HERE/'analysis.json').read_text()),'Aggregate recount differs'
    print('Saved-array recount matches the published result; no fluid integration run.')
else:
    out.mkdir(parents=True)
    for name in ['analysis.json',*['comparison-'+l+'--'+r+'.json' for l,r in zip(TAGS,TAGS[1:])]]:
        shutil.copyfile(HERE/name,out/name)
    for tag in TAGS:
        (out/tag).mkdir();shutil.copyfile(HERE/tag/'analysis.json',out/tag/'analysis.json')
    lean=scratch/'outputs/heat-grid-lean';lean.mkdir()
    shutil.copyfile(HERE.parent/'heat-grid-lean/receipt.json',lean/'receipt.json')
    run(work/'make_report.py')
print(scratch)
