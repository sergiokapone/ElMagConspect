// check-mathjax-html.js - runs every formula of an lwarp HTML page through MathJax 3 and lists the failing ones.
// Usage:  npm i mathjax-full      (once, in this folder)
//         node check-mathjax-html.js ch3.html [more.html ...]
// \seteqnumber and \require are provided by the page's own MathJax configuration and are not reported.
const fs = require('fs');
const { mathjax } = require('mathjax-full/js/mathjax.js');
const { TeX } = require('mathjax-full/js/input/tex.js');
const { SVG } = require('mathjax-full/js/output/svg.js');
const { liteAdaptor } = require('mathjax-full/js/adaptors/liteAdaptor.js');
const { RegisterHTMLHandler } = require('mathjax-full/js/handlers/html.js');
const { AllPackages } = require('mathjax-full/js/input/tex/AllPackages.js');
const { HTMLMathItem } = require('mathjax-full/js/handlers/html/HTMLMathItem.js');
RegisterHTMLHandler(liteAdaptor());
const PAGE_PROVIDED = /\\(seteqnumber|require)\b/;
const FRAG = /\\begin\{(equation\*?|align\*?|gather\*?|multline\*?|eqnarray\*?)\}[\s\S]*?\\end\{\1\}|\\\[[\s\S]*?\\\]|\\\([\s\S]*?\\\)/g;
const ENT = { '&lt;': '<', '&gt;': '>', '&amp;': '&', '&apos;': "'", '&quot;': '"', '&nbsp;': ' ' };
const decode = t => t.replace(/&(lt|gt|amp|apos|quot|nbsp);|&#(\d+);/g, (m, n, d) => d ? String.fromCharCode(+d) : ENT[m]);   // MathJax reads the decoded DOM text
function findError(n) {
  if (n.isKind && n.isKind('merror')) return n;
  for (const c of n.childNodes || []) { const r = findError(c); if (r) return r; }
  return null;
}
for (const file of process.argv.slice(2)) {
  const html = fs.readFileSync(file, 'utf8').replace(/\r/g, '').replace(/<script[\s\S]*?<\/script>/g, '');
  const tex = new TeX({ packages: AllPackages });
  const doc = mathjax.document('', { InputJax: tex, OutputJax: new SVG({ fontCache: 'none' }) });
  let total = 0, bad = [];
  for (const m of html.matchAll(FRAG)) {
    total++;
    let s = decode(m[0]), display = !s.startsWith('\\(');
    if (s.startsWith('\\(') || s.startsWith('\\[')) s = s.slice(2, -2);
    if (PAGE_PROVIDED.test(s) && s.length < 60) continue;
    let msg = null;
    try {
      const mml = tex.compile(new HTMLMathItem(s, tex, display), doc);
      const e = findError(mml);
      if (e) msg = e.attributes.get('data-mjx-error') || 'error';
      else { const u = /mtext\((\\[A-Za-z]+)\)/.exec(mml.toString()); if (u) msg = 'undefined macro ' + u[1]; }
    } catch (e) { msg = 'exception: ' + e.message; }
    if (msg) bad.push({ line: html.slice(0, m.index).split('\n').length, msg, src: m[0].replace(/\s+/g, ' ').slice(0, 130) });
  }
  console.log(`${file}: ${total} formulas, ${bad.length} failing`);
  const by = {}; bad.forEach(b => by[b.msg] = (by[b.msg] || 0) + 1);
  for (const [k, v] of Object.entries(by).sort((a, b) => b[1] - a[1]).slice(0, 6)) console.log(`   ${v} x ${k}`);
  bad.slice(0, 8).forEach(b => console.log(`   line ${b.line}: ${b.msg}\n      ${b.src}`));
}
