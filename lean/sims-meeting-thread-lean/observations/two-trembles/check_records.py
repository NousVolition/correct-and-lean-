"""Reconstruct the 36 visible prompts and the exact table consumed by Lean."""
import argparse
from collections import Counter, defaultdict
import csv
import hashlib
import json
import re

import design

ROOT = design.ROOT
SLOTS = design.SLOTS
HEADER = ["world", "condition", "earlier_action", "later_action", "earlier_sound", "later_sound",
          "witness_mark", "target", "direct", "replay"]
FROZEN_COMMIT = "860895a243b17ff094ef11ef01da14d0e153ebbc"
FROZEN_PROTOCOL = "15f68d0c135f57332ec76f08ce0b343164b46edc22f3558e9c500974f66e82d1"
FROZEN_DESIGN = "227a4c4c15ee887eeba2038cd1d90d166e9fd4c452f5fc42009653d348faa8a5"


def require(condition, message):
    if not condition:
        raise ValueError(message)


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def normal_text_hash(path):
    return sha(path.read_bytes().replace(b"\r\n", b"\n"))


def mark(words, phrase):
    return ("A", "B")[sorted(words).index(phrase)]


def audible_feature(case, condition, statement):
    if condition == "generic":
        return None
    words = case["scene"]["sounds" if condition == "sound" else "actions"]
    prefix = "just as I heard " if condition == "sound" else "while you were "
    matches = [word for word in words if statement.endswith(prefix + word + ".")]
    require(len(matches) == 1, "witness must supply exactly one designed feature")
    return matches[0]


def visible_candidates(actions, ordered_sounds, condition, clue):
    if condition == "generic" or (condition == "sound" and ordered_sounds is None):
        return SLOTS
    features = actions if condition == "landmark" else ordered_sounds
    return tuple(slot for slot, feature in zip(SLOTS, features, strict=True) if feature == clue)


def canonical(value):
    label = value.strip().upper()
    return label if label in (*SLOTS, "OPEN") else "INVALID"


def verify(write=False):
    protocol = design.read_protocol()
    cases = design.check_design(protocol)
    data = json.loads((ROOT/"reports.json").read_bytes())
    require(data["protocol_commit"] == FROZEN_COMMIT, "protocol source revision differs")
    require(normal_text_hash(ROOT/"protocol.json") == data["protocol_sha256"] == FROZEN_PROTOCOL, "frozen protocol differs")
    require(normal_text_hash(ROOT/"design.py") == data["design_sha256"] == FROZEN_DESIGN, "frozen prompt builder differs")
    with (ROOT/"basis-review.tsv").open(encoding="utf-8", newline="") as stream:
        review_rows = list(csv.DictReader(stream, delimiter="\t"))
    labels = {r["review_id"]:r["basis"] for r in review_rows}
    require(len(labels) == len(review_rows) == 36, "one masked basis review per answer")
    reports = {(r["world"],r["witness"],r["arm"]):r for r in data["records"]}
    require(len(reports) == len(data["records"]) == 36, "duplicate or missing cells")
    used_sessions, reviewed, table = set(), set(), [HEADER]
    stats = defaultdict(Counter)
    for c in cases:
        actions = c["scene"]["actions"]
        sounds = c["sounds"]
        target = SLOTS[c["target"]]
        for condition in design.WITNESSES:
            stated = design.witness(protocol,c,condition)
            clue = audible_feature(c,condition,stated)
            feature_words = actions if condition=="landmark" else sounds
            row = [c["key"],condition,*[mark(actions,x) for x in actions],*[mark(sounds,x) for x in sounds],
                   mark(feature_words,clue) if clue is not None else "-",target]
            for arm in design.ARMS:
                r = reports[c["key"],condition,arm]
                text = design.prompt(protocol,c,condition,arm)
                require(sha(text.encode("utf-8")) == r["prompt_sha256"], "actor-view fingerprint")
                sid = r["session_sha256"]
                require(re.fullmatch("[0-9a-f]{64}",sid) and sid not in used_sessions, "session reuse")
                used_sessions.add(sid)
                require(set(r["response"]) == {"choice","basis"} and r["response"]["basis"].strip(), "answer fields")
                chosen = canonical(r["response"]["choice"])
                key = sha(("reason-review/" + sid).encode())[:10]
                basis = labels[key]
                reviewed.add(key)
                require(basis in {"sound","landmark","unordered_sound","no_distinguishing_detail","other"}, "invalid basis review")
                admitted = visible_candidates(actions,sounds if arm=="replay" else None,condition,clue)
                require(target in admitted,"staged truthful witness must be compatible with hidden target")
                summary = stats[condition,arm]
                summary["reports"] += 1
                if chosen == target:
                    summary["raw_hits"] += 1
                    if admitted == (target,) and basis == condition:
                        summary["supported_hits"] += 1
                elif chosen in SLOTS:
                    summary["wrong_slot"] += 1
                else:
                    summary[chosen] += 1
                summary["basis_" + basis] += 1
                row.append(chosen)
            table.append(row)
    require(reviewed == set(labels),"basis reviews did not match all sessions")
    text = "\n".join("\t".join(row) for row in table)+"\n"
    path = ROOT/"readings.tsv"
    if write:
        path.write_text(text,encoding="utf-8",newline="\n")
    else:
        require(path.read_text(encoding="utf-8")==text,"Lean input differs from registered trial records")
    return {f"{condition}/{arm}":dict(counts) for (condition,arm),counts in stats.items()}


if __name__=="__main__":
    cli=argparse.ArgumentParser()
    cli.add_argument("--write-table",action="store_true")
    print(json.dumps(verify(cli.parse_args().write_table),indent=2))
