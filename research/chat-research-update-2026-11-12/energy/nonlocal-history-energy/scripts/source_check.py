"""One targeted read of nonlocal kernels, carried relations and shared history."""
from pathlib import Path
import json,re,hashlib,zipfile,xml.etree.ElementTree as ET,html
from datetime import datetime,timezone
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'outputs/nonlocal-history-energy';OUT.mkdir(parents=True,exist_ok=True)
prior=json.loads((ROOT/'outputs/s-gradient-energy/source-scan.json').read_text(encoding='utf-8'))
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
assert all(sha(p)==h for p,h in prior['input_sha256'].items())
pattern=re.compile(r'non.?local|kernel|adjoint|pair|convol|Volterra|spatial|carri|relationship|relational|interaction flux|boundary|recipro|integral|∫|energy',re.I)
docs=[]
for info in prior['documents']:
    with zipfile.ZipFile(info['source']) as z:
        tree=ET.fromstring(z.read('word/document.xml'));ns={'w':'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
        ps=[''.join(t.text or '' for t in e.findall('.//w:t',ns)) for e in tree.findall('.//w:p',ns)]
    ids=set()
    for i,t in enumerate(ps):
        if pattern.search(t):ids.update(range(max(0,i-1),min(len(ps),i+2)))
    docs.append(dict(source=info['source'],paragraphs=[dict(paragraph=i+1,text=ps[i]) for i in sorted(ids)]))
def svgs(x):
    if isinstance(x,dict):
        if isinstance(x.get('svg'),str):yield x['svg']
        else:
            for v in x.values():yield from svgs(v)
    elif isinstance(x,list):
        for v in x:yield from svgs(v)
items={}
for source in prior['board_read_scope']:
    p=Path(source['file'])
    for svg in svgs(json.loads(p.read_text(encoding='utf-8-sig'))):
        for el in ET.fromstring(svg).iter():
            raw=el.attrib.get('data-content','')
            if el.tag.endswith('textArea'):raw+=''.join(el.itertext())
            t=re.sub('<[^>]+>',' ',html.unescape(raw)).strip()
            if t and pattern.search(t):items[(el.attrib.get('data-miro-id'),t)]=dict(id=el.attrib.get('data-miro-id'),text=t)
notes=[]
for p in prior['input_sha256']:
    if Path(p).suffix!='.md':continue
    lines=Path(p).read_text(encoding='utf-8-sig').splitlines();ids=set()
    for i,t in enumerate(lines):
        if pattern.search(t):ids.update(range(max(0,i-2),min(len(lines),i+4)))
    notes.append(dict(source=p,lines=[dict(line=i+1,text=lines[i]) for i in sorted(ids)]))
report=dict(checked_utc=datetime.now(timezone.utc).isoformat(),read_only=True,input_sha256=prior['input_sha256'],
    sources_unchanged=all(sha(p)==h for p,h in prior['input_sha256'].items()),documents=docs,
    selected_board_items=list(items.values()),later_note_excerpts=notes,
    limits=['Archived readable source content; skipped board/image objects and live updates untested','Later added pair laws and nonlocal closure conventions are not original corpus laws'])
assert report['sources_unchanged']
(OUT/'source-check.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
for d in docs[:2]:
    print('DOCUMENT '+Path(d['source']).name)
    for x in d['paragraphs']:
        if re.search(r'non.?local|kernel|Volterra|convol|recipro|∫|energy',x['text'],re.I):print(json.dumps(x,ensure_ascii=False))
print('BOARD KERNEL CANDIDATES')
for x in items.values():
    if re.search(r'kernel|non.?local|Volterra|convol|recipro|energy',x['text'],re.I):print(json.dumps(x,ensure_ascii=False))
