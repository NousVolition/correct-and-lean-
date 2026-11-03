"""Append a frozen proof-verification run without modifying any model source."""
from pathlib import Path
from datetime import datetime, timezone
from fractions import Fraction
import sys, json, shutil, hashlib, re, subprocess, warnings, traceback
sys.dont_write_bytecode=True
ROOT=Path(r'C:\Users\ziman\Documents\Codex\2026-10-31\ca')
REV=ROOT/'outputs/hug-v3-proof-corrected/revision-2'
PACK=REV/'testing-packet'
PRIOR=ROOT/'outputs/hug-v3-proof-review/20261101T051856.361354Z'
ATTACH=Path(r'C:\Users\ziman\.codex\attachments\56912d7e-687c-448d-b8a2-13f301b7ac58\Pasted text.txt')
DEPS=Path(r'C:\Users\ziman\Documents\Codex\2026-10-08\referenced-chatgpt-conversation-this-is-an-2\work\full-deps')
SKILL=Path(r'C:\Users\ziman\.codex\plugins\cache\nous-volition-local\lexical-lens-draft\2.7.0-draft.11\skills\discrete-math-logic')
RUN=datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ')
OUT=PACK/'runs'/RUN
OUT.mkdir(parents=True,exist_ok=False)
(ROOT/'work/current-corrected-hug-run.txt').write_text(str(OUT),encoding='utf8')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(path,obj):path.write_text(json.dumps(obj,indent=2,allow_nan=False),encoding='utf8')
manifest=[]
def copy(src,relative):
    dst=OUT/relative;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,dst)
    assert sha(src)==sha(dst)
    manifest.append(dict(source=str(src),snapshot=relative,sha256=sha(src)))
seal=json.loads((PRIOR/'sources/source_seal.json').read_text(encoding='utf8'))
origin=Path(json.loads((PRIOR/'prior-evidence/source-audit.json').read_text(encoding='utf8'))['source'])
triangle=ROOT/'outputs/triangle-hug'
triangle_manifest=json.loads((triangle/'testing-packet/source-manifest.json').read_text(encoding='utf8'))
triangle_paths=[triangle/'triangle_hug.py',triangle/'testing-packet/trial_model.py']+[triangle/'testing-packet'/x['snapshot_path'] for x in triangle_manifest['files']]
triangle_hashes={str(p):sha(p) for p in triangle_paths}
for rel,h in seal.items():
    assert sha(origin/rel)==sha(PRIOR/'sources'/rel)==h
    copy(PRIOR/'sources'/rel,'sources/'+rel)
copy(PRIOR/'sources/source_seal.json','sources/source_seal.json')
for name in ['proof.md','CORRECTIONS.md']:
    copy(REV/name,'inputs/'+name)
copy(PACK/'protocol.json','inputs/protocol.json')
copy(ATTACH,'inputs/original-submitted-proof.tex')
copy(Path(__file__),'verification.py')
copy(PRIOR/'checks.json','historical/prior-review-checks.json')
copy(PRIOR/'prior-evidence/verification-report.json','historical/earlier-formal-verification.json')
save(OUT/'input-manifest.json',manifest)
result=dict(run_id=RUN,model='hug-structural-memory-v3',proof_revision=2,
            scope='Finite static checks and analytical identities; not a time-integrated run or full formal certificate.',checks=[])
def check(name,ok,**data):
    result['checks'].append(dict(name=name,passed=bool(ok),**data))
    if not ok:raise AssertionError(name)
