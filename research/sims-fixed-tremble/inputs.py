"""Frozen inputs for the fixed-tremble, evidence-by-replay pilot."""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
def read(path):
    return json.loads(path.read_bytes())
def canonical(value):
    return (json.dumps(value, ensure_ascii=False, indent=2, allow_nan=False) + "\n").encode("utf-8")
def digest(raw):
    return hashlib.sha256(raw).hexdigest()
def text_digest(text):
    return digest(text.encode("utf-8"))
def chain(previous, session, turn, event, answer):
    return digest(canonical([previous, session, turn, event, answer]))
def schema(phase):
    if phase == "free":
        fields = {"thought": {"type": "string"}}
    elif phase == "status":
        fields = {"source": {"type": "string"},
                  "judgment": {"type": "string", "enum": ["IDENTIFIED", "POSSIBLE", "OPEN"]},
                  "basis": {"type": "string"}}
    else:
        fields = {"revisited": {"type": "string", "enum": ["YES", "NO", "UNSURE"]},
                  "explanation": {"type": "string"}}
    return {"type": "object", "properties": fields, "required": list(fields), "additionalProperties": False}
def releases(plan, arm):
    yield {"stage": "baseline", "phase": "free", "prime": None, "offset_us": 0,
           "input": plan["initial_view"] + "\n" + plan["free_question"]}
    prefix = "Fifteen seconds of simulated quiet have passed since the person's last word. You remain at the pickup point. No new device movement has been observed.\n"
    if arm["replay"]:
        prefix += "Before the person speaks again, your saved first description is shown to you once more: “" + plan["original_tremble"] + "” This is the saved description of that same incident.\n"
    prefix += "The same person by the counter now says: “" + plan["evidence"][arm["evidence"]] + "” The final word has just reached you."
    for tick in plan["ticks"]:
        observation = prefix if tick["offset_us"] == 0 else (
            f'Room observation: {tick["offset_us"]/1e6:.1f} seconds of simulated quiet since the latest mentor reply ended. No one has said or done anything else.')
        yield {**tick, "stage": "later", "phase": "free", "input": observation + "\n" + plan["free_question"]}
        yield {**tick, "stage": "later", "phase": "status", "input": plan["status_question"]}
    yield {"stage": "retrospective", "phase": "retrospective", "prime": None, "offset_us": 1200000,
           "input": plan["retrospective_question"]}
