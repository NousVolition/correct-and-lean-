"""Static proof checks for the unchanged sealed v3 main system. No integration."""
from pathlib import Path
from fractions import Fraction as Q
import hashlib
import json
import sys
from datetime import datetime, timezone

OUT = Path(__file__).resolve().parent
SOURCE = OUT.parents[2] / 'lean' / 'hug-v3-transfer-lean' / 'sources'
PROOF = OUT.parent / 'corrected-proof-revision-2' / 'proof.md'

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

seal = json.loads((SOURCE / 'source_seal.json').read_text(encoding='utf-8'))
before = {name: sha(SOURCE / name) for name in seal}
assert before == seal, 'Frozen source mismatch'
sys.path.insert(0, str(SOURCE))
import numpy as np
from preflight import approve
declaration = approve('main')
from structural_hug import Config, Solver
solver = Solver(Config(**declaration['config']))
state = solver.initial()
events = declaration['events']
assert [e['event_id'] for e in events] == [0, 1, 2]
assert [(e['start'], e['end']) for e in events] == [(0., .4), (.2, .8), (.8, 1.2)]
assert len(events) < solver.c.capacity == 4

# Exact rational consequences of the sealed fabric coefficients.
k, mobility, height, a = Q(1,25), Q(1,20), Q(1,500), Q(1,50)
linear = mobility * (height / a**2 - k)
cubic = mobility * height / a**4
assert linear == Q(31,125) and cubic == 625
def rate(e,b):
    return mobility*k*e + linear*b - cubic*b**3
positive_buffer_rate = rate(Q(-1,2),Q(3,500))
assert positive_buffer_rate == Q(353,1000000) > 0
negative_buffer_rate = rate(Q(1,2),Q(-3,500))
assert negative_buffer_rate == -positive_buffer_rate

# On y in [0.006,0.02], .248*y - 625*y^3 >= -0.00004.
# Its derivative has at most one positive zero, a maximum, so the minimum
# is at an endpoint; the assertion records those endpoint values.
def stable_part(y):
    return linear*y-cubic*y**3
assert stable_part(a) == Q(-1,25000)
assert stable_part(Q(3,500)) > stable_part(a)
T = Q(8,5)
integrated_strain_limit = (a-Q(3,500)-T/Q(25000))*500
assert integrated_strain_limit == Q(871,125)  # 6.968

# If every material column has squared length <= 2, then |e| <= 1/2.
# The unchanged fabric flow then preserves [-0.025,0.025].
B = Q(1,40)
D = a+B
assert rate(Q(1,2), B) < 0
assert rate(Q(-1,2), -B) > 0
# Bound each positive quartic coefficient by its absolute-value bound.
# Use total fabric mass, not just the smaller mass of the written slot.
grad_bound = k*(Q(1,2)+B)+height*B/a**2*((B/a)**2+1)
coefficient_density_bounds = [
    grad_bound*D+Q(5,2)*D**2,
    (k/2+height*(3*B**2+a**2)/(2*a**4))*D**2,
    height*B*D**3/a**4,
    height*D**4/(4*a**4)]
mass_upper = Q(4,3)*Q(22,7)*Q(22,100)*Q(17,100)*Q(19,100)
actual_mass = sum((Q.from_float(float(w)) for w in solver.fabric.weight), Q(0))
assert actual_mass < mass_upper
budget_upper = mass_upper*sum(coefficient_density_bounds)
assert budget_upper < Q(1,50)

