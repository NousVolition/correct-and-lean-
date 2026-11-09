const fs=require('fs');
const path=require('path');
const {pathToFileURL}=require('url');
const {createHash}=require('crypto');
const packages=process.env.PROOF_NODE_MODULES;
const {marked}=require(path.join(packages,'marked'));
const {chromium}=require(path.join(packages,'playwright'));
const root=process.env.PROOF_WORKSPACE;
const rev=path.join(root,'outputs/hug-v3-proof-corrected/revision-2');
const scratch=path.join(root,'work/hug-proof-render');
const source=fs.readFileSync(path.join(rev,'proof.md'),'utf8');
const hash=x=>createHash('sha256').update(x).digest('hex');
const formulas=[];
const protectedMd=source.replace(/\\\[([\s\S]*?)\\\]/g,(whole,body)=>{
  const id='FORMULA_'+formulas.length;
  formulas.push({id:'P'+String(formulas.length+1).padStart(2,'0'),text:body,source:whole});
  return '\n\n'+id+'\n\n';
});
const esc=s=>s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
let body=marked.parse(protectedMd);
formulas.forEach((f,i)=>body=body.replace('<p>FORMULA_'+i+'</p>','<div class="math" data-formula="'+f.id+'">'+esc(f.source)+'</div>'));
const mathjax=fs.readFileSync(path.join(scratch,'tex-svg.js'),'utf8');
let html=`<!doctype html><html lang="en"><head><meta charset="utf-8"><title>Hug v3 — corrected proof, revision 2</title>
<style>
@page { size:A4; margin:18mm 19mm 19mm; }
*{box-sizing:border-box}body{margin:0;color:#182832;background:white;font-family:Georgia,'Times New Roman',serif;font-size:13.1px;line-height:1.44}
h1,h2,h3{font-family:Arial,sans-serif;color:#184e77;line-height:1.22;break-after:avoid}h1{font-size:25px;margin:0 0 15px}h2{font-size:17px;margin:24px 0 10px;border-top:1px solid #d8e2e9;padding-top:11px}h3{font-size:14px;margin:19px 0 7px}
p{margin:8px 0;orphans:3;widows:3}strong{color:#123a55}code{font-family:Consolas,monospace;font-size:11px;overflow-wrap:anywhere}.math{font-size:12.5px;break-inside:avoid;margin:13px 0;padding:1px 0}mjx-container{max-width:100%}a{color:#184e77}blockquote{border-left:2px solid #184e77;padding-left:12px;margin-left:0}ul{padding-left:20px}li{margin:6px 0}
</style>
<script>window.MathJax={tex:{packages:['base','ams'],displayMath:[['\\\\[','\\\\]']],inlineMath:[['\\\\(','\\\\)']]},svg:{fontCache:'local'},options:{enableMenu:false}};</script>
<script>${mathjax}</script></head><body>${body}</body></html>`;
const htmlPath=path.join(rev,'proof.html');fs.writeFileSync(htmlPath,html);

