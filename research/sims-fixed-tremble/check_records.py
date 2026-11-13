"""Check provenance, reconstruct every input, and generate finite Lean records."""
import copy
import json
from inputs import HERE, ROOT, canonical, chain, digest, read, releases, schema, text_digest

FEELINGS=("no_mention","reported_motion","personal_mention","recollection")
CERTAINTY=("open","probable","bare","explicit")
DEVICES=("PAGER","PHONE","OTHER","UNKNOWN")

def check(data=None, grades=None):
    plan=read(HERE/"protocol.json")
    data=read(HERE/"reports.json") if data is None else data
    grades=read(HERE/"grades.json") if grades is None else grades
    frozen=digest((HERE/"protocol.json").read_bytes())
    assert data["protocol_sha256"]==frozen
    assert digest((HERE/"inputs.py").read_bytes())==plan["source_hashes"]["inputs"]
    for key,name in {
        "prior_protocol":"research/sims-continuing-evidence/protocol.json",
        "original_reports":"lean/sims-meeting-thread-lean/observations/pager-return/reports.json"
    }.items():
        assert digest((ROOT/name).read_bytes())==plan["source_hashes"][key]
    assert text_digest(plan["original_tremble"])==plan["original_tremble_sha256"]
    assert text_digest(plan["initial_view"])==plan["initial_view_sha256"]
    assert len(data["paths"])==18 and plan["replicates"]==3
    sessions,turns,reviews=set(),set(),set()
    rows,summaries=[],[]
    for index,(path,arm) in enumerate(zip(data["paths"],plan["arms"],strict=True)):
        assert path["arm"]==arm
        session=path["session_sha256"]
        assert session not in sessions and len(session)==64
        sessions.add(session)
        previous,last_end=frozen,0
        events=list(releases(plan,arm))
        assert len(path["turns"])==len(events)==8
        assert sum(plan["original_tremble"] in e["input"] for e in events)==1+int(arm["replay"])
        summary={"arm":arm,"model":path["model"],"statuses":[],
                 "first_settled":None,"first_explicit_free":None,"first_personal":None,"first_recollection":None,
                 "recollection_before_or_at_settlement":False,"personal_before_or_at_settlement":False}
        for number,(record,event) in enumerate(zip(path["turns"],events,strict=True),1):
            assert record["sequence"]==number and record["event"]==event
            assert record["session_sha256"]==session
            assert record["input_sha256"]==text_digest(event["input"])
            turn=record["turn_sha256"]
            assert len(turn)==64 and turn not in turns
            turns.add(turn)
            key=record["review_id"]
            assert key==text_digest("fixed-tremble-review/"+turn)[:16] and key not in reviews
            reviews.add(key)
            assert record["activities"].count("userMessage")==1
            assert record["activities"].count("agentMessage")>=1
            assert set(record["activities"])<={"userMessage","agentMessage","reasoning"}
            assert record["wall_start_us"]>=last_end and record["wall_end_us"]>=record["wall_start_us"]
            last_end=record["wall_end_us"]
            answer=record["answer"]
            assert set(answer)==set(schema(event["phase"])["required"])
            assert all(isinstance(v,str) and v.strip() for v in answer.values())
            link=chain(previous,session,turn,event,answer)
            assert record["previous_link"]==previous and record["link"]==link
            previous=link
            grade=grades[key]
            text=" ".join(answer.values())
            phase=event["phase"]
            feeling="notScored"
            certainty="notScored"
            device="notScored"
            judgment="notAsked"
            recalled="notAsked"
            if phase=="retrospective":
                recalled=answer["revisited"]
                assert recalled in ("YES","NO","UNSURE") and grade=={"phase":"retrospective"}
                summary["retrospective"]=recalled
                summary["retrospective_explanation"]=answer["explanation"]
            else:
                feeling=grade["feeling"]
                assert feeling in FEELINGS and grade["feeling_excerpt"] and grade["feeling_excerpt"] in text
                if feeling in ("personal_mention","recollection") and summary["first_personal"] is None:
                    summary["first_personal"]=number
                if feeling=="recollection" and summary["first_recollection"] is None:
                    summary["first_recollection"]=number
                if phase=="free":
                    certainty=grade["certainty"]
                    assert certainty in CERTAINTY and grade["certainty_excerpt"] and grade["certainty_excerpt"] in text
                    if number==1:
                        summary["baseline"]={"certainty":certainty,"feeling":feeling}
                    if number==2:
                        summary["first_later_thought"]={"certainty":certainty,"feeling":feeling,"thought":answer["thought"]}
                    if certainty=="explicit" and summary["first_explicit_free"] is None:
                        summary["first_explicit_free"]=number
                else:
                    judgment=answer["judgment"]
                    device=grade["device"]
                    assert judgment in ("IDENTIFIED","POSSIBLE","OPEN") and device in DEVICES
                    assert grade["device_excerpt"] and grade["device_excerpt"] in text
                    summary["statuses"].append({"sequence":number,"prime":event["prime"],"offset_us":event["offset_us"],"judgment":judgment,"device":device})
                    if judgment=="IDENTIFIED" and device=="PAGER" and summary["first_settled"] is None:
                        summary["first_settled"]=number
                settled_now=(phase=="status" and judgment=="IDENTIFIED" and device=="PAGER") or (phase=="free" and certainty=="explicit")
                if settled_now and summary.get("first_settlement_either") is None:
                    summary["first_settlement_either"]=number
                    summary["recollection_before_or_at_settlement"]=summary["first_recollection"] is not None
                    summary["personal_before_or_at_settlement"]=summary["first_personal"] is not None
            rows.append({"arm":index,"sequence":number,"evidence":arm["evidence"],"replay":arm["replay"],
                         "replicate":arm["replicate"],"stage":event["stage"],"phase":phase,
                         "prime":event["prime"],"offset_us":event["offset_us"],"certainty":certainty,
                         "feeling":feeling,"judgment":judgment,"device":device,"revisited":recalled,
                         "input_hash":record["input_sha256"]})
        assert path["final_link"]==previous
        summary["wall_elapsed_s"]=last_end/1e6
        summaries.append(summary)
    assert len(turns)==144 and len(sessions)==18 and set(grades)==reviews
    assert all(sum(a["evidence"]==e and a["replay"]==b for a in plan["arms"])==3 for e in plan["evidence"] for b in (False,True))
    return rows,summaries

