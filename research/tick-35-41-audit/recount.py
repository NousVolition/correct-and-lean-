"""Audit released tick-35--41 records without running a solver or actor.

Run from any directory: python research/tick-35-41-audit/recount.py
Use --write to refresh this audit's results.json after a deliberate source update.
"""
import argparse
import csv
import hashlib
import json
import math
from pathlib import Path
import statistics

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
FLUID = ROOT / "research/hug-v3/finer-grid-study"
SIMS = ROOT / "lean/sims-mentor-first-thought-lean"
TARGET = 0.001
WINDOWS = ("local", "extended")


def require(condition, message):
    if not condition:
        raise ValueError(message)


def read(path):
    return json.loads(path.read_bytes())


def csvrows(path):
    with path.open(encoding="utf-8-sig", newline="") as source:
        return list(csv.DictReader(source))


def close(a, b, message, tolerance=1e-14):
    require(math.isfinite(a) and math.isfinite(b) and abs(a-b) <= tolerance, message)


def microseconds(value):
    return round(float(value)*1_000_000)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def verify_inputs():
    manifest = read(HERE / "source-manifest.json")
    for entry in manifest["copied_files"]:
        data = (HERE / entry["published_path"]).read_bytes()
        require(len(data) == entry["bytes"] and sha(data) == entry["sha256"],
                "Imported record changed: " + entry["published_path"])
    for entry in manifest["repository_inputs"]:
        data = (ROOT / entry["path"]).read_bytes().replace(b"\r\n", b"\n")
        require(sha(data) == entry["lf_text_sha256"], "Repository input changed: " + entry["path"])
    return manifest


def load_gaps(run):
    rows = [r for r in csvrows(FLUID / "runs" / run / "gaps-primary.csv") if r["convention"] == "fixed"]
    data = {(microseconds(r["time"]), int(r["seed"])): r for r in rows}
    keys = {(1_100_000+2_000*i, pair) for i in range(51) for pair in range(25)}
    require(len(rows) == len(data) == 1275 and set(data) == keys, "Incomplete fixed-label source: " + run)
    for row in rows:
        local, extended = float(row["local_gap"]), float(row["extended_gap"])
        require(math.isfinite(local) and 0 <= extended <= local + 1e-12, "Invalid nested-window gap")
    return data


def snapshot(rows):
    worst = max(rows, key=lambda r: r["difference"])
    return {"maximum_difference": worst["difference"], "time": worst["time_us"]/1e6,
            "pair": worst["pair"], "window": worst["window"],
            "pairs_above_target": sorted({r["pair"] for r in rows if r["difference"] > TARGET})}


def summarize(rows):
    times = sorted({r["time_us"] for r in rows})
    by_time = []
    for time in times:
        subset = [r for r in rows if r["time_us"] == time]
        item = snapshot(subset)
        outside = [r for r in subset if r.get("outside", False)]
        item["outside_maximum_difference"] = max((r["difference"] for r in outside), default=None)
        item["outside_sample_count"] = len(outside)
        by_time.append(item)
    outside = [r for r in rows if r.get("outside", False)]
    return {"samples": len(rows), "times": len(times), "full": snapshot(rows),
            "tick37": snapshot([r for r in rows if r["time_us"] == 1_100_000]),
            "tick41_before_write": snapshot([r for r in rows if r["time_us"] == 1_200_000]),
            "saved_times_above_target": sum(bool(r["pairs_above_target"]) for r in by_time),
            "outside_samples": len(outside), "outside": snapshot(outside) if outside else None,
            "outside_failures": [{"time": r["time_us"]/1e6, "pair": r["pair"],
                "window": r["window"], "difference": r["difference"]}
                for r in outside if r["difference"] > TARGET], "by_time": by_time}


