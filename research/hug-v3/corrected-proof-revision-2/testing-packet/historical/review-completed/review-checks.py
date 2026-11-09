"""Source-preserving, finite counterexamples to a pasted proof draft; no time integration."""
from pathlib import Path
import os
from datetime import datetime, timezone
from fractions import Fraction
import hashlib, json, shutil, sys, traceback, warnings, platform

sys.dont_write_bytecode = True
ROOT = Path(os.environ['PROOF_WORKSPACE'])
PACKAGE = Path(os.environ['PROOF_PACKAGE'])
ATTACHMENT = Path(os.environ['PROOF_ATTACHMENT'])
RUN = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ')
OUT = ROOT / 'outputs' / 'hug-v3-proof-review' / RUN
OUT.mkdir(parents=True, exist_ok=False)
(ROOT / 'work' / 'current-hug-proof-review.txt').write_text(str(OUT), encoding='utf8')

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

manifest = []
def preserve(src, rel):
    dest = OUT / rel
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(src, dest)
    entry = dict(source=str(src), snapshot=rel, sha256=digest(src), bytes=src.stat().st_size)
    assert digest(dest) == entry['sha256']
    manifest.append(entry)

audit = json.loads((PACKAGE / 'source-audit.json').read_text(encoding='utf8'))
original = Path(audit['source'])
seal = json.loads((PACKAGE / 'sources' / 'source_seal.json').read_text(encoding='utf8'))
preservation = []
for rel, expected in seal.items():
    rec = dict(file=rel, expected=expected,
               original=digest(original / rel), proof_snapshot=digest(PACKAGE / 'sources' / rel))
    assert rec['original'] == rec['proof_snapshot'] == expected
    preservation.append(rec)
    preserve(PACKAGE / 'sources' / rel, 'sources/' + rel)
preserve(PACKAGE / 'sources' / 'source_seal.json', 'sources/source_seal.json')
preserve(ATTACHMENT, 'submitted-proof.tex')
for name in ['LOCAL_PROOF_ROUTE.md', 'source-audit.json', 'verification-report.json',
             'V3EventSpecification.lean', 'V3EventProofs.lean']:
    preserve(PACKAGE / name, 'prior-evidence/' + name)
preserve(Path(__file__), 'review-checks.py')
(OUT / 'input-manifest.json').write_text(json.dumps(manifest, indent=2), encoding='utf8')
triangle = ROOT / 'outputs' / 'triangle-hug' / 'testing-packet' / 'trial_model.py'
triangle_before = digest(triangle)
result = dict(run_id=RUN, model='hug-structural-memory-v3',
              scope='Targeted source review, algebra and counterexamples; not a trajectory, full proof or new Lean run.',
              source_preservation_before=preservation, checks={})
