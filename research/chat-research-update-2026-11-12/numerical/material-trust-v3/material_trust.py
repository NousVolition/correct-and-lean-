"""Finite material lead-up journal; recall has no software-history dependency.

New declaration: 801 fixed material sample slots, one per accepted time 0..1.6.
Original event slots, cell equations, probe, quantization and work laws are reused.
The added cells retain original per-cell weights, so their physical cost is added.
"""
from __future__ import annotations
import speck_base as speck
from speck_base import base, np, plain, json_bytes, sha, atomic_bytes, trust_reading, prefix_weight
from structural_hug import Fabric, Solver as StructuralSolver, MemoryReadError, CapacityError, outcome_score
from continuum import strain_magnitude
from dataclasses import dataclass,asdict
from pathlib import Path
import argparse,csv,io,json,struct,time,zipfile,zlib

ROOT=Path(__file__).resolve().parent
VERSION=3
ROWS=801
ROW_SHORTS=31
ROW_BYTES=2*ROW_SHORTS+4
ROW_MAGIC=1731

@dataclass(frozen=True)
class Settings(speck.Settings):
    def validate(self):
        super().validate()
        if self.history_mode!='leadup':raise ValueError('This declaration reads the material lead-up only.')

def source_fingerprint():
    return {**base.source_fingerprint(),**{name:sha((ROOT/name).read_bytes()) for name in
        ('base_meter.py','speck_base.py','material_trust.py','DECLARATION.json','sources/particle-identities.json')}}