try:
    # Exact comparison of all displayed equations from the original and its copy.
    def eqs(p):
        text=p.read_text(encoding='utf8')
        pattern=r'\\begin\{(equation|align)\}(.*?)\\end\{\1\}'
        return [dict(id=f'original-display-{i:03d}',text=m.group(0)) for i,m in enumerate(re.finditer(pattern,text,re.S),1)]
    save(OUT/'original-equations-reference.json',eqs(ATTACH))
    save(OUT/'original-equations-retained.json',eqs(OUT/'inputs/original-submitted-proof.tex'))
    eq_run=subprocess.run([sys.executable,'-B',str(SKILL/'scripts/equation_check.py'),str(OUT/'original-equations-reference.json'),str(OUT/'original-equations-retained.json')],capture_output=True,text=True)
    (OUT/'equation-preservation.json').write_text(eq_run.stdout,encoding='utf8')
    check('original_displayed_equations_exactly_retained',eq_run.returncode==0,count=len(eqs(ATTACH)))
    sys.path.insert(0,str(DEPS));sys.path.insert(0,str(OUT/'sources'))
    import numpy as np
    import scipy
    import sympy as sp
    import struct,zlib
    import preflight
    declaration=preflight.approve('main')
    from structural_hug import Solver,Config,outcome_score
    so=Solver(Config(**declaration['config']));s=so.initial()
    result['environment']=dict(python=sys.version,numpy=np.__version__,scipy=scipy.__version__,sympy=sp.__version__,dependency_path=str(DEPS))
    check('unchanged_main_declaration_gate',True,manifest_sha256=declaration['manifest_sha256'])
    check('coordinate_count',sum(x.size for x in s.values())==193122,count=sum(x.size for x in s.values()))
    checkpoints=sorted({0.,so.c.end}|{v for e in declaration['events'] for v in [e['start'],e['end']]})
    check('checkpoint_partition',checkpoints==[0.,.2,.4,.8,1.2,1.6],actual=checkpoints)
    def domain(state):
        if np.min(np.abs(state['b']))<=.005:return False
        if np.min(np.linalg.norm(np.einsum('pij,kj->pki',state['F'],so.directions),axis=-1))<=0:return False
        try:
            records=so.read_material(state)
            return all(rec['end']>=rec['start'] and all(v is None or -1<=v<=1 for v in [rec['observed'],rec['recipient_report']]) for _,rec in records)
        except Exception:return False
    check('corrected_domain_accepts_initial',domain(s))
    rec=dict(origin=0,recipient=1,event_id=0,start=0.,end=.2,predecessors=0,observed=1.,recipient_report=None,
             context=np.array([.5,.5]),recognition=0.,authority=0.,actions=np.zeros(7),delta_E=np.zeros((so.P,6)))
    payload=so.fabric.payload(rec)
    def payload_state(index=None,value=None):
        data=np.frombuffer(payload[:-4],dtype='<i2').copy()
        if index is not None:data[index]=value
        body=data.tobytes();blob=body+struct.pack('<I',zlib.crc32(body))
        out={k:v.copy() for k,v in s.items()};out['context'][:]=.5;out['association'][:]=0
        bits=np.unpackbits(np.frombuffer(blob,dtype=np.uint8),bitorder='little')
        out['b'][:so.fabric.bits_per_slot]=so.c.rest_amplitude*(2*bits.astype(float)-1)
        return out
    neg=payload_state(6,-120);invalid=payload_state(10,20000);zero=payload_state(6,0);valid=payload_state()
    check('counterexamples_rejected_by_corrected_domain',not domain(neg) and not domain(invalid),old_reader_accepts_negative=bool(so.read_material(neg)),old_reader_accepts_invalid_outcome=bool(so.read_material(invalid)))
    check('valid_and_zero_duration_records_admitted',domain(valid) and domain(zero))
    mem,exposure,_=so.retrieve(0.,zero)
    check('zero_duration_denominator',np.isfinite(mem).all() and np.min(so.c.history_prior+exposure)>=.12,minimum=float(np.min(so.c.history_prior+exposure)))
    b=s['b'].copy();b[0]+=.001
    before=so.fabric.probe(s['F'],s['b']);after=so.fabric.probe(s['F'],b)
    check('probe_values_change_without_bit_change',np.array_equal(so.fabric.bits_from_probe(*before),so.fabric.bits_from_probe(*after)) and b[0]!=s['b'][0])
    rho_b=float(np.min(np.abs(s['b']))-.005);rho_F=float(np.min(np.linalg.norm(np.einsum('pij,kj->pki',s['F'],so.directions),axis=-1)))
    radius=min(1.,rho_b,rho_F)/4
    check('full_state_ball_margins',2*radius<=rho_b/2 and 2*radius<=rho_F/2,radius=radius,lower_bit_margin=rho_b-2*radius,lower_fiber_length=rho_F-2*radius)
    safe=np.pi*np.sqrt(3)*so.n
    max_symbol=float(np.sqrt(so.k2).max())
    wave=np.cos(2*np.pi*7*np.indices((so.n,)*3).sum(axis=0)/so.n)
    measured=float(np.linalg.norm(so.grad(wave))/np.linalg.norm(wave))
    check('full_grid_spectral_bound',max_symbol<=safe*(1+1e-12) and measured<=safe,all_modes=so.n**3,max_symbol=max_symbol,corrected_bound=float(safe),previous_counterexample=measured)
    rng=np.random.default_rng(20261031)
    transport_ratios=[]
    for _ in range(12):
        C,Ct=rng.normal(size=(2,so.n,so.n,so.n));u,ut=rng.normal(size=(2,so.n,so.n,so.n,3))
        lhs=np.linalg.norm(so.context_transport(C,u)-so.context_transport(Ct,ut))
        rhs=12*so.n**2*so.c.diffusion*np.linalg.norm(C-Ct)+6*so.n*(np.linalg.norm(u)*np.linalg.norm(C-Ct)+np.linalg.norm(Ct)*np.linalg.norm(u-ut))
        transport_ratios.append(float(lhs/rhs))
        cd=np.stack([(np.roll(C,-1,axis=j)-np.roll(C,1,axis=j))/(2*so.dx) for j in range(3)],-1)
        assert np.linalg.norm(cd)<=np.sqrt(3)*so.n*np.linalg.norm(C)*(1+1e-12)
    check('transport_and_centered_difference_samples',max(transport_ratios)<=1+1e-12,samples=12,max_transport_bound_ratio=max(transport_ratios),scope='Finite examples supplement the analytical inequalities.')
    w=so.c.thermal_width
    def psi(x):return sum(np.exp(-(x+v)**2/(2*w*w)) for v in [-1,0,1])
    seam=psi(.5);correct=2*np.exp(-1/(8*w*w))+np.exp(-9/(8*w*w))
    check('correct_gaussian_seam',abs(seam-correct)<=1e-12*abs(correct) and psi(-.5)==seam,value=float(seam))
    X=so.X0.copy();X[:3]=[[-.5,0,.5],[.5,.5,.5],[1.5,-1.5,.2]]
    R=so.matrices(X)[1]
    check('thermal_kernel_nonnegative_row_sums',R.min()>=0 and np.max(np.abs(R.sum(1)-1))<=1e-12,max_row_error=float(np.max(np.abs(R.sum(1)-1))))
    zmin=np.exp(-1/(8*so.n**2*w*w));denominators=[];qerrors=[]
    for x in np.linspace(-1.5,1.5,41):
        y=x+.017
        fx=psi((x-so.x+.5)%1-.5);fy=psi((y-so.x+.5)%1-.5);zx=fx.sum();zy=fy.sum()
        rx=fx/zx;ry=fy/zy
        qerrors.append(float(np.max(np.abs((rx-ry)-((fx-fy)-ry*(zx-zy))/zx))))
        denominators.extend([float(zx),float(zy)])
    check('thermal_quotient_and_positive_normalization',max(qerrors)<=1e-12 and min(denominators)>=zmin,max_identity_error=max(qerrors),minimum_normalizer=min(denominators),proven_lower_bound=float(zmin))
    q,eps,v,r,tau,wr=sp.symbols('q eps v r tau wr',positive=True)
    activation=q*sp.exp(-eps**2/q**2);d=sp.diff(activation,q)
    expected=(1+2*eps**2/q**2)*sp.exp(-eps**2/q**2)
    phi=(1+2*v)*sp.exp(-v)
    raw=wr*r*r/(r*r+tau*tau)
    check('symbolic_activation_and_rate_bounds',sp.simplify(d-expected)==0 and sp.simplify(sp.diff(phi,v)-(1-2*v)*sp.exp(-v))==0 and sp.simplify(sp.diff(raw,r).subs(r,tau/sp.sqrt(3))-3*sp.sqrt(3)*wr/(8*tau))==0,
          activation_max=str(sp.simplify(phi.subs(v,sp.Rational(1,2)))),rate_critical_derivative=str(sp.simplify(sp.diff(raw,r,2).subs(r,tau/sp.sqrt(3)))))
    current={k:v.copy() for k,v in s.items()};static_writes=[]
    for event in declaration['events']:
        record=so.make_event(current,s['F'].copy(),event)
        current,account=so.write_event(current,record)
        assert domain(current)
        static_writes.append(dict(event_id=event['event_id'],required_budget=account['required_budget'],budget=so.c.write_budget,work=account['work']))
    check('declared_metadata_static_writes_preserve_domain',True,writes=static_writes,scope='Static F=I fixtures, not the physical trajectory at event times.')
    before={k:v.copy() for k,v in current.items()}
    duplicate=so.make_event(current,s['F'].copy(),declaration['events'][0])
    try:so.write_event(current,duplicate);rejected=False
    except ValueError:rejected=True
    check('rejected_duplicate_write_preserves_input',rejected and all(np.array_equal(current[k],before[k]) for k in current))
    endpoints=so.fabric.quant(np.array([-32768.,32767.]),1.).tolist();outside=[]
    for x in [-32769.,32768.]:
        try:so.fabric.quant(x,1.);outside.append(False)
        except ValueError:outside.append(True)
    check('exact_signed_encoding_range',endpoints==[-32768,32767] and all(outside),accepted=endpoints,rejected=[-32769,32768])
    result['status']='PASS_TARGETED_CHECKS'
except Exception:
    result['status']='FAIL_OR_INCOMPLETE';result['exception']=traceback.format_exc()
finally:
    result['preservation']=dict(original_21=all(sha(origin/p)==h for p,h in seal.items()),prior_snapshot_21=all(sha(PRIOR/'sources'/p)==h for p,h in seal.items()),run_snapshot_21=all(sha(OUT/'sources'/p)==h for p,h in seal.items()),
        frozen_inputs=all(sha(OUT/x['snapshot'])==x['sha256'] for x in manifest),triangle_files=all(sha(Path(p))==h for p,h in triangle_hashes.items()),original_attachment=sha(ATTACH)==sha(OUT/'inputs/original-submitted-proof.tex'))
    if not all(result['preservation'].values()):result['status']='FAIL_PRESERVATION'
    save(OUT/'checks.json',result)
    with (PACK/'runs.jsonl').open('a',encoding='utf8') as f:f.write(json.dumps(dict(run_id=RUN,stage='analytical-and-static-checks',status=result['status'],result=str(OUT/'checks.json')))+'\n')
print(json.dumps(dict(run=str(OUT),status=result['status'],checks=len(result['checks']),preservation=result['preservation'],exception=result.get('exception')),indent=2))
