"""Codec/operator counterexamples only; no fluid simulation or changed equation."""
from pathlib import Path
import sys, json, hashlib, struct, zlib, shutil
from fractions import Fraction
import numpy as np

P = Path(__file__).resolve().parent
SRC = P / 'sources'
DRAFT = P / 'pasted-proof.tex'
sys.path.insert(0, str(SRC))
from preflight import approve
decl = approve('main')
from structural_hug import Config, Fabric, HEADER, MAGIC, outcome_score
from continuum import body_quadrature
c = Config(**decl['config'])
X, V = body_quadrature(c)
fab = Fabric(c, X, V)
F = np.broadcast_to(np.eye(3), (fab.P, 3, 3)).copy()

def encoded_state(start_ticks, end_ticks, observed_ticks):
    h = np.zeros(HEADER, dtype='<i2')
    h[:5] = [MAGIC, 1, 0, 1, 0]
    h[5:7] = [start_ticks, end_ticks]
    h[8] = 1
    h[10] = observed_ticks
    body = h.tobytes() + np.zeros((fab.P, 6), dtype='<i2').tobytes()
    payload = body + struct.pack('<I', zlib.crc32(body))
    bits = np.unpackbits(np.frombuffer(payload, dtype=np.uint8), bitorder='little')
    b = fab.initial()
    b[:fab.bits_per_slot] = c.rest_amplitude * (2 * bits.astype(float) - 1)
    rows = fab.read(F, b)
    assert len(rows) == 1
    assert np.abs(b).min() > c.read_margin * c.rest_amplitude
    return rows[0][1]

bad_score = encoded_state(0, 400, 20000)
try:
    outcome_score(bad_score['observed'], bad_score['recipient_report'])
    raise AssertionError('Expected source outcome validation to reject 2.0')
except ValueError as err:
    score_result = dict(unpack_and_probe_accepted=True, observed=bad_score['observed'],
                        downstream_outcome_error=str(err))

bad_interval = encoded_state(120, 0, 5000)
duration = Fraction(str(bad_interval['end'])) - Fraction(str(bad_interval['start']))
assert duration == Fraction(-3, 25)
denominator_at_matching_cue = Fraction(str(c.history_prior)) + duration
assert denominator_at_matching_cue == 0

# Exact source grad acts without mask. A real cosine in mode (7,7,7)
# on n=16 has gradient/input norm ratio 2*pi*sqrt(7^2+7^2+7^2).
n = c.n
axis = np.arange(n) / n
xyz = np.stack(np.meshgrid(axis, axis, axis, indexing='ij'), -1)
C = np.cos(2 * np.pi * 7 * xyz.sum(-1))
freq = np.fft.fftfreq(n) * n
k = 2 * np.pi * np.stack(np.meshgrid(freq, freq, freq, indexing='ij'), -1)
hat = np.fft.fftn(C)
grad = np.stack([np.fft.ifftn(1j * k[...,j] * hat).real for j in range(3)], -1)
ratio = float(np.linalg.norm(grad) / np.linalg.norm(C))
claimed = float(2 * np.pi * n / np.sqrt(3))
assert ratio > claimed

record = dict(
    scope='New source-method unit checks and finite-grid operator counterexample. No evolved main trajectory was simulated.',
    declaration_gate=dict(case='main', accepted=True, manifest_sha256=decl['manifest_sha256']),
    draft_sha256=hashlib.sha256(DRAFT.read_bytes()).hexdigest(),
    crc_valid_but_semantically_invalid_outcome=score_result,
    crc_valid_but_reversed_interval=dict(unpack_and_probe_accepted=True,
        start=bad_interval['start'], end=bad_interval['end'], duration=str(duration),
        matching_cue_denominator=str(denominator_at_matching_cue),
        qualification='Constructed state in the proposed paper domain; not asserted reachable from the declared initial condition or through the writer.'),
    unfiltered_spectral_gradient=dict(n=n, mode=[7,7,7], measured_norm_ratio=ratio,
        exact_ratio='14*pi*sqrt(3)', proposed_upper_bound=claimed,
        correct_safe_unfiltered_bound='sqrt(3)*pi*n',
        dealiased_bound='2*pi*n/sqrt(3) applies on masked modes'),
    equations_and_sealed_sources_unchanged=True,
)
for rel, digest in json.loads((SRC / 'source_seal.json').read_text()).items():
    assert hashlib.sha256((SRC / rel).read_bytes()).hexdigest() == digest, rel
(P / 'paper-checks.json').write_text(json.dumps(record, indent=2) + '\n')
print(json.dumps(record, indent=2))