def fluid_records():
    runs = {tag: load_gaps(tag) for tag in ("n40_dt0p0005", "n48_dt0p0005", "n48_dt0p00025")}
    windows = read(HERE / "data/declared-windows.json")
    require(len(windows) == 50, "Expected both windows for each pair")
    # Rebuild the frozen exclusions from the original coarse-output records.
    for pair in range(25):
        for window in WINDOWS:
            bounds = []
            for run in ("n40_dt0p0005", "n48_dt0p0005"):
                data = runs[run]
                times = sorted(t for t, p in data if p == pair)
                rises = [float(data[b, pair][window+"_gap"])-float(data[a, pair][window+"_gap"])
                         for a, b in zip(times, times[1:])]
                index = max(range(len(rises)), key=rises.__getitem__)
                lo, hi = max(times[0], times[index]-2000), min(times[-1], times[index+1]+2000)
                original = windows[f"{pair}:{window}"]["constituents"][run]
                require((lo, hi) == (microseconds(original["lo"]), microseconds(original["hi"])), "Frozen constituent moved")
                require([times[index], times[index+1]] == [microseconds(t) for t in original["rise_bracket"]], "Rise bracket moved")
                bounds.append((lo, hi))
            union = windows[f"{pair}:{window}"]
            require((microseconds(union["lo"]), microseconds(union["hi"])) ==
                    (min(a for a,b in bounds), max(b for a,b in bounds)), "Frozen union moved")
    imported = csvrows(HERE / "data/comparison-samples.csv")
    require({r["comparison"] for r in imported} == {"space40_48", "time48_full_history"}, "Unknown comparison")
    groups = {key: [] for key in ("space40_48", "time48_full_history")}
    seen = set()
    for row in imported:
        comparison, time, pair, window = row["comparison"], microseconds(row["time"]), int(row["seed"]), row["window"]
        identity = comparison, time, pair, window
        require(identity not in seen and window in WINDOWS and 0 <= pair < 25, "Duplicate/invalid reading")
        seen.add(identity)
        left, right = float(row["coarse_gap"]), float(row["fine_gap"])
        require(math.isfinite(left) and math.isfinite(right) and min(left,right) >= 0, "Invalid distance")
        difference = abs(left-right)
        close(difference, float(row["absolute_error"]), "Stored subtraction mismatch")
        limits = windows[f"{pair}:{window}"]
        outside = time < microseconds(limits["lo"]) or time > microseconds(limits["hi"])
        require(outside == (row["outside_transition"] == "True"), "Incorrect exclusion label")
        require((difference <= TARGET) == (row["target_met"] == "True"), "Incorrect target label")
        if time % 2000 == 0:
            a, b = ("n40_dt0p0005", "n48_dt0p0005") if comparison == "space40_48" else ("n48_dt0p0005", "n48_dt0p00025")
            close(left, float(runs[a][time,pair][window+"_gap"]), "Coarse common-time record changed")
            close(right, float(runs[b][time,pair][window+"_gap"]), "Fine common-time record changed")
        groups[comparison].append({"time_us": time, "pair": pair, "window": window,
                                  "coarse_gap": left, "fine_gap": right, "difference": difference, "outside": outside})
    for comparison, count, step in (("space40_48",201,500), ("time48_full_history",51,2000)):
        keys = {(r["time_us"],r["pair"],r["window"]) for r in groups[comparison]}
        require(keys == {(1_100_000+i*step,p,w) for i in range(count) for p in range(25) for w in WINDOWS}, "Missing comparison cells")
    corrections = read(HERE / "data/tracing-correction.json")
    for correction in corrections:
        require(correction["grid"] == 40 and correction["pair"] == 5 and correction["time"] == 1.1805, "Unexpected correction")
        require(abs(correction["direct_4096"]-correction["direct_8192"]) < .00005, "Direct correction unresolved")
        row = next(r for r in groups["space40_48"] if (r["time_us"],r["pair"],r["window"]) == (1180500,5,correction["window"]))
        close(row["coarse_gap"], correction["direct_8192"], "Correction not carried into table")
    sparse = [r for r in groups["space40_48"] if r["time_us"] % 2000 == 0]
    return {"sparse_spatial": summarize(sparse), "native_spatial": summarize(groups["space40_48"]),
            "full_history_time_control": summarize(groups["time48_full_history"]),
            "common_time_comparisons_match_published_sources": True, "frozen_windows_reconstructed": 50,
            "direct_corrected_window_readings": len(corrections)}


def direct_extrema():
    rows = read(HERE / "data/direct-extrema.json")
    indexed = {(r["grid"],r["denominator"],microseconds(r["time"]),r["seed"]):r for r in rows}
    cases = [(1169000,23), (1195000,3), (1195500,3)]
    require(len(indexed) == len(rows) == 12, "Missing direct readouts")
    results = []
    for time, pair in cases:
        for window in WINDOWS:
            field = window + "_gap"
            coarse, fine = indexed[40,8192,time,pair][field], indexed[48,8192,time,pair][field]
            agreement = max(abs(indexed[n,4096,time,pair][field]-indexed[n,8192,time,pair][field]) for n in (40,48))
            require(agreement < .00005, "Unresolved direct refinement")
            results.append({"time":time/1e6,"pair":pair,"window":window,
                            "grid_difference":abs(coarse-fine),"max_direct_step_difference":agreement})
    return results


