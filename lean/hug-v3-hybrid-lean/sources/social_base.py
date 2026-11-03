"""Declared joint social/history/continuum candidate, not an empirical social law.

Source definitions and every added closure are specified in MODEL.md.
No physical half gate, fixed social partner, one-hot response, or archive decay.
"""
from dataclasses import dataclass, asdict
from pathlib import Path
import json, time, hashlib
import numpy as np
from scipy.special import expit, softmax
from continuum import Config as FieldConfig, Solver as FieldSolver, strain_magnitude

ROOT=Path(__file__).resolve().parent
MODES=['imitation','cooperation','rivalry','refusal','coercion','withdrawal','repair']
NAMES=['Performer','Office holder','Host','Collaborator','Visitor','Observer']

@dataclass
class Config(FieldConfig):
    n:int=24
    dt:float=.005
    end:float=3.
    radial:int=3
    polar:int=4
    azimuth:int=8
    source_width:float=.075
    response_rate:float=4.
    map_rate:float=2.
    history_width:float=.32
    history_prior:float=.12
    memory_feedback:float=1.
    map_feedback:float=1.
    response_feedback:float=1.
    field_feedback:float=1.
    social_source:float=1.
    social_distribution:float=1.
    restructure:float=1.
    disabled_mode:int=-1
    scenario:str='rooms'
    encounter_width:float=.06

def offdiag(a):
    a=a.copy(); a[np.arange(len(a)),np.arange(len(a))]=0.; return a