# Static cross-check of the energy/transport identities used in the proof.
# This is one RHS evaluation, not a trajectory or a timestep.
sample = {name: value.copy() for name, value in state.items()}
xyz = solver.xyz
sample['g'][...,0] = .02*np.sin(2*np.pi*xyz[...,1])
sample['g'][...,1] = .015*np.sin(2*np.pi*xyz[...,2])
sample['g'][...,2] = .01*np.sin(2*np.pi*xyz[...,0])
sample['g'][...,3] = .03*np.sin(2*np.pi*xyz[...,0])*np.sin(2*np.pi*xyz[...,1])+.01*np.cos(4*np.pi*xyz[...,2])
sample['F'][:] = np.diag(np.exp([.03,.02,-.05]))
sample['m'][:] = .01
ds, stats, detail = solver.rhs(.3,sample,details=True)
c = solver.c
F,Fdot = sample['F'],ds['F']
d = np.einsum('pij,kj->pki',F,solver.directions)
ddot = np.einsum('pij,kj->pki',Fdot,solver.directions)
strain = (np.sum(d*d,-1)-1)/2
strain_rate = np.sum(d*ddot,-1)
weights = c.Gm*(-np.expm1(-sample['m']/c.mscale)).sum(-1)*solver.direction_weights
Y = .5*c.Gm/c.mscale*np.exp(-sample['m']/c.mscale)*strain[...,None]**2*solver.direction_weights[None,:,None]
Pm = float(np.einsum('p,pki,pki',solver.V,Y,ds['m']))
base_dot = float(np.dot(solver.V,c.G0*np.sum(F*Fdot,axis=(1,2))+np.sum(weights*strain*strain_rate,axis=1)))+Pm
e = solver.fabric.local_strain(F)
edot = np.sum(F*Fdot,axis=1)[solver.fabric.point,solver.fabric.axis]
b = sample['b']
grad_b = c.micro_k*(b-e)+c.well_height*b/c.rest_amplitude**2*((b/c.rest_amplitude)**2-1)
fabric_dot = float(np.dot(solver.fabric.weight,c.micro_k*(e-b)*edot+grad_b*ds['b']))
u = sample['g'][...,:3]
kinetic_dot = float(np.mean(np.sum(u*ds['g'][...,:3],axis=-1)))
Lu = solver.grad(u)
Du = (Lu+Lu.swapaxes(-1,-2))/2
nu = c.nu*np.exp(-c.thermal_feedback*np.tanh(sample['g'][...,4]/.03))
Qv = 2*nu*np.sum(Du*Du,axis=(-1,-2))
Db = float(np.dot(solver.fabric.weight,c.fabric_mobility*grad_b**2))
energy_identity_residual = kinetic_dot+base_dot+fabric_dot-(-float(Qv.mean())+Pm-Db+float(ds['ledger'][1]))
assert abs(energy_identity_residual) < 1e-12
assert 0 <= Pm <= c.eta*float(Qv.mean())+1e-14
assert np.max(np.abs(np.trace(detail['L'],axis1=-2,axis2=-1))) < 1e-12
C = sample['g'][...,3]
transport = solver.context_transport(C,u)
context_dissipation = c.diffusion*sum(float(np.mean(((np.roll(C,-1,axis=j)-C)/solver.dx)**2)) for j in range(3))
transport_identity_residual = float(np.mean(C*transport))+context_dissipation
assert abs(transport_identity_residual) < 1e-12

# Static admissible state: this is NOT claimed to be reachable from main data.
# It tests whether read validity + finite deformation alone imply write success.
static = {name: value.copy() for name, value in state.items()}
static['b'][:] = -.01
assert solver.read_material(static) == []
record = solver.make_event(static, state['F'], events[0])
payload = solver.fabric.payload(record)
decoded = solver.fabric.unpack(payload)
assert decoded['event_id'] == 0
assert decoded['start'] == 0. and decoded['end'] == .4
bits = np.unpackbits(np.frombuffer(payload,dtype=np.uint8),bitorder='little')
weights = solver.fabric.weight[:solver.fabric.bits_per_slot]
mass = sum((Q.from_float(float(w)) for w in weights), Q(0))
one_mass = sum((Q.from_float(float(w)) for w,bit in zip(weights,bits) if bit), Q(0))
one_fraction = one_mass / mass
zero_work, one_work = Q(-101,4000000), Q(7899,4000000)
exact_work = zero_work*(mass-one_mass)+one_work*one_mass
assert one_fraction < Q(101,8000)
assert exact_work < 0
try:
    solver.write_event(static,record)