def crossing(times, gaps, fraction):
    level = gaps[0]+fraction*(gaps[-1]-gaps[0])
    index = next(i for i, gap in enumerate(gaps) if gap >= level)
    require(index > 0, "Crossing lacks left bracket")
    before, after = gaps[index-1:index+1]
    estimate = times[index-1] + (level-before)/(after-before)*(times[index]-times[index-1])
    return {"first_sample":times[index],"bracket":[times[index-1],times[index]],"interpolated":estimate}


def pair6():
    rows = csvrows(HERE / "data/pair6-native.csv")
    times = [float(r["time"]) for r in rows]
    require([microseconds(t) for t in times] == list(range(1178000,1186001,500)), "Pair 6 native schedule")
    comparisons = {(microseconds(r["time"]),r["window"]):r for r in csvrows(HERE / "data/comparison-samples.csv")
                   if r["comparison"] == "space40_48" and r["seed"] == "6"}
    for row in rows:
        for window in WINDOWS:
            comparison = comparisons[microseconds(row["time"]),window]
            close(float(row["gap_40"]),float(comparison["coarse_gap"]),"Pair 6 coarse source join")
            close(float(row["gap_48"]),float(comparison["fine_gap"]),"Pair 6 fine source join")
    values = {}
    for grid in (40,48):
        gaps = [float(r[f"gap_{grid}"]) for r in rows]
        increments = [b-a for a,b in zip(gaps,gaps[1:])]
        require(all(d>0 for d in increments), "Pair 6 increase no longer monotone")
        values[str(grid)] = {"samples":len(rows),"positive_increments":len(increments),
            "largest_increment_share":max(increments)/(gaps[-1]-gaps[0]),"half":crossing(times,gaps,.5),
            "10_to_90_duration":crossing(times,gaps,.9)["interpolated"]-crossing(times,gaps,.1)["interpolated"]}
    local = []
    for row in csvrows(HERE / "data/pair6-local-timing.csv"):
        d = {k:float(v) for k,v in row.items() if k != "scope"}
        close(d["t50_48"]-d["t50_40"],d["offset_48_minus_40"],"Local offset subtraction")
        local.append({**d,"scope":row["scope"]})
    return {"native":values,"native_estimated_offset":values["48"]["half"]["interpolated"]-values["40"]["half"]["interpolated"],
            "local_timing_table":local,"local_table_scope":"Saved interpolation estimates and brackets; local runs inherit coarse-history starts."}


def write_meter():
    rows = csvrows(FLUID / "prime-meter.csv")
    require(len(rows) == 80 and len({(r["run"],r["prime"],r["side"]) for r in rows}) == 80, "Prime meter identity")
    labels = [2,3,5,7,11,13,17,19,23,29,31,37,41]
    for r in rows:
        close(float(r["model_time"]),labels.index(int(r["prime"]))/10,"Prime-meter clock")
    out = []
    fields = ("kinetic","elastic","thermal","energy","source_work","breathing_work","write_work","memory","model_scalar_A_not_particle_A")
    for run in sorted({r["run"] for r in rows}):
        a = next(r for r in rows if (r["run"],r["prime"],r["side"]) == (run,"41","before_write"))
        b = next(r for r in rows if (r["run"],r["prime"],r["side"]) == (run,"41","after_write"))
        delta = {k:float(b[k])-float(a[k]) for k in fields}
        close(delta["energy"],delta["write_work"],"Write energy account",1e-15)
        require(delta["kinetic"] == 0,"Kinetic value changed at write")
        out.append({"run":run,"delta":delta,"energy_minus_write_work":delta["energy"]-delta["write_work"]})
    return out


