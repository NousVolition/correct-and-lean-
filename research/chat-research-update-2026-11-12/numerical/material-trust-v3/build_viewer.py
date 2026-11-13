from pathlib import Path
import json
ROOT=Path(__file__).resolve().parent
runs={}
presets={'00':'both-untrusting','01':'b-trusting','10':'a-trusting','11':'both-trusting'}
for key,name in presets.items():
    folder=ROOT/'runs'/name
    run=json.loads((folder/'view.json').read_text())
    s=run['summary']['settings']
    assert [s['trust_ab'],s['trust_ba']]==[int(key[0]),int(key[1])], 'Preset initial values do not match their labels.'
    assert s['attachment_mode']=='moving' and s['history_mode']=='leadup'
    material=json.loads((folder/'decoded-material-leadup.json').read_text())
    run['material']={k:material[k] for k in ('times','trust','positions')}
    assert len(material['times'])==651 and material['actor_ids']==[0,1]
    runs[key]=run
assert set(runs)=={'00','01','10','11'}, 'All four full runs must complete before publishing the meter.'
template=(ROOT/'viewer-template.html').read_text(encoding='utf-8')
data='window.TRUST_RUNS='+json.dumps(runs,ensure_ascii=True,separators=(',',':'))+';'
assert '</script' not in data.lower()
html=template.replace('/*DATA*/',data).replace('/*APP*/',(ROOT/'viewer.js').read_text(encoding='utf-8'))
(ROOT/'index.html').write_text(html,encoding='utf-8')
print(json.dumps({'runs':len(runs),'bytes':len(html.encode()),'samples':{k:v['summary']['samples'] for k,v in runs.items()}}))