class MaterialFabric(Fabric):
    def __init__(self,config,X,V):
        super().__init__(config,X,V)
        self.event_size=self.size
        self.journal_bits=ROWS*ROW_BYTES*8
        self.original_counts=np.bincount(self.point,minlength=self.P)
        self.size+=self.journal_bits
        index=np.arange(self.size);self.point=index%self.P;self.axis=(index//self.P)%3
        # Retain original cell weights. Added storage is not made cost-free by renormalizing.
        self.local_weight=1/self.original_counts[self.point]
        self.weight=self.V[self.point]*self.local_weight

    def probe(self,F,b,noise=None):
        # Exactly the original derivative traction; avoid calculating unused W and dW/db.
        e=self.local_strain(F);q=self.c.probe_strain
        loads=np.stack([e-q,e+q])
        tractions=self.c.micro_k*(loads-b)
        if noise is not None:tractions=tractions+np.asarray(noise)
        return loads,tractions

    def decode_probe(self,loads,tractions):
        bits=self.bits_from_probe(loads,tractions)
        packed=np.packbits(bits[:self.event_size],bitorder='little').reshape(self.c.capacity,self.byte_count)
        return [(slot,r) for slot,row in enumerate(packed) if (r:=self.unpack(row.tobytes())) is not None]

    def journal_from_bits(self,bits):
        packed=np.packbits(bits[self.event_size:],bitorder='little').reshape(ROWS,ROW_BYTES)
        used=np.any(packed!=0,axis=1);count=int(used.sum())
        if not np.all(used[:count]) or np.any(used[count:]):raise MemoryReadError('Noncontiguous material journal.')
        rows=np.empty((count,ROW_SHORTS),dtype='<i2')
        for k,row in enumerate(packed[:count]):
            body=row[:-4].tobytes()
            if zlib.crc32(body)!=struct.unpack('<I',row[-4:].tobytes())[0]:
                raise MemoryReadError('Lead-up checksum failed; no archive fallback.')
            rows[k]=np.frombuffer(body,dtype='<i2')
        if count:
            if not np.all(rows[:,0]==ROW_MAGIC) or not np.array_equal(rows[:,1],2*np.arange(count)):
                raise MemoryReadError('Lead-up code or sample clock mismatch.')
            if not np.all(rows[:,2:4]==rows[0,2:4]) or not (0<=rows[0,2]<6 and 0<=rows[0,3]<6 and rows[0,2]!=rows[0,3]):
                raise MemoryReadError('Lead-up actor identity mismatch.')
            if not np.all(rows[:,4]==12):raise MemoryReadError('Lead-up speck seed identity mismatch.')
        q=self.c.feature_quantum
        return dict(times=rows[:,1].astype(float)*self.c.clock_quantum,
            actor_ids=rows[0,2:4].astype(int).tolist() if count else [],seed=12,
            actor_features=rows[:,5:23].reshape(count,6,3).astype(float)*q,
            trust=rows[:,23:25].astype(float)*q,
            positions=rows[:,25:31].reshape(count,2,3).astype(float)*q)

    def read_bundle(self,F,b):
        loads,tractions=self.probe(F,b)
        bits=self.bits_from_probe(loads,tractions)
        packed=np.packbits(bits[:self.event_size],bitorder='little').reshape(self.c.capacity,self.byte_count)
        events=[(slot,r) for slot,row in enumerate(packed) if (r:=self.unpack(row.tobytes())) is not None]
        return events,self.journal_from_bits(bits)

    def encode_sample(self,frame,actor_ids,actor_features,trust,positions):
        if not isinstance(frame,int) or not 0<=frame<ROWS:raise CapacityError('Material journal capacity exhausted; no overwrite.')
        a,b=actor_ids
        if not (0<=a<6 and 0<=b<6 and a!=b):raise ValueError('Invalid sample actor IDs.')
        values=np.r_[np.asarray(actor_features).ravel(),trust,np.asarray(positions).ravel()]
        if values.shape!=(26,):raise ValueError('Lead-up sample schema mismatch.')
        data=np.r_[np.array([ROW_MAGIC,2*frame,a,b,12],dtype='<i2'),self.quant(values,self.c.feature_quantum)].astype('<i2')
        body=data.tobytes()
        return body+struct.pack('<I',zlib.crc32(body))

    def prepare_sample(self,F,b,frame,payload,budget):
        _,journal=self.read_bundle(F,b)
        if frame!=len(journal['times']):raise ValueError('Material lead-up must append exactly once per accepted time.')
        if not 0<=frame<ROWS:raise CapacityError('Material journal capacity exhausted.')
        if len(payload)!=ROW_BYTES:raise ValueError('Lead-up payload size mismatch.')
        sl=slice(self.event_size+frame*ROW_BYTES*8,self.event_size+(frame+1)*ROW_BYTES*8)
        bits=np.unpackbits(np.frombuffer(payload,dtype=np.uint8),bitorder='little')
        target=self.c.rest_amplitude*(2*bits.astype(float)-1)
        return self.prepare_cells(F,b,sl,target,budget)

    def prepare_cells(self,F,b,sl,target,budget):
        """Original stroke polynomial, restricted to changed cells (others have delta=0)."""
        c=self.c;a=c.rest_amplitude;old=b[sl];d=target-old
        points=self.point[sl];axes=self.axis[sl];weights=self.weight[sl];local=self.local_weight[sl]
        strain=(np.sum(F*F,axis=1)-1)/2;e=strain[points,axes]
        heat_cell=c.stroke_drag*d*d/c.stroke_duration
        heat=np.bincount(points,weights=local*heat_cell,minlength=self.P)
        stored=float(np.dot(weights,self.energy_force(e,target)[0]-self.energy_force(e,old)[0]))
        dissipation=float(np.dot(self.V,heat));work=stored+dissipation
        coefficients=np.array([0.,
            np.dot(weights,(-c.micro_k*(e-old)+c.well_height*old/a**2*((old/a)**2-1))*d)+dissipation,
            np.dot(weights,(.5*c.micro_k+c.well_height*(3*old*old-a*a)/(2*a**4))*d*d),
            np.dot(weights,c.well_height*old*d**3/a**4),
            np.dot(weights,c.well_height*d**4/(4*a**4))])
        roots=np.polynomial.polynomial.polyroots(np.arange(1,5)*coefficients[1:])
        candidates=[0.,1.]+[float(z.real) for z in roots if abs(z.imag)<1e-10 and 0<z.real<1]
        peak=max(float(np.polynomial.polynomial.polyval(x,coefficients)) for x in candidates)
        required=float(np.maximum(coefficients,0).sum())
        if not np.isfinite(budget) or budget<required or work<0:raise ValueError('Insufficient lead-up writing work budget.')
        out=b.copy();out[sl]=target
        return out,heat,dict(work=work,stored=stored,heat=dissipation,peak_work=peak,required_budget=required)

class MaterialSolver(speck.SpeckSolver):
    def __init__(self,config,trail,settings):
        super().__init__(config,trail,settings)
        self.fabric=MaterialFabric(config,self.X0,self.V)
        # Explicitly remove the v2 software memory attributes.
        del self.leadup;del self.recall_profiles

    def rhs(self,t,state,details=False):
        # Reuse one physical probe only during this immutable RHS evaluation.
        # Nothing survives to a different state, write, read, or solver stage.
        self._probe_state=state;self._probe_records=None
        try:return super().rhs(t,state,details)
        finally:del self._probe_state;del self._probe_records

    def read_material(self,state):
        in_scope=getattr(self,'_probe_state',None) is state
        if in_scope and self._probe_records is not None:return self._probe_records
        events,journal=self.fabric.read_bundle(state['F'],state['b'])
        result=[]
        for slot,event in events:
            mask=journal['times']<=event['end']+1e-12
            times=journal['times'][mask]
            if len(times)<2 or abs(times[-1]-event['end'])>1e-12:
                raise MemoryReadError('Event lacks a complete material lead-up prefix.')
            i,j=event['recipient'],event['origin']
            af=journal['actor_features'][mask]
            profile=dict(times=times,features=.5*(af[:,i]+af[:,j]),duration=event['end']-event['start'])
            result.append((slot,{**event,'leadup':dict(profile=profile,trust=journal['trust'][mask],
                positions=journal['positions'][mask],actor_ids=journal['actor_ids'],seed=journal['seed'])}))
        if in_scope:self._probe_records=result
        return result

    def retrieve(self,t,state):
        self.refresh_binding(state)
        numerator=np.zeros((self.N,self.N,4));exposure=np.zeros((self.N,self.N));old=np.zeros_like(exposure)
        if 'b' not in state:return numerator,exposure,old
        cue=self.memory_feature(state)+.15*np.tanh(state['association'])
        for _,r in self.read_material(state):
            i,j=r['recipient'],r['origin'];outcome=outcome_score(r['observed'],r['recipient_report'])
            if outcome is None:continue
            weight=prefix_weight(r['leadup']['profile'],cue[i,j],self.c.history_width,self.c.field_feedback)
            evidence=np.array([max(outcome,0),max(-outcome,0),r['recognition'],r['authority']])
            numerator[i,j]+=weight*evidence;exposure[i,j]+=weight
            if r['end']<.9:old[i,j]+=weight
        return self.c.read_feedback*numerator/(self.c.history_prior+exposure)[...,None],exposure,old/(self.c.history_prior+exposure)

    def sample_values(self,state):
        self.refresh_binding(state)
        af=np.c_[state['context'],np.tanh(self.attach@strain_magnitude(state['F'])/.12)]
        a,b=self.settings.actor_a,self.settings.actor_b
        return af,[state['relation'][a,b,2],state['relation'][b,a,2]],self.points(state)

    def write_sample(self,state,frame,budget=None):
        values=self.sample_values(state)
        payload=self.fabric.encode_sample(frame,(self.settings.actor_a,self.settings.actor_b),*values)
        target,heat,account=self.fabric.prepare_sample(state['F'],state['b'],frame,payload,
            self.c.write_budget if budget is None else budget)
        out={k:v.copy() for k,v in state.items()};out['b']=target
        R=self.matrices(state['X'])[1]
        heat_grid=(R.T@(self.V*heat)/self.dv).reshape(self.n,self.n,self.n)
        out['g'][...,4]+=self.filter(heat_grid);out['write_work']+=account['work']
        return out,{**account,'frame':frame,'kind':'material_leadup_sample'}

    def write_event(self,state,record,budget=None):
        # Require the physical prefix before allowing the original outcome write.
        _,journal=self.fabric.read_bundle(state['F'],state['b'])
        if not len(journal['times']) or abs(journal['times'][-1]-record['end'])>1e-12:
            raise MemoryReadError('Write requires the material prefix through the event end.')
        return StructuralSolver.write_event(self,state,record,budget)

def build_solver(settings):
    case=base.preflight.approve('threshold_1')
    with (base.UPSTREAM/'marker-seeds.csv').open(newline='') as f:trail=base.Trail(list(csv.DictReader(f)))
    return MaterialSolver(base.Config(**case['config']),trail,settings),case

class Session(base.Session):
    def __init__(self,settings:Settings):
        settings.validate();self.settings=settings;self.ties=[]
        self.solver,self.case=build_solver(settings);self.state=self.solver.initial()
        a,b=settings.actor_a,settings.actor_b
        self.state['relation'][a,b,2]=settings.trust_ab;self.state['relation'][b,a,2]=settings.trust_ba
        self.state,account=self.solver.write_sample(self.state,0)
        self.solver.utility_baseline=self.solver.utility(self.state,np.zeros((6,3)))
        self.frame=0;self.starts={};self.history=[];self.records=[];self.write_accounts=[account]
        self.fingerprint=source_fingerprint();self.capture('initial');self.capture_starts()

    def capture(self,phase):
        self.solver._probe_state=self.state;self.solver._probe_records=None
        try:
            super().capture(phase)
            self.history[-1].update(memory_feature=plain(self.solver.memory_feature(self.state)),
                speck_positions=plain(self.solver.points(self.state)),write_work=float(self.state['write_work']))
        finally:del self.solver._probe_state;del self.solver._probe_records

    def step(self):
        if self.frame>=round(self.settings.horizon/self.settings.dt):raise ValueError('Horizon complete.')
        self.state=self.solver.step(self.t,self.state,self.settings.dt);self.frame+=1
        if not all(np.isfinite(v).all() for v in self.state.values()):raise FloatingPointError('Nonfinite state.')
        self.state,account=self.solver.write_sample(self.state,self.frame);self.write_accounts.append(account)
        events=[e for e in self.case['events'] if round(e['end']/self.settings.dt)==self.frame]
        self.capture('before_write' if events else 'flow')
        for event in events:
            raw=self.solver.make_event(self.state,self.starts[event['event_id']],event)
            before=self.state['relation'].copy()
            self.state,work=self.solver.write_event(self.state,raw)
            np.testing.assert_array_equal(self.state['relation'],before)
            self.write_accounts.append({**plain(work),'frame':self.frame,'kind':'event','event_id':event['event_id']})
            self.records.append(self.read_trust_memory(event['event_id']))
            del self.starts[event['event_id']];self.capture('after_write')
        self.capture_starts()

    def read_trust_memory(self,event_id):
        record=next(r for _,r in self.solver.read_material(self.state) if r['event_id']==event_id)
        return json.loads(json_bytes(record))

    def state_bytes(self):
        packed=io.BytesIO()
        np.savez_compressed(packed,**self.state,**{'start_'+str(k):v for k,v in self.starts.items()},
            aux_utility_baseline=np.asarray(self.solver.utility_baseline))
        return packed.getvalue()

    def restore_body(self,data):
        with np.load(io.BytesIO(data),allow_pickle=False) as z:
            self.state={k:z[k].copy() for k in z.files if not k.startswith(('start_','aux_'))}
            self.starts={int(k[6:]):z[k].copy() for k in z.files if k.startswith('start_')}
            self.solver.utility_baseline=float(z['aux_utility_baseline'])
        _,journal=self.solver.fabric.read_bundle(self.state['F'],self.state['b'])
        self.frame=len(journal['times'])-1
        if self.frame<0 or journal['actor_ids']!=[self.settings.actor_a,self.settings.actor_b]:raise MemoryReadError('Body clock/identity mismatch.')
        self.history=[];self.records=[];self.write_accounts=[]
        self.solver.read_material(self.state)  # No audit history used in this check.

    @classmethod
    def from_body(cls,path,settings):
        obj=cls(settings);obj.restore_body(Path(path).read_bytes());obj.capture('restored_from_material');return obj

    def save(self,path):
        members={'state.npz':self.state_bytes(),
            'session.json':json_bytes(dict(version=VERSION,settings=asdict(self.settings),fingerprint=self.fingerprint,case=self.case)),
            'audit.json':json_bytes(dict(history=self.history,records=self.records,write_accounts=self.write_accounts))}
        members['checksums.json']=json_bytes({k:sha(v) for k,v in members.items()})
        data=io.BytesIO()
        with zipfile.ZipFile(data,'w',compression=zipfile.ZIP_DEFLATED) as z:
            for k,v in members.items():z.writestr(k,v)
        atomic_bytes(path,data.getvalue())

    @classmethod
    def load(cls,path):
        with zipfile.ZipFile(path) as z:
            expected=json.loads(z.read('checksums.json'));members={k:z.read(k) for k in expected}
        if any(sha(members[k])!=v for k,v in expected.items()):raise ValueError('Checkpoint checksum failed.')
        meta=json.loads(members['session.json'])
        if meta['version']!=VERSION or meta['fingerprint']!=source_fingerprint():raise ValueError('Checkpoint version/source mismatch.')
        obj=cls(Settings(**meta['settings']));obj.case=meta['case'];obj.restore_body(members['state.npz'])
        audit=json.loads(members['audit.json'])
        obj.history=audit['history'];obj.records=audit['records'];obj.write_accounts=audit['write_accounts']
        return obj

    def export(self,folder):
        folder=Path(folder);folder.mkdir(parents=True,exist_ok=True)
        self.records=[self.read_trust_memory(r['event_id']) for _,r in self.solver.read_material(self.state)]
        summary=super().export(folder)
        atomic_bytes(folder/'body.npz',self.state_bytes())
        minimal=io.BytesIO();np.savez_compressed(minimal,F=self.state['F'],b=self.state['b'])
        atomic_bytes(folder/'material-only.npz',minimal.getvalue())
        _,journal=self.solver.fabric.read_bundle(self.state['F'],self.state['b'])
        atomic_bytes(folder/'decoded-material-leadup.json',json_bytes(journal))
        atomic_bytes(folder/'write-accounts.json',json_bytes(self.write_accounts))
        summary.update(version=VERSION,scope='Full coupled solver with moving speck trust and a finite, mechanically read material lead-up journal.',
            leadup_storage='b: traction-probed material journal; audit files are not used by recall or writing',
            material_samples=len(journal['times']),journal_capacity=ROWS,journal_row_bytes=ROW_BYTES,
            original_event_cells=self.solver.fabric.event_size,added_journal_cells=self.solver.fabric.journal_bits,
            total_fabric_cells=self.solver.fabric.size,write_work=float(self.state['write_work']),
            final_positions=plain(self.solver.points(self.state)),identities=speck.IDENTITIES)
        view=json.loads((folder/'view.json').read_text());view['summary']=summary
        for row,h in zip(view['history'],self.history):row.update(positions=h['speck_positions'],write_work=h['write_work'])
        atomic_bytes(folder/'summary.json',json_bytes(summary));atomic_bytes(folder/'view.json',json_bytes(view));return summary

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--trust-ab',type=float);p.add_argument('--trust-ba',type=float);p.add_argument('--horizon',type=float,default=1.3)
    p.add_argument('--out',required=True,type=Path);p.add_argument('--resume',type=Path)
    args=p.parse_args()
    if args.out.exists() and any(args.out.iterdir()):p.error('Use an empty output folder.')
    if args.resume:
        if args.trust_ab is not None or args.trust_ba is not None:p.error('Resume preserves starts.')
        s=Session.load(args.resume)
    else:
        if args.trust_ab is None or args.trust_ba is None:p.error('Choose both independent trust starts.')
        s=Session(Settings(args.trust_ab,args.trust_ba,horizon=args.horizon))
    args.out.mkdir(parents=True,exist_ok=True);start=time.perf_counter()
    while s.frame<round(s.settings.horizon/s.settings.dt):
        s.step()
        if s.frame%100==0:
            s.save(args.out/'checkpoint.zip')
            if s.frame==600:atomic_bytes(args.out/'body-at-1.2.npz',s.state_bytes())
            print(json.dumps(dict(frame=s.frame,time=s.t,seconds=round(time.perf_counter()-start,2))),flush=True)
    summary=s.export(args.out);print(json.dumps({k:summary[k] for k in ('frame','events','final','material_samples','write_work')}),flush=True)

if __name__=='__main__':main()
