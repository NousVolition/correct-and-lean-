"""Bounded provenance check for the specific old paired-context law."""
from pathlib import Path
from datetime import datetime,timezone
import hashlib,json
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'outputs/paired-context-energy'
OLD=Path(r'$USER_HOME\Documents\Codex\2026-10-08\referenced-chatgpt-conversation-this-is-an-2\outputs\hug-field-specification')
CORRECTION=Path(r'$USER_HOME\Documents\Codex\2026-11-11\ang-mills-as-an-instance-the\work\github-publication\research\comparisons\hug-navier-single-system-scope-correction.md')
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
targets={OLD/'SPECIFICATION.md':[(247,285)],OLD/'COUPLED_FIELD.md':[(9,22),(70,87),(181,199)],
    OLD/'SOURCES.md':[(60,71)],OLD/'decisions.json':[(106,142)],
    OLD/'latest_interaction_design.json':[(1,58)],CORRECTION:[(3,34)],
    OLD/'coupled_hug.py':[(35,68),(124,146),(196,217)]}
hashes={str(p):sha(p) for p in targets};excerpts=[]
for path,ranges in targets.items():
    lines=path.read_text(encoding='utf-8-sig').splitlines()
    for start,end in ranges:
        excerpts.append(dict(source=str(path),start_line=start,end_line=min(end,len(lines)),
            text='\n'.join(f'{i+1}: {lines[i]}' for i in range(start-1,min(end,len(lines))))))
latest=json.loads((OLD/'latest_interaction_design.json').read_text())
assert latest['user_requirements']['fixed_physical_half'] is False
assert latest['user_requirements']['context_switch_does_not_erase_retained_history'] is True
assert any('Replace the fixed mirrored partner' in v for v in latest['historical_implementation_obligations'])
historical=ROOT/'outputs/nonlocal-history-energy/source-check.json'
prior=json.loads(historical.read_text())
prior_overlap={p:h==prior['input_sha256'][p] for p,h in hashes.items() if p in prior['input_sha256']}
assert all(prior_overlap.values())
assert all(sha(p)==h for p,h in hashes.items())
result=dict(checked_utc=datetime.now(timezone.utc).isoformat(),read_only=True,
    scope='Eight known source/provenance files, targeted ranges; original-corpus and board review retained as historical evidence, not newly repeated',
    input_sha256=hashes,sources_unchanged=True,prior_overlapping_files_match=prior_overlap,
    historical_source_review=dict(path=str(historical),sha256=sha(historical),
        limits='Previously checked readable archives only; no new full-corpus sweep, live-board lookup, or image interpretation'),
    findings=[
        'Persistent carrying means continuing relationships while configuration changes, not frozen positions or states.',
        'Reference reflection, the tanh exchange, multiplication of height gates, and the receiving kernel are added comparison choices.',
        'The later interaction design supersedes the fixed physical half and calls for replacement of mirrored pairing; this old law is not the requested full carrying/history relation.',
        'The original A/S source form and the added pair exchange are identified separately in the provenance table.',
        'The old specification gives indirect mechanical influence through C, with no separate mimetic stress/traction.',
        'No independent configuration/history-only gravitational energy or conversion of this pair potential to physical energy is specified in these passages.'
    ],excerpts=excerpts,script_sha256=sha(Path(__file__)))
(OUT/'source-check.json').write_text(json.dumps(result,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
print(json.dumps({k:result[k] for k in ['scope','sources_unchanged','prior_overlapping_files_match','findings']},indent=2))
if __name__=='__main__':pass
