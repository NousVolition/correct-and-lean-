"""Verify the paired state transitions and reconstruct the table read by Lean."""
import argparse
from collections import Counter
import csv
import hashlib
import json
import re
import study

ROOT=study.ROOT
FROZEN="e399d747f9afbdd9b64a447965716089b6fdb147"
PROTOCOL="46603285442117ca94d8b262f627c5b77829913a6385cf9d86129add3415c9cb"
BUILDER="ea04e21967d56749f96a7085c337a950cd60658ac63706a5fc662f78a3e80aae"
HEADER=["world","order","target","mentioned_action","mentioned_sound","initial","linked","linked_notice","unlinked","unlinked_notice"]


def require(value,message):
    if not value: raise ValueError(message)


def sha(s):
    return hashlib.sha256(s.encode("utf-8")).hexdigest()


def canonical(value):
    result=value.strip().upper()
    return result if result in (*study.SLOTS,"OPEN") else "INVALID"


def performance(choice,target):
    if choice==target: return "correct"
    if choice in study.SLOTS: return "wrong"
    return choice.lower()


def notice_id(row):
    return sha("reversal-reason/"+row["session_sha256"])[:12]


def mentioned_mark(words, linked, unlinked):
    heard=[word for word in words if word in linked and word in unlinked]
    require(len(heard)==1,"one feature mentioned in both action details")
    return ("A","B")[sorted(words).index(heard[0])]


def verify(write=False):
    plan,original,cases=study.check_design()
    saved=json.loads((ROOT/"reports.json").read_bytes())
    require(saved["frozen_commit"]==FROZEN, "preregistration revision")
    require(study.text_hash(ROOT/"protocol.json")==saved["protocol_sha256"]==PROTOCOL,"protocol digest")
    require(study.text_hash(ROOT/"study.py")==saved["study_sha256"]==BUILDER,"packet builder digest")
    rows=saved["reports"]
    indexed={(r["world"],r["order"],r["stage"]):r for r in rows}
    sessions={r["session_sha256"] for r in rows}
    require(len(sessions)==len(indexed)==len(rows)==36,"36 independent report sessions")
    require(all(re.fullmatch("[0-9a-f]{64}",s) for s in sessions),"session fingerprints")
    with (ROOT/"conflict-review.tsv").open(encoding="utf-8",newline="") as f:
        codings=list(csv.DictReader(f,delimiter="\t"))
    notices={c["review_id"]:c["code"] for c in codings}
    require(len(notices)==len(codings)==24 and set(notices.values()) <= {"EXPLICIT","NOT_EXPLICIT"},
            "one conflict code for every follow-up")
    table=[HEADER]
    outcomes={order:{s:Counter() for s in ("initial",*study.DETAILS)} for order in study.ORDERS}
    used_notices=set()
    for case in cases:
        target=study.SLOTS[case["target"]]
        for order in study.ORDERS:
            parent=indexed[case["key"],order,"initial"]
            check_response(parent)
            require("parent_session_sha256" not in parent,"initial report has a parent")
            require(parent["prompt_sha256"]==sha(study.initial(original,case,order)),"initial prompt fingerprint")
            first=canonical(parent["response"]["choice"])
            initial=performance(first,target)
            outcomes[order]["initial"][initial]+=1
            paired_details=[study.detail(plan,case,k) for k in study.DETAILS]
            action=mentioned_mark(case["scene"]["actions"],*paired_details)
            sound=mentioned_mark(case["scene"]["sounds"],*paired_details)
            line=[case["key"],order,target,action,sound,first]
            for kind in study.DETAILS:
                child=indexed[case["key"],order,kind]
                check_response(child)
                require(child["parent_session_sha256"]==parent["session_sha256"],"continuation parent")
                actual_packet=study.followup(plan,original,case,order,parent["response"],kind)
                require(child["prompt_sha256"]==sha(actual_packet),"continuation transcript fingerprint")
                review=notice_id(child)
                code=notices[review]
                used_notices.add(review)
                choice=canonical(child["response"]["choice"])
                final=performance(choice,target)
                counts=outcomes[order][kind]
                counts[final]+=1
                counts["explicit"]+=int(code=="EXPLICIT")
                if initial=="wrong":
                    counts["initially_wrong"]+=1
                    counts["initially_wrong_to_"+final]+=1
                    counts["initially_wrong_explicit"]+=int(code=="EXPLICIT")
                line.extend([choice,code])
            table.append(line)
    require(used_notices==set(notices),"unmatched conflict code")
    text="\n".join("\t".join(r) for r in table)+"\n"
    target_file=ROOT/"readings.tsv"
    if write: target_file.write_text(text,encoding="utf-8",newline="\n")
    else: require(target_file.read_text(encoding="utf-8")==text,"Lean table differs from the records")
    return outcomes


def check_response(row):
    a=row["response"]
    require(set(a)=={"choice","basis"} and all(isinstance(s,str) and s.strip() for s in a.values()),
            "raw categorical report and explanation")


if __name__=="__main__":
    parser=argparse.ArgumentParser()
    parser.add_argument("--write-table",action="store_true")
    print(json.dumps(verify(parser.parse_args().write_table),indent=2))
