"""Verify the frozen actor inputs and regenerate the exact table Lean reads."""
import argparse
import hashlib
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parent
ARMS = ("direct", "replay")
PHASES = ("before", "matched", "different", "detail")


def digest(text):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def require(condition, message):
    if not condition:
        raise ValueError(message)


def report(row):
    return row["source"] + "/" + row["judgment"]


def verify():
    protocol_bytes = (ROOT / "protocol.json").read_bytes().replace(b"\r\n", b"\n")
    protocol = json.loads(protocol_bytes)
    records = json.loads((ROOT / "reports.json").read_bytes())
    require(hashlib.sha256(protocol_bytes).hexdigest() == records["protocol_sha256"], "protocol digest")
    require(hashlib.sha256(protocol_bytes.replace(b"\n", b"\r\n")).hexdigest()
            == records["frozen_room_protocol_crlf_sha256"], "original room protocol digest")
    require(digest(protocol["witness_matching"]) == protocol["matched_witness_utf8_sha256"], "witness digest")
    cases = records["cases"]
    designed = [(c["id"], c["private_motif"]) for c in protocol["cases"]]
    require(len(designed) == len({k for k, _ in designed}) == len({m for _, m in designed}) == 5,
            "five distinct cases and private markers")
    require([(c["case"], c["motif_at_first_feeling"]) for c in cases] == designed, "case schedule")
    views = records["separate_view_check"]["results"]
    require([r["case"] for r in views] == [k for k, _ in designed], "two-view cases")
    fields = ("before", "matched", "grounded", "different", "motif")
    header = ["case", "original_motif", "initial"] + [f"{arm}_{f}" for arm in ARMS for f in fields]
    table = [header]
    sessions = set()

    def check_input(observation, packet):
        require(digest(packet) == observation["prompt_sha256"], "private input digest")
        session = observation["session_sha256"]
        require(re.fullmatch("[0-9a-f]{64}", session) and session not in sessions, "distinct private session")
        sessions.add(session)

    for case, view in zip(cases, views, strict=True):
        first, key, motif = case["initial"], case["case"], case["motif_at_first_feeling"]
        common, trace = case["shared_checkpoint"], case["sensory_trace"]
        check_input(first, case["initial_input"])
        require(trace in case["initial_input"] and motif in trace, "original felt detail")
        require(digest(common) == case["shared_checkpoint_sha256"], "shared checkpoint")
        require(key in common and (first["source"] + " / " + first["judgment"]) in common, "retained question")
        values = [key, motif, report(first)]
        for arm in ARMS:
            branch = case["branches"][arm]
            require(set(branch) == set(PHASES), "complete source and marker probes")
            private = records["direct_visual"] if arm == "direct" else (
                "The first sensation comes back to mind. Your memory of it: “" + trace + "”")
            for phase in PHASES:
                obs = branch[phase]
                if phase == "before":
                    public = "The other person has not answered yet."
                else:
                    line = protocol["witness_different" if phase == "different" else "witness_matching"]
                    public = "You hear the other person say: “" + line + "”"
                packet = common + "\n" + private + "\n" + public + "\n"
                if phase == "detail":
                    outcome = branch["matched"]
                    packet += f"You just reported {outcome['source']} / {outcome['judgment']}.\n" + records["detail_question"]
                    correct = obs["motif"].strip(" .!").casefold() == motif
                    require(correct == obs["correct_motif"], "secondary marker grade")
                else:
                    packet += protocol["initial_source_question"]
                    require(digest("blinded-source-review/" + obs["prompt_sha256"])[:10] == obs["review_id"],
                            "basis review ID")
                    if obs["basis_grounded_in_this_episode"]:
                        require(report(obs) == "PAGER/IDENTIFIED" and phase == "matched", "grounded report label")
                check_input(obs, packet)
                require((re.search(r"\b" + re.escape(motif) + r"\b", packet) is not None) == (arm == "replay"),
                        "visibility of the private marker")
                require((trace in packet) == (arm == "replay") and first["basis"] not in packet,
                        "original sensation and explanation access")
            outcome = branch["matched"]
            words = (outcome["source"] + " / " + outcome["judgment"] + ". " + outcome["basis"]
                     + " Motif reported: " + branch["detail"]["motif"] + ".")
            require(digest(words) == view[arm + "_account_sha256"], "Verify PR room readback")
            values.extend([report(branch["before"]), report(outcome),
                           "yes" if outcome["basis_grounded_in_this_episode"] else "no",
                           report(branch["different"]), branch["detail"]["motif"]])
        require(view["separate_accounts_after_reload"] and view["same_mark"] == ["24%", "76%"],
                "same position, separate saved views")
        table.append(values)
    require(len(sessions) == 45, "45 separate private turns")
    return "".join("\t".join(row) + "\n" for row in table).encode("utf-8")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true", help="regenerate readings.tsv after checking the records")
    write = parser.parse_args().write
    ledger = ROOT / "readings.tsv"
    expected = verify()
    if write:
        ledger.write_bytes(expected)
    require(ledger.read_bytes().replace(b"\r\n", b"\n") == expected, "stored Lean inputs differ from reports")
    print("Verified 45 private turns, five pairs, both room views and the exact table used by Lean.")
