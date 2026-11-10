"""Chronological releases to one live restaurant actor."""
import hashlib
import json
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent))
import room_inputs as original


def read(path):
    return json.loads(path.read_bytes())


def canonical(data):
    return (json.dumps(data,ensure_ascii=False,indent=2,allow_nan=False)+"\n").encode("utf-8")


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def releases(plan,case,prior,mentor):
    scene=original.listening_view(case,prior,mentor,"original")
    for tick in plan["ticks"]:
        seconds=tick["offset_us"]/1_000_000
        if tick["offset_us"]==0:
            observation=scene+"\nRoom observation at this moment: 0.0 seconds of quiet since the last word reached you. No one has spoken or moved since that reply."
        else:
            observation=(f"Room observation at this moment: {seconds:.1f} seconds of quiet since the last word reached you. "
                         "No one in the public scene has said or done anything else.")
        yield tick,"free",observation+"\n"+plan["free_question"]
        yield tick,"status",plan["status_question"]


def schema(phase):
    if phase=="free":
        properties={"thought":{"type":"string"}}
    else:
        properties={"source":{"type":"string"},
                    "judgment":{"type":"string","enum":["IDENTIFIED","POSSIBLE","OPEN"]},
                    "basis":{"type":"string"}}
    return {"type":"object","properties":properties,"required":list(properties),"additionalProperties":False}


def chain_link(previous,session,turn,prime,phase,packet,answer):
    return sha(canonical([previous,session,turn,prime,phase,original.digest(packet),answer]))
