"""Bidirectional trust meter and durable lead-up for the sealed full Hug solver.

The original physical and trust RHS and physical event payload are unchanged.
This extension adds initial trust choices and a separately declared software
memory record. The new record is readable after restart; it is not disguised as
an addition to the original material bit capacity or a new trust feedback law.
"""
from __future__ import annotations
import os
for _name in ('OPENBLAS_NUM_THREADS', 'OMP_NUM_THREADS', 'MKL_NUM_THREADS'):
    os.environ.setdefault(_name, '1')
import argparse, csv, hashlib, io, json, math, sys, time, zipfile
from dataclasses import dataclass, asdict
from pathlib import Path
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parent
UPSTREAM = ROOT/'upstream'
sys.path.insert(0, str(UPSTREAM))
import numpy as np
from scipy.special import expit
import preflight
from structural_hug import Config
from breathing import ComparisonSolver, Trail

VERSION = 1
DT = .002
N = 6

def plain(value):
    if isinstance(value, np.ndarray): return value.tolist()
    if isinstance(value, np.generic): return value.item()
    if isinstance(value, dict): return {k:plain(v) for k,v in value.items()}
    if isinstance(value, (tuple,list)): return [plain(v) for v in value]
    return value

def json_bytes(value):
    return (json.dumps(plain(value),ensure_ascii=False,allow_nan=False,separators=(',',':'))+'\n').encode()

def sha(data): return hashlib.sha256(data).hexdigest()

def atomic_bytes(path, data):
    path = Path(path)
    temporary = path.with_name(path.name+'.pending')
    temporary.write_bytes(data)
    temporary.replace(path)

@dataclass(frozen=True)
class Settings:
    trust_ab: float
    trust_ba: float
    actor_a: int = 0
    actor_b: int = 1
    dt: float = DT
    horizon: float = 1.2

    def validate(self):
        if not (isinstance(self.actor_a,int) and isinstance(self.actor_b,int) and
                0 <= self.actor_a < N and 0 <= self.actor_b < N and self.actor_a != self.actor_b):
            raise ValueError('Select two distinct actor IDs from 0 through 5.')
        if not all(math.isfinite(v) and 0 <= v <= 1 for v in (self.trust_ab,self.trust_ba)):
            raise ValueError('Each initial trust must be a finite number in [0,1].')
        if self.dt != DT or not math.isfinite(self.horizon) or not 0 < self.horizon <= 1.6:
            raise ValueError('This extension uses step 0.002 and a horizon in (0,1.6].')
        if abs(self.horizon/self.dt-round(self.horizon/self.dt)) > 1e-9:
            raise ValueError('Horizon must be a whole number of declared steps.')

def validate_ties(ties):
    allowed = {'neighbor','parent_child','caregiver','ancestry','communicated'}
    for tie in ties:
        if set(tie)-{'from','to','kind','source','origin_event','received_as'}:
            raise ValueError('Unknown tie fields; numerical influence weights are not inferred.')
        if tie.get('kind') not in allowed or not tie.get('source'):
            raise ValueError('Each tie requires a supported kind and its source.')
        if not all(isinstance(tie.get(k),int) and 0<=tie[k]<N for k in ('from','to')) or tie['from']==tie['to']:
            raise ValueError('A tie requires two distinct known actors.')
        if tie.get('received_as','unspecified') not in ('direct','communicated','unspecified'):
            raise ValueError('received_as must preserve direct/communicated attribution.')
        if tie['kind']=='communicated' and tie.get('received_as')!='communicated':
            raise ValueError('Communicated history cannot be relabeled direct experience.')
    return json.loads(json_bytes(ties))

def source_fingerprint():
    names=list(json.loads((UPSTREAM/'source_seal.json').read_text()))
    names += ['source_seal.json','breathing.py','marker-seeds.csv']
    return {name:sha((UPSTREAM/name).read_bytes()) for name in names}

def build_solver():
    case = preflight.approve('threshold_1')
    with (UPSTREAM/'marker-seeds.csv').open(newline='') as f:
        trail = Trail(list(csv.DictReader(f)))
    solver = ComparisonSolver(Config(**case['config']),.5,.6,trail)
    return solver,case

def trust_reading(solver, state):
    """Read the existing trust RHS terms, without adding a new update law."""
    c=solver.c
    mem=solver.retrieve(0,state)[0]*c.memory_feedback
    r=c.response_feedback*state['responses']
    delta=state['expression'][None,:,:]-state['expression'][:,None,:]
    agreement=np.exp(-np.sum(delta*delta,axis=-1)/.6)
    pieces={'agreement':1.4*agreement,'offset':np.full((N,N),-1.),
            'remembered_help':1.5*mem[...,0],'remembered_harm':-1.5*mem[...,1],
            'cooperation':r[...,1],'repair':r[...,6],'rivalry':-r[...,2],
            'incoming_coercion':-r[...,4].T}
    target=expit(sum(pieces.values()))*solver.mask_social
    trust=state['relation'][...,2]
    rate=c.map_rate*(target-trust)
    return trust.copy(),target,rate,pieces

