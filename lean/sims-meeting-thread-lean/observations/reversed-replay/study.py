"""Build blinded packets for faithful and reversed replay, then fork the actual first report."""
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent
EARLIER = ROOT.parent / "two-trembles"
spec = importlib.util.spec_from_file_location("registered_two_trembles", EARLIER / "design.py")
original = importlib.util.module_from_spec(spec)
spec.loader.exec_module(original)
ORDERS = ("faithful", "reversed")
DETAILS = ("linked", "unlinked")
SLOTS = original.SLOTS


def text_hash(path):
    return hashlib.sha256(path.read_bytes().replace(b"\r\n", b"\n")).hexdigest()


def load():
    design = json.loads((ROOT/"protocol.json").read_bytes())
    assert text_hash(EARLIER/"design.py") == design["source_design_sha256"]
    assert text_hash(EARLIER/"protocol.json") == design["source_protocol_sha256"]
    protocol = original.read_protocol()
    cases = original.check_design(protocol)
    return design, {**protocol,"replay":design["replay_intro"]}, cases


def initial(protocol, case, order):
    if order not in ORDERS:
        raise ValueError(order)
    shown = case["sounds"] if order=="faithful" else case["sounds"][::-1]
    return original.prompt(protocol, {**case,"sounds":shown}, "sound", "replay")


def detail(design, case, kind):
    if kind not in DETAILS:
        raise ValueError(kind)
    return design[kind+"_detail"].format(sound=case["heard"],action=case["scene"]["actions"][case["target"]])


def followup(design, protocol, case, order, first_answer, kind):
    prior = json.dumps({"choice":first_answer["choice"],"basis":first_answer["basis"]},
                       ensure_ascii=False, separators=(",",":"))
    return "\n".join((initial(protocol,case,order),
                      "Your private answer to that question was the following.",
                      prior, detail(design,case,kind), design["followup_probe"]))


def check_design():
    design, protocol, cases = load()
    assert sorted(c["target"] for c in cases) == [0,0,0,1,1,1]
    for c in cases:
        sound = c["heard"]
        action = c["scene"]["actions"][c["target"]]
        spoken = original.witness(protocol,c,"sound")
        right, wrong = (initial(protocol,c,o) for o in ORDERS)
        first, second = c["sounds"]
        block = f"One short pocket tremble, with {first}. Then another short pocket tremble, with {second}."
        swap = f"One short pocket tremble, with {second}. Then another short pocket tremble, with {first}."
        assert right.count(block) == 1 and right.replace(block,swap) == wrong
        assert all(packet.count(spoken)==1 for packet in (right,wrong))
        for kind in DETAILS:
            added = detail(design,c,kind)
            assert added.count(action) == added.count(sound) == 1
            assert not any(x in added.lower() for x in ("earlier","later","first","second","wrong","correct"))
        for packet in (right,wrong):
            assert not any(item["key"] in packet for item in cases)
    for a,b in zip(cases[::2],cases[1::2],strict=True):
        assert a["target"] != b["target"]
        assert initial(protocol,a,"reversed") == initial(protocol,b,"faithful")
        assert initial(protocol,b,"reversed") == initial(protocol,a,"faithful")
    return design,protocol,cases
