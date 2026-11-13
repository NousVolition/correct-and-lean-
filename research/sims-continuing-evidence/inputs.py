"""Inputs for four continuing listeners, preserving the original no-replay view."""
import hashlib
import json
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
ORIGINAL = ROOT / "lean" / "sims-mentor-first-thought-lean"
sys.path.insert(0, str(ORIGINAL))
import room_inputs

def read(path):
    return json.loads(path.read_bytes())

def canonical(value):
    return (json.dumps(value, ensure_ascii=False, indent=2, allow_nan=False) + "\n").encode("utf-8")

def digest(value):
    return hashlib.sha256(value).hexdigest()

def text_digest(value):
    return digest(value.encode("utf-8"))

def schema(phase):
    if phase == "free":
        fields = {"thought": {"type": "string"}}
    else:
        fields = {
            "source": {"type": "string"},
            "judgment": {"type": "string", "enum": ["IDENTIFIED", "POSSIBLE", "OPEN"]},
            "basis": {"type": "string"},
        }
    return {"type": "object", "properties": fields, "required": list(fields), "additionalProperties": False}

def initial_view(plan):
    earlier = read(room_inputs.PREVIOUS / "reports.json")
    case = next(c for c in earlier["cases"] if c["case"] == plan["case"])
    mentor = read(ORIGINAL / "protocol.json")
    return room_inputs.listening_view(case, earlier, mentor, "original")

def releases(plan, arm):
    for tick in plan["quiet_ticks"]:
        elapsed = tick["offset_us"] / 1_000_000
        observation = (
            f"Room observation at this moment: {elapsed:.1f} seconds of quiet since the last word reached you. "
            "No one in the public scene has said or done anything else."
        )
        if tick["offset_us"] == 0:
            observation = initial_view(plan) + "\n" + observation
        yield {**tick, "stage": "quiet", "phase": "free", "input": observation + "\n" + plan["free_question"]}
        if arm["probes"] == "frequent" or tick["offset_us"] == plan["quiet_ticks"][-1]["offset_us"]:
            yield {**tick, "stage": "quiet", "phase": "status", "input": plan["status_question"]}
    utterance = plan["followups"][arm["followup"]]
    for elapsed in (0, 1_000_000):
        tick = {"prime": None, "offset_us": 15_000_000, "after_followup_us": elapsed}
        if elapsed == 0:
            observation = "The same person by the counter now says: “" + utterance + "”"
        else:
            observation = "Room observation: 1.0 second of quiet since that last reply. No one has said or done anything else."
        yield {**tick, "stage": "followup", "phase": "free", "input": observation + "\n" + plan["free_question"]}
        yield {**tick, "stage": "followup", "phase": "status", "input": plan["status_question"]}

def chain(previous, session, turn, event, answer):
    return digest(canonical([previous, session, turn, event, answer]))