function texEscape(s){
 const vals=[];
 s=s.replace(/`([^`]+)`/g,(_,x)=>{const k='ZZCODE'+vals.length+'ZZ';vals.push('\\texttt{'+x.replace(/[\\{}%$#&_]/g,c=>({'\\':'\\textbackslash{}','{':'\\{','}':'\\}','%':'\\%','$':'\\$','#':'\\#','&':'\\&','_':'\\_'}[c]))+'}');return k;});
 s=s.replace(/[\\{}%$#&_]/g,c=>({'\\':'\\textbackslash{}','{':'\\{','}':'\\}','%':'\\%','$':'\\$','#':'\\#','&':'\\&','_':'\\_'}[c]));
 s=s.replace(/Ω\*/g,'\\(\\Omega_*\\)').replace(/²/g,'\\textsuperscript{2}').replace(/³/g,'\\textsuperscript{3}').replace(/–|—/g,'--').replace(/“|”/g,'"').replace(/’/g,"'").replace(/·/g,' / ');
 s=s.replace(/\*\*([^*]+)\*\*/g,'\\textbf{$1}');
 vals.forEach((v,i)=>s=s.replace('ZZCODE'+i+'ZZ',v));return s;
}
let tex='\\documentclass[11pt,a4paper]{article}\n\\usepackage[margin=20mm]{geometry}\n\\usepackage[T1]{fontenc}\n\\usepackage[utf8]{inputenc}\n\\usepackage{lmodern,amsmath,amssymb,mathtools,hyperref,microtype}\n\\setlength{\\parindent}{0pt}\n\\setlength{\\parskip}{6pt}\n\\emergencystretch=2em\n\\begin{document}\n';
for(const line of protectedMd.split('\n')){
 const fm=line.match(/^FORMULA_(\d+)$/);
 if(fm){tex+=formulas[Number(fm[1])].source+'\n';continue;}
 const h=line.match(/^(#{1,3}) (.*)$/);
 if(h){tex+='\\'+({1:'section*',2:'subsection*',3:'subsubsection*'}[h[1].length])+'{'+texEscape(h[2])+'}\n';continue;}
 tex+=texEscape(line)+'\n';
}
tex+='\\end{document}\n';fs.writeFileSync(path.join(rev,'proof.tex'),tex);
const texFormulas=[...tex.matchAll(/\\\[([\s\S]*?)\\\]/g)].map(m=>m[1]);
if(texFormulas.length!==formulas.length||formulas.some((f,i)=>f.text!==texFormulas[i]))throw Error('TeX formula text drift');
fs.writeFileSync(path.join(rev,'testing-packet','corrected-formula-register.json'),JSON.stringify(formulas.map(({id,text})=>({id,text})),null,2));
(async()=>{
 const browser=await chromium.launch({headless:true,executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe'});
 try{
  // A4 content width after 19 mm margins is about 650 CSS pixels.
  const page=await browser.newPage({viewport:{width:650,height:1100}});const errors=[];
  await page.emulateMedia({media:'print'});
  page.on('pageerror',e=>errors.push(e.message));
  await page.goto(pathToFileURL(htmlPath).href,{waitUntil:'load'});
  await page.evaluate(()=>MathJax.startup.promise);
  await page.evaluate(()=>document.fonts.ready);
  const rendered=await page.evaluate(()=>({mathCount:document.querySelectorAll('mjx-container').length,mathErrors:[...document.querySelectorAll('mjx-merror,[data-mjx-error]')].map(e=>e.textContent),overflows:[...document.querySelectorAll('.math')].filter(e=>e.scrollWidth>e.clientWidth+2).map(e=>({id:e.dataset.formula,width:e.scrollWidth,available:e.clientWidth}))}));
  if(errors.length||rendered.mathErrors.length||rendered.mathCount!==formulas.length||rendered.overflows.length)throw Error(JSON.stringify({errors,rendered,expected:formulas.length}));
  await page.pdf({path:path.join(rev,'corrected-proof.pdf'),format:'A4',printBackground:true,preferCSSPageSize:true,displayHeaderFooter:true,headerTemplate:'<span></span>',footerTemplate:'<div style="font-family:Arial;font-size:8px;width:100%;padding:0 19mm;color:#526572;display:flex;justify-content:space-between"><span>Hug structural memory v3 / proof revision 2 / separate from Triangle Hug</span><span><span class="pageNumber"></span> / <span class="totalPages"></span></span></div>'});
  await page.screenshot({path:path.join(scratch,'first-screen.png'),fullPage:false});
  fs.writeFileSync(path.join(rev,'testing-packet','render-checks.json'),JSON.stringify({status:'PASS_BROWSER_MATH_RENDER',...rendered,source_sha256:hash(source),mathjax_version:'3.2.2',mathjax_sha256:hash(mathjax),html_sha256:hash(html),tex_sha256:hash(tex),formula_texts_identical_in_tex:true,render_method:'Local MathJax SVG in Chrome PDF, generated from the same Markdown master; TeX compiler unavailable, editable TeX not compiled.',visual_page_review:'pending'},null,2));
  console.log(JSON.stringify({status:'PASS_BROWSER_MATH_RENDER',formulas:formulas.length,pdf:path.join(rev,'corrected-proof.pdf')}));
 }finally{await browser.close();}
})().catch(e=>{fs.writeFileSync(path.join(scratch,'render-error.txt'),e.stack);console.error(e);process.exitCode=1;});
