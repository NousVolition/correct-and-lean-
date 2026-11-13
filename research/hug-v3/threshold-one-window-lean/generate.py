"""Exact decimal transcription from hash-pinned numerical records.

This Python ingestion is outside Lean's kernel. Lean checks the emitted integer
data and statements. JSON numbers are parsed as Decimal, never binary floats.
"""
import argparse,csv,hashlib,json
from decimal import Decimal
from pathlib import Path

HERE=Path(__file__).resolve().parent
WINDOWS=('forward_075','forward_150','forward_300','both_075','both_150','both_300')
FIELDS=('forward075','forward150','forward300','both075','both150','both300')
EVENTS=tuple(f'event-{i}-{side}' for i in (1,2,3) for side in ('left','right'))
EXPECTED=(['native-589']+[f'interval-589-{i:03d}' for i in range(8,193,8)]+list(EVENTS[:4])+
          ['native-599']+[f'interval-599-{i:03d}' for i in range(8,65,8)]+list(EVENTS[4:]))

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read_json(p):return json.loads(p.read_text(encoding='utf-8'),parse_float=Decimal)
def read_csv(p):
    with p.open(encoding='utf-8',newline='') as f:return list(csv.DictReader(f))
def checked_records(source,json_name,csv_name,expected_labels):
    rows=read_json(source/json_name);table=read_csv(source/csv_name)
    assert [r['label'] for r in rows]==expected_labels,'Unexpected sample coverage/order'
    index={(r['label'],r['window']):r for r in table}
    assert len(index)==len(table)==len(rows)*6,'Duplicate or missing CSV rows'
    assert set(index)=={(label,w) for label in expected_labels for w in WINDOWS}
    for row in rows:
        assert set(row['windows'])==set(WINDOWS)
        for w in WINDOWS:
            csvrow=index[row['label'],w];selected=row['windows'][w]['winner']
            assert Decimal(csvrow['time'])==row['time']
            assert Decimal(csvrow['s'])==selected['s'] and Decimal(csvrow['d'])==selected['d']
            assert csvrow['kind']==selected['kind']
            assert row['windows'][w]['candidates'],'Empty candidate list'
    return rows

def build(source):
    manifest=json.loads((HERE/'source-inputs.json').read_text(encoding='utf-8'))
    for name,expected in manifest['files'].items():assert sha(source/name)==expected,'Source drift: '+name
    rows=checked_records(source,'measurements.json','measurements.csv',EXPECTED)
    tight=checked_records(source,'measurements-tight.json','measurements-tight.csv',list(EVENTS))
    values=[]
    for r in rows+tight:
        values.append(Decimal(r['time']))
        for w in WINDOWS:
            item=r['windows'][w]
            for c in [item['winner']]+item['candidates']:
                values.extend((Decimal(c['s']),Decimal(c['d'])))
    assert all(x.is_finite() for x in values)
    digits=max(max(0,-x.as_tuple().exponent) for x in values)
    def integer(v):
        d=Decimal(v);sign,coefficient,exponent=d.as_tuple()
        assert exponent+digits>=0
        n=int(''.join(map(str,coefficient))) * 10**(exponent+digits)
        return -n if sign else n
    def lit(n):return str(n) if n>=0 else '('+str(n)+')'
    def reading(item):
        win=item['winner'];assert win['d']>=0
        candidates=[]
        for c in item['candidates']:
            assert c['d']>=0
            candidates.append(f'({lit(integer(c["s"]))}, {integer(c["d"])})')
        return f'⟨{lit(integer(win["s"]))}, {integer(win["d"])}, ['+', '.join(candidates)+']⟩'
    lines=['import WindowRecordTypes','namespace ThresholdOneRecords',
           '/- Generated from the hash-pinned written decimals. Every time, signed\n'
           'arclength, and distance has the shared denominator decimalScale.\n'
           'The integers do not assert a relationship to an actual trajectory. -/',
           f'def decimalScale : Nat := 10 ^ {digits}',
           f'def candidateCount : Nat := {sum(len(r["windows"][w]["candidates"]) for r in rows for w in WINDOWS)}']
    for prefix,records in [('sample',rows),('tight',tight)]:
        for i,r in enumerate(records):
            assert r['time']>=0
            lines.append(f'def {prefix}{i} : Sample :=\n  {{ label := {json.dumps(r["label"])}, stamp := {integer(r["time"])}')
            for key,field in zip(WINDOWS,FIELDS,strict=True):lines.append(f'    {field} := '+reading(r['windows'][key]))
            lines.append('  }')
    lines.append('def samples : List Sample := ['+', '.join(f'sample{i}' for i in range(len(rows)))+']')
    for label in EVENTS:
        num,side=label.split('-')[1:]
        lines.append(f'def event{num}{side.title()} : Sample := sample{EXPECTED.index(label)}')
    lines += [
        'def eventPairs : List (Sample × Sample) := [(event1Left, event1Right), (event2Left, event2Right), (event3Left, event3Right)]',
        'def eventSides : List Sample := [event1Left, event1Right, event2Left, event2Right, event3Left, event3Right]',
        'def firstTwoEventSides : List Sample := [event1Left, event1Right, event2Left, event2Right]',
        'def thirdEventSides : List Sample := [event3Left, event3Right]',
        'def tighterSamples : List Sample := [tight0, tight1, tight2, tight3, tight4, tight5]',
        'end ThresholdOneRecords','']
    return '\n'.join(lines),{'decimal_places':digits,'samples':len(rows),'windows_per_sample':6,
        'candidate_count':sum(len(r['windows'][w]['candidates']) for r in rows for w in WINDOWS),
        'recorded_nested_comparisons':480,'event_side_backward_comparisons':18,'tighter_comparisons':36}

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--source-dir',type=Path,default=HERE.parent/'threshold-one-window-study')
    parser.add_argument('--write',action='store_true')
    args=parser.parse_args()
    data,counts=build(args.source_dir)
    target=HERE/'WindowRecordData.lean'
    if args.write:target.write_text(data,encoding='utf-8',newline='\n')
    else:assert target.read_bytes()==data.encode('utf-8'),'Generated Lean input differs'
    print(json.dumps(counts,indent=2))
if __name__=='__main__':main()
