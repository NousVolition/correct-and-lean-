"""Rebuild the four chronological transcripts, review links and generated Lean readings."""
import copy
import json
from pathlib import Path
from inputs import HERE, ORIGINAL, canonical, chain, digest, read, releases, schema, text_digest

FEELINGS = ("no_mention", "reported_motion", "personal_mention", "recollection")
CERTAINTY = ("open", "probable", "bare", "explicit")

def check(data=None, grades=None):
    plan = read(HERE / "protocol.json")
    data = read(HERE / "reports.json") if data is None else data
    grades = read(HERE / "grades.json") if grades is None else grades
    frozen = digest((HERE / "protocol.json").read_bytes())
    assert data["protocol_sha256"] == frozen
    assert plan["source_hashes"]["new_inputs"] == digest((HERE / "inputs.py").read_bytes())
    for key, path in {
        "prior_protocol": ORIGINAL / "one-traveller/protocol.json",
        "prior_reports": ORIGINAL / "one-traveller/reports.json",
        "mentor_protocol": ORIGINAL / "protocol.json",
        "original_inputs": ORIGINAL / "room_inputs.py",
    }.items():
        assert plan["source_hashes"][key] == digest(path.read_bytes()), key
    assert len(data["paths"]) == 4
    sessions, turns, reviews = set(), set(), set()
    rows, summaries = [], []
    for index, (path, arm) in enumerate(zip(data["paths"], plan["arms"], strict=True)):
        assert path["arm"] == arm
        session = path["session_sha256"]
        assert session not in sessions and len(session) == 64
        sessions.add(session)
        previous, last_end = frozen, 0
        events = list(releases(plan, arm))
        assert len(path["turns"]) == len(events)
        summary = {"arm": arm, "model": path["model"], "first_free_personal": None,
                   "first_free_explicit": None, "first_free_bare_or_explicit": None,
                   "first_identified": None, "first_personal_any": None,
                   "quiet_free_certainty": {c: 0 for c in CERTAINTY},
                   "quiet_free_personal_count": 0, "quiet_status_counts": {k: 0 for k in ("IDENTIFIED", "POSSIBLE", "OPEN")},
                   "followup_status": [], "status_transitions": []}
        prior_status = None
        for number, (record, event) in enumerate(zip(path["turns"], events, strict=True), 1):
            assert record["sequence"] == number and record["event"] == event
            assert record["session_sha256"] == session
            assert record["input_sha256"] == text_digest(event["input"])
            assert record["turn_sha256"] not in turns
            turns.add(record["turn_sha256"])
            assert record["review_id"] == text_digest("continued-evidence-review/" + record["turn_sha256"])[:16]
            assert record["review_id"] not in reviews
            reviews.add(record["review_id"])
            assert record["activities"].count("userMessage") == 1
            assert record["activities"].count("agentMessage") >= 1
            assert set(record["activities"]) <= {"agentMessage", "reasoning", "userMessage"}
            assert record["wall_start_us"] >= last_end and record["wall_end_us"] >= record["wall_start_us"]
            last_end = record["wall_end_us"]
            assert set(record["answer"]) == set(schema(event["phase"])["required"])
            link = chain(previous, session, record["turn_sha256"], event, record["answer"])
            assert record["previous_link"] == previous and record["link"] == link
            previous = link
            grade = grades[record["review_id"]]
            assert grade["feeling"] in FEELINGS
            text = " ".join(record["answer"].values())
            assert grade["feeling_excerpt"] in text
            point = {"sequence": number, "stage": event["stage"], "prime": event["prime"],
                     "offset_us": event["offset_us"], "after_followup_us": event.get("after_followup_us"), "phase": event["phase"]}
            personal = grade["feeling"] in ("personal_mention", "recollection")
            if personal and summary["first_personal_any"] is None:
                summary["first_personal_any"] = point
            free = event["phase"] == "free"
            certainty, judgment, device = "notScored", "notAsked", "notScored"
            if free:
                certainty = grade["certainty"]
                assert certainty in CERTAINTY and grade["certainty_excerpt"] in text
                if personal and summary["first_free_personal"] is None:
                    summary["first_free_personal"] = point
                if certainty == "explicit" and summary["first_free_explicit"] is None:
                    summary["first_free_explicit"] = point
                if certainty in ("bare", "explicit") and summary["first_free_bare_or_explicit"] is None:
                    summary["first_free_bare_or_explicit"] = point
                if event["stage"] == "quiet":
                    summary["quiet_free_certainty"][certainty] += 1
                    summary["quiet_free_personal_count"] += int(personal)
            else:
                judgment, device = record["answer"]["judgment"], grade["device"]
                assert judgment in ("IDENTIFIED", "POSSIBLE", "OPEN") and device in ("PAGER", "PHONE", "OTHER")
                assert grade["device_excerpt"] in text
                if judgment == "IDENTIFIED" and device == "PAGER" and summary["first_identified"] is None:
                    summary["first_identified"] = point
                if prior_status and prior_status["judgment"] != judgment:
                    summary["status_transitions"].append({"from": prior_status, "to": {"judgment": judgment, "point": point}})
                prior_status = {"judgment": judgment, "point": point}
                if event["stage"] == "quiet":
                    summary["quiet_status_counts"][judgment] += 1
                    summary["last_quiet_judgment"] = judgment
                else:
                    summary["followup_status"].append({"point": point, "judgment": judgment})
            rows.append({"arm": index, "sequence": number, "quiet": event["stage"] == "quiet", "free": free,
                         "offset_us": event["offset_us"], "prime": event["prime"],
                         "after_followup_us": event.get("after_followup_us", 0),
                         "certainty": certainty, "feeling": grade["feeling"], "judgment": judgment, "device": device})
        assert path["final_link"] == previous
        summaries.append(summary)
    assert len(turns) == 120 and len(sessions) == 4 and set(grades) == reviews
    return rows, summaries

