"""Summarize the fixed five-person samples with the predeclared reading rules."""
from sweep_inputs import original


def personally_mentions(row):
    return row["feeling"] in {"personal_mention","recollection"}


def identified(row):
    source=row["source"]["answer"]
    return source["source"]=="PAGER" and source["judgment"]=="IDENTIFIED" and row["grounded"]


def describe(rows):
    by_prime=[]
    for t in original.clock_schedule():
        group=[r for r in rows if r["prime"]==t["prime"]]
        if len(group)!=5:
            raise ValueError("Expected five separate listeners per tick")
        entry={**t, "n":len(group),
            "explicit":sum(r["certainty"]=="explicit" for r in group),
            "unhedged_or_explicit":sum(r["certainty"] in {"explicit","bare"} for r in group),
            "probable":sum(r["certainty"]=="probable" for r in group),
            "open":sum(r["certainty"]=="open" for r in group),
            "prompted_identified":sum(map(identified,group)),
            "prompted_pager_possible":sum((r["source"]["answer"]["source"],r["source"]["answer"]["judgment"])==("PAGER","POSSIBLE") for r in group),
            "own_feeling":sum(map(personally_mentions,group)),
            "recollection":sum(r["feeling"]=="recollection" for r in group),
            "device_motion_only":sum(r["feeling"]=="reported_motion" for r in group),
            "own_feeling_while_probable":sum(personally_mentions(r) and r["certainty"]=="probable" for r in group),
            "own_feeling_before_prompted_identification":sum(personally_mentions(r) and identified(r) for r in group)}
        # Between-tick differences compare different listeners. There are five at each tick and 0.1 s per interval.
        previous=by_prime[-1] if by_prime else None
        entry["change_in_share_per_second"]={name:2*(entry[name]-previous[name]) if previous else None
            for name in ("explicit","unhedged_or_explicit","prompted_identified","own_feeling")}
        by_prime.append(entry)
    def threshold(name,minimum):
        return next((t["prime"] for t in by_prime if t[name]>=minimum),None)
    thresholds={}
    for name in ("explicit","unhedged_or_explicit","prompted_identified","own_feeling"):
        thresholds[name]={"first_any":threshold(name,1),"first_majority":threshold(name,3),
            "first_sustained_majority":next((t["prime"] for i,t in enumerate(by_prime[:-1])
                 if all(later[name]>=3 for later in by_prime[i:])),None)}
    return {"by_prime":by_prime,"thresholds":thresholds}
