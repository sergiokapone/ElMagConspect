/* Спільні допоміжні функції аплетів «Електромагнітні хвилі» */
"use strict";
const EW=(()=>{
  const col={};
  function readCols(){const s=getComputedStyle(document.documentElement);
    for(const n of["ink","muted","line","pos","neg","zero","panel","acc","warn"])col[n]=s.getPropertyValue("--"+n).trim();return col;}
  /* полотно з урахуванням devicePixelRatio; повертає {c,g,w,h,dpr}; метод fit() перераховує розмір */
  function view(c){
    const v={c,g:c.getContext("2d"),w:300,h:300,dpr:1,
      fit(){v.dpr=window.devicePixelRatio||1;const r=c.getBoundingClientRect();
        c.width=Math.max(10,Math.round(r.width*v.dpr));c.height=Math.max(10,Math.round(r.height*v.dpr));v.w=r.width;v.h=r.height;},
      begin(){v.g.setTransform(v.dpr,0,0,v.dpr,0,0);v.g.clearRect(0,0,v.w,v.h);return v.g;}};
    v.fit();return v;}
  /* графік: o={x0,x1,y0,y1,title,xl,yl,xt,yt,curves:[{f|pts,c,w,d}],marks:[[x,y,color]],vlines:[[x,color,dash]]} */
  function plot(v,o){
    const g=v.begin(),w=v.w,h=v.h;
    const ml=48,mr=10,mt=26,mb=36,X=x=>ml+(x-o.x0)/(o.x1-o.x0)*(w-ml-mr),Y=y=>h-mb-(y-o.y0)/(o.y1-o.y0)*(h-mt-mb);
    g.save();g.beginPath();g.rect(ml,mt,w-ml-mr,h-mt-mb);g.clip();
    for(const vl of(o.vlines||[])){g.strokeStyle=vl[1]||col.zero;g.setLineDash(vl[2]||[4,4]);g.lineWidth=1;g.beginPath();g.moveTo(X(vl[0]),mt);g.lineTo(X(vl[0]),h-mb);g.stroke();}
    g.setLineDash([]);
    if(o.y0<0&&o.y1>0){g.strokeStyle=col.line;g.lineWidth=1;g.beginPath();g.moveTo(ml,Y(0));g.lineTo(w-mr,Y(0));g.stroke();}
    for(const cu of o.curves){g.strokeStyle=cu.c;g.lineWidth=cu.w||1.7;g.setLineDash(cu.d||[]);g.beginPath();
      if(cu.pts){cu.pts.forEach((p,k)=>{const px=X(p[0]),py=Y(p[1]);k?g.lineTo(px,py):g.moveTo(px,py);});}
      else{const N=o.n||300;for(let k=0;k<=N;k++){const x=o.x0+(o.x1-o.x0)*k/N,px=X(x),py=Y(cu.f(x));k?g.lineTo(px,py):g.moveTo(px,py);}}
      g.stroke();}
    g.restore();g.setLineDash([]);
    g.strokeStyle=col.ink;g.fillStyle=col.ink;g.lineWidth=1;g.strokeRect(ml,mt,w-ml-mr,h-mt-mb);
    g.font="11px system-ui,sans-serif";g.textAlign="right";g.textBaseline="middle";
    for(const t of o.yt||[])g.fillText(t,ml-5,Y(t));
    g.textAlign="center";g.textBaseline="top";for(const t of o.xt||[])g.fillText(t,X(t),h-mb+4);
    g.font="12px system-ui,sans-serif";g.fillText(o.xl||"",ml+(w-ml-mr)/2,h-16);
    g.save();g.translate(12,mt+(h-mt-mb)/2);g.rotate(-Math.PI/2);g.textBaseline="middle";g.fillText(o.yl||"",0,0);g.restore();
    g.font="600 12.5px system-ui,sans-serif";g.textBaseline="middle";g.fillText(o.title||"",ml+(w-ml-mr)/2,13);
    for(const m of o.marks||[]){g.fillStyle=m[2]||"#e5484d";g.beginPath();g.arc(X(m[0]),Y(m[1]),4.5,0,6.2832);g.fill();}
    return {X,Y};}
  /* стрілка */
  function arrow(g,x0,y0,x1,y1,color,lw,head){
    const dx=x1-x0,dy=y1-y0,L=Math.hypot(dx,dy);if(L<0.5)return;
    head=head||Math.min(9,L*0.4);const a=Math.atan2(dy,dx);
    g.strokeStyle=color;g.fillStyle=color;g.lineWidth=lw||2;
    g.beginPath();g.moveTo(x0,y0);g.lineTo(x1-Math.cos(a)*head*0.7,y1-Math.sin(a)*head*0.7);g.stroke();
    g.beginPath();g.moveTo(x1,y1);g.lineTo(x1-head*Math.cos(a-0.4),y1-head*Math.sin(a-0.4));g.lineTo(x1-head*Math.cos(a+0.4),y1-head*Math.sin(a+0.4));g.closePath();g.fill();}
  /* годинник-плеєр: t у довільних одиницях, обертається на [0,wrap) */
  function clock(o){
    const $=id=>document.getElementById(id),k={t:o.t0||0,mult:1,paused:false,last:performance.now()/1000,rate:o.rate||0.1,wrap:o.wrap||2};
    const bP=$("bPause"),ph=$("ph");
    k.setPause=v=>{k.paused=v;if(bP)bP.textContent=v?"Продовжити":"Пауза";k.last=performance.now()/1000;};
    if(bP)bP.onclick=()=>k.setPause(!k.paused);
    if($("bReset"))$("bReset").onclick=()=>{k.t=o.t0||0;k.setPause(false);};
    if($("bSlow"))$("bSlow").onclick=()=>{k.mult/=1.5;};
    if($("bFast"))$("bFast").onclick=()=>{k.mult*=1.5;};
    if(ph)ph.addEventListener("input",()=>{k.t=+ph.value;k.setPause(true);});
    document.addEventListener("keydown",e=>{
      if(e.target&&/INPUT|SELECT|TEXTAREA/.test(e.target.tagName)&&e.code==="Space")return;
      if(e.code==="Space"){e.preventDefault();k.setPause(!k.paused);}
      else if(["r","R","к","К"].includes(e.key)){k.t=o.t0||0;k.setPause(false);}
      else if(e.key==="ArrowUp"){e.preventDefault();k.mult*=1.5;}
      else if(e.key==="ArrowDown"){e.preventDefault();k.mult/=1.5;}});
    k.tick=()=>{const now=performance.now()/1000,dt=Math.min(now-k.last,0.1);k.last=now;
      if(!k.paused)k.t=(k.t+dt*k.rate*k.mult)%k.wrap;if(ph)ph.value=k.t;return k.t;};
    return k;}
  const fmt=(x,d=2)=>(x<0?"−":"")+Math.abs(x).toFixed(d);
  return{col,readCols,view,plot,arrow,clock,fmt};
})();
