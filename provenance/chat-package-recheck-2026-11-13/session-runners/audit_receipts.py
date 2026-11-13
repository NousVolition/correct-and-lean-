"""Audit saved check outcomes without rerunning any proof or simulation."""
import hashlib,json,re
from pathlib import Path
from datetime import datetime,timezone
HERE=Path(__file__).resolve().parent
ALLOWED={'propext','Quot.sound','Classical.choice'}
PATTERN=re.compile(r"'([^']+)' (?:depends on axioms: \[([^\]]*)\]|does not depend on any axioms)",re.S)
def read(p):return json.loads(p.read_text())
rows=[]
for family in ['vortex','generic']:
    summary=read(HERE/('private-'+family)/'summary.json')
    for record in summary:
        assert record['status']=='PASS' and record['sources_unchanged']
        slug=record['package'].removeprefix('vortex/').replace('/','--') if family=='vortex' else record['batch']
        root=HERE/('private-'+family)/slug
        logs=root/'evidence' if family=='vortex' else root
        if family=='vortex':
            assert record['runner_exit']==0
            for name in ['comparator','lean-build','axioms']:
                assert int((logs/(name+'.exit')).read_text())==0,(slug,name)
        else:
            for name in ['comparator','lean_build','axioms']:
                assert record[name]['exit']==0,(slug,name)
        cmp=(logs/'comparator.log').read_text()
        for verdict in ['nanoda kernel accepts the solution','Lean default kernel accepts the solution','Your solution is okay!']:
            assert verdict in cmp,(slug,verdict)
        ax=(logs/'axioms.log').read_text()
        seen={}
        for name,listing in PATTERN.findall(ax):
            dependencies={s.strip() for s in listing.split(',') if s.strip()}
            seen.setdefault(name,[]).append(dependencies)
        targets=record['targets']
        for target in targets:
            assert target in seen,(slug,'missing axiom print',target)
            assert all(a<=ALLOWED for a in seen[target]),(slug,target,seen[target])
        rows.append({'id':record.get('package',record.get('batch')),'configured_declarations':len(targets),'all_configured_axiom_prints_present':True,'only_three_permitted_axioms':True,'all_required_exits_zero':True,'both_kernel_acceptance_messages_present':True,'comparator_log_sha256':hashlib.sha256((logs/'comparator.log').read_bytes()).hexdigest()})
assert len(rows)==9
result={'checked_at_utc':datetime.now(timezone.utc).isoformat(),'status':'PASS','kind':'read-only audit of newly produced receipts; no proof rerun','checks':rows}
(HERE/'receipt-audit.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'status':'PASS','batches':len(rows),'configured_declaration_occurrences':sum(x['configured_declarations'] for x in rows),'note':'Counts include helpers and overlap.'}))