class Solver(FieldSolver):
    def __init__(self,c):
        super().__init__(c)
        self.N=6; self.mask_social=1-np.eye(self.N)
        # Synthetic role resources, not coefficients for race/health/class.
        self.recognition=np.array([[.95,.7],[.25,.85],[.6,.75],[.65,.3],[.2,.2],[.4,.4]])
        self.authority=np.array([[.7,.15],[.2,.98],[.75,.8],[.4,.25],[.1,.2],[.25,.35]])
        self.intent=np.array([[.8,.1],[-.5,.65],[.15,.6],[.65,-.35],[-.5,-.45],[-.1,.2]])
        self.home=np.array([[.9,.1],[.15,.85],[.5,.5],[.8,.2],[.4,.6],[.6,.4]])
        # Explicit interpretation: agents observe/actuate material patches.
        # They are not literal people embedded in clay. This map has no status gate.
        ang=np.arange(self.N)*2*np.pi/self.N
        centers=np.c_[.13*np.cos(ang),.1*np.sin(ang),.08*np.cos(2*ang)]
        H=np.exp(-np.sum((centers[:,None,:]-self.X0[None,:,:])**2,axis=-1)/(2*c.source_width**2))*self.V
        self.attach=H/H.sum(axis=1,keepdims=True)
        self.records=[]; self.record_times=[]; self._archive_cache=None
        self.utility_baseline=0.
        if not 0<c.dt<=0.125:
            raise ValueError('dt must be <= 1/8 for the declared two-context SSP invariant bound')
        if not 0<=c.response_feedback<=1:
            raise ValueError('response_feedback must be in [0,1] for the declared invariant bound')
        if c.social_distribution not in (0.,1.):
            raise ValueError('social_distribution is a declared path control: 0 or 1')

    def initial(self):
        s=super().initial(); N=self.N
        s.update(expression=self.intent.copy(),context=self.home.copy(),norm=.65*self.intent.copy(),
                 logradius=np.full((N,N),np.log(.72)),relation=np.zeros((N,N,3)),
                 responses=np.zeros((N,N,7)),association=np.zeros((N,N,3)))
        s['relation'][...,0]=self.home@self.recognition.T
        s['relation'][...,1]=self.home@self.authority.T
        s['relation'][...,2]=.5
        s['relation']=offdiag(s['relation'])
        self.utility_baseline=self.utility(s,np.zeros((N,3)))
        initial_intensity=np.mean(s['relation'][...,0],axis=0)
        self.frozen_source_weights=self.attach.T@softmax(initial_intensity)
        self.frozen_source_weights/=self.frozen_source_weights.sum()
        self.append_record(0.,s)
        return s

    def memory_feature(self,s):
        ctx=s['context'];strain=np.tanh(self.attach@strain_magnitude(s['F'])/.12)
        return np.concatenate([.5*(ctx[:,None,:]+ctx[None,:,:]),.5*(strain[:,None]+strain[None,:])[...,None]],axis=-1)

    def episode(self,s):
        r=s['responses']; ctx=s['context']; B=s['relation']
        feature=self.memory_feature(s)
        harm=(r[...,2]+r[...,3]+r[...,4])/3
        help_=(r[...,1]+r[...,6])/2
        outcome=np.stack([help_,harm,B[...,0],B[...,1]],-1)
        return dict(feature=feature.copy(),outcome=outcome.copy(),expression=s['expression'].copy(),
                    relation=B.copy(),responses=r.copy(),association=s['association'].copy(),
                    norm=s['norm'].copy(),logradius=s['logradius'].copy(),
                    X=s['X'].copy(),F=s['F'].copy(),A=s['A'].copy(),
                    field_totals=np.array([s['g'][...,3].mean(),s['g'][...,4].mean()]),step_source_rate_pair=np.zeros(2))

    def append_record(self,t,s,stage_source_rate=None):
        if self.record_times and t<=self.record_times[-1]:raise ValueError('history must append in time order')
        ep=self.episode(s)
        if stage_source_rate is not None:ep['step_source_rate_pair']=np.array(stage_source_rate)
        self.record_times.append(float(t)); self.records.append(ep); self._archive_cache=None

    def retrieve(self,t,s):
        N=self.N
        if len(self.record_times)==0:return np.zeros((N,N,4)),np.zeros((N,N)),np.zeros((N,N))
        if self._archive_cache is None:
            self._archive_cache=(np.array(self.record_times),np.array([r['feature'] for r in self.records]),
                                 np.array([r['outcome'] for r in self.records]))
        ts,feat,out=self._archive_cache
        if t>ts[-1]+1e-12:
            ep=self.episode(s);ts=np.r_[ts,t];feat=np.concatenate([feat,ep['feature'][None]])
            out=np.concatenate([out,ep['outcome'][None]])
        cue=self.memory_feature(s)+.15*np.tanh(s['association'])
        diff=feat-cue[None];diff[...,2:]*=self.c.field_feedback
        kernel=np.exp(-np.sum(diff**2,-1)/(2*self.c.history_width**2))
        # Trapezoidal Volterra integral. No record truncation, time decay or floor.
        if len(ts)<2:return np.zeros((N,N,4)),np.zeros((N,N)),np.zeros((N,N))
        weights=np.zeros_like(ts); d=np.diff(ts); weights[:-1]+=d/2;weights[1:]+=d/2
        exposure=np.einsum('h,hij->ij',weights,kernel)
        retrieved=np.einsum('h,hij,hijk->ijk',weights,kernel,out)/(self.c.history_prior+exposure)[...,None]
        old=np.einsum('h,hij->ij',weights*(ts<.9),kernel)/(self.c.history_prior+exposure)
        return offdiag(retrieved),exposure,old

    def margins(self,s,actions=None):
        a=s['expression'] if actions is None else np.asarray(actions)
        return np.exp(s['logradius'])-np.linalg.norm(a[None,:,:]-s['norm'][:,None,:],axis=-1)

    def room(self,t):
        if self.c.scenario=='steady':return np.array([.85,.15])
        w=self.c.encounter_width
        middle=expit((t-1.)/w)-expit((t-2.)/w)
        return np.array([.85-.7*middle,.15+.7*middle])

    def utility(self,s,obs):
        r=s['responses']*self.c.response_feedback
        social=np.sum((r[...,1]+r[...,6]-r[...,2]-r[...,4])*self.mask_social)/(self.N*(self.N-1))
        meaning=np.mean(np.sum((s['expression']-self.intent)**2,axis=-1))
        reception=np.sum(np.tanh(self.margins(s)/.4)*self.mask_social)/(self.N*(self.N-1))
        return .35*social-.2*meaning+.2*reception+.08*np.mean(np.tanh(obs[:,0]))

    def social_rhs(self,t,s,obs):
        c=self.c; N=self.N; r=s['responses']; e=s['expression']; B=s['relation']
        mem,exposure,old=self.retrieve(t,s)
        usedmem=c.memory_feedback*mem
        # Recognition history (index 2) is retrieved/audited but deliberately
        # unused: no source-supported evolution law has been defined for it.
        usedmem[...,3]*=c.map_feedback
        usedB=c.map_feedback*B+(1-c.map_feedback)*np.array([.5,.5,.5])[None,None,:]*self.mask_social[...,None]
        rr=c.response_feedback*r
        help_,harm=usedmem[...,0],usedmem[...,1]
        recognition,authority,trust=np.moveaxis(usedB,-1,0)
        physical=c.field_feedback*obs
        margin=self.margins(s); permit=expit(margin/.18)
        delta=e[None,:,:]-e[:,None,:]; dist2=np.sum(delta*delta,-1)
        agreement=np.exp(-dist2/.6)
        context_similarity=np.exp(-np.sum((s['context'][:,None]-s['context'][None,:])**2,-1)/.35)
        # Encounters can weaken but are never assigned a physical-half ban.
        attention=(.15+.85*context_similarity)*(.3+.7*recognition)*(1-.6*rr[...,5])
        attention*=self.mask_social
        incoming_coercion=rr[...,4].T
        targets=np.stack([
            expit(-.7+1.8*recognition+.7*trust+help_-harm+.4*permit-.7*rr[...,3]),
            expit(-.9+1.7*trust+agreement+help_-harm+.6*rr[...,6]-.5*rr[...,2]),
            expit(-1.4+recognition+1.1*(1-trust)+.8*(1-agreement)+harm-help_-.6*rr[...,6]),
            expit(-1.4+incoming_coercion+harm+(1-permit)+.3*physical[:,1,None]-.5*rr[...,6]),
            expit(-1.7+1.8*authority.T+.9*(1-permit)+.7*rr[...,2]-.8*trust),
            expit(-1.8+harm+incoming_coercion+.5*(1-permit)+.35*physical[:,1,None]-help_),
            expit(-1.2+trust+harm*trust+.6*rr[...,1]-.7*rr[...,2]+.2*physical[:,2,None])],-1)*attention[...,None]
        if c.disabled_mode>=0:targets[...,c.disabled_mode]=0.
        dr=c.response_rate*(targets-r)
        # Simultaneous responses act on expression, norms, relations and cues.
        bounded_delta=delta/np.sqrt(1+dist2)[...,None]
        pull=rr[...,0]+.65*rr[...,1]+.8*rr[...,6]-.6*rr[...,2]
        de=.8*(self.intent-e)+np.sum(pull[...,None]*bounded_delta,axis=1)/(N-1)
        de+=np.sum(incoming_coercion[...,None]*(s['norm'][None,:,:]-e[:,None,:]),axis=1)/(N-1)
        de+=np.mean(rr[...,3]+rr[...,5],axis=1)[:,None]*(self.intent-e)
        proof=np.mean(usedB,axis=0)[None,:,:]
        recbase=s['context']@self.recognition.T
        authbase=s['context']@self.authority.T
        targetB=np.stack([
            expit(3*(recbase-.5)+.7*proof[...,0]+.8*(rr[...,0]+rr[...,2])+help_-.5*harm),
            expit(3*(authbase-.5)+.7*proof[...,1]+.8*incoming_coercion-.8*rr[...,3]+.5*usedmem[...,3]),
            expit(1.4*agreement-1+1.5*help_-1.5*harm+rr[...,1]+rr[...,6]-rr[...,2]-incoming_coercion)],-1)
        dB=c.map_rate*(offdiag(targetB)-B)
        targetctx=.6*self.home+.4*self.room(t)[None,:]
        dc=2*(targetctx-s['context'])
        # Added v2 closure: approach mixes contexts; withdrawal redistributes
        # existing context weights away from the other context. The latter is
        # a replicator term: sum zero and vanishes componentwise at c_i,k=0.
        ctx=s['context'];difference=ctx[:,None,:]-ctx[None,:,:]
        approach=rr[...,0]+rr[...,1]
        contrast=difference-np.sum(ctx[:,None,:]*difference,axis=-1,keepdims=True)
        repel=2*ctx[:,None,:]*contrast
        dc+=np.sum(-approach[...,None]*difference+rr[...,5,None]*repel,axis=1)/(N-1)
        dn=.7*(.6*self.intent+.4*e-s['norm'])
        dn+=np.sum((rr[...,1]+rr[...,6]-rr[...,4])[...,None]*(e[None,:]-s['norm'][:,None]),axis=1)/(N-1)
        targetradius=.55+.45*expit(1.4*trust+help_-harm+rr[...,6]-rr[...,4]-.3*physical[:,0,None])
        dl=1.8*(np.log(targetradius)-s['logradius'])
        strain_difference=physical[None,:,1]-physical[:,None,1]
        association_direction=np.concatenate([delta,strain_difference[...,None]],axis=-1)
        assoc_target=2*(help_-harm)[...,None]*np.tanh(association_direction)
        da=c.restructure*1.5*(assoc_target-s['association'])
        utility=self.input(t)+c.social_source*.8*(self.utility(s,physical)-self.utility_baseline)
        intensity=np.mean(rr.sum(-1),axis=1)+np.mean(usedB[...,0],axis=0)
        actuator=softmax(intensity)
        weights=self.attach.T@actuator;weights/=weights.sum()
        if not c.social_distribution:weights=self.frozen_source_weights.copy()
        ds=dict(expression=de,context=dc,norm=dn,logradius=dl,relation=dB,responses=dr,association=da)
        detail=dict(memory=mem,exposure=exposure,old_retrieval=old,margin=margin,attention=attention,
                    targets=targets,observations=obs,room=self.room(t),utility=utility,source_weights=weights)
        return detail,ds

    def coupling(self,t,s,M,R,L):
        # Every RK/Heun stage sees current field and material state.
        C=self.attach@(R@s['g'][...,3].ravel())/.08
        strain=self.attach@strain_magnitude(s['F'])/.12
        theta=self.attach@(R@s['g'][...,4].ravel())/.03
        obs=np.stack([np.tanh(C),np.tanh(strain),np.tanh(theta)],-1)
        return self.social_rhs(t,s,obs)

    def step(self,t,s,dt):
        # Explicit trapezoidal integration, including within-step history.
        k1=self.rhs(t,s); pred={k:s[k]+dt*k1[k] for k in s}
        k2=self.rhs(t+dt,pred)
        out={k:s[k]+dt/2*(k1[k]+k2[k]) for k in s}
        self.append_record(t+dt,out,[float(k1['A']),float(k2['A'])])
        return out

