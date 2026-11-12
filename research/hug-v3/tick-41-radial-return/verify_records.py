"""Recount published frozen-field measurements; no fluid or curve integration."""
from pathlib import Path
import json,csv,math,hashlib
HERE=Path(__file__).resolve().parent
def main():
    manifest=HERE/'publication-manifest.json'
    if manifest.exists():
        for path,expected in json.loads(manifest.read_text()).items():
            assert hashlib.sha256((HERE/path).read_bytes()).hexdigest()==expected,path
    rows=list(csv.DictReader((HERE/'every-seed-return-miss.csv').open()))
    summary=json.loads((HERE/'summary.json').read_text())
    checks=json.loads((HERE/'checks.json').read_text())
    assert len(rows)==2062 and len({(r['grid'],r['seed_fraction']) for r in rows})==2062
    assert sum(r['measurement_status']=='undefined on axis' for r in rows)==3
    assert sum(r['measurement_status']=='unresolved between integrators' for r in rows)==7
    for r in rows:
        if not r['return_miss']:
            assert float(r['distance'])==0
            continue
        miss=float(r['return_miss']);dx=float(r['delta_x']);dy=float(r['delta_y']);dz=float(r['delta_z']);trans=float(r['transverse_miss'])
        assert math.isclose(miss*miss,dx*dx+dy*dy+dz*dz,rel_tol=1e-11,abs_tol=1e-18)
        assert math.isclose(trans*trans,dy*dy+dz*dz,rel_tol=1e-11,abs_tol=1e-18)
        assert float(r['return_length'])<=float(r['arclength_limit'])+1e-12
    for n,values in summary.items():
        selected=[r for r in rows if r['grid']==n]
        assert len(selected)==values['sampled_positive_seeds']+1
        assert sum(r['measurement_status']=='unresolved between integrators' for r in selected)==checks[n]['unresolved']
    print(json.dumps(dict(rows=2062,undefined_axis_entries=3,unresolved_precision_checks=7,displacement_decompositions_pass=True,scope='Saved-table recount only; no curve or field replay'),indent=2))
if __name__=='__main__':main()
