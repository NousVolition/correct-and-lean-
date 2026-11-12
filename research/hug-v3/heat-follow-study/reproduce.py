"""Prepare separate outputs; optionally rerun the numerical study there."""
import argparse,shutil,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('action',choices=['recount','plot','simulate']);a=p.parse_args()
work=HERE/'reproduction/work/heat-follow';out=HERE/'reproduction/outputs/heat-follow'
if a.action=='simulate':
    if out.exists():raise SystemExit('Output already exists; use a separate clean checkout for a new simulation.')
    for dt in ['.002','.001']:subprocess.run([sys.executable,str(work/'run_heat.py'),'run','--dt',dt],check=True)
else:
    out.mkdir(parents=True,exist_ok=True)
    for tag in ['n16_dt0p002','n16_dt0p001']:
        (out/tag).mkdir(exist_ok=True)
        for name in ['history.csv','receipt.json','fields.npz']:shutil.copyfile(HERE/tag/name,out/tag/name)
    shutil.copyfile(HERE/'analysis.json',out/'analysis.json')
    subprocess.run([sys.executable,str(work/('analyze_heat.py' if a.action=='recount' else 'plot_heat.py'))],check=True)
print(out)