except ValueError as exc:
    rejection = str(exc)
    assert 'insufficient writing work budget or undeclared recovery path' in rejection
else:
    raise AssertionError('Expected source rejection of negative-work static example')

# Actual source arithmetic is checked separately from the rational argument.
target = static['b'].copy()
target[:len(bits)] = solver.c.rest_amplitude*(2*bits.astype(float)-1)
delta = target-static['b']
heat_cell = solver.c.stroke_drag*delta*delta/solver.c.stroke_duration
heat = np.bincount(solver.fabric.point,weights=solver.fabric.local_weight*heat_cell,minlength=solver.P)
machine_work = solver.fabric.energy(static['F'],target)-solver.fabric.energy(static['F'],static['b'])+float(solver.V@heat)
assert machine_work < 0
assert abs(machine_work-float(exact_work)) < 1e-16
e = solver.fabric.local_strain(static['F'])
b = static['b']
c = solver.c
coefficients = np.array([0.,
    np.dot(solver.fabric.weight,(-c.micro_k*(e-b)+c.well_height*b/c.rest_amplitude**2*((b/c.rest_amplitude)**2-1))*delta)+float(solver.V@heat),
    np.dot(solver.fabric.weight,(.5*c.micro_k+c.well_height*(3*b*b-c.rest_amplitude**2)/(2*c.rest_amplitude**4))*delta**2),
    np.dot(solver.fabric.weight,c.well_height*b*delta**3/c.rest_amplitude**4),
    np.dot(solver.fabric.weight,c.well_height*delta**4/(4*c.rest_amplitude**4))])
required_budget = float(np.maximum(coefficients,0).sum())
assert required_budget < c.write_budget
assert coefficients[-1] > 0

# An explicit coarse global bound: finite-state continuation does not give
# the small quantitative bound needed for memory clearance.
from math import exp, sqrt, pi
growth = 1.58
offset = 3.25/growth
def expression_norm_bound(t):
    return (1+offset)*exp(growth*t)-offset
# R'=1.58 R+3.25, R(0)=1 bounds max expression/norm vector magnitude.
# |A'| <= .13312 + .0128 (R+1)^2. Monotonicity gives the following
# conservative, explicit bounds for all times up to T.
horizon = float(events[0]['end'])
Rf = expression_norm_bound(horizon)
Aprime = .13312+.0128*(Rf+1)**2
Abound = horizon*Aprime
Cbound = 64*horizon*Abound
initial_mechanical = solver.fabric.energy(state['F'],state['b'])
velocity_bound = sqrt(2*initial_mechanical)+.16*sqrt(3)*16*horizon*Cbound
minimum_volume = float(solver.V.min())
column_square_bound = 3+velocity_bound**2/(.08*minimum_volume)
strain_integral_bound = horizon*max(0.,(column_square_bound-1)/2)
assert strain_integral_bound > float(integrated_strain_limit)

