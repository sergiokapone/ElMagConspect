const {mathjax}=require('mathjax-full/js/mathjax.js');
const {TeX}=require('mathjax-full/js/input/tex.js');
const {SVG}=require('mathjax-full/js/output/svg.js');
const {liteAdaptor}=require('mathjax-full/js/adaptors/liteAdaptor.js');
const {RegisterHTMLHandler}=require('mathjax-full/js/handlers/html.js');
const {AllPackages}=require('mathjax-full/js/input/tex/AllPackages.js');
const fs=require('fs');
RegisterHTMLHandler(liteAdaptor());
const tex=new TeX({packages:AllPackages});
const doc=mathjax.document('',{InputJax:tex,OutputJax:new SVG({fontCache:'none'})});
const {HTMLMathItem}=require('mathjax-full/js/handlers/html/HTMLMathItem.js');
const run=s=>{try{const it=new HTMLMathItem(s,tex,true);const m=tex.compile(it,doc).toString();const r=/merror[^)]*|mtext\(\\[A-Za-z]+/.exec(m);return r?r[0].slice(0,80):null;}catch(e){return e.message;}};
const macros=fs.readFileSync(process.argv[2],'utf8').split('\n').filter(l=>l.startsWith('\\CustomizeMathJax{')).map(l=>l.slice(18,-1));
let bad=0;
console.log('negative control (must FAIL):', run('\\definitelyUndefinedMacro{x}')?'FAIL (good)':'passed (detector broken!)');
for(const m of macros){const e=run(m);if(e){bad++;console.log('MACRO ERROR',m,'->',e);}}
const S=[ '\\tcbhighmath{ \\vect{F}_{12} = \\frac{q_1 q_2}{r^2}\\frac{\\vect{r}_{12}}{r}. }',
 'F=\\frac{q_1q_2}{r^{2+\\epsilon}},\\ |\\epsilon|\\ll1','\\rot\\Efield=-\\frac1c\\parttime{\\Bfield},\\ \\divg\\Dfield=4\\pi\\rho',
 '\\oiint \\Dfield\\cdot d\\vect{S}=4\\pi Q,\\ \\iiint\\rho\\,dV,\\ \\iint\\vect{j}\\,d\\vect{S}',
 '\\diff{f}{x}+\\ddiff{f}{x}+\\pparttime{\\phi}=\\Laplasian\\phi','\\grad\\phi,\\Div\\vect{j},\\Rot\\Hfield,\\Grad f,\\const,\\inv',
 '\\nfrac{1}{2}mv^2,\\ \\emf=-\\frac{d\\Phi}{dt}','\\vect{\\omega}\\times\\vect{r},\\ \\vect{\\nabla}f'];
for(const s of S){const e=run(s);if(e)bad++;console.log(e?'FAIL':'ok  ',s.slice(0,60),e||'');}
console.log(bad?bad+' problem(s)':'all fine');
