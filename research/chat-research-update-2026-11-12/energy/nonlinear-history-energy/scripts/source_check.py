"""Targeted nonlinear/full-history source review; prior coverage preserved."""
from pathlib import Path
import json,re,hashlib,zipfile,xml.etree.ElementTree as ET,html
from datetime import datetime,timezone
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'outputs/nonlinear-history-energy';OUT.mkdir(parents=True,exist_ok=True)
prior=json.loads((ROOT/'outputs/s-gradient-energy/source-scan.json').read_text(encoding='utf-8'))
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
assert all(sha(p)==h for p,h in prior['input_sha256'].items())
pattern=re.compile(r'non.?linear|hyster|bistab|double.?well|potential|functional|Lyapunov|Hamilton|saturat|stored|reservoir|history|retain|configuration|carri|memory|fading|exponent|e\^|exp\(|∫|energy|energet',re.I)
docs=[]
for info in prior['documents']:
    p=Path(info['source'])
    with zipfile.ZipFile(p) as z:
        root=ET.fromstring(z.read('word/document.xml'));ns={'w':'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
        ps=[''.join(t.text or '' for t in e.findall('.//w:t',ns)) for e in root.findall('.//w:p',ns)]
    selected=set()
    for i,t in enumerate(ps):
        if pattern.search(t):selected.update(range(max(0,i-1),min(len(ps),i+2)))
    docs.append(dict(source=str(p),paragraphs=[dict(paragraph=i+1,text=ps[i]) for i in sorted(selected)]))
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
            if not t or not pattern.search(t):continue
            ident=el.attrib.get('data-miro-id');key=(ident,t)
            if key not in items:items[key]=dict(id=ident,text=t,sources=[])
            items[key]['sources'].append(p.name)
notes=[]
for p in prior['input_sha256']:
    if Path(p).suffix!='.md':continue
    lines=Path(p).read_text(encoding='utf-8-sig').splitlines();selected=set()
    for i,t in enumerate(lines):
        if pattern.search(t):selected.update(range(max(0,i-1),min(len(lines),i+3)))
    notes.append(dict(source=p,lines=[dict(line=i+1,text=lines[i]) for i in sorted(selected)]))
result=dict(checked_utc=datetime.now(timezone.utc).isoformat(),read_only=True,prior_scan_sha256=sha(ROOT/'outputs/s-gradient-energy/source-scan.json'),
    input_sha256=prior['input_sha256'],sources_unchanged=all(sha(p)==h for p,h in prior['input_sha256'].items()),
    documents=docs,selected_board_items=list(items.values()),later_specification_excerpts=notes,
    scope='One targeted nonlinear/storage/history extraction; same source hashes. Archived readable text only. Original content distinguished from added physical realization.')
assert result['sources_unchanged']
(OUT/'source-check.json').write_text(json.dumps(result,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
for d in docs[:2]:
    print('DOCUMENT '+Path(d['source']).name)
    for r in d['paragraphs']:
        if re.search(r'hyster|non.?linear|potential|functional|Lyapunov|Hamilton|saturat|reservoir|history|retain|memory|exponent|ener',r['text'],re.I):print(json.dumps(r,ensure_ascii=False))
print('BOARD CANDIDATES')
for x in items.values():
    if re.search(r'hyster|non.?linear|potential|functional|Lyapunov|Hamilton|saturat|reservoir|history|retain|memory|exponent|ener',x['text'],re.I):print(json.dumps(x,ensure_ascii=False))
