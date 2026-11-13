"""Added structural-memory candidate, not a calibrated clay constitutive law.

See STRUCTURAL_MEMORY.md for provenance, units and the continuum coupling.
This module supplies local constitutive evaluations, not a moving-body solver.
All parameter values must be passed explicitly; there are no material defaults.
"""
from dataclasses import dataclass
import math
import numpy as np


@dataclass(frozen=True)
class Parameters:
    directions: np.ndarray  # unit material/reference directions, (n, 3)
    G0: float              # Pa
    G_history: np.ndarray  # Pa, (n, 2): extending/shortening records
    mu: float              # Pa s
    m_scale: float         # dimensionless
    write_rate: float      # 1/s
    rate_scale: float      # 1/s, strictly positive
    write_fraction: float # [0, 1]
    power_floor: float    # W/m^3, strictly positive
    k_base: float         # W/(m K), strictly positive
    k_history: np.ndarray # W/(m K), (n, 2), nonnegative

    def __post_init__(self):
        for name in ('directions', 'G_history', 'k_history'):
            value = np.array(getattr(self, name), dtype=float, copy=True)
            if not np.all(np.isfinite(value)):
                raise ValueError(f'{name}: finite entries required')
            value.setflags(write=False)
            object.__setattr__(self, name, value)
        n = len(self.directions)
        if self.directions.shape != (n, 3) or n == 0:
            raise ValueError('directions must be a nonempty (n, 3) array')
        if not np.allclose(np.linalg.norm(self.directions, axis=1), 1, atol=1e-12, rtol=0):
            raise ValueError('material directions must have unit length')
        for name in ('G_history', 'k_history'):
            value = getattr(self, name)
            if value.shape != (n, 2) or np.any(value < 0):
                raise ValueError(f'{name}: nonnegative (n, 2) entries required')
        for name in ('G0', 'mu', 'm_scale', 'rate_scale', 'power_floor', 'k_base'):
            value = getattr(self, name)
            if not math.isfinite(value) or value <= 0:
                raise ValueError(f'{name} must be positive and finite')
        if not math.isfinite(self.write_rate) or self.write_rate < 0:
            raise ValueError('write_rate must be nonnegative and finite')
        if not math.isfinite(self.write_fraction) or not 0 <= self.write_fraction <= 1:
            raise ValueError('write_fraction must lie in [0, 1]')


def evaluate(F, L, memory, p):
    """Return energy, stress, recording rate and conductivity at one parcel.

    F maps reference to current material; det F = 1. L = grad u, trace L = 0.
    memory contains two nonnegative, material-attached records per direction.
    No observation, motion-stop, or threshold operation resets those records.
    """
    F, L, memory = (np.asarray(v, dtype=float) for v in (F, L, memory))
    if F.shape != (3, 3) or L.shape != (3, 3) or memory.shape != p.G_history.shape:
        raise ValueError('incompatible state shapes')
    if not all(np.all(np.isfinite(v)) for v in (F, L, memory)) or np.any(memory < 0):
        raise ValueError('states must be finite; memory must be nonnegative')
    if not np.isclose(np.linalg.det(F), 1, atol=1e-8, rtol=0):
        raise ValueError('this candidate requires det F = 1')
    if abs(np.trace(L)) > 1e-10 * max(1., np.linalg.norm(L)):
        raise ValueError('this candidate requires incompressible velocity')
    D = (L + L.T) / 2
    directions_now = p.directions @ F.T
    lengths2 = np.einsum('ki,ki->k', directions_now, directions_now)
    strain = (lengths2 - 1) / 2
    strain_rate = np.einsum('ki,ij,kj->k', directions_now, D, directions_now)
    expressed = -np.expm1(-memory / p.m_scale)
    expression_derivative = np.exp(-memory / p.m_scale) / p.m_scale
    weights = np.sum(p.G_history * expressed, axis=1)
    B = F @ F.T
    energy = p.G0 / 2 * (np.trace(B) - 3) + np.sum(weights * strain**2) / 2
    tau_el = p.G0 * (B - np.eye(3)) + np.einsum(
        'k,ki,kj->ij', weights * strain, directions_now, directions_now)
    conjugate = p.G_history * expression_derivative * strain[:, None]**2 / 2
    positive_rates = np.column_stack((np.maximum(strain_rate, 0), np.maximum(-strain_rate, 0)))
    # hypot avoids overflow in the rate normalization for large finite rates.
    fraction = positive_rates / np.hypot(positive_rates, p.rate_scale)
    raw = p.write_rate * fraction**2
    viscous_power = 2 * p.mu * np.sum(D * D)
    raw_power = np.sum(conjugate * raw)
    budget = p.write_fraction * viscous_power
    limiter = budget / (p.power_floor + budget + raw_power)
    memory_rate = limiter * raw
    write_power = np.sum(conjugate * memory_rate)
    heat_power = viscous_power - write_power
    unit_now = directions_now / np.sqrt(lengths2)[:, None]
    conductivity = p.k_base * np.eye(3) + np.einsum(
        'k,ki,kj->ij', np.sum(p.k_history * expressed, axis=1), unit_now, unit_now)
    return dict(energy=float(energy), tau_el=tau_el, tau_visc=2*p.mu*D,
                memory_rate=memory_rate, expression=expressed, conjugate=conjugate,
                strain=strain, strain_rate=strain_rate, viscous_power=float(viscous_power),
                write_power=float(write_power), heat_power=float(heat_power),
                conductivity=conductivity, limiter=float(limiter))