def lean_source(rows):
    out = [
        "import Std",
        "",
        "/-! Generated from the 120 verified turns and explicit textual grades.",
        "Lean checks these coded records. The raw sentences and rubric remain in reports.json and grades.json. -/",
        "namespace ContinuingEvidence.Recorded",
        "",
        "structure Row where",
        "  arm : Nat", "  sequence : Nat", "  quiet : Bool", "  free : Bool",
        "  offsetUs : Nat", "  prime : Option Nat", "  afterFollowupUs : Nat",
        "  certainty : String", "  feeling : String", "  judgment : String", "  device : String",
        "  deriving DecidableEq",
        "",
        "def rows : List Row := [",
    ]
    for row in rows:
        values = [str(row["arm"]), str(row["sequence"]), str(row["quiet"]).lower(), str(row["free"]).lower(),
                  str(row["offset_us"]), "none" if row["prime"] is None else "some " + str(row["prime"]),
                  str(row["after_followup_us"])]
        values += [json.dumps(row[k]) for k in ("certainty", "feeling", "judgment", "device")]
        out.append("  ⟨" + ", ".join(values) + "⟩,")
    out[-1] = out[-1].rstrip(",")
    out += ["]", "", "end ContinuingEvidence.Recorded", ""]
    return "\n".join(out).encode("utf-8")

def reject_corruptions():
    original, grades = read(HERE / "reports.json"), read(HERE / "grades.json")
    mutations = [
        ("spliced session", lambda d: d["paths"][0]["turns"][1].update(session_sha256=d["paths"][1]["session_sha256"])),
        ("duplicate turn", lambda d: d["paths"][0]["turns"][1].update(turn_sha256=d["paths"][0]["turns"][0]["turn_sha256"])),
        ("replaced reply", lambda d: d["paths"][0]["turns"][0]["answer"].update(thought="This was definitely a pager.")),
        ("changed delivered input", lambda d: d["paths"][0]["turns"][0]["event"].update(input="Replay the tremble.")),
        ("wrong clock", lambda d: d["paths"][0]["turns"][0]["event"].update(offset_us=99)),
        ("broken predecessor", lambda d: d["paths"][0]["turns"][1].update(previous_link="0" * 64)),
        ("lost turn", lambda d: d["paths"][0]["turns"].pop()),
    ]
    for name, mutate in mutations:
        candidate = copy.deepcopy(original)
        mutate(candidate)
        try:
            check(candidate, grades)
        except (AssertionError, KeyError, ValueError):
            continue
        raise AssertionError("Accepted " + name)
    return [name for name, _ in mutations]

if __name__ == "__main__":
    rows, summaries = check()
    assert (HERE / "RecordedData.lean").read_bytes() == lean_source(rows)
    assert read(HERE / "results.json") == summaries
    refused = reject_corruptions()
    print("PASS: four continuing sessions, 120 ordered turns, exact inputs, grades, clocks and Lean rows.")
    print("Rejected " + str(len(refused)) + " altered-record fixtures.")
