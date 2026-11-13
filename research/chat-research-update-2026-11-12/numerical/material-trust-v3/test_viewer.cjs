const fs=require('fs'),vm=require('vm'),assert=require('assert');
const html=fs.readFileSync('index.html','utf8');
const data=html.match(/<script>(window\.TRUST_RUNS=[\s\S]*?)<\/script>/)[1];
const elements={};
function el(id){return elements[id]??=( {value:id==='initial-ab'?'1':id==='initial-ba'?'0':'0',max:'0',style:{},attributes:{},events:{},clientWidth:760,clientHeight:300,
    setAttribute(k,v){this.attributes[k]=v;},addEventListener(k,f){this.events[k]=f;},textContent:'',innerHTML:''} );}
const context={window:{addEventListener(){}},document:{getElementById:el},setInterval(){return 1;},clearInterval(){}};
vm.createContext(context);vm.runInContext(data,context);vm.runInContext(fs.readFileSync('viewer.js','utf8'),context);
for(const ab of ['0','1'])for(const ba of ['0','1']){
  el('initial-ab').value=ab;el('initial-ba').value=ba;el('initial-ab').events.change();
  assert.equal(el('value-ab').textContent,Number(ab).toFixed(4));assert.equal(el('value-ba').textContent,Number(ba).toFixed(4));
  assert.equal(Number(el('timeline').max),653);
  const initialA=el('speck-a').attributes.cx;
  el('next-write').events.click();assert(el('time-value').textContent.includes('0.400 · before write'));
  el('timeline').value=653;el('timeline').events.input();
  const last=context.window.TRUST_RUNS[ab+ba].history.at(-1);
  assert.equal(el('value-ab').textContent,last.ab.toFixed(4));assert.equal(el('value-ba').textContent,last.ba.toFixed(4));
  assert(el('path-ab').attributes.d.startsWith('M'));assert(el('path-ba').attributes.d.includes('L'));
  assert.notEqual(el('speck-a').attributes.cx,initialA);
  assert(el('speck-path-a').attributes.d.includes('L'));assert(el('speck-path-b').attributes.d.includes('L'));
  assert(el('positions').textContent.includes(last.positions[0][0].toFixed(6)));
  const stored=context.window.TRUST_RUNS[ab+ba].material.trust.at(-1);
  assert(el('material-trust').textContent.includes(stored[0].toFixed(4)));
  assert(el('material-trust').textContent.includes(stored[1].toFixed(4)));
  assert(el('material-samples').textContent.includes('651 retained'));
  assert(el('write-work').textContent.includes(last.write_work.toExponential(4)));
}
console.log('PASS: four starts, meters, timeline, speck paths, material-decoded trust and write work.');
