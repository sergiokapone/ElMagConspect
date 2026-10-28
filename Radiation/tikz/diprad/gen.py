import numpy as np, contourpy
LAM=1.0; k=2*np.pi
XM,ZM=1.55,1.24
S=4.6  # cm per wavelength
def psi(x,z,wt=0.0):
    r=np.hypot(x,z); R=k*r; s2=(x/np.maximum(r,1e-9))**2
    u=R-wt
    return s2*(np.sin(u)+np.cos(u)/R)
def E(x,z,wt=0.0,h=1e-5):
    dpx=(psi(x+h,z,wt)-psi(x-h,z,wt))/(2*h)
    dpz=(psi(x,z+h,wt)-psi(x,z-h,wt))/(2*h)
    rho=max(abs(x),1e-9)
    return np.array([-dpz/rho, dpx/rho])  # s=-1 : (Erho,Ez)=-(dpsi/dz, -dpsi/drho)/rho
def rdp(p,eps):
    if len(p)<3: return p
    a,b=p[0],p[-1]; d=b-a; n=np.hypot(*d)
    if n==0: dist=np.hypot(*(p-a).T)
    else: dist=np.abs(d[0]*(p[:,1]-a[1])-d[1]*(p[:,0]-a[0]))/n
    i=np.argmax(dist)
    if dist[i]>eps: return np.vstack([rdp(p[:i+1],eps)[:-1],rdp(p[i:],eps)])
    return np.vstack([a,b])
wt=0.0
xs=np.linspace(-XM,XM,1801)+1e-4; zs=np.linspace(-ZM,ZM,1441)+1e-4
X,Z=np.meshgrid(xs,zs); P=psi(X,Z,wt)
# levels: sinh-like spacing, symmetric
base=np.array([0.1,0.2,0.32,0.46,0.62,0.8,1.05,1.5,2.5,5])
levels=np.concatenate([-base[::-1],base])
gen=contourpy.contour_generator(xs,zs,P)
out=[]
for lv in levels:
    for line in gen.lines(lv):
        line=np.asarray(line)
        if len(line)<8: continue
        # skip tiny near-origin blobs outside drawing
        if np.hypot(*line.T).min()<0.03 and len(line)<40: continue
        m=len(line)//2
        t=line[min(m+1,len(line)-1)]-line[m-1]
        e=E(*line[m],wt)
        if np.dot(t,e)<0: line=line[::-1]
        line=rdp(line,0.0012)
        out.append(line)
print(len(out),sum(len(l) for l in out))
f=lambda v:f"({v[0]*S:.3f},{v[1]*S:.3f})"
with open('/mnt/user-data/outputs/dipole_radiation.tex','w') as fh:
    fh.write(r"""\documentclass[tikz,border=4pt]{standalone}
\usetikzlibrary{decorations.markings,decorations.pathmorphing,arrows.meta}
% Силові лінії E випромінювання осцилюючого диполя (диполь Герца) у меридіональній площині.
% Лінії є ізолініями функції потоку
%   psi(r,theta) = sin^2(theta) [ sin(kr - wt) + cos(kr - wt)/(kr) ],
% згенерованими для wt = 0 (див. gen.py).
\definecolor{fieldred}{RGB}{204,24,30}
\definecolor{dipblue}{RGB}{31,119,180}
\definecolor{bcol}{RGB}{20,70,125}
\tikzset{
  bfront/.style={bcol, line cap=round,
    decoration={markings, mark=at position 0.5 with {\arrow[bcol]{Stealth[length=5pt,width=5pt]}}},
    postaction=decorate},
  bback/.style={bcol!70, dash pattern=on 2pt off 2pt}
}
\tikzset{
  fl/.style={fieldred, line width=0.9pt, line join=round, line cap=round,
    decoration={markings,
      mark=at position 0.27 with {\arrow[fieldred]{Stealth[length=4pt,width=4pt]}},
      mark=at position 0.77 with {\arrow[fieldred]{Stealth[length=4pt,width=4pt]}}},
    postaction=decorate}
}
\begin{document}
\begin{tikzpicture}
\clip (CL1,CL2) rectangle (CL3,CL4);
""".replace("CL1",f"{-XM*S:.3f}").replace("CL2",f"{-ZM*S:.3f}").replace("CL3",f"{XM*S:.3f}").replace("CL4",f"{ZM*S:.3f}"))
    for l in out:
        fh.write(r"\draw[fl] "+" -- ".join(f(v) for v in l)+";\n")
    # магнітне поле: B_phi — кола навколо осі z; показані як еліпси (вид зверху під кутом)
    def Bphi(x,z):
        r=np.hypot(x,z); R=k*r; u=R-wt
        return -(abs(x)/r)*(np.cos(u)-np.sin(u)/R)/r
    SA=0.28   # sin(кута нахилу)
    rhos=[0.33,0.95,1.47]; zs_=[-0.55,0.0,0.55]
    Bm=max(abs(Bphi(r_,z_)) for r_ in rhos for z_ in zs_)
    fh.write("% магнітне поле: кола B_phi навколо осі диполя (вид під кутом)\n")
    for r_ in rhos:
        for z_ in zs_:
            b=Bphi(r_,z_)
            if abs(b)<0.12*Bm: continue
            cx,cz=0.0,z_*S; a_=r_*S; b_=a_*SA
            lw=0.5+0.5*min(1,abs(b)/Bm)
            st,en=(180,360) if b>0 else (360,180)
            fh.write(f"\\draw[bfront, line width={lw:.2f}pt] ({cx+a_*np.cos(np.radians(st)):.3f},{cz+b_*np.sin(np.radians(st)):.3f}) arc[start angle={st}, end angle={en}, x radius={a_:.3f}, y radius={b_:.3f}];\n")
            fh.write(f"\\draw[bback, line width={lw*0.8:.2f}pt] ({cx+a_:.3f},{cz:.3f}) arc[start angle=0, end angle=180, x radius={a_:.3f}, y radius={b_:.3f}];\n")
    fh.write(r"""% диполь: два заряди на пружинці
\fill[white, rounded corners=2pt] (-0.2,-0.8) rectangle (0.2,0.8);
\draw[decorate, decoration={coil, aspect=0.6, segment length=1.6mm, amplitude=1.6mm},
      line width=0.7pt, black] (0,-0.76) -- (0,0.76);
\shade[ball color=fieldred] (0,0.95) circle (0.19);
\shade[ball color=dipblue] (0,-0.95) circle (0.19);
\node[white, font=\scriptsize\bfseries] at (0,0.95) {$+$};
\node[white, font=\scriptsize\bfseries] at (0,-0.95) {$-$};
\end{tikzpicture}
\end{document}
""")
