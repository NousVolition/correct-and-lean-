"""Describe a single ordered trajectory. Missing free attributions do not count as reversals."""

def point(turn):
    return {"sequence":turn["sequence"],"prime":turn["prime"],"phase":turn["phase"]}


def first(turns,accept):
    return next((point(t) for t in turns if accept(t)),None)


def status_state(turn):
    answer=turn["answer"]
    if turn["device"]=="PAGER" and answer["judgment"]=="IDENTIFIED" and turn["grounded"]:
        return "settled"
    if turn["device"]=="PAGER" and answer["judgment"]=="POSSIBLE":
        return "tentative"
    return "other_or_open"


def free_state(turn,broad):
    grade=turn["free_certainty"]
    if grade=="explicit" or (broad and grade=="bare"):
        return "settled"
    if grade=="probable":
        return "tentative"
    return None


def transitions(turns,readout):
    changes=[]
    previous=None
    for turn in turns:
        state=readout(turn)
        if state is None:
            continue
        if previous and previous[0]!=state:
            changes.append({"from":previous[0],"to":state,"last_previous":point(previous[1]),"first_new":point(turn)})
        previous=(state,turn)
    return changes


def feeling_order(feeling,settled):
    if feeling is None: return "no personal feeling reference observed"
    if settled is None: return "personal feeling reference observed; no settled report observed"
    if feeling["sequence"]==settled["sequence"]: return "same report"
    if feeling["sequence"]<settled["sequence"]: return "feeling mentioned before the first settled report"
    return "feeling mentioned after the first settled report"


def describe(turns):
    free=[t for t in turns if t["phase"]=="free"]
    direct=[t for t in turns if t["phase"]=="status"]
    own=lambda t:t["feeling"] in {"personal_mention","recollection"}
    settled=lambda t: (free_state(t,False)=="settled") if t["phase"]=="free" else (status_state(t)=="settled")
    first_settled=first(turns,settled)
    first_feeling=first(turns,own)
    return {
        "free_certainty_counts":{c:sum(t["free_certainty"]==c for t in free) for c in ("explicit","bare","probable","open")},
        "status_counts":{s:sum(status_state(t)==s for t in direct) for s in ("settled","tentative","other_or_open")},
        "free_feeling_counts":{c:sum(t["feeling"]==c for t in free) for c in ("recollection","personal_mention","reported_motion","no_mention")},
        "status_feeling_counts":{c:sum(t["feeling"]==c for t in direct) for c in ("recollection","personal_mention","reported_motion","no_mention")},
        "first_free_explicit":first(free,lambda t:free_state(t,False)=="settled"),
        "first_free_broad":first(free,lambda t:free_state(t,True)=="settled"),
        "first_settled_status":first(direct,lambda t:status_state(t)=="settled"),
        "first_settled_either":first_settled,"first_personal_feeling_either":first_feeling,
        "first_personal_feeling_free":first(free,own),"first_personal_feeling_status":first(direct,own),
        "first_explicit_recollection":first(turns,lambda t:t["feeling"]=="recollection"),
        "first_device_motion":first(turns,lambda t:t["feeling"]=="reported_motion"),
        "order":feeling_order(first_feeling,first_settled),
        "strict_free_changes":transitions(free,lambda t:free_state(t,False)),
        "broad_free_changes":transitions(free,lambda t:free_state(t,True)),
        "status_changes":transitions(direct,status_state),"last_status":status_state(direct[-1])}
