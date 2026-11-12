"""Matched residual writes at the transverse coordinate x=0, using the sealed Hug writer."""
import argparse
import csv
import hashlib
import json
import struct
import sys
import zlib
from pathlib import Path

import numpy as np


def load_state(path):
    with np.load(path, allow_pickle=False) as data:
        return {key: data[key] for key in data.files}


def state_digest(state):
    hash_ = hashlib.sha256()
    for key in sorted(state):
        a = np.ascontiguousarray(state[key])
        hash_.update(str((key, a.shape, a.dtype.str)).encode())
        hash_.update(a.tobytes())
    return hash_.hexdigest()


def run(root, out):
    sys.path.insert(0, str(root / "upstream"))
    from preflight import approve
    from structural_hug import Config, Solver, HEADER

    main = approve("main")
    solver = Solver(Config(**main["config"]))
    solver.initial()
    fabric = solver.fabric
    audit = root / "results/provenance-audit"
    source = audit / "sealed-main/prime-23-before_write.npz"
    template = load_state(audit / "sealed-main/prime-23-after_write.npz")
    expected = next(r for r in csv.DictReader((audit / "write-records.csv").open())
                    if r["experiment"] == "sealed-main" and r["prime"] == "23")
    slot, event = solver.read_material(template)[-1]
    original = fabric.payload(event)
    assert hashlib.sha256(original).hexdigest() == expected["payload_sha256"]
    assert slot == 1 and event["event_id"] == 1 and event["end"] == .8

    common = load_state(source)
    common_hash = state_digest(common)
    old_record, = solver.read_material(common)
    assert old_record[1]["event_id"] == 0
    # Reserve one existing numeric word for the external probe reading. All
    # other payload bytes before the checksum are the original tick-23 bytes.
    word = 2*HEADER
    rows = []
    for residual in (0., 2.):
        before = {key: value.copy() for key, value in common.items()}
        assert state_digest(before) == common_hash
        probe = dict(event, delta_E=event["delta_E"].copy())
        probe["delta_E"][0,0] = residual
        payload = fabric.payload(probe)
        assert payload[:word] == original[:word] and payload[word+2:-4] == original[word+2:-4]
        code = struct.unpack_from("<h", payload, word)[0]
        assert code == round(residual/solver.c.strain_quantum)
        assert struct.unpack("<I",payload[-4:])[0] == zlib.crc32(payload[:-4])
        after, account = solver.write_event(before, probe)
        records = solver.read_material(after)
        assert [r["event_id"] for _,r in records] == [0,1] and account["slot"]==slot
        assert fabric.payload(records[0][1]) == fabric.payload(old_record[1])
        assert fabric.payload(records[1][1]) == payload and records[1][1]["delta_E"][0,0] == residual

        bits = np.unpackbits(np.frombuffer(payload,dtype=np.uint8),bitorder="little")
        indices = slice(slot*fabric.bits_per_slot, (slot+1)*fabric.bits_per_slot)
        target = solver.c.rest_amplitude*(2*bits.astype(float)-1)
        q = fabric.weight[indices]*solver.c.stroke_drag*(target-before["b"][indices])**2/solver.c.stroke_duration
        heat = float(account["heat"])
        grid_heat = float(np.mean(after["g"][...,4] - before["g"][...,4]))
        np.testing.assert_allclose([q.sum(),grid_heat,account["work"]-account["stored"]],heat,rtol=1e-11,atol=1e-18)
        assert state_digest(before) == common_hash
        word_heat = float(q[8*word:8*(word+2)].sum())
        crc_heat = float(q[-32:].sum())
        rows.append(dict(cue_x=0,prime_meter_tick=23,model_time=.8,event_id=1,slot=slot,residual=residual,
                         stored_code=code,readback=records[1][1]["delta_E"][0,0],write_heat=heat,
                         grid_heat_deposit=grid_heat,word_heat=word_heat,checksum_heat=crc_heat,
                         remaining_record_heat=float(q[:8*word].sum()+q[8*(word+2):-32].sum()),
                         checksum_ones=int(bits[-32:].sum()),word_ones=int(bits[8*word:8*(word+2)].sum()),
                         work=float(account["work"]),stored_energy_change=float(account["stored"]),
                         encoding="delta_E[0,0] carries residual component 2 in units of 0.0001",
                         prestate_sha256=common_hash,payload_sha256=hashlib.sha256(payload).hexdigest()))
    assert rows[0]["remaining_record_heat"] == rows[1]["remaining_record_heat"]
    with out.open("w",newline="",encoding="utf-8") as stream:
        writer=csv.DictWriter(stream,fieldnames=list(rows[0]));writer.writeheader();writer.writerows(rows)
    print(json.dumps(rows,indent=2))
    print("Heat difference",rows[1]["write_heat"]-rows[0]["write_heat"],
          "percent",100*(rows[1]["write_heat"]/rows[0]["write_heat"]-1))
    print("Word contribution",rows[1]["word_heat"]-rows[0]["word_heat"],
          "CRC contribution",rows[1]["checksum_heat"]-rows[0]["checksum_heat"])


if __name__ == "__main__":
    p=argparse.ArgumentParser()
    p.add_argument("setup",type=Path)
    p.add_argument("output",type=Path)
    args=p.parse_args()
    run(args.setup.resolve(),args.output.resolve())
