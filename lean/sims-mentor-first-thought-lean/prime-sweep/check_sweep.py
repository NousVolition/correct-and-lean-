"""Rebuild all 130 private inputs, clock stamps and the separate free and prompted readouts."""
import argparse
import hashlib
import re
from results import describe
from sweep_inputs import CERTAINTY, FEELING, ROOT, first_input, observation_view, original, read, source_input


def require(ok, reason):
    if not ok:
        raise ValueError(reason)


def digest_file(path):
    return hashlib.sha256(path.read_bytes().replace(b"\r\n",b"\n")).hexdigest()


def verify():
    plan=read(ROOT/"protocol.json")
    run=read(ROOT/"reports.json")
    old=read(ROOT.parent/"protocol.json")
    earlier=read(original.PREVIOUS/"reports.json")
    require(digest_file(ROOT/"protocol.json")==run["protocol_sha256"],"frozen protocol")
    require(digest_file(ROOT.parent/"protocol.json")==plan["earlier_first_thought_protocol_sha256"] and
            digest_file(original.PREVIOUS/"reports.json")==plan["earlier_room_records_sha256"],"prior checkpoints")
    require(digest_file(ROOT/"slope-source.json")==plan["slope_source_sha256"],"frozen slope comparison")
    slope=read(ROOT/"slope-source.json")["refined_checks"]
    for grid in (32,48):
        for cutoff,time in ((0.15,1.106),(0.10,1.126)):
            for bracket,expected in (([29,31],[]),([37,41],[time])):
                hits=[r["split_times"] for r in slope if
                      (r["sampling_grid"],r["relative_level"],r["bracket"])==(grid,cutoff,bracket)]
                require(hits==[expected],"sourced Hug cutoff comparison")
    fine=read(ROOT/"slope-refinement.json")["persistent_splits"]
    require({(r["cutoff_pct"],r["grid"]):r["split_us"] for r in fine}==
            {(15,64):[1106000],(15,96):[1104000],(15,128):[1104000],
             (10,64):[1126000],(10,96):[1126000],(10,128):[1126000]}, "denser slope readback")
    require(plan["mentor_line"]==old["mentor_lines"]["original"] and plan["epoch_room_us"]==old["epoch_room_us"],
            "original mentor words, audio and epoch")
    require(plan["source_question"]==old["source_question"] and not re.search(
        r"know|certain|probably|pager|phone|trembl|feel|felt|recall|remember|buzz|vibrat",plan["free_question"],re.I),
        "neutral present-time free question")
    require(plan["feeling_grades"]==old["categories"],"prior feeling rubric")
    ticks=original.clock_schedule()
    require(len(plan["ticks"])==len(ticks)==13,"all prime coincidences")
    for frozen,t in zip(plan["ticks"],ticks,strict=True):
        require(all(frozen[k]==v for k,v in t.items()) and frozen["room_us"]==old["epoch_room_us"]+t["offset_us"],
                "clock correspondence")
        require(frozen["quiet_frames"]*1_000_000==t["offset_us"]*plan["sample_rate"],"quiet duration")
    cases={c["case"]:c for c in earlier["cases"]}
    require(plan["cases"]==list(cases) and len(cases)==5,"old five event references")
    rows=run["trials"]
    require([(r["prime"],r["case"]) for r in rows]==[(t["prime"],k) for t in ticks for k in cases],
            "one new listener per checkpoint per prime")
    by_tick={t["prime"]:t for t in plan["ticks"]}
    sessions=set()
    table=[["prime","case","free_certainty","free_feeling","source","judgment","grounded"]]
    for r in rows:
        t,case=by_tick[r["prime"]],cases[r["case"]]
        require(r["room_us"]==t["room_us"],"both probes held at the assigned instant")
        view=observation_view(case,earlier,old,t)
        require(not re.search(r"\b"+re.escape(case["motif_at_first_feeling"])+r"\b",view,re.I) and
                case["sensory_trace"] not in view and case["initial"]["basis"] not in view,"no replay")
        free,source=r["free"],r["source"]
        words=free["answer"]["thought"]
        require(set(free["answer"])=={"thought"} and words.strip() and r["certainty"] in CERTAINTY
                and r["feeling"] in FEELING,"independent first report grades")
        require(all(r[k] and r[k] in words for k in ("certainty_excerpt","feeling_excerpt")),"literal rubric excerpts")
        require(set(source["answer"])=={"basis","source","judgment"} and source["answer"]["basis"].strip()
                and source["answer"]["source"] in {"PAGER","PHONE","OTHER","UNKNOWN"} and
                source["answer"]["judgment"] in {"OPEN","POSSIBLE","IDENTIFIED"},"later source response")
        require(r["basis_excerpt"] and r["basis_excerpt"] in source["answer"]["basis"] and
                type(r["grounded"]) is bool,"source review excerpt")
        require(original.digest("sweep-free/"+free["session_sha256"])[:14]==r["review_id"] and
                original.digest("sweep-source/"+source["session_sha256"])[:14]==r["source_review_id"],"blind labels")
        require(plan["source_question"] not in first_input(view,plan),"source question cannot precede open words")
        for capture,packet in [(free,first_input(view,plan)),(source,source_input(view,words,plan))]:
            require(capture["prompt_sha256"]==original.digest(packet),"exact actor input")
            require(0<=capture["wall_start_us"]<=capture["wall_end_us"] and capture["wall_turnaround_s"]>=0,
                    "wall clock")
            s=capture["session_sha256"]
            require(re.fullmatch("[0-9a-f]{64}",s) and s not in sessions and
                    re.fullmatch("[0-9a-f]{64}",capture["receipt_sha256"]),"distinct authenticated actor receipt")
            sessions.add(s)
        table.append([str(t["prime"]),r["case"],r["certainty"],r["feeling"],source["answer"]["source"],
                      source["answer"]["judgment"],"yes" if r["grounded"] else "no"])
    require(len(sessions)==130 and max(r["free"]["wall_end_us"] for r in rows) <
            min(r["source"]["wall_start_us"] for r in rows),"all open answers locked before any status interview")
    require(describe(rows)==run["results"],"per-prime counts, crossings and adjacent slopes")
    return "".join("\t".join(row)+"\n" for row in table)


if __name__=="__main__":
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write",action="store_true",help="regenerate the checked Lean table")
    write=parser.parse_args().write
    expected=verify()
    table=ROOT/"readings.tsv"
    if write: table.write_bytes(expected.encode("utf-8"))
    require(table.read_text(encoding="utf-8")==expected,"Lean input disagrees with the verified interviews")
    print("Checked 65 fresh no-replay listeners, 130 private turns, identical mentor evidence and 13 shared prime ticks.")
