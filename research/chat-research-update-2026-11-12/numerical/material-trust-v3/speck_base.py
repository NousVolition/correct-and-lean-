"""Explicit extension: actual advected specks own directed trust and recall lead-up.

The moving attachment and duration-normalized prefix recall are NEW bridge rules.
Sealed physical equations, trust RHS, event evidence and write budget are reused.
The prefix is a software memory state, not encoded in the original fabric bits.
"""
from __future__ import annotations
import base_meter as base
from base_meter import np, plain, json_bytes, sha, atomic_bytes, trust_reading
from dataclasses import dataclass, asdict
from pathlib import Path
import argparse, csv, io, json, time, zipfile
from structural_hug import outcome_score
from breathing import wrap

ROOT=Path(__file__).resolve().parent
VERSION=2
IDENTITIES=json.loads((ROOT/'sources/particle-identities.json').read_text())

@dataclass(frozen=True)
class Settings(base.Settings):
    horizon: float=1.3
    attachment_mode: str='moving'
    history_mode: str='leadup'

    def validate(self):
        super().validate()
        if self.attachment_mode not in ('moving','original'):
            raise ValueError('Unknown attachment mode.')
        if self.history_mode not in ('leadup','endpoint'):
            raise ValueError('Unknown history mode.')

def source_fingerprint():
    return {**base.source_fingerprint(),**{name:sha((ROOT/name).read_bytes()) for name in
            ('sources/particle-identities.json','speck_trust.py','base_meter.py')}}

def prefix_weight(profile,cue,width,field_feedback):
    """Mean relevance of the whole retained prefix, times original event duration."""
    ts=np.asarray(profile['times'],dtype=float)
    features=np.asarray(profile['features'],dtype=float)
    if len(ts)<2 or features.shape!=(len(ts),3) or np.any(np.diff(ts)<0) or ts[-1]<=ts[0]:
        raise ValueError('Invalid retained prefix; no endpoint fallback.')
    diff=features-np.asarray(cue);diff[:,2]*=field_feedback
    kernel=np.exp(-np.sum(diff*diff,axis=1)/(2*width**2))
    integral=np.sum(np.diff(ts)*(kernel[:-1]+kernel[1:])/2)
    return float(profile['duration']*integral/(ts[-1]-ts[0]))

class SpeckSolver(base.ComparisonSolver):
    def __init__(self,config,trail,settings):
        self.settings=settings
        self.seed_points=np.asarray(IDENTITIES['initial_AB'],dtype=float)
        self.leadup=[]
        self.recall_profiles={}
        super().__init__(config,.5,.6,trail)
        self.reference_attach=self.attach.copy()

    def points(self,state):
        return state['observer_X'][-2:] if 'observer_X' in state else self.seed_points

    def refresh_binding(self,state):
        self.attach=self.reference_attach.copy()
        if self.settings.attachment_mode=='moving':
            delta=wrap(self.points(state)[:,None,:]-state['X'][None,:,:])
            h=np.exp(-np.sum(delta*delta,axis=-1)/(2*self.c.source_width**2))*self.V
            mass=h.sum(axis=1,keepdims=True)
            if not np.isfinite(mass).all() or np.any(mass<=0):
                raise FloatingPointError('No finite material support for speck binding.')
            self.attach[[self.settings.actor_a,self.settings.actor_b]]=h/mass

    def initial(self):
        state=super().initial()
        state['observer_X']=np.vstack([state['observer_X'],self.seed_points])
        self.refresh_binding(state)
        return state

    def memory_feature(self,state):
        self.refresh_binding(state)
        return super().memory_feature(state)

    def rhs(self,t,state,details=False):
        self.refresh_binding(state)
        return super().rhs(t,state,details)

    def coupling(self,t,state,M,R,L):
        self.refresh_binding(state)
        return super().coupling(t,state,M,R,L)

    def retrieve(self,t,state):
        self.refresh_binding(state)
        if self.settings.history_mode=='endpoint':
            return super().retrieve(t,state)
        numerator=np.zeros((self.N,self.N,4));exposure=np.zeros((self.N,self.N));old=np.zeros_like(exposure)
        if 'b' not in state:return numerator,exposure,old
        cue=self.memory_feature(state)+.15*np.tanh(state['association'])
        for _,record in self.read_material(state):
            i,j=record['recipient'],record['origin']
            outcome=outcome_score(record['observed'],record['recipient_report'])
            if outcome is None:continue
            profile=self.recall_profiles.get(record['event_id'])
            if profile is None:raise ValueError('Decoded outcome lacks retained lead-up; no fallback.')
            weight=prefix_weight(profile,cue[i,j],self.c.history_width,self.c.field_feedback)
            evidence=np.array([max(outcome,0),max(-outcome,0),record['recognition'],record['authority']])
            numerator[i,j]+=weight*evidence;exposure[i,j]+=weight
            if record['end']<.9:old[i,j]+=weight
        return self.c.read_feedback*numerator/(self.c.history_prior+exposure)[...,None],exposure,old/(self.c.history_prior+exposure)

    def write_event(self,state,record,budget=None):
        # Prepare a prefix but commit it only after the original writer succeeds.
        i,j=record['recipient'],record['origin']
        profile=dict(event_id=record['event_id'],origin=j,recipient=i,
                     duration=record['end']-record['start'],
                     times=[h['time'] for h in self.leadup],
                     features=[h['memory_feature'][i][j] for h in self.leadup])
        if not profile['times'] or abs(profile['times'][-1]-record['end'])>1e-12:
            raise ValueError('Writer must retain the current pre-write sample.')
        prefix_weight(profile,profile['features'][-1],self.c.history_width,self.c.field_feedback)
        out,account=super().write_event(state,record,budget)
        self.recall_profiles[record['event_id']]=json.loads(json_bytes(profile))
        return out,account

