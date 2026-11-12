"""Check saved evidence and replay the first paired step using packaged sources."""
from run_transfer import *
from html.parser import HTMLParser

def main(output=None):
    manifest=HERE/'SOURCE-MANIFEST.json'
    if manifest.exists():
        for path,expected in json.loads(manifest.read_text()).items():assert digest(HERE/path)==expected,path
    decl=json.loads((HERE/'EXPERIMENT.json').read_text())
    result=json.loads((HERE/'report/RESULTS.json').read_text())
    assert digest(STATE)==decl['source_state_sha256']
    assert digest(INPUT/'unit-fine-perturbation.npy')==decl['perturbation_sha256']
    model_inside_package=MODEL==HERE/'model'
    seals=0
    if model_inside_package:
        for seal in list(MODEL.rglob('source_seal.json'))+list(MODEL.rglob('comparison-seal.json')):
            for name,expected in json.loads(seal.read_text()).items():assert digest(seal.parent/name)==expected,(seal,name)
            seals+=1
    rows_checked=0;mode_snapshots=0
    for dt in decl['time_steps']:
        folder=HERE/'outputs'/('dt'+str(dt).replace('.','p'))
        with (folder/'history.csv').open() as f:rows=list(csv.DictReader(f))
        for row in rows:
            total=float(row['fine_error_total_rms'])
            squared=sum(float(row[f'fine_error_{b}_rms'])**2 for b in BANDS)
            assert abs(squared-total*total)<1e-12*total*total
            rows_checked+=1
        with np.load(folder/'broad-difference-modes.npz') as z:
            every=round(.0005/dt)
            for j,v in enumerate(z['values']):
                for a,name in enumerate(z['arms']):
                    expected=float(rows[j*every][f'{name}_broad_rms'])
                    assert abs(norm(v[a])-expected)<1e-12*max(expected,1e-25)
                    mode_snapshots+=1
    solver,_=new_solver();base=load_state();pert={k:v.copy() for k,v in base.items()}
    pert['g'][...,:3]+=decl['perturbation_absolute_rms']*np.load(INPUT/'unit-fine-perturbation.npy')
    dt=.0005
    advanced_base=solver.step(START,base,dt);advanced_pert=solver.step(START,pert,dt)
    response=low(spectrum(advanced_pert['g'][...,:3]-advanced_base['g'][...,:3]))
    with np.load(HERE/'outputs/dt0p0005/broad-difference-modes.npz') as z:saved=z['values'][1,0]
    replay_difference=norm(response-saved)
    replay_tolerance=max(1e-17,1e-4*norm(saved))  # allow cross-platform subtraction roundoff
    assert replay_difference<replay_tolerance,replay_difference
    class InspectHTML(HTMLParser):
        def __init__(self):super().__init__();self.images=[];self.links=[]
        def handle_starttag(self,tag,attrs):
            a=dict(attrs)
            if tag=='img':self.images.append(a['src'])
            if tag=='a':self.links.append(a['href'])
    html=InspectHTML();html.feed((HERE/'report/Tick-41-fine-to-broad-test.html').read_text(encoding='utf-8'))
    assert len(html.images)==2 and all(x.startswith('data:image/png;base64,') for x in html.images)
    assert all((HERE/'report'/p).is_file() for p in html.links)
    verification=dict(source_state_hash=True,perturbation_hash=True,packaged_model_used=model_inside_package,
        source_seals_checked=seals,history_rows_checked=rows_checked,complex_mode_snapshots_checked=mode_snapshots,
        paired_first_step_replay_relative_difference=replay_difference/norm(saved),
        paired_first_step_replay_absolute_difference=replay_difference,paired_first_step_replay_absolute_tolerance=replay_tolerance,
        self_contained_report_images=len(html.images),all_report_links_exist=True,
        acceptance_checks=result['validation'])
    if output:write_json(output,verification)
    print(json.dumps(verification,indent=2))

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--output',type=Path)
    main(p.parse_args().output)
