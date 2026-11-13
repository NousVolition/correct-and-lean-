"""Read-only targeted search of original corpus versions and archived board text."""
from pathlib import Path
import json,hashlib,re,zipfile,xml.etree.ElementTree as ET,html
from datetime import datetime,timezone
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'outputs/s-gradient-energy';OUT.mkdir(parents=True,exist_ok=True)
desktop=Path(r'$USER_HOME\OneDrive\Desktop')
boardroot=Path(r'$USER_HOME\Documents\Codex\2026-10-08\referenced-chatgpt-conversation-this-is-an-2\work\hug-field-specification-source')
noteroot=boardroot.parents[1]/'outputs/hug-field-specification'
docs=[desktop/'Plain_Language_Corpus_Combined_Google_Docs.docx',desktop/'Plain_Language_Corpus_Math_and_Logic_Corrected.docx']
docs+=list((desktop/'Plain_Language_Corpus_Revision_Pack').rglob('*.docx'))
boards=sorted(boardroot.glob('miro-*.json'))
notes=[noteroot/n for n in ['SPECIFICATION.md','SOURCES.md','HOLDING_AND_ENERGY.md','STRUCTURAL_MEMORY.md','COUPLED_FIELD.md','ASSUMPTION_AUDIT.md']]
paths=docs+boards+notes;sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();before={str(p):sha(p) for p in paths}
pattern=re.compile(r'energ|diffus|smooth|gradient|∇S|∇C|entropy|chemical|thermo|Dirichlet|dissipat|reservoir|fuel',re.I)
documents=[]
for p in docs:
    with zipfile.ZipFile(p) as z:
        tree=ET.fromstring(z.read('word/document.xml'));ns={'w':'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
        ps=[''.join(t.text or '' for t in e.findall('.//w:t',ns)) for e in tree.findall('.//w:p',ns)]
        math_count=len(tree.findall('.//{http://schemas.openxmlformats.org/officeDocument/2006/math}oMath'))
        media=[name for name in z.namelist() if name.startswith('word/media/')]
    selected=set()
    for i,t in enumerate(ps):
        if pattern.search(t):selected.update(range(max(0,i-1),min(len(ps),i+2)))
    documents.append(dict(source=str(p),paragraph_count=len(ps),embedded_math_objects=math_count,
        embedded_media_files=media,excerpts=[dict(paragraph=i+1,text=ps[i]) for i in sorted(selected)]))
def svg_records(d):
    if isinstance(d,dict):
        if isinstance(d.get('svg'),str):yield d
        else:
            for x in d.values():yield from svg_records(x)
    elif isinstance(d,list):
        for x in d:yield from svg_records(x)
items={};boardreports=[]
for p in boards:
    d=json.loads(p.read_text(encoding='utf-8-sig'));records=list(svg_records(d));count=0
    for rec in records:
        tree=ET.fromstring(rec['svg'])
        for el in tree.iter():
            raw=el.attrib.get('data-content','')
            if el.tag.endswith('textArea'):raw+=''.join(el.itertext())
            t=re.sub('<[^>]+>',' ',html.unescape(raw)).strip()
            if not t:continue
            id=el.attrib.get('data-miro-id');key=(id,t)
            if key not in items:items[key]=dict(id=id,text=t,sources=[])
            items[key]['sources'].append(p.name);count+=1
    boardreports.append(dict(file=str(p),svg_record_count=len(records),readable_items=count,
        skipped_counts=[r.get('skipped_count') for r in records],top_keys=list(d) if isinstance(d,dict) else None))
selected=[x for x in items.values() if pattern.search(x['text'])]
note_excerpts=[]
for p in notes:
    lines=p.read_text(encoding='utf-8-sig').splitlines();ids=set()
    for i,t in enumerate(lines):
        if re.search(r'free energy|field.norm|energy and information|gradient.*energy|energy.*gradient|chemical|Dirichlet|thermo|E2|\bQ_v\b',t,re.I):ids.update(range(max(0,i-2),min(len(lines),i+4)))
    note_excerpts.append(dict(source=str(p),lines=[dict(line=i+1,text=lines[i]) for i in sorted(ids)]))
assert before=={str(p):sha(p) for p in paths}
report=dict(checked_utc=datetime.now(timezone.utc).isoformat(),read_only=True,input_sha256=before,sources_unchanged=True,
    documents=documents,board_read_scope=boardreports,unique_readable_board_items=len(items),selected_board_items=selected,later_note_excerpts=note_excerpts,
    limits=['Archived readable board text only; skipped foreign/image objects and live-board updates not audited','Later specifications are proposals, not automatically original user laws'])
(OUT/'source-scan.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
print(json.dumps(dict(documents=[dict(source=x['source'],paragraphs=x['paragraph_count']) for x in documents],board_files=len(boards),unique_readable_items=len(items),selected_board_items=len(selected)),ensure_ascii=False))
for doc in documents:
    print('DOCUMENT '+doc['source'])
    for item in doc['excerpts']:
        if re.search(r'energ|diffus|thermo|reservoir|fuel|chemical|entropy|dissipat',item['text'],re.I):print(json.dumps(item,ensure_ascii=False))
print('BOARD ENERGY CANDIDATES')
for item in selected:
    if re.search(r'energ|diffus|thermo|reservoir|fuel|chemical|entropy|dissipat',item['text'],re.I):print(json.dumps(item,ensure_ascii=False))