after = {name: sha(SOURCE / name) for name in seal}
assert after == before == seal
result = {
    'checked_at_utc':datetime.now(timezone.utc).isoformat(),
    'scope':'Static source/rational checks; no time integration, no new model, no Lean run',
    'full_continuation_proved':False,
    'source':str(SOURCE), 'source_files':len(seal),
    'source_hashes_before':before, 'source_hashes_after':after,
    'all_source_hashes_match_seal':True,
    'reference_proof':{'path':str(PROOF),'sha256':sha(PROOF)},
    'config_unchanged':True,'schedule_unchanged':True,
    'schedule':events,'capacity':solver.c.capacity,
    'fabric_exact_algebra':{
        'linear':str(linear),'cubic':str(cubic),
        'positive_006_boundary_min_rate':str(positive_buffer_rate),
        'negative_006_boundary_max_rate_if_column_squared_le_2':str(negative_buffer_rate),
        'sufficient_integrated_positive_strain_bound_through_1p6':str(integrated_strain_limit),
        'bound_discharged_for_main_trajectory':False},
    'consequences_if_all_column_squared_lengths_le_2':{
        'hypothesis_discharged_for_main_trajectory':False,
        'fabric_absolute_upper_bound':str(B),
        'upper_boundary_max_rate':str(rate(Q(1,2),B)),
        'lower_boundary_min_rate':str(rate(Q(-1,2),-B)),
        'absolute_delta_E_component_bound':2,
        'positive_coefficient_density_bounds':[str(v) for v in coefficient_density_bounds],
        'total_fabric_mass_upper_bound':str(mass_upper),
        'required_budget_upper_bound':float(budget_upper),
        'required_budget_upper_bound_exact':str(budget_upper),
        'declared_budget':.02,
        'nonnegative_work_does_not_follow':True},
    'static_energy_and_transport_crosscheck':{
        'trajectory_or_timestep_executed':False,
        'mechanical_identity_residual':energy_identity_residual,
        'context_transport_identity_residual':transport_identity_residual,
        'directional_storage_power':Pm,
        'directional_power_upper_bound':c.eta*float(Qv.mean()),
        'max_absolute_trace_interpolated_velocity_gradient':float(np.max(np.abs(np.trace(detail['L'],axis1=-2,axis2=-1)))),
        'scope':'One nontrivial static RHS evaluation supports identities; not a universal proof'},
    'static_write_counterexample':{
        'reachable_from_main_initial_state': 'NOT ESTABLISHED; no trajectory claim',
        'F':'identity', 'all_b': '-1/100', 'decoded_before':[],
        'event_id':0,'payload_parses':True,'ones_count':int(bits.sum()),
        'bits_per_slot':int(len(bits)),
        'weighted_one_fraction':float(one_fraction),
        'required_fraction_for_nonnegative_work':float(Q(101,8000)),
        'per_zero_bit_work_density':str(zero_work),
        'per_one_bit_work_density':str(one_work),
        'exact_work_for_fixed_binary_quadrature_weights':str(exact_work),
        'exact_work_decimal':float(exact_work),
        'source_arithmetic_work':machine_work,
        'source_required_budget':required_budget,'declared_budget':c.write_budget,
        'work_polynomial_coefficients':coefficients.tolist(),
        'source_rejection':rejection,
        'conclusion':'Read validity and bounded deformation do not alone imply write acceptance'},
    'coarse_bound_attempt':{
        'scope':'Before first write at 0.4; deliberately conservative analytic bound conditional only on remaining in read domain',
        'horizon':horizon,
        'expression_norm_bound':Rf,'A_bound':Abound,'C_h_norm_bound':Cbound,
        'sqrt_two_mechanical_energy_bound':velocity_bound,
        'minimum_particle_volume':minimum_volume,
        'column_square_bound':column_square_bound,
        'positive_strain_integral_bound':strain_integral_bound,
        'does_not_close_memory_clearance':True},
    'checked_claims_not_certified':[
        'Exact main trajectory stays strictly above decoder margin',
        'Exact main material-change payload fits encoding range',
        'Exact main write work is nonnegative and required budget <= 0.02',
        'Source polynomial-root diagnostic succeeds on every actual write',
        'Full exact-real trajectory existence through 1.6',
        'Numerical approximation error and floating-point correctness']
}
(OUT/'checks.json').write_text(json.dumps(result,indent=2,allow_nan=False)+'\n',encoding='utf-8')
print(json.dumps({'source_files':len(seal),'preserved':True,'static_write_work':machine_work,
                  'static_one_fraction':float(one_fraction),'required_fraction':float(Q(101,8000)),
                  'coarse_strain_integral_bound':strain_integral_bound,
                  'needed_strain_integral_bound':float(integrated_strain_limit),
                  'full_continuation_proved':False},indent=2))