def energy_flux(energy_density, velocity, total_stress, heat_flux):
    """S_E [W/m^2], in a declared laboratory frame; stress includes pressure."""
    u = np.asarray(velocity, dtype=float)
    return energy_density*u - np.asarray(total_stress) @ u + np.asarray(heat_flux)


def context_force(gradient, threshold, delta, epsilon, sigma, direction):
    """Corpus smooth exact-off branch with cutoff-preserving norm regularization.

    Choosing this branch is explicit; it does not alter the memory write law.
    Context units Q are not energy units. Sigma has units Pa/Q.
    """
    gradient, direction = np.asarray(gradient, float), np.asarray(direction, float)
    if gradient.shape != (3,) or direction.shape != (3,) or not np.all(np.isfinite(gradient)):
        raise ValueError('finite three-dimensional context gradient required')
    if not np.all(np.isfinite(direction)) or not np.isclose(np.linalg.norm(direction), 1):
        raise ValueError('force direction must be a finite unit vector')
    if not all(math.isfinite(v) for v in (threshold, delta, epsilon, sigma)):
        raise ValueError('finite force parameters required')
    if threshold < 0 or delta <= 0 or epsilon <= 0 or sigma < 0:
        raise ValueError('invalid force parameters')
    magnitude = math.hypot(*gradient)
    q = math.hypot(magnitude, delta) - math.hypot(threshold, delta)
    activation = 0. if q <= 0 else q*math.exp(-(epsilon/q)**2)
    return -sigma*activation*direction


def pair_exchange(ca, cb, ha, hb, rate, scale, length):
    """Separate graded upper-half context interaction; equal parcel volumes.

    Heights use the CURRENT physical mid-plane. Neither direction is evaluated
    below that plane; arbitrary finite context states then give exact zeros.
    """
    if not all(math.isfinite(v) for v in (ca, cb, ha, hb, rate, scale, length)):
        raise ValueError('finite pair states and parameters required')
    if rate < 0 or scale <= 0 or length <= 0:
        raise ValueError('invalid pair parameters')
    if ha <= 0 or hb <= 0:
        return 0., 0.
    wa = (ha/math.hypot(ha, length))**2
    wb = (hb/math.hypot(hb, length))**2
    # Opposite extreme finite states can overflow subtraction to +/-inf;
    # tanh has the correct saturated limit. No subtraction occurs in off case.
    diff = cb-ca
    d = rate*wa*wb*scale*math.tanh(diff/scale)
    return d, -d


def conduction_rhs(temperature, conductivity, capacity, dx):
    """Stationary 1-D body/exterior slice, insulated endpoints, unit area.

    Uniform finite-volume cells. Harmonic face conductivity supplies one shared
    interface heat flux; opposite signs prevent disappearing transfer energy.
    capacity is volumetric heat capacity, J/(m^3 K), not total heat capacity.
    """
    t, k, cap = (np.asarray(v, dtype=float) for v in (temperature, conductivity, capacity))
    if t.ndim != 1 or len(t) < 2 or t.shape != k.shape or t.shape != cap.shape:
        raise ValueError('matching one-dimensional arrays, at least two cells required')
    if not all(np.all(np.isfinite(v)) for v in (t, k, cap)) or np.any(t <= 0) or np.any(k <= 0) or np.any(cap <= 0) or not math.isfinite(dx) or dx <= 0:
        raise ValueError('positive finite temperature, conductivity, capacity and dx required')
    face_k = 2/(1/k[:-1]+1/k[1:])
    flux = np.zeros(len(t)+1)
    flux[1:-1] = -face_k*np.diff(t)/dx
    return (flux[:-1]-flux[1:])/(cap*dx), flux
