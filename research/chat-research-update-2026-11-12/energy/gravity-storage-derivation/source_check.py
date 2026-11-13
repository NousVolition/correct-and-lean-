"""Read original corpus text and preserved board exports without changing them."""
from pathlib import Path
import zipfile,xml.etree.ElementTree as ET,json,hashlib,re,html
from datetime import datetime,timezone
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'outputs/gravity-storage-derivation';OUT.mkdir(parents=True,exist_ok=True)
doc=Path(r'$USER_HOME\Documents\Codex\2026-10-05\ca\outputs\sims-framework-correction-20261022\sources\corrected-corpus.docx')
boardroot=Path(r'$USER_HOME\Documents\Codex\2026-10-08\referenced-chatgpt-conversation-this-is-an-2\work\hug-field-specification-source')
boards=[boardroot/'miro-holding-review-2026-10-23.json',boardroot/'miro-structural-review-2026-10-23.json',boardroot/'miro-coupled-read-0.json',boardroot/'miro-coupled-read-1.json',boardroot/'miro-coupled-read-2.json']
meaning=Path(r'$USER_HOME\Documents\Codex\2026-11-11\ang-mills-as-an-instance-the\work\github-publication\research\comparisons\hug-navier-single-system-scope-correction.md')
holding=ROOT/'outputs/hug-source-energy-connection/sources/HOLDING_AND_ENERGY.md'
structural=ROOT/'outputs/hug-source-energy-connection/sources/STRUCTURAL_MEMORY.md'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
paths=[doc,meaning,holding,structural]+boards;before={str(p):sha(p) for p in paths}
with zipfile.ZipFile(doc) as z:
    tree=ET.fromstring(z.read('word/document.xml'))
    ns={'w':'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
    paragraphs=[''.join(t.text or '' for t in p.findall('.//w:t',ns)) for p in tree.findall('.//w:p',ns)]
selected=[dict(xml_paragraph=i+1,text=t) for i,t in enumerate(paragraphs) if 228<=i+1<=266 or 517<=i+1<=539 or 545<=i+1<=580]
board_extracts=[]
for p in boards:
    d=json.loads(p.read_text(encoding='utf-8-sig'))
    if 'read' in d and isinstance(d['read'],dict):d=d['read']
    svg=d.get('svg','')
    if not svg:
        board_extracts.append(dict(source=str(p),keys=list(d),note='No top-level SVG; not interpreted further'))
        continue
    root=ET.fromstring(svg)
    items=[]
    for el in root.iter():
        content=el.attrib.get('data-content','')
        if el.tag.endswith('textArea'):content+=''.join(el.itertext())
        content=re.sub('<[^>]+>',' ',html.unescape(content)).strip()
        if content and re.search(r'energ|gravit|holding|potential|retain|accumul|coupl|stress|transport|source|∂|∇|A\(|J\(',content,re.I):
            items.append(dict(id=el.attrib.get('data-miro-id'),text=content))
    board_extracts.append(dict(source=str(p),historical_status='Preserved export; not a live-board freshness check',item_count=d.get('item_count'),skipped_count=d.get('skipped_count'),items=items))
assert before=={str(p):sha(p) for p in paths}
report=dict(checked_utc=datetime.now(timezone.utc).isoformat(),read_only=True,source_hashes=before,source_files_unchanged=True,corpus_paragraph_count=len(paragraphs),corpus_gravity_mentions=[dict(xml_paragraph=i+1,text=t) for i,t in enumerate(paragraphs) if re.search(r'gravit|potential energy',t,re.I)],corpus_equations=selected,board_exports=board_extracts,scope='Corrected corpus; five archived readable board selections; retained meaning correction and two later proposals. No exhaustive search of all chats, unread board images, or current board state.')
(OUT/'source-check.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
print(json.dumps(dict(paragraphs=len(paragraphs),gravity_mentions=report['corpus_gravity_mentions'],boards=[dict(source=Path(x['source']).name,selected=len(x.get('items',[])),skipped=x.get('skipped_count')) for x in board_extracts]),ensure_ascii=False))
for x in board_extracts:
    for item in x.get('items',[]):
        if re.search(r'energ|gravit|potential|accumul|holding',item['text'],re.I):print(json.dumps(item,ensure_ascii=False))
