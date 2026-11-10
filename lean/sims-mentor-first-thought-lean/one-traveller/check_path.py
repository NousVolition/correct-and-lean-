"""Reconstruct the 26 released inputs and validate the unbroken single-session receipt chain."""
import argparse
import re
from analysis import describe
from inputs import HERE, chain_link, original, read, releases, schema, sha


def require(ok,message):
    if not ok: raise ValueError(message)


def digest_file(path):
    return sha(path.read_bytes().replace(b"\r\n",b"\n"))


def verify():
    plan=read(HERE/"protocol.json")
    reports=read(HERE/"reports.json")
    prior=read(original.PREVIOUS/"reports.json")
    mentor=read(HERE.parent/"protocol.json")
    sweep=read(HERE.parent/"prime-sweep/protocol.json")
    previous=digest_file(HERE/"protocol.json")
    require(previous==reports["protocol_sha256"],"frozen longitudinal protocol")
    for path,key in [(original.PREVIOUS/"reports.json","prior_room_sha256"),(HERE.parent/"protocol.json","mentor_protocol_sha256"),
                     (HERE.parent/"prime-sweep/protocol.json","sweep_protocol_sha256")]:
        require(digest_file(path)==plan[key],"older pinned restaurant input")
    require(sweep["mentor_line"]==mentor["mentor_lines"]["original"]==plan["mentor_line"] and
            plan["epoch_room_us"]==sweep["epoch_room_us"],"same mentor, audio and clock origin")
    require(sweep["ticks"]==plan["ticks"] and
            all(all(t[k]==v for k,v in shared.items()) for shared,t in zip(original.clock_schedule(),plan["ticks"],strict=True)),
            "same prime labels, quiet frames and timing")
    case=prior["cases"][0]
    require(case["case"]==plan["case"]==reports["case"]==sweep["cases"][0] and
            original.digest(case["shared_checkpoint"])==case["shared_checkpoint_sha256"]==plan["checkpoint_sha256"],
            "first predetermined event checkpoint")
    require(plan["free_question"]==sweep["free_question"] and plan["free_certainty"]==sweep["free_certainty"]
            and plan["feeling_grades"]==sweep["feeling_grades"],"same free-report rubric")
    events=reports["turns"]
    messages=list(releases(plan,case,prior,mentor))
    require(len(messages)==len(events)==26,"all ordered probes")
    session=reports["session_sha256"]
    require(re.fullmatch("[0-9a-f]{64}",session),"session fingerprint")
    used=set()
    end=0
    for i,(t,(tick,phase,packet)) in enumerate(zip(events,messages,strict=True),1):
        require(t["sequence"]==i and (t["prime"],t["phase"],t["room_us"])==(tick["prime"],phase,tick["room_us"]),"time/order")
        require(t["session_sha256"]==session and t["input_sha256"]==original.digest(packet),"same session and exact released text")
        turn=t["turn_sha256"]
        require(re.fullmatch("[0-9a-f]{64}",turn) and turn not in used and
                re.fullmatch("[0-9a-f]{64}",t["private_receipt_sha256"]),"unique backend turn and original receipt")
        used.add(turn)
        require(t["previous_link"]==previous,"previous response chain")
        previous=chain_link(previous,session,turn,t["prime"],phase,packet,t["answer"])
        require(previous==t["link"] and original.digest("one-traveller-review/"+turn)[:14]==t["review_id"],"response binding")
        require(t["wall_start_us"]>=end and t["wall_end_us"]>=t["wall_start_us"],"serial wall-time capture")
        end=t["wall_end_us"]
        require(t["activities"].count("userMessage")==1 and t["activities"].count("agentMessage")>=1
                and set(t["activities"]) <= {"userMessage","reasoning","agentMessage"},"tool-free delivered input and output")
        require(case["sensory_trace"] not in packet and case["initial"]["basis"] not in packet and
                not re.search(r"\b"+re.escape(case["motif_at_first_feeling"])+r"\b",packet,re.I),"sensory input withheld")
        if i>1:
            require(not re.search(r"\b(pager|phone|tremble|buzz|feel|felt|vibrat\w*|remember\w*|replay)\b",packet,re.I),
                    "later prompt would name a source or felt sensation")
        a=t["answer"]
        require(set(a)==set(schema(phase)["required"]) and all(isinstance(v,str) and v.strip() for v in a.values()),"reported fields")
        words=" ".join(a.values())
        require(t["feeling"] in sweep["feeling_grades"] and t["feeling_excerpt"] and t["feeling_excerpt"] in words,"verbatim feeling grade")
        if phase=="free":
            require(t["free_certainty"] in sweep["free_certainty"] and t["certainty_excerpt"] and
                    t["certainty_excerpt"] in a["thought"],"free certainty grade")
        else:
            require(a["judgment"] in {"IDENTIFIED","POSSIBLE","OPEN"} and t["device"] in {"PAGER","PHONE","OTHER","UNKNOWN"} and
                    type(t["grounded"]) is bool and t["basis_excerpt"] and t["basis_excerpt"] in a["basis"],"judgment and firsthand evidence")
    require(sum(m.count(plan["mentor_line"]["heard"]) for _,_,m in messages)==1 and
            plan["mentor_line"]["heard"] in messages[0][2],"one mentor delivery")
    require(previous==reports["final_link"] and len(used)==26,"complete session")
    audit=reports["history_check"]
    require(audit["thread_read"] in {"matched","unavailable","no retained turn list"} and
            (audit["thread_read"]!="matched" or audit["listed_turns"]==26),"post-run server check")
    require(describe(events)==reports["results"],"transition and feeling ordering analysis")
    table=[["prime","offset_us","session","free_turn","status_turn","free_certainty","free_feeling","source","judgment","grounded","status_feeling"]]
    for tick,free,status in zip(plan["ticks"],events[::2],events[1::2],strict=True):
        table.append([str(tick["prime"]),str(tick["offset_us"]),session,free["turn_sha256"],status["turn_sha256"],
                      free["free_certainty"],free["feeling"],status["device"],status["answer"]["judgment"],
                      "yes" if status["grounded"] else "no",status["feeling"]])
    return "".join("\t".join(row)+"\n" for row in table)


if __name__=="__main__":
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write",action="store_true",help="regenerate the verified Lean ledger")
    write=parser.parse_args().write
    expected=verify()
    target=HERE/"readings.tsv"
    if write: target.write_bytes(expected.encode("utf-8"))
    require(target.read_text(encoding="utf-8")==expected,"Lean ledger differs")
    print("Verified one continuing session, 26 distinct ordered turns, one mentor answer and all 13 no-replay ticks.")
