"""Read-only validation of the published Lean receipt, logs, data and regeneration."""
import argparse,json
from pathlib import Path
from certificate import HERE,COUNTS,TARGETS,sha,audit_source,validate
from generate import build

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--source-dir',type=Path,default=HERE.parent/'threshold-one-window-study')
    parser.add_argument('--fresh',type=Path)
    args=parser.parse_args()
    audit_source()
    data,counts=build(args.source_dir)
    assert counts==COUNTS
    assert (HERE/'WindowRecordData.lean').read_bytes()==data.encode('utf-8')
    saved=json.loads((HERE/'receipt.json').read_text(encoding='utf-8'))
    validate(saved)
    for run in saved['runs']:
        assert sha(HERE/run['log'])==run['log_sha256'],'Saved compiler log changed'
    if args.fresh:
        fresh=json.loads(args.fresh.read_text(encoding='utf-8'))
        validate(fresh)
        for run in fresh['runs']:
            assert sha(args.fresh.parent/run['log'])==run['log_sha256'],'Fresh compiler log changed'
    print(json.dumps({'status':'PASS','theorems':len(TARGETS),'source_and_generated_input_match':True,
                      'saved_logs_match':True,'fresh_receipt_checked':args.fresh is not None}))
if __name__=='__main__':main()
