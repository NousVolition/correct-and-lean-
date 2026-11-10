"""Repeat the withheld-state test across the published directional input family."""
import argparse
import json
from pathlib import Path

import numpy as np

from check_guard_transport import Snapshot, blend, load_source, sampling_control


def interval(frames, start):
    axis = 2*np.pi*(np.arange(16)+.37)/16
    initial = np.stack(np.meshgrid(axis,axis,indexing="ij"), axis=-1).reshape(-1,2)
    p = initial.copy()
    dt = 1/320
    left, right = start/640, (start+64)/640
    fields = {left:frames[start], right:frames[start+64]}
    measurements = []
    for k in range(16):
        t = left+k*dt
        v1 = blend(fields,left,right,t,p)
        v2 = blend(fields,left,right,t+dt/2,p+dt*v1/2)
        v3 = blend(fields,left,right,t+dt/2,p+dt*v2/2)
        v4 = blend(fields,left,right,t+dt,p+dt*v3)
        p = p + dt*(v1+2*v2+2*v3+v4)/6
        if k not in (0,15):
            continue
        target = frames[start+2*(k+1)]
        truth = target.velocity(p)
        gradients = target.gradients(p)
        a = (k+1)/32
        pred = (1-a)*frames[start].velocity(p)+a*frames[start+64].velocity(p)
        def error(estimate):
            delta = estimate-truth
            slip = np.einsum("pi,pgi->pg",delta,gradients)
            return {"velocity_rms": float(np.sqrt(np.mean(np.sum(delta**2,axis=1)))),
                    "guard_advection_rms_AB_BA": np.sqrt(np.mean(slip**2,axis=0)).tolist()}
        entry = {"time": (start+2*(k+1))/640, "both_at_new": error(pred)}
        if k == 0:
            stale = (1-a)*frames[start].velocity(initial)+a*frames[start+64].velocity(p)
            entry["stale_left"] = error(stale)
        else:
            narrow = (frames[start+16].velocity(p)+frames[start+48].velocity(p))/2
            entry["half_spacing"] = error(narrow)
            entry["rms_ratio"] = entry["both_at_new"]["velocity_rms"]/entry["half_spacing"]["velocity_rms"]
        measurements.append(entry)
    return {"start": left, "end": right, "checks": measurements}


def main(folder):
    model, protocol = load_source(folder)
    sampling_control()
    cases = [c for c in model.cases(protocol) if c["mode"] == "directional"]
    starts = (256,384,512)
    ticks = sorted({left+offset for left in starts for offset in (0,2,16,32,48,64)})
    times = [t/640 for t in ticks]
    config = {**protocol,"time":{**protocol["time"],"end":times[-1],"field_times":times}}
    _, raw, saved = model.run(config,cases,48,1/640)
    np.testing.assert_allclose(times,saved,rtol=0,atol=2e-15)
    results = []
    for i, case in enumerate(cases):
        fields = {tick:Snapshot(raw[j,i]) for j,tick in enumerate(ticks)}
        results.append({"weight":case["weight"],"pulse":case["pulse"],
                        "intervals":[interval(fields,s) for s in starts]})
    return {"grid":48,"solver_dt":1/640,"markers_per_interval":256,"cases":results}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source_folder",type=Path)
    print(json.dumps(main(parser.parse_args().source_folder),indent=2,allow_nan=False))