def build_solver(settings):
    case=base.preflight.approve('threshold_1')
    with (base.UPSTREAM/'marker-seeds.csv').open(newline='') as f:
        trail=base.Trail(list(csv.DictReader(f)))
    return SpeckSolver(base.Config(**case['config']),trail,settings),case

class Session(base.Session):
    def __init__(self,settings:Settings,ties=None):
        settings.validate();self.settings=settings;self.ties=base.validate_ties(ties or [])
        self.solver,self.case=build_solver(settings)
        self.state=self.solver.initial()
        a,b=settings.actor_a,settings.actor_b
        self.state['relation'][a,b,2]=settings.trust_ab
        self.state['relation'][b,a,2]=settings.trust_ba
        self.solver.utility_baseline=self.solver.utility(self.state,np.zeros((base.N,3)))
        self.frame=0;self.starts={};self.history=[];self.records=[]
        self.solver.leadup=self.history
        self.fingerprint=source_fingerprint()
        self.capture('initial');self.capture_starts()

    def capture(self,phase):
        super().capture(phase)
        self.history[-1].update(memory_feature=plain(self.solver.memory_feature(self.state)),
                               speck_positions=plain(self.solver.points(self.state)))

    def step(self):
        before=len(self.records)
        super().step()
        for record in self.records[before:]:
            record['version']=VERSION
            record['recall_profile']=self.solver.recall_profiles[record['event_id']]
            record['provenance'].update(trust_history_storage='operative software memory extension',
                binding='original seed-12 specks A/B bound to actor slots '+str((self.settings.actor_a,self.settings.actor_b)),
                recall_rule='duration-normalized full-prefix Gaussian relevance')

    def save(self,path):
        data=io.BytesIO()
        np.savez_compressed(data,**self.state,**{'start_'+str(k):v for k,v in self.starts.items()})
        members={'state.npz':data.getvalue(),
                 'memory.json':json_bytes(dict(history=self.history,records=self.records,profiles=self.solver.recall_profiles)),
                 'session.json':json_bytes(dict(version=VERSION,settings=asdict(self.settings),frame=self.frame,
                    ties=self.ties,fingerprint=self.fingerprint,utility_baseline=self.solver.utility_baseline,case=self.case))}
        members['checksums.json']=json_bytes({name:sha(value) for name,value in members.items()})
        packed=io.BytesIO()
        with zipfile.ZipFile(packed,'w',compression=zipfile.ZIP_DEFLATED) as z:
            for name,value in members.items():z.writestr(name,value)
        atomic_bytes(path,packed.getvalue())

    @classmethod
    def load(cls,path):
        with zipfile.ZipFile(path) as z:
            expected=json.loads(z.read('checksums.json'));members={name:z.read(name) for name in expected}
        if any(sha(members[k])!=v for k,v in expected.items()):raise ValueError('Checkpoint checksum failed.')
        meta=json.loads(members['session.json'])
        if meta['version']!=VERSION or meta['fingerprint']!=source_fingerprint():raise ValueError('Checkpoint source/version mismatch.')
        obj=cls(Settings(**meta['settings']),meta['ties'])
        with np.load(io.BytesIO(members['state.npz']),allow_pickle=False) as z:
            obj.state={k:z[k].copy() for k in z.files if not k.startswith('start_')}
            obj.starts={int(k[6:]):z[k].copy() for k in z.files if k.startswith('start_')}
        memory=json.loads(members['memory.json'])
        obj.history=memory['history'];obj.records=memory['records'];obj.frame=meta['frame'];obj.case=meta['case']
        obj.solver.leadup=obj.history
        obj.solver.recall_profiles={int(k):v for k,v in memory['profiles'].items()}
        obj.solver.utility_baseline=meta['utility_baseline']
        if not obj.history or obj.history[-1]['time']!=obj.t:raise ValueError('Memory and state clocks disagree.')
        if not np.array_equal(obj.history[-1]['trust'],obj.state['relation'][...,2]):raise ValueError('Memory and state trust disagree.')
        if not np.array_equal(obj.history[-1]['speck_positions'],obj.solver.points(obj.state)):raise ValueError('Speck identity/state mismatch.')
        obj.solver.retrieve(obj.t,obj.state)  # Require operative profiles for all scored outcomes.
        return obj

    def export(self,folder):
        summary=super().export(folder);folder=Path(folder)
        summary.update(version=VERSION,identities=IDENTITIES,final_positions=plain(self.solver.points(self.state)),
            scope='Full threshold-one physical solver with explicitly new moving-speck binding and operative prefix recall.',
            history_features_used=['pair context','pair material strain'],
            physical_payload_unchanged=True,leadup_storage='software; not the original fabric code')
        view=json.loads((folder/'view.json').read_text())
        view['summary']=summary
        for row,full in zip(view['history'],self.history):row['positions']=full['speck_positions']
        atomic_bytes(folder/'summary.json',json_bytes(summary));atomic_bytes(folder/'view.json',json_bytes(view))
        return summary

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--trust-ab',type=float);p.add_argument('--trust-ba',type=float)
    p.add_argument('--out',type=Path,required=True);p.add_argument('--resume',type=Path)
    p.add_argument('--horizon',type=float,default=1.3)
    p.add_argument('--attachment-mode',choices=['moving','original'],default='moving')
    p.add_argument('--history-mode',choices=['leadup','endpoint'],default='leadup')
    args=p.parse_args()
    if args.out.exists() and any(args.out.iterdir()):p.error('Use an empty output directory.')
    if args.resume:
        if args.trust_ab is not None or args.trust_ba is not None:p.error('Resume preserves independent starts.')
        session=Session.load(args.resume)
    else:
        if args.trust_ab is None or args.trust_ba is None:p.error('Specify both independent starts.')
        session=Session(Settings(args.trust_ab,args.trust_ba,horizon=args.horizon,
                         attachment_mode=args.attachment_mode,history_mode=args.history_mode))
    args.out.mkdir(parents=True,exist_ok=True);start=time.perf_counter()
    while session.frame<round(session.settings.horizon/session.settings.dt):
        session.step()
        if session.frame%100==0:
            session.save(args.out/'checkpoint.zip')
            if session.frame==600:session.save(args.out/'at-1.2.zip')
            print(json.dumps(dict(frame=session.frame,time=session.t,seconds=round(time.perf_counter()-start,2))),flush=True)
    summary=session.export(args.out)
    print(json.dumps({k:summary[k] for k in ('frame','events','initial','final','final_positions')}),flush=True)

if __name__=='__main__':main()
