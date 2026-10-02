import json, base64, html, sys, subprocess, os
S=os.path.dirname(os.path.abspath(__file__))
src, out = sys.argv[1], sys.argv[2]
W,H = 1920,1080
cmds=json.load(open(src))
def col(r,g,b,scale=255): 
    f = (lambda v: int(round(v*255))) if scale==1 else (lambda v: int(round(v)))
    return f"rgb({f(r)},{f(g)},{f(b)})"
o=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">',
 '<defs><linearGradient id="bg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#5f7f9f"/><stop offset="0.5" stop-color="#9db4c4"/><stop offset="0.56" stop-color="#4f5a45"/><stop offset="1" stop-color="#2c332b"/></linearGradient>',
 '<filter id="blur"><feGaussianBlur stdDeviation="6"/></filter></defs>',
 f'<rect width="{W}" height="{H}" fill="url(#bg)"/>',
 # algo de "mundo" detrás para que el cristal tenga qué desenfocar
 '<rect x="560" y="300" width="120" height="70" fill="#c33" opacity="0.8"/><rect x="900" y="620" width="200" height="90" fill="#eee" opacity="0.7"/><rect x="1180" y="260" width="140" height="300" fill="#243" opacity="0.8"/>']
gid=0; clipn=0; opened=0
for c in cmds:
    k=c[0]
    if k=='r':
        _,x,y,w,h,r,g,b,a,rad=c
        o.append(f'<rect x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{h:.1f}" rx="{rad:.1f}" fill="{col(r,g,b)}" fill-opacity="{a/255:.3f}"/>')
    elif k=='b':
        _,x,y,w,h,rad,r,g,b,a=c
        gid+=1
        o.append(f'<foreignObject x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{h:.1f}"><div xmlns="http://www.w3.org/1999/xhtml" style="width:100%;height:100%;border-radius:{rad}px;backdrop-filter:blur(10px);background:rgba({int(r*255)},{int(g*255)},{int(b*255)},{a*0.55:.3f})"></div></foreignObject>')
    elif k=='g':
        _,x,y,w,h,rad,r1,g1,b1,a1,r2,g2,b2,a2,r3,g3,b3,a3,r4,g4,b4,a4=c
        gid+=1
        vertical = (abs(r1-r2)+abs(g1-g2)+abs(b1-b2)+abs(a1-a2)) <= (abs(r1-r4)+abs(g1-g4)+abs(b1-b4)+abs(a1-a4))
        if vertical:
            s0=(r1,g1,b1,a1); s1=(r4,g4,b4,a4); xy='x1="0" y1="0" x2="0" y2="1"'
        else:
            s0=(r1,g1,b1,a1); s1=(r2,g2,b2,a2); xy='x1="0" y1="0" x2="1" y2="0"'
        o.append(f'<linearGradient id="g{gid}" {xy}><stop offset="0" stop-color="{col(*s0[:3],scale=1)}" stop-opacity="{s0[3]:.3f}"/><stop offset="1" stop-color="{col(*s1[:3],scale=1)}" stop-opacity="{s1[3]:.3f}"/></linearGradient>')
        o.append(f'<rect x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{h:.1f}" rx="{rad:.1f}" fill="url(#g{gid})"/>')
    elif k=='o':
        _,x,y,w,h,r,g,b,a,th,rad=c
        o.append(f'<rect x="{x+th/2:.1f}" y="{y+th/2:.1f}" width="{w-th:.1f}" height="{h-th:.1f}" rx="{rad:.1f}" fill="none" stroke="{col(r,g,b)}" stroke-opacity="{a/255:.3f}" stroke-width="{th}"/>')
    elif k=='c':
        _,x,y,rr,fill,r,g,b,a,th=c
        if fill: o.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{rr:.1f}" fill="{col(r,g,b,1)}" fill-opacity="{a:.3f}"/>')
        else: o.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{rr:.1f}" fill="none" stroke="{col(r,g,b,1)}" stroke-opacity="{a:.3f}" stroke-width="{th}"/>')
    elif k=='l':
        _,x1,y1,x2,y2,r,g,b,a,th=c
        o.append(f'<line x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" y2="{y2:.1f}" stroke="{col(r,g,b,1)}" stroke-opacity="{a:.3f}" stroke-width="{th}" stroke-linecap="round"/>')
    elif k=='p':
        _,x,y,w,h=c; clipn+=1; opened+=1
        o.append(f'<clipPath id="cp{clipn}"><rect x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{h:.1f}"/></clipPath><g clip-path="url(#cp{clipn})">')
    elif k=='q':
        if opened>0: o.append('</g>'); opened-=1
    elif k=='t':
        _,x,y,t,sz,r,g,b,a,f=c
        fs=sz/1.4 if f else sz
        bold = 'font-weight="600"' if sz>=20 else ''
        o.append(f'<text x="{x:.1f}" y="{y+fs*0.95:.1f}" font-size="{fs:.1f}" {bold} font-family="Poppins,Segoe UI,Helvetica,Arial,sans-serif" fill="{col(r,g,b)}" fill-opacity="{a/255:.3f}">{html.escape(t)}</text>')
    elif k=='i':
        _,x,y,w,h,r,g,b,a,tex=c
        d=base64.b64encode(open(f'{S}/tex_{int(tex)}.bin','rb').read()).decode()
        o.append(f'<image x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{h:.1f}" opacity="{a/255:.3f}" href="data:image/png;base64,{d}"/>')
while opened>0: o.append('</g>'); opened-=1
o.append('</svg>')
svg=out.replace('.png','.svg'); open(svg,'w').write('\n'.join(o))
B=subprocess.check_output("find /opt/pw-browsers/chromium-1194 -maxdepth 3 -name chrome -type f | head -1",shell=True).decode().strip()
subprocess.run([B,"--headless=new","--no-sandbox","--disable-gpu","--hide-scrollbars","--window-size=1920,1080",f"--screenshot={out}","file://"+svg],stderr=subprocess.DEVNULL)
print("ok",out,len(cmds),"ordenes")
