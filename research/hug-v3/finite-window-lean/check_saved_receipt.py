"""Match this package's saved proof evidence to its exact published inputs."""
import argparse
import hashlib
import json
from pathlib import Path
import re

ROOT=Path(__file__).resolve().parent
EXPECTED_INPUTS={'WindowGap.lean','RecordedWindows.lean','CheckAxioms.lean',
                 'lean-toolchain','lakefile.toml','verify.py',
                 'evidence/source-pairs.csv','evidence/source-statistics.csv'}

def check(root=ROOT,fresh=None):
    saved=json.loads((root/'receipt.json').read_text(encoding='utf-8'))
    expected_names=[]
    for module in ['WindowGap','RecordedWindows']:
        source=(root/(module+'.lean')).read_text(encoding='utf-8')
        expected_names.extend(module+'.'+n for n in re.findall(r'^theorem\s+(\w+)',source,re.M))
    if len(expected_names)!=15 or len(set(expected_names))!=15:
        raise ValueError('Expected the published set of 15 distinct statements.')
    if set(saved['inputs_sha256'])!=EXPECTED_INPUTS:
        raise ValueError('Saved receipt has a missing or unexpected proof input.')
    for name,digest in saved['inputs_sha256'].items():
        actual=hashlib.sha256((root/name).read_bytes()).hexdigest()
        if actual!=digest:raise ValueError(f'Stale saved receipt: {name} differs.')
    for label,receipt in [('saved',saved)]+([('fresh',json.loads(Path(fresh).read_text(encoding='utf-8')))] if fresh else []):
        if receipt.get('status')!='PASS':raise ValueError(f'{label}: result is not PASS.')
        if receipt.get('theorem_count')!=15 or receipt.get('targets')!=expected_names:
            raise ValueError(f'{label}: target list differs from the published statements.')
        if receipt.get('axioms')!={name:[] for name in expected_names}:
            raise ValueError(f'{label}: missing result or nonempty axiom dependencies.')
        if receipt.get('inputs_sha256')!=saved['inputs_sha256']:
            raise ValueError(f'{label}: proof-input fingerprints differ.')
        if receipt.get('source_inputs_unchanged_during_check') is not True or receipt.get('native_decide_used') is not False:
            raise ValueError(f'{label}: source preservation or kernel-check flag differs.')
        if 'version 4.34.0-rc2,' not in receipt.get('lean_version',''):
            raise ValueError(f'{label}: unexpected Lean version.')
        expected_modules=['WindowGap','RecordedWindows','CheckAxioms']
        runs=receipt.get('runs',[])
        if [r.get('module') for r in runs]!=expected_modules or any(r.get('exit_code')!=0 for r in runs):
            raise ValueError(f'{label}: a compiler/audit step is missing or did not pass.')
        if (receipt.get('frames'),receipt.get('pairs_per_frame'),receipt.get('pairwise_comparisons'),receipt.get('decimal_places'))!=(51,25,1275,24):
            raise ValueError(f'{label}: data coverage differs.')
    log=(root/'evidence/CheckAxioms.log').read_text(encoding='utf-8')
    logged=re.findall(r"'([^']+)' does not depend on any axioms",log)
    if logged!=expected_names or 'depends on axioms:' in log:
        raise ValueError('Saved axiom log differs from the receipt targets.')
    return {'status':'PASS','statements':15,'frames':51,'pairwise_comparisons':1275,
            'fresh_receipt_checked':fresh is not None,'scope':'Window rules and exact recorded numbers; not fluid-simulation verification.'}

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--fresh',type=Path)
    args=parser.parse_args()
    print(json.dumps(check(fresh=args.fresh),indent=2))