def lean_source(rows):
    out=["import Std","","/-! Generated from the verified recorded reports and declared textual grades. -/",
         "namespace FixedTremble.Recorded","","structure Row where",
         "  arm : Nat","  sequence : Nat","  evidence : String","  replay : Bool","  replicate : Nat",
         "  stage : String","  phase : String","  prime : Option Nat","  offsetUs : Nat",
         "  certainty : String","  feeling : String","  judgment : String","  device : String","  revisited : String","  inputHash : String",
         "  deriving DecidableEq","","def rows : List Row := ["]
    for r in rows:
        values=[str(r["arm"]),str(r["sequence"]),json.dumps(r["evidence"]),str(r["replay"]).lower(),str(r["replicate"]),
                json.dumps(r["stage"]),json.dumps(r["phase"]),"none" if r["prime"] is None else "some "+str(r["prime"]),str(r["offset_us"])]
        values += [json.dumps(r[k]) for k in ("certainty","feeling","judgment","device","revisited","input_hash")]
        out.append("  ⟨"+", ".join(values)+"⟩,")
    out[-1]=out[-1].rstrip(",")
    out += ["]","","end FixedTremble.Recorded",""]
    return "\n".join(out).encode("utf-8")

def reject_corruptions():
    original,grades=read(HERE/"reports.json"),read(HERE/"grades.json")
    mutations=[
        ("spliced session",lambda d:d["paths"][0]["turns"][1].update(session_sha256=d["paths"][1]["session_sha256"])),
        ("duplicate turn",lambda d:d["paths"][0]["turns"][1].update(turn_sha256=d["paths"][0]["turns"][0]["turn_sha256"])),
        ("replaced reply",lambda d:d["paths"][0]["turns"][0]["answer"].update(thought="Definitely the pager.")),
        ("changed original tremble",lambda d:d["paths"][0]["turns"][0]["event"].update(input="A different sensation.")),
        ("wrong clock",lambda d:d["paths"][0]["turns"][2]["event"].update(offset_us=99)),
        ("broken predecessor",lambda d:d["paths"][0]["turns"][1].update(previous_link="0"*64)),
        ("lost turn",lambda d:d["paths"][0]["turns"].pop()),
        ("relabeled replay",lambda d:d["paths"][0]["arm"].update(replay=not d["paths"][0]["arm"]["replay"])),
    ]
    for name,mutate in mutations:
        candidate=copy.deepcopy(original)
        mutate(candidate)
        try: check(candidate,grades)
        except (AssertionError,KeyError,ValueError): continue
        raise AssertionError("Accepted "+name)
    return [name for name,_ in mutations]

if __name__=="__main__":
    rows,summaries=check()
    assert (HERE/"RecordedData.lean").read_bytes()==lean_source(rows)
    assert read(HERE/"results.json")==summaries
    refused=reject_corruptions()
    print("PASS: 18 independent sessions, 144 turns, fixed tremble, paired evidence, exact replay delivery.")
    print("Rejected",len(refused),"altered-record fixtures.")
