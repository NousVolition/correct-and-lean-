from pathlib import Path
from datetime import datetime,timezone
import json,hashlib,shutil,re,zipfile
ROOT=Path(r'C:\Users\ziman\Documents\Codex\2026-10-31\ca')
REV=ROOT/'outputs/hug-v3-proof-corrected/revision-2'
PACK=REV/'testing-packet'
RUN=Path((ROOT/'work/current-corrected-hug-run.txt').read_text(encoding='utf8'))
PRIOR=ROOT/'outputs/hug-v3-proof-review/20261101T051856.361354Z'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,x):p.write_text(json.dumps(x,indent=2,allow_nan=False),encoding='utf8')
checks=json.loads((RUN/'checks.json').read_text(encoding='utf8'))
assert checks['status']=='PASS_TARGETED_CHECKS'
assert len(checks['checks'])==19 and all(x['passed'] for x in checks['checks'])
assert all(checks['preservation'].values())
assert sha(REV/'proof.md')==sha(RUN/'inputs/proof.md')
assert sha(REV/'CORRECTIONS.md')==sha(RUN/'inputs/CORRECTIONS.md')
origin=Path(json.loads((PRIOR/'prior-evidence/source-audit.json').read_text(encoding='utf8'))['source'])
seal=json.loads((RUN/'sources/source_seal.json').read_text(encoding='utf8'))
source_files=[]
for rel,h in seal.items():
    assert sha(origin/rel)==sha(RUN/'sources'/rel)==sha(PRIOR/'sources'/rel)==h
    source_files.append(dict(file=rel,original=str(origin/rel),snapshot=str((RUN/'sources'/rel).relative_to(PACK)),sha256=h))
save(PACK/'source-manifest.json',dict(model='hug-structural-memory-v3',source_files=source_files,
    original_draft=dict(snapshot=str((RUN/'inputs/original-submitted-proof.tex').relative_to(PACK)),sha256=sha(RUN/'inputs/original-submitted-proof.tex')),
    proof_scope='Local existence and conditional hybrid uniqueness; unchanged model equations.'))
for label,src in [('review-completed',PRIOR),('review-first-incomplete',ROOT/'outputs/hug-v3-proof-review/20261101T051806.050149Z')]:
    dst=PACK/'historical'/label
    assert not dst.exists()
    shutil.copytree(src,dst)

pages=sorted((ROOT/'work/hug-proof-render').glob('page-[0-9].png'))
assert len(pages)==9
visual=PACK/'visual-pages';visual.mkdir(exist_ok=False)
for p in pages:shutil.copyfile(p,visual/p.name)
visual_record=dict(status='PASS_VISUAL_REVIEW',reviewed_at_utc=datetime.now(timezone.utc).isoformat(),pages=list(range(1,10)),
    method='Assistant inspected all nine Poppler page images, plus a larger crop of the piecewise activation on page 4.',
    findings=['All displayed formulas legible; corrected bounds and Gaussian expressions visible.','No clipped equation branches, missing glyphs, overlapping text or footer collisions observed.','Headings, page numbers and version boundary legible.'],
    scope='Document appearance and transcription review, not a formal mathematics certificate.')
save(PACK/'visual-review.json',visual_record)
render=json.loads((PACK/'render-checks.json').read_text(encoding='utf8'))
assert render['status']=='PASS_BROWSER_MATH_RENDER' and render['mathCount']==34 and not render['mathErrors'] and not render['overflows']
render['visual_page_review']='PASS; see visual-review.json'
save(PACK/'render-checks.json',render)
layout=json.loads((PACK/'pdf-layout-checks.json').read_text(encoding='utf8'))
assert layout['pdf_pages']==9 and all(not x['outside_page'] for x in layout['checks'])
layout['visual_review']='PASS; see visual-review.json'
save(PACK/'pdf-layout-checks.json',layout)
attempt=PACK/'render-attempts/02';attempt.mkdir(exist_ok=False)
for p in [REV/'proof.md',REV/'proof.tex',REV/'proof.html',REV/'corrected-proof.pdf',PACK/'render-checks.json',PACK/'pdf-layout-checks.json',PACK/'visual-review.json',ROOT/'work/render_corrected_hug_proof.cjs']:
    shutil.copyfile(p,attempt/p.name)
save(attempt/'provenance.json',dict(renderer='MathJax 3.2.2 SVG + Chrome',source='https://cdn.jsdelivr.net/npm/mathjax@3.2.2/es5/tex-svg.js',
    formatter_sha256=sha(ROOT/'work/hug-proof-render/tex-svg.js'),tex_compiler_run=False,
    setup_observations=['No native TeX compiler found. WSL returned access denied; no retry on that path.','Restricted network lookup failed; the approved formatter download succeeded.','The first static-check run lacked SymPy; task-local SymPy 1.14.0 and mpmath 1.3.0 enabled the next run.']))
completion=dict(stage='completed-corrected-proof-packet',proof_revision=2,status='COMPLETE_WRITTEN_CONDITIONAL_PROOF',
    targeted_checks='PASS',check_count=19,source_files_unchanged=21,pdf_pages=9,display_formulas=34,
    lean_or_nanoda_run=False,unconditional_continuation_proved=False,continuum_limit_proved=False,
    triangle_model_changed=False,verified_at_utc=datetime.now(timezone.utc).isoformat())
save(PACK/'completion.json',completion)
with (PACK/'runs.jsonl').open('a',encoding='utf8') as f:f.write(json.dumps(completion)+'\n')
shutil.copyfile(Path(__file__),PACK/'finalize-packet.py')
artifact_hashes=[dict(path=str(p.relative_to(REV)),sha256=sha(p),bytes=p.stat().st_size) for p in sorted(REV.rglob('*')) if p.is_file() and p.name!='final-artifacts.json']
save(PACK/'final-artifacts.json',dict(proof_revision=2,files=artifact_hashes,scope='Final files; this manifest does not hash itself.'))
for p in [REV/'CORRECTIONS.md',PACK/'PACKET.md',ROOT/'outputs/hug-v3-proof-review/INDEX.md',ROOT/'outputs/triangle-hug/testing-packet/PACKET.md']:
    for target in re.findall(r'\]\(([^)]+)\)',p.read_text(encoding='utf8')):
        if '://' not in target:assert (p.parent/target).resolve().exists(),(str(p),target)
archive=REV.parent/'hug-v3-corrected-proof-packet.zip'
assert not archive.exists()
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
    for p in sorted(REV.rglob('*')):
        if p.is_file():z.write(p,'hug-v3-proof-revision-2/'+p.relative_to(REV).as_posix())
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
    zip_files=len(z.infolist())
print(json.dumps(dict(**completion,archive=str(archive),archive_bytes=archive.stat().st_size,archive_files=zip_files,
    all_local_navigation_links_valid=True,all_final_artifact_hashes_match=all(sha(REV/x['path'])==x['sha256'] for x in artifact_hashes)),indent=2))