def travellers():
    plan = read(SIMS / "one-traveller/protocol.json")
    report = read(SIMS / "one-traveller/reports.json")
    sweep_plan = read(SIMS / "prime-sweep/protocol.json")
    sweep = read(SIMS / "prime-sweep/reports.json")
    early = read(SIMS / "reports.json")
    require(plan["ticks"] == sweep_plan["ticks"], "Traveller clocks differ")
    clock = [{"prime":t["prime"],"offset_seconds":t["offset_us"]/1e6,
              "listener_step":t["listener_step"],"mentor_step":t["mentor_step"]}
             for t in plan["ticks"] if 35 <= t["prime"] <= 41]
    require([t["prime"] for t in clock] == [37,41], "Unexpected late prime labels")
    turns = report["turns"]
    require(len(turns) == 26 and len({r["turn_sha256"] for r in turns}) == 26,"Continuing turn identity")
    previous = report["protocol_sha256"]
    for sequence, turn in enumerate(turns,1):
        require(turn["sequence"] == sequence and turn["session_sha256"] == report["session_sha256"],"Session/order changed")
        require(turn["previous_link"] == previous,"Broken prior reply link")
        payload = [previous,turn["session_sha256"],turn["turn_sha256"],turn["prime"],turn["phase"],turn["input_sha256"],turn["answer"]]
        previous = sha((json.dumps(payload,ensure_ascii=False,indent=2,allow_nan=False)+"\n").encode())
        require(previous == turn["link"],"Broken reply binding")
    require(previous == report["final_link"],"Wrong final reply link")
    late = [r for r in turns if 35 <= r["prime"] <= 41]
    groups = []
    for prime in (37,41):
        rows = [r for r in sweep["trials"] if r["prime"] == prime]
        require(len(rows) == 5,"Missing fresh listeners")
        groups.append({"prime":prime,"samples":len(rows),
            "settled_free":sum(r["certainty"] in ("explicit","bare") for r in rows),
            "grounded_identified":sum(r["grounded"] and r["source"]["answer"]["source"] == "PAGER" and r["source"]["answer"]["judgment"] == "IDENTIFIED" for r in rows),
            "identified_cases":[r["case"] for r in rows if r["source"]["answer"]["judgment"] == "IDENTIFIED"]})
    require(len({r["free"]["session_sha256"] for r in sweep["trials"] if r["prime"] in (37,41)}) == 10,"Fresh groups share free sessions")
    early_counts = []
    for arm in ("original","paraphrase"):
        rows = [r for r in early["turns"] if r["arm"] == arm]
        require(len(rows) == 5 and all(r["source"]["prime"] == 41 for r in rows),"Earlier source schedule")
        early_counts.append({"arm":arm,"samples":5,"identified":sum(r["source"]["answer"]["judgment"] == "IDENTIFIED" for r in rows)})
    return {"clock":clock,"missing_requested_prime_labels":[35,36,38,39,40],
        "continuing_late":[{k:r[k] for k in ("sequence","prime","phase","answer","feeling")} for r in late],
        "continuing_source_answer_identical":late[1]["answer"] == late[3]["answer"],
        "released_reply_hash_chain_checked":True,"prompt_reconstruction_rerun":False,
        "fresh_groups":groups,"earlier_two_probe_tick41":early_counts}


def audit():
    inputs = verify_inputs()
    replay = [read(HERE / f"data/replay{n}-receipt.json") for n in (40,48)]
    require(all(r["status"] == "complete" and r["saved_native_samples"] == 201 and
            r["checked_common_samples"] == 51 and max(r["final_array_errors"].values()) == 0 and
            r["native_event_crcs_match"] for r in replay),"Incomplete prior replay receipt")
    result = {"source_revision":inputs["source_revision"],"scope":"Recount of saved distances, write meters and released Traveller records. No solver, actor or Lean rerun.",
        "verified_imported_file_hashes":len(inputs["copied_files"]),"verified_repository_text_hashes":len(inputs["repository_inputs"]),
        "fluid":fluid_records(),"direct_checks":direct_extrema(),"pair6":pair6(),"write_meter":write_meter(),"travellers":travellers(),
        "prior_replay_receipts_checked":2,"replay_run_by_this_audit":False}
    prior = read(HERE / "data/prior-verification.json")
    native = result["fluid"]["native_spatial"]
    require((native["samples"],native["outside_samples"]) == (prior["full_samples"],prior["outside_samples"]), "Prior audit coverage differs")
    for current, original in ((native["full"],prior["worst_full"]),(native["outside"],prior["worst_outside"])):
        require((current["time"],current["pair"],current["window"]) == (original["time"],original["pair"],original["window"]), "Prior audit maximum identity differs")
        close(current["maximum_difference"],original["absolute_error"],"Prior audit maximum differs")
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write",action="store_true")
    args = parser.parse_args()
    result = audit()
    path = HERE / "results.json"
    if args.write:
        path.write_text(json.dumps(result,ensure_ascii=False,indent=2,allow_nan=False)+"\n",encoding="utf-8")
    else:
        require(result == read(path),"Saved audit result differs from recount")
    print(json.dumps({"status":"pass","imported_hashes":result["verified_imported_file_hashes"],
        "repository_hashes":result["verified_repository_text_hashes"],
        "sparse":{k:v for k,v in result["fluid"]["sparse_spatial"].items() if k not in ("by_time","outside_failures")},
        "native":{k:v for k,v in result["fluid"]["native_spatial"].items() if k not in ("by_time",)},
        "continuing_answer_identical":result["travellers"]["continuing_source_answer_identical"]},indent=2))
