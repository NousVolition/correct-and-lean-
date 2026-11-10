"""The common no-replay checkpoint, exact clock coincidences and two ordered interviews."""
import hashlib
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parent
PREVIOUS = ROOT.parent / "sims-meeting-thread-lean" / "observations" / "pager-return"
ARMS = ("original", "paraphrase")
GRADES = ("recollection", "personal_mention", "reported_motion", "no_mention")


def read(path):
    return json.loads(path.read_bytes())


def digest(text):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def primes_through(n):
    return [p for p in range(2, n + 1) if all(p % d for d in range(2, p) if d*d <= p)]


def clock_schedule():
    # The listener inherits the marker clock. Both clocks start when the final word arrives.
    primes = primes_through(41)
    shared = [(k, 250*k//320) for k in range(385) if (250*k) % 320 == 0]
    return [{"prime": p, "listener_step": k, "mentor_step": j, "offset_us": k*1_000_000//320}
            for p, (k, j) in zip(primes, shared, strict=True)]


def listening_view(case, earlier, protocol, arm):
    line = protocol["mentor_lines"][arm]["heard"]
    return "\n".join([case["shared_checkpoint"], earlier["direct_visual"],
                      "You hear the other person say: “" + line + "”"])


def first_packet(view, protocol):
    return view + "\n" + protocol["first_question"]


def source_packet(view, thought, protocol):
    return "\n".join([view, "Your immediately preceding private answer, verbatim: “" + thought + "”",
                      protocol["source_question"]])
