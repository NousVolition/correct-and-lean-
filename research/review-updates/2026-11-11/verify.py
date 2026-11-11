"""Recount the saved outputs beside this script. Does not rerun their producers."""
from pathlib import Path
from collections import Counter
from decimal import Decimal
import csv
import hashlib
import json
import math

ROOT = Path(__file__).resolve().parent

def read_json(name):
    return json.loads((ROOT / name).read_text(encoding='utf-8-sig'))

def read_csv(name):
    with (ROOT / name).open(encoding='utf-8-sig', newline='') as stream:
        return list(csv.DictReader(stream))

def endpoint(rows, time):
    found = [r for r in rows if math.isclose(r['time'], time, rel_tol=0, abs_tol=1e-12)]
    assert found, time
    return next((r for r in reversed(found) if r['phase'] in ('after', 'at')), found[-1])

def close(a, b):
    assert math.isclose(a, b, rel_tol=1e-10, abs_tol=1e-17), (a, b)

def main():
    source = read_json('sources.json')
    for name, record in source['sources'].items():
        raw = (ROOT / name).read_bytes()
        assert hashlib.sha256(raw).hexdigest() == record['sha256'], name
        assert len(raw) == record['bytes'], name

    metrics = read_csv('history-metrics.csv')
    for row in metrics:
        level = int(row['refinement'])
        on = read_json(f'history-on-h{level}.json')
        off = read_json(f'history-off-h{level}.json')
        for t, column in [(0.7, 'energy_difference_at_07'), (1.2, 'energy_difference_at_12'), (3.6, 'energy_difference_at_36')]:
            close(endpoint(on, t)['energy'] - endpoint(off, t)['energy'], float(row[column]))
        work = ((endpoint(on, 3.6)['source_work'] - endpoint(on, 1.2)['source_work'])
                - (endpoint(off, 3.6)['source_work'] - endpoint(off, 1.2)['source_work']))
        close(work, float(row['extra_threshold_work_12_to_36']))
        close(endpoint(on, 3.6)['residual'] - endpoint(off, 3.6)['residual'], float(row['residual_difference_at_36']))
    numeric = [{k: Decimal(v) for k, v in row.items()} for row in metrics]
    changes = {}
    for column in ['energy_difference_at_07', 'extra_threshold_work_12_to_36']:
        changes[column] = {
            'half_to_quarter_percent': float(100 * (numeric[2][column] - numeric[1][column]) / abs(numeric[2][column])),
            'native_to_quarter_percent': float(100 * (numeric[2][column] - numeric[0][column]) / abs(numeric[2][column])),
        }
    reduction = float(numeric[0]['residual_difference_at_36'] / numeric[2]['residual_difference_at_36'])

    events = read_csv('threshold-1-exchanges.csv')
    pair = read_json('threshold-1-result.json')
    assert len(events) == len(pair['confirmed_exchanges'])
    for row, event in zip(events, pair['confirmed_exchanges']):
        assert row['arm'] == event['arm']
        close(float(row['model_time']), event['model_time'])
        assert float(row['bracket_start']) <= float(row['model_time']) <= float(row['bracket_end'])
        assert row['curve_geometry_pass'] == 'True'
    windows = pair['late_comparison']['on']['windows']
    assert windows == pair['late_comparison']['off']['windows']
    event_counts = dict(Counter(row['arm'] for row in events))
    late_counts = {arm: sum(row['arm'] == arm and any(lo <= float(row['model_time']) <= hi for lo, hi in windows) for row in events) for arm in ['on', 'off']}
    assert all(late_counts[arm] == pair['late_comparison'][arm]['exchanges'] for arm in late_counts)

    specks = read_csv('speck-trajectories.csv')
    groups = {}
    for row in specks:
        key = (row['case'], int(row['grid']))
        groups.setdefault(key, []).append(row)
        assert float(row['completed_to']) == 9
    counts = []
    paired_positions = {}
    for (case, grid), rows in sorted(groups.items()):
        assert len(rows) == 201
        assert len({r['speck_id'] for r in rows}) == 201
        positions = {r['speck_id']: (r['initial_x_R'], r['initial_y_up_R']) for r in rows}
        if case in paired_positions:
            assert positions == paired_positions[case]
        paired_positions[case] = positions
        counts.append({'case': case, 'grid': grid, 'crossed': sum(r['ever_above_1'] == 'True' for r in rows), 'total': len(rows)})

    replays = read_csv('dining-replay-answers.csv')
    by_key = {}
    for row in replays:
        key = (row['batch'], row['id'])
        assert row['repetition'] not in by_key.setdefault(key, {})
        by_key[key][row['repetition']] = row
    differences = {'sentences': 0, 'actions': 0, 'prompt_hashes': 0}
    for rows in by_key.values():
        assert set(rows) == {'A', 'B'}
        a, b = rows['A'], rows['B']
        differences['sentences'] += a['answer'] != b['answer']
        differences['actions'] += (a['target'], a['mode'], Decimal(a['intensity'])) != (b['target'], b['mode'], Decimal(b['intensity']))
        differences['prompt_hashes'] += a['prompt_sha256'] != b['prompt_sha256']
    repeats = read_csv('dining-repeat-counts.csv')
    assert all(int(row[k]) == 0 for row in repeats for k in ['sentences', 'actions', 'raw', 'tokens'])
    assert len(replays) == source['dining']['saved_primary_receipt']['new_calls']
    assert all(row[k] == 'False' for row in replays for k in ['sentence_changed_from_saved_original', 'action_changed_from_saved_original'])
    result = {
        'scope': 'Saved-output recount; no fresh fluid simulation, AI sampling or Lean build.',
        'source_hashes_match': True,
        'history_relative_changes': changes,
        'history_percent_denominator': 'Absolute quarter-step value, matching the original comparison.',
        'residual_reduction_factor': reduction,
        'threshold_1_verified_examples': event_counts,
        'threshold_1_late_examples': late_counts,
        'unresolved_route_changes': len(pair['unresolved_rapid_route_changes']),
        'maximum_local_event_time_shift': max(float(r['timestep_time_shift']) for r in events),
        'speck_crossings': counts,
        'dining_fresh_calls_in_saved_audit': len(replays),
        'dining_matched_prompt_pairs': len(by_key),
        'dining_recomputed_A_B_differences': differences,
        'dining_original_match': 'Saved flags agree; original raw outputs and token files are not independently replayed by this compact check.'
    }
    (ROOT / 'recheck.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(result, indent=2))

if __name__ == '__main__':
    main()
