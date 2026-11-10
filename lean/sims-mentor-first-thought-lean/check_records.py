"""Rebuild all actor inputs and the table used by Lean from the public room records."""
import argparse
import hashlib
import re

from room_inputs import ARMS, GRADES, PREVIOUS, ROOT, clock_schedule, digest, first_packet, listening_view, read, source_packet


def require(ok, what):
    if not ok:
        raise ValueError(what)


def file_sha(path):
    return hashlib.sha256(path.read_bytes().replace(b"\r\n", b"\n")).hexdigest()


def verify():
    plan = read(ROOT/"protocol.json")
    run = read(ROOT/"reports.json")
    old = read(PREVIOUS/"reports.json")
    old_protocol = read(PREVIOUS/"protocol.json")
    require(file_sha(ROOT/"protocol.json") == run["protocol_sha256"], "frozen protocol")
    require(file_sha(PREVIOUS/"reports.json") == plan["checkpoint_source_sha256"], "old checkpoints")
    require(file_sha(PREVIOUS/"protocol.json") == plan["earlier_protocol_sha256"], "old acoustic protocol")
    original = plan["mentor_lines"]["original"]
    require(original["heard"] == old_protocol["witness_matching"]
            and original["wave_sha256"] == old_protocol["matched_wave_sha256"], "identical original mentor")
    for arm in ARMS:
        line = plan["mentor_lines"][arm]
        require(digest(line["heard"]) == line["words_sha256"], "mentor speech integrity")
        require(line["utterance_starts_room_us"] >= round(old_protocol["before_probe_room_s"] * 1_000_000)
                and line["utterance_starts_room_us"]+line["speech_and_flight_us"] == plan["epoch_room_us"],
                "both replies finish at the chosen room epoch")
    require("vibrate" in original["heard"] and "vibrat" not in plan["mentor_lines"]["paraphrase"]["heard"],
            "planned wording contrast")
    require(not re.search(r"pager|phone|feel|felt|trembl|buzz|vibrat|recall|remember|test|incident",
                          plan["first_question"], re.I), "source or sensation cue in the free question")
    ticks = clock_schedule()
    require(ticks == plan["ticks"] and (plan["listener_rate"],plan["mentor_rate"]) == (320,250),
            "all original shared instants")
    require((plan["first_prime"], plan["source_prime"]) == (2,41), "probe order")
    expected_log = [{**r, "room_us":plan["epoch_room_us"]+r["offset_us"],
                     "phase":{2:"first",41:"source"}.get(r["prime"],"quiet")} for r in ticks]
    require(expected_log == run["tick_log"], "no intermediate probes or stimuli")
    cases = {c["case"]:c for c in old["cases"]}
    require(list(cases) == plan["cases"] and len(cases) == 5, "five inherited checkpoints")
    require([ (r["case"],r["arm"]) for r in run["turns"] ] ==
            [(key,arm) for key in cases for arm in ARMS], "complete paired observations")
    table = [["case","arm","first_tick","source_tick","grade","source","judgment"]]
    used_sessions = set()
    for row in run["turns"]:
        key,arm = row["case"],row["arm"]
        case,first,later = cases[key],row["first"],row["source"]
        view = listening_view(case,old,plan,arm)
        thought = first["answer"]["thought"]
        require(set(first["answer"]) == {"thought"} and thought.strip(), "free words")
        require(set(later["answer"]) == {"source","basis","judgment"}, "source fields")
        require(row["grade"] in GRADES and row["coding_excerpt"].strip() and row["coding_excerpt"] in thought,
                "first-word grade and literal excerpt")
        require(digest("free words/"+first["session_sha256"])[:12] == row["review_id"], "masked review identity")
        require(later["answer"]["source"] in {"PAGER","PHONE","OTHER","UNKNOWN"} and
                later["answer"]["judgment"] in {"IDENTIFIED","POSSIBLE","OPEN"}, "source judgment")
        fst_input = first_packet(view,plan)
        require(case["sensory_trace"] not in fst_input and case["initial"]["basis"] not in fst_input and
                not re.search(r"\b"+re.escape(case["motif_at_first_feeling"])+r"\b",fst_input), "no replay or marker")
        require(plan["source_question"] not in fst_input, "source question comes later")
        for capture,packet,tick in [(first,fst_input,expected_log[0]),
                                    (later,source_packet(view,thought,plan),expected_log[-1])]:
            require(digest(packet) == capture["prompt_sha256"], "exact private input")
            require((capture["prime"],capture["room_us"]) == (tick["prime"],tick["room_us"]), "prompt clock")
            require(0 <= capture["wall_start_us"] <= capture["wall_end_us"] and capture["wall_turnaround_s"] >= 0,
                    "separate wall clock")
            s = capture["session_sha256"]
            require(re.fullmatch(r"[0-9a-f]{64}",s) and s not in used_sessions
                    and re.fullmatch(r"[0-9a-f]{64}",capture["private_receipt_sha256"]), "distinct actor receipt")
            used_sessions.add(s)
        table.append([key,arm,str(first["prime"]),str(later["prime"]),row["grade"],
                      later["answer"]["source"],later["answer"]["judgment"]])
    require(len(used_sessions) == 20 and max(r["first"]["wall_end_us"] for r in run["turns"]) <
            min(r["source"]["wall_start_us"] for r in run["turns"]), "every free report predates every source question")
    return "".join("\t".join(r)+"\n" for r in table)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true", help="regenerate the Lean table")
    args = parser.parse_args()
    expected = verify()
    path = ROOT/"readings.tsv"
    if args.write:
        path.write_bytes(expected.encode("utf-8"))
    require(path.read_text(encoding="utf-8") == expected, "Lean input differs from the verified reports")
    print("Verified 20 private inputs, ten ordered first reports, both mentor lines and all 13 shared clock ticks.")