class Session:
    def __init__(self, settings: Settings, ties=None):
        settings.validate()
        self.settings=settings
        self.ties=validate_ties(ties or [])
        self.solver,self.case=build_solver()
        self.state=self.solver.initial()
        a,b=settings.actor_a,settings.actor_b
        self.state['relation'][a,b,2]=settings.trust_ab
        self.state['relation'][b,a,2]=settings.trust_ba
        self.solver.utility_baseline=self.solver.utility(self.state,np.zeros((N,3)))
        self.frame=0
        self.starts={}
        self.history=[]
        self.records=[]
        self.fingerprint=source_fingerprint()
        self.capture('initial')
        self.capture_starts()

    @property
    def t(self): return self.frame*self.settings.dt

    def capture_starts(self):
        for event in self.case['events']:
            if round(event['start']/self.settings.dt)==self.frame:
                self.starts[event['event_id']]=self.state['F'].copy()

    def capture(self,phase):
        trust,target,rate,pieces=trust_reading(self.solver,self.state)
        if not np.isfinite(trust).all() or np.min(trust)<-1e-12 or np.max(trust)>1+1e-12:
            raise FloatingPointError('Trust left its declared range; no clipping is applied.')
        row=dict(sequence=len(self.history),time=self.t,frame=self.frame,phase=phase,
                 trust=trust,target=target,rate=rate,inputs=pieces,
                 relation=self.state['relation'],responses=self.state['responses'],
                 context=self.state['context'],expression=self.state['expression'],
                 association=self.state['association'],norm=self.state['norm'],
                 logradius=self.state['logradius'],decoded_event_ids=[r['event_id'] for _,r in self.solver.read_material(self.state)])
        self.history.append(plain(row))

    def step(self):
        if self.frame>=round(self.settings.horizon/self.settings.dt):
            raise ValueError('The declared horizon is already complete.')
        prior_time=self.t
        self.state=self.solver.step(prior_time,self.state,self.settings.dt)
        self.frame+=1
        if not all(np.isfinite(v).all() for v in self.state.values()):
            raise FloatingPointError('Nonfinite full state.')
        events=[e for e in self.case['events'] if round(e['end']/self.settings.dt)==self.frame]
        self.capture('before_write' if events else 'flow')
        for event in events:
            raw=self.solver.make_event(self.state,self.starts[event['event_id']],event)
            after,work=self.solver.write_event(self.state,raw)
            decoded=next(r for _,r in self.solver.read_material(after) if r['event_id']==event['event_id'])
            assert np.array_equal(self.state['relation'],after['relation'])
            origin,recipient=event['origin'],event['recipient']
            leadup=[dict(sequence=h['sequence'],time=h['time'],phase=h['phase'],
                         origin_to_recipient=h['trust'][origin][recipient],
                         recipient_to_origin=h['trust'][recipient][origin],
                         origin_rate=h['rate'][origin][recipient],recipient_rate=h['rate'][recipient][origin]) for h in self.history]
            record=dict(version=VERSION,event_id=event['event_id'],origin=origin,recipient=recipient,
                        event_interval=[event['start'],event['end']],retained_from=self.history[0]['time'],
                        before_write_sequence=self.history[-1]['sequence'],trust_leadup=leadup,
                        evidence=plain(decoded),write_account=plain(work),ties=self.ties,
                        luck={'rule':None,'attribution':None,'status':'not established in the searched sources'},
                        provenance={'outcome_source':'sealed fixture','direct_or_communicated':'unspecified',
                                    'physical_payload_unchanged':True,'trust_history_storage':'software memory extension'})
            self.state=after
            self.records.append(record)
            del self.starts[event['event_id']]
            self.capture('after_write')
        self.capture_starts()

    def advance(self,to_frame=None):
        target=round(self.settings.horizon/self.settings.dt) if to_frame is None else to_frame
        if not self.frame<=target<=round(self.settings.horizon/self.settings.dt):
            raise ValueError('Advance target is outside this run.')
        while self.frame<target: self.step()

    def read_trust_memory(self,event_id):
        return json.loads(json_bytes(next(r for r in self.records if r['event_id']==event_id)))

    def save(self,path):
        data=io.BytesIO()
        arrays={**self.state,**{'start_'+str(k):v for k,v in self.starts.items()}}
        np.savez_compressed(data,**arrays)
        members={'state.npz':data.getvalue(),
                 'memory.json':json_bytes({'history':self.history,'records':self.records}),
                 'session.json':json_bytes({'version':VERSION,'settings':asdict(self.settings),'frame':self.frame,
                    'ties':self.ties,'fingerprint':self.fingerprint,'utility_baseline':self.solver.utility_baseline})}
        members['checksums.json']=json_bytes({name:sha(value) for name,value in members.items()})
        packed=io.BytesIO()
        with zipfile.ZipFile(packed,'w',compression=zipfile.ZIP_DEFLATED) as z:
            for name,value in members.items(): z.writestr(name,value)
        atomic_bytes(path,packed.getvalue())

    @classmethod
    def load(cls,path):
        with zipfile.ZipFile(path) as z:
            expected=json.loads(z.read('checksums.json'))
            members={name:z.read(name) for name in expected}
        if any(sha(members[k])!=v for k,v in expected.items()):
            raise ValueError('Checkpoint content checksum failed.')
        metadata=json.loads(members['session.json'])
        if metadata['version']!=VERSION or metadata['fingerprint']!=source_fingerprint():
            raise ValueError('Checkpoint version or source mismatch.')
        obj=cls(Settings(**metadata['settings']),metadata['ties'])
        with np.load(io.BytesIO(members['state.npz']),allow_pickle=False) as z:
            obj.state={k:z[k].copy() for k in z.files if not k.startswith('start_')}
            obj.starts={int(k[6:]):z[k].copy() for k in z.files if k.startswith('start_')}
        memory=json.loads(members['memory.json'])
        obj.history=memory['history']; obj.records=memory['records']; obj.frame=metadata['frame']
        obj.solver.utility_baseline=metadata['utility_baseline']
        if not obj.history or obj.history[-1]['time']!=obj.t:
            raise ValueError('Lead-up and checkpoint clocks disagree.')
        if not np.array_equal(np.array(obj.history[-1]['trust']),obj.state['relation'][...,2]):
            raise ValueError('Lead-up and live trust disagree.')
        return obj

    def export(self,folder):
        folder=Path(folder); folder.mkdir(parents=True,exist_ok=True)
        self.save(folder/'checkpoint.zip')
        atomic_bytes(folder/'trust-history.json',json_bytes(self.history))
        atomic_bytes(folder/'memory-records.json',json_bytes(self.records))
        a,b=self.settings.actor_a,self.settings.actor_b
        view=[dict(time=h['time'],phase=h['phase'],ab=h['trust'][a][b],ba=h['trust'][b][a],
                   rate_ab=h['rate'][a][b],rate_ba=h['rate'][b][a],
                   inputs_ab={k:v[a][b] for k,v in h['inputs'].items()},
                   inputs_ba={k:v[b][a] for k,v in h['inputs'].items()}) for h in self.history]
        summary=dict(version=VERSION,settings=asdict(self.settings),samples=len(self.history),frame=self.frame,
                     events=len(self.records),initial=[view[0]['ab'],view[0]['ba']],final=[view[-1]['ab'],view[-1]['ba']],
                     scope='Full original threshold-one breathing-on dynamics; new initial trust and software memory.',
                     unimplemented_trust_rules=['neighbor-specific weighting','parent-child transmission','luck attribution'],
                     source_fingerprint=self.fingerprint)
        atomic_bytes(folder/'summary.json',json_bytes(summary))
        atomic_bytes(folder/'view.json',json_bytes(dict(summary=summary,history=view)))
        with (folder/'trust.csv').open('w',newline='',encoding='utf-8') as f:
            writer=csv.writer(f);writer.writerow(['time','phase','trust_a_to_b','trust_b_to_a','rate_a_to_b','rate_b_to_a'])
            writer.writerows([h[k] for k in ('time','phase','ab','ba','rate_ab','rate_ba')] for h in view)
        return summary

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--trust-ab',type=float);p.add_argument('--trust-ba',type=float)
    p.add_argument('--actor-a',type=int,default=0);p.add_argument('--actor-b',type=int,default=1)
    p.add_argument('--horizon',type=float,default=1.2)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--resume',type=Path);p.add_argument('--ties',type=Path)
    args=p.parse_args()
    if args.out.exists() and any(args.out.iterdir()): p.error('Use an empty output directory; existing runs are preserved.')
    if args.resume:
        if args.trust_ab is not None or args.trust_ba is not None or args.ties: p.error('Resume preserves starts and ties; do not supply replacements.')
        session=Session.load(args.resume)
    else:
        if args.trust_ab is None or args.trust_ba is None: p.error('Supply both independent initial trust values.')
        session=Session(Settings(args.trust_ab,args.trust_ba,args.actor_a,args.actor_b,horizon=args.horizon),
                        json.loads(args.ties.read_text()) if args.ties else [])
    args.out.mkdir(parents=True,exist_ok=True)
    start=time.perf_counter()
    while session.frame<round(session.settings.horizon/session.settings.dt):
        session.step()
        if session.frame%100==0:
            session.save(args.out/'checkpoint.zip')
            print(json.dumps({'frame':session.frame,'time':session.t,'seconds':round(time.perf_counter()-start,2)}),flush=True)
    print(json.dumps(session.export(args.out)),flush=True)

if __name__=='__main__': main()
