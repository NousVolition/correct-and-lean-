"""Numerical illustration of the exact signed snapshot theorem. Unit box, ε = Γ = σ/ρ = 1."""
import json
from math import cos, fsum, pi, tanh


def response(q):
    return q * (1 + tanh(q)) / 2


def trial(n):
    gradients = [abs(cos(2 * pi * (i + 0.5) / n)) for i in range(n)]

    def mean(amplitude):
        return fsum(response(amplitude * g - 1) for g in gradients) / n

    lo, hi = 1.0, 2.0
    assert mean(lo) < 0 < mean(hi)
    for _ in range(43):
        middle = (lo + hi) / 2
        if mean(middle) < 0:
            lo = middle
        else:
            hi = middle
    amplitude = (lo + hi) / 2
    return dict(midpoints=n, amplitude=amplitude, mean=mean(amplitude),
                push_at_zero=-response(amplitude - 1), push_at_quarter=-response(-1))


if __name__ == "__main__":
    data = {"scope": "floating-point quadrature of a single spatial snapshot", "runs": [
        trial(8192), trial(65536)]}
    print(json.dumps(data, indent=2))
