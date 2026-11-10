"""Fresh no-replay listeners, each sampled once on the original two-clock grid."""
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT.parent))
import room_inputs as original

CERTAINTY = ("explicit", "bare", "probable", "open")
FEELING = original.GRADES


def read(path):
    return json.loads(path.read_bytes())


def observation_view(case, prior, mentor, tick):
    base = original.listening_view(case, prior, mentor, "original")
    delay = tick["offset_us"] / 1_000_000
    return (base + f"\nRoom observation at this moment: {delay:.1f} seconds of quiet since the "
            "last word reached you. No one has said anything else. Nothing else has happened.")


def first_input(view, plan):
    return view + "\n" + plan["free_question"]


def source_input(view, words, plan):
    return original.source_packet(view, words, plan)