def run(c,name,save=True):
    solver=Solver(c);s=solver.initial();steps=round(c.end/c.dt);dt=c.end/steps
    history=[]; snaps=[]; allm=[];start=time.time();E0=None
    for j in range(steps+1):
        t=j*dt
        if j%max(1,steps//90)==0 or j==steps:
            _,st,ex=solver.rhs(t,s,True); soc=ex['social']
            if E0 is None:E0=st['energy']
            st['energy_balance']=st['energy']-E0-st['source_work']
            st.update(utility=float(soc['utility']),response_means=np.sum(s['responses'],axis=(0,1)).tolist(),
                      episode_count=len(solver.records),social_memory=float(np.mean(soc['memory'])),
                      old_retrieval=float(np.mean(soc['old_retrieval'])),
                      expression_shift=float(np.linalg.norm(s['expression']-solver.intent)),
                      social_context=s['context'].tolist(),min_viscosity=float(ex['viscosity'].min()))
            history.append(st)
            snap={k:s[k].copy() for k in ['X','F','m','expression','context','norm','logradius','relation','responses','association']}
            snap.update(t=t,u=s['g'][...,:3].copy(),C=s['g'][...,3].copy(),theta=s['g'][...,4].copy(),
                        SE=ex['SE'].copy(),heatflux=ex['heatflux'].copy(),retrieved=soc['memory'],old_retrieval=soc['old_retrieval'],
                        margin=soc['margin'],observations=soc['observations'],room=soc['room'])
            snaps.append(snap)
        allm.append(s['m'].copy())
        if j==steps:break
        s=solver.step(t,s,dt)
        if not all(np.isfinite(v).all() for v in s.values()):raise FloatingPointError(f'nonfinite at {t}')
        if s['m'].min() < -1e-12:raise FloatingPointError('negative material record; no clipping used')
    result=dict(name=name,config=asdict(c),steps=steps,particles=solver.P,history=history,elapsed_s=time.time()-start,
                source_hashes={p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in ['social_hug.py','continuum.py']},
                scope='Version 2: objective strain sensor and simplex-preserving context closure; synthetic, dimensionless; structural event-memory proposal not implemented')
    if save:
        out=ROOT/'results';out.mkdir(exist_ok=True)
        (out/(name+'.json')).write_text(json.dumps(result,indent=2,allow_nan=False)+'\n',encoding='utf8')
        np.savez_compressed(out/(name+'.npz'),**{k:np.array([sn[k] for sn in snaps]) for k in snaps[0]},
                            **{'archive_'+k:np.array([r[k] for r in solver.records]) for k in solver.records[0]},
                            archive_times=solver.record_times,material_every_step=np.array(allm),reference_X=solver.X0,weights=solver.V,
                            intent=solver.intent,attachment=solver.attach,final_grid=s['g'],final_ledger=s['ledger'])
    return result,s,solver

if __name__=='__main__':
    import argparse
    ap=argparse.ArgumentParser();ap.add_argument('--name',default='main');ap.add_argument('--n',type=int,default=24)
    ap.add_argument('--dt',type=float,default=.005);ap.add_argument('--end',type=float,default=3.)
    args=ap.parse_args();r,_,_=run(Config(n=args.n,dt=args.dt,end=args.end),args.name)
    print(json.dumps({'name':args.name,'elapsed_s':r['elapsed_s'],'final':r['history'][-1]}))
