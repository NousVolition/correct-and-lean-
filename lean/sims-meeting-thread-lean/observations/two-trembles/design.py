"""Construct the listener's view without sending evaluator IDs or the target slot."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parent
ARMS = ("direct", "replay")
WITNESSES = ("sound", "landmark", "generic")
SLOTS = ("EARLIER", "LATER")


def read_protocol():
    return json.loads((ROOT / "protocol.json").read_bytes())


def case_rows(protocol):
    for scene in protocol["scenes"]:
        for swapped, key in enumerate(scene["worlds"]):
            sounds = scene["sounds"][::-1] if swapped else scene["sounds"][:]
            heard = scene["sounds"][scene["witness_sound"]]
            target = sounds.index(heard)
            yield {"key":key, "scene":scene, "sounds":sounds, "heard":heard, "target":target}


def witness(protocol, case, condition):
    start = "I pressed TEST and saw your restaurant pager vibrate against your pocket"
    if condition == "sound":
        return f"{start} just as I heard {case['heard']}."
    if condition == "landmark":
        action = case["scene"]["actions"][case["target"]]
        return f"{start} while you were {action}."
    if condition == "generic":
        return protocol["generic_witness"]
    raise ValueError(condition)


def prompt(protocol, case, condition, arm):
    scene = case["scene"]
    first, second = scene["actions"]
    inventory = scene["sounds"]
    common = (f"At the earlier tremble you were {first}. At the later tremble you were {second}. "
              f"You remember two background sounds from the wait. Your list of them is unordered. "
              f"You heard {inventory[0]} and {inventory[1]}.")
    if arm == "direct":
        attention = protocol["no_replay"]
    elif arm == "replay":
        a, b = case["sounds"]
        attention = (f"{protocol['replay']} One short pocket tremble, with {a}. "
                     f"Then another short pocket tremble, with {b}.")
    else:
        raise ValueError(arm)
    return "\n".join((protocol["participant"], protocol["trembles"], common, attention,
                       'The person at the counter tells you, “' + witness(protocol,case,condition) + '”',
                       protocol["probe"]))


def candidates(case, condition, arm):
    if condition == "generic" or (condition == "sound" and arm == "direct"):
        return SLOTS
    if condition == "landmark":
        clue = case["scene"]["actions"][case["target"]]
        observed = case["scene"]["actions"]
    elif condition == "sound" and arm == "replay":
        clue = case["heard"]
        observed = case["sounds"]
    else:
        raise ValueError((condition,arm))
    return tuple(SLOTS[i] for i, feature in enumerate(observed) if feature == clue)


def check_design(protocol):
    cases = list(case_rows(protocol))
    assert len(cases) == len({c["key"] for c in cases}) == 6
    assert sorted(c["target"] for c in cases) == [0, 0, 0, 1, 1, 1]
    for left,right in zip(cases[::2],cases[1::2],strict=True):
        assert left["target"] != right["target"] and left["sounds"] == list(reversed(right["sounds"]))
        assert len(set(left["sounds"])) == len(set(left["scene"]["actions"])) == 2
        for condition in WITNESSES:
            for c in (left,right):
                sentence = witness(protocol,c,condition)
                assert not any(word in sentence.lower() for word in ("earlier","later","first","second"))
                for arm in ARMS:
                    text = prompt(protocol,c,condition,arm)
                    assert all(item["key"] not in text for item in cases)
                    assert text.count(sentence) == 1
                    assert SLOTS[c["target"]] in candidates(c,condition,arm)
            if condition != "landmark":
                assert prompt(protocol,left,condition,"direct") == prompt(protocol,right,condition,"direct")
    return cases