try:
    # Reuse the existing CPython 3.12 scientific packages; no installation or source edits.
    scientific_packages = Path(os.environ['PROOF_DEPS'])
    sys.path.insert(0, str(scientific_packages))
    sys.path.insert(0, str(OUT / 'sources'))
    import numpy as np
    import scipy
    import preflight
    declaration = preflight.approve('main')
    from structural_hug import Solver, Config, outcome_score
    import struct, zlib
    so = Solver(Config(**declaration['config']))
    s = so.initial()
    result['environment'] = dict(python=sys.version, numpy=np.__version__, scipy=scipy.__version__, platform=platform.platform(), scientific_packages=str(scientific_packages))
    result['declaration_gate'] = dict(case='main', manifest_sha256=declaration['manifest_sha256'], accepted=True)
    checks = result['checks']
    checks['dimension'] = dict(actual=sum(v.size for v in s.values()), claimed=193122)
    assert checks['dimension']['actual'] == 193122
    checks['checkpoint_partition'] = sorted({0., so.c.end} | {v for e in declaration['events'] for v in (e['start'], e['end'])})

    # The source grad is not filtered. This real Fourier mode lies below Nyquist.
    grid = np.indices((so.n, so.n, so.n))
    wave = np.cos(2*np.pi*7*grid.sum(axis=0)/so.n)
    ratio = float(np.linalg.norm(so.grad(wave)) / np.linalg.norm(wave))
    claimed = float(2*np.pi*so.n/np.sqrt(3))
    checks['spectral_gradient_counterexample'] = dict(n=so.n, mode=[7,7,7],
        measured_norm_ratio=ratio, exact_ratio='14*pi*sqrt(3)', claimed_upper_bound=claimed,
        correction_safe_full_space_bound=float(np.pi*so.n*np.sqrt(3)), contradicts_bound=ratio > claimed)
    assert ratio > claimed

    # Analog rest-strain moves within the same decoded all-zero component.
    bb = s['b'].copy(); bb[0] += .001
    loads0, tractions0 = so.fabric.probe(s['F'], s['b'])
    loads1, tractions1 = so.fabric.probe(s['F'], bb)
    estimate0 = np.mean(loads0 - tractions0 / so.c.micro_k, axis=0)
    estimate1 = np.mean(loads1 - tractions1 / so.c.micro_k, axis=0)
    bits0 = so.fabric.bits_from_probe(loads0, tractions0)
    bits1 = so.fabric.bits_from_probe(loads1, tractions1)
    checks['analog_vs_decoded'] = dict(first_before=float(estimate0[0]), first_after=float(estimate1[0]),
        perturbation=.001, allowed_half_margin=(.02-.005)/2, same_bits=bool(np.array_equal(bits0,bits1)),
        records_before=so.fabric.read(s['F'],s['b']), records_after=so.fabric.read(s['F'],bb))
    assert np.array_equal(bits0,bits1) and estimate0[0] != estimate1[0]

    # Build one well-formed payload, then test the larger domain admitted by unpack.
    # These are static domain counterexamples, NOT events produced by the writer.
    rec = dict(origin=0, recipient=1, event_id=0, start=0., end=.2,
               predecessors=0, observed=1., recipient_report=None, context=np.array([.5,.5]),
               recognition=0., authority=0., actions=np.zeros(7), delta_E=np.zeros((so.P,6)))
    payload = so.fabric.payload(rec)
    def changed_payload(index, value):
        header_body = np.frombuffer(payload[:-4], dtype='<i2').copy()
        header_body[index] = value
        body = header_body.tobytes()
        return body + struct.pack('<I', zlib.crc32(body))
    invalid_outcome_payload = changed_payload(10, 20000)
    record_outcome = so.fabric.unpack(invalid_outcome_payload)
    try:
        outcome_score(record_outcome['observed'], record_outcome['recipient_report'])
        outcome_error = None
    except ValueError as exc:
        outcome_error = str(exc)
    checks['decoded_outcome_domain_gap'] = dict(unpack_succeeds=True, decoded_observed=record_outcome['observed'],
        later_outcome_error=outcome_error, produced_by_valid_writer=False)
    assert record_outcome['observed'] == 2. and outcome_error is not None

    negative_duration_payload = changed_payload(6, -120)
    bad = {k:v.copy() for k,v in s.items()}
    bad['context'][:] = .5
    bad['association'][:] = 0.
    bad_bits = np.unpackbits(np.frombuffer(negative_duration_payload,dtype=np.uint8),bitorder='little')
    bad['b'][:so.fabric.bits_per_slot] = so.c.rest_amplitude * (2*bad_bits.astype(float)-1)
    decoded = so.read_material(bad)
    with warnings.catch_warnings(record=True) as caught:
        warnings.simplefilter('always')
        mem, exposure, old = so.retrieve(0.,bad)
    lower_fiber = float(np.linalg.norm(np.einsum('pij,kj->pki',bad['F'],so.directions),axis=-1).min())
    exact_denominator = Fraction(12,100) + Fraction(-120,1000)
    checks['retrieval_denominator_counterexample'] = dict(unpack_succeeds=True, decoded_duration=decoded[0][1]['end']-decoded[0][1]['start'],
        minimum_absolute_b=float(np.abs(bad['b']).min()), required_b_threshold=.005,
        minimum_sampled_fiber_length=lower_fiber, cue_difference_is_zero=True,
        exposure=float(exposure[1,0]), denominator=float(so.c.history_prior+exposure[1,0]),
        exact_rational_denominator=str(exact_denominator), all_retrieval_values_finite=bool(np.isfinite(mem).all()),
        warnings=[str(w.message) for w in caught], produced_by_valid_writer=False,
        claim_scope='All states in the submitted Omega_valid, not reachability from the main initial state')
    assert exact_denominator == 0 and so.c.history_prior+exposure[1,0] == 0 and not np.isfinite(mem).all()

    w = so.c.thermal_width
    seam_direct = sum(np.exp(-(.5+shift)**2/(2*w*w)) for shift in (-1,0,1))
    seam_submitted = sum(np.exp(-k/(8*w*w)) for k in (1,9,25))
    seam_corrected = 2*np.exp(-1/(8*w*w)) + np.exp(-9/(8*w*w))
    checks['wrapped_gaussian_seam'] = dict(width=w, direct=float(seam_direct),
        submitted=float(seam_submitted), corrected=float(seam_corrected),
        corrected_expression='2 exp(-1/(8 w^2)) + exp(-9/(8 w^2))',
        submitted_equality_is_false=bool(seam_direct != seam_submitted))
    assert seam_direct == seam_corrected and seam_direct != seam_submitted
    def gaussian(delta):
        return sum(np.exp(-(delta+shift)**2/(2*w*w)) for shift in (-1,0,1))
    def normalized(position):
        vals=np.array([gaussian((position-x+.5)%1-.5) for x in so.x])
        return vals/vals.sum(),vals,vals.sum()
    ra,va,za=normalized(0.);rb,vb,zb=normalized(.02)
    m=int(np.argmax(np.abs(ra-rb)))
    checks['quotient_identity'] = dict(node_index=m, lhs=float(abs(ra[m]-rb[m])),
        submitted_rhs=float(abs((va[m]-ra[m]*za)/zb)),
        algebra='Submitted numerator is identically psi(X)-[psi(X)/Z(X)]*Z(X)=0.')
    assert abs(ra[m]-rb[m]) > .01
    checks['flat_activation'] = dict(analytic_derivative='(1+2 epsilon^2/q^2) exp(-epsilon^2/q^2)',
        maximizer='q=sqrt(2)*epsilon', exact_bound='2/sqrt(e)', bound=float(2/np.sqrt(np.e)),
        assessment='Correct for positive epsilon; analytic check, not an exhaustive numerical proof.')
    result['status']='REVIEW_COMPLETE_SUBMITTED_PROOF_NOT_VALID_AS_WRITTEN'
except Exception:
    result['status']='CHECK_EXECUTION_INCOMPLETE'
    result['exception']=traceback.format_exc()
finally:
    result['source_preservation_after'] = dict(
        all_21_originals_match_seal=all(digest(original/rel)==h for rel,h in seal.items()),
        all_21_prior_snapshots_match_seal=all(digest(PACKAGE/'sources'/rel)==h for rel,h in seal.items()),
        all_21_review_snapshots_match_seal=all(digest(OUT/'sources'/rel)==h for rel,h in seal.items()),
        attachment_unchanged=digest(ATTACHMENT)==next(m['sha256'] for m in manifest if m['snapshot']=='submitted-proof.tex'),
        frozen_review_inputs_unchanged=all(digest(OUT/m['snapshot'])==m['sha256'] for m in manifest),
        triangle_trial_unchanged=digest(triangle)==triangle_before)
    (OUT/'checks.json').write_text(json.dumps(result,indent=2,allow_nan=False),encoding='utf8')
print(json.dumps(dict(output=str(OUT),status=result['status'],checks=result.get('checks'),preservation=result['source_preservation_after'],exception=result.get('exception')),indent=2))
