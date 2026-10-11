"""CHIM OStim Bridge - Nexus banner (1920x1080), original artwork, no third-party logos.
Left half: CHIM - cold blue AI network and dialogue. Right half: OStim - warm romance.
The halves meet on a 45 degree diagonal. Writes banner.html; render it to PNG with
a headless browser (see render_banner.ps1).
"""
import math, os, random

W, H = 1920, 1080
# 45 degree divider: x + y = C, through the middle of the picture
C = W // 2 + H // 2
rnd = random.Random(1307)

def inside_left(x, y, margin=0):
    return x + y < C - margin

out = []
add = out.append
add(f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">')
add(f'''<defs>
  <linearGradient id="cold" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#040b1c"/><stop offset="0.55" stop-color="#0a2348"/><stop offset="1" stop-color="#0f3a6e"/>
  </linearGradient>
  <linearGradient id="warm" x1="1" y1="1" x2="0" y2="0">
    <stop offset="0" stop-color="#1d0410"/><stop offset="0.5" stop-color="#5e0d2a"/><stop offset="1" stop-color="#a3174a"/>
  </linearGradient>
  <radialGradient id="coldGlow" cx="0.32" cy="0.42" r="0.55">
    <stop offset="0" stop-color="#3fc8ff" stop-opacity="0.28"/><stop offset="1" stop-color="#3fc8ff" stop-opacity="0"/>
  </radialGradient>
  <radialGradient id="warmGlow" cx="0.72" cy="0.6" r="0.55">
    <stop offset="0" stop-color="#ff5c8a" stop-opacity="0.35"/><stop offset="1" stop-color="#ff5c8a" stop-opacity="0"/>
  </radialGradient>
  <linearGradient id="seam" x1="0" y1="1" x2="1" y2="0">
    <stop offset="0" stop-color="#3fc8ff"/><stop offset="0.5" stop-color="#ffffff"/><stop offset="1" stop-color="#ff5c8a"/>
  </linearGradient>
  <linearGradient id="titleGrad" x1="0" y1="0" x2="1" y2="0">
    <stop offset="0" stop-color="#7fdcff"/><stop offset="0.5" stop-color="#ffffff"/><stop offset="1" stop-color="#ff8fb0"/>
  </linearGradient>
  <filter id="blur8"><feGaussianBlur stdDeviation="8"/></filter>
  <filter id="blur3" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="3"/></filter>
  <filter id="soft" x="-60%" y="-60%" width="220%" height="220%"><feGaussianBlur stdDeviation="22"/></filter>
  <filter id="shadow" x="-20%" y="-50%" width="140%" height="200%">
    <feDropShadow dx="0" dy="4" stdDeviation="10" flood-color="#000" flood-opacity="0.85"/>
  </filter>
  <clipPath id="leftHalf"><polygon points="0,0 {C},0 {C - H},{H} 0,{H}"/></clipPath>
  <clipPath id="rightHalf"><polygon points="{C},0 {W},0 {W},{H} {C - H},{H}"/></clipPath>
  <path id="heart" d="M0,-30 C-25,-70 -90,-55 -90,-5 C-90,40 -30,75 0,105 C30,75 90,40 90,-5 C90,-55 25,-70 0,-30 Z"/>
</defs>''')

# ---------------- left: CHIM
add('<g clip-path="url(#leftHalf)">')
add(f'<rect width="{W}" height="{H}" fill="url(#cold)"/><rect width="{W}" height="{H}" fill="url(#coldGlow)"/>')
# faint hex grid
for row in range(0, 30):
    for col in range(0, 40):
        x = col * 60 + (30 if row % 2 else 0)
        y = row * 52
        if inside_left(x, y):
            pts = " ".join(f"{x + 26 * math.cos(math.radians(a)):.1f},{y + 26 * math.sin(math.radians(a)):.1f}" for a in range(30, 390, 60))
            add(f'<polygon points="{pts}" fill="none" stroke="#3fc8ff" stroke-opacity="0.05" stroke-width="1"/>')
# neural network
nodes = []
while len(nodes) < 70:
    x, y = rnd.uniform(40, C), rnd.uniform(40, H - 40)
    if inside_left(x, y, 60):
        nodes.append((x, y))
for i, (x1, y1) in enumerate(nodes):
    near = sorted(nodes, key=lambda p: (p[0] - x1) ** 2 + (p[1] - y1) ** 2)[1:4]
    for (x2, y2) in near:
        add(f'<line x1="{x1:.0f}" y1="{y1:.0f}" x2="{x2:.0f}" y2="{y2:.0f}" stroke="#3fc8ff" stroke-opacity="0.22" stroke-width="1.4"/>')
for (x, y) in nodes:
    r = rnd.uniform(2.5, 6)
    add(f'<circle cx="{x:.0f}" cy="{y:.0f}" r="{r * 3:.1f}" fill="#3fc8ff" opacity="0.12" filter="url(#blur3)"/>')
    add(f'<circle cx="{x:.0f}" cy="{y:.0f}" r="{r:.1f}" fill="#bff0ff" opacity="0.85"/>')
# dialogue bubbles
def bubble(cx, cy, w, h, tail_left, opacity):
    tail = f"M{cx - w * 0.25:.0f},{cy + h / 2:.0f} l{-28 if tail_left else 28},38 l{30 if tail_left else -30},-38 Z"
    add(f'<g opacity="{opacity}"><rect x="{cx - w / 2:.0f}" y="{cy - h / 2:.0f}" width="{w}" height="{h}" rx="{h / 2:.0f}" fill="#0b2a52" stroke="#7fdcff" stroke-width="3"/>'
        f'<path d="{tail}" fill="#0b2a52" stroke="#7fdcff" stroke-width="3" stroke-linejoin="round"/>'
        + "".join(f'<circle cx="{cx + d:.0f}" cy="{cy:.0f}" r="9" fill="#bff0ff"/>' for d in (-34, 0, 34)) + '</g>')
bubble(330, 300, 230, 96, True, 0.95)
bubble(600, 190, 190, 80, False, 0.8)
bubble(250, 820, 160, 70, True, 0.6)
add('</g>')

# ---------------- right: OStim
add('<g clip-path="url(#rightHalf)">')
add(f'<rect width="{W}" height="{H}" fill="url(#warm)"/><rect width="{W}" height="{H}" fill="url(#warmGlow)"/>')
# bokeh
for _ in range(60):
    x, y = rnd.uniform(C - H, W), rnd.uniform(0, H)
    if not inside_left(x, y, -40):
        r = rnd.uniform(10, 60)
        col = rnd.choice(["#ff8fb0", "#ffb36b", "#ff5c8a", "#ffd2e0"])
        add(f'<circle cx="{x:.0f}" cy="{y:.0f}" r="{r:.0f}" fill="{col}" opacity="{rnd.uniform(0.06, 0.2):.2f}" filter="url(#blur3)"/>')
# hearts
def heart(x, y, s, opacity, glow=False):
    if glow:
        add(f'<use href="#heart" transform="translate({x},{y}) scale({s * 1.15})" fill="#ff5c8a" opacity="0.55" filter="url(#soft)"/>')
    add(f'<use href="#heart" transform="translate({x},{y}) scale({s})" fill="#ff5c8a" stroke="#ffd2e0" stroke-width="{3 / s:.2f}" opacity="{opacity}"/>')
heart(1700, 830, 1.35, 0.95, glow=True)
heart(1420, 960, 0.6, 0.5)
heart(1790, 330, 0.7, 0.5)
heart(1450, 230, 0.5, 0.4)
# sparkles
for _ in range(40):
    x, y = rnd.uniform(C - H + 100, W), rnd.uniform(0, H)
    if not inside_left(x, y, -60):
        s = rnd.uniform(2, 5)
        add(f'<path d="M{x:.0f},{y - s * 3:.0f} L{x + s:.0f},{y:.0f} L{x:.0f},{y + s * 3:.0f} L{x - s:.0f},{y:.0f} Z" fill="#fff" opacity="{rnd.uniform(0.4, 0.9):.2f}"/>')
add('</g>')

# ---------------- seam
add(f'<line x1="{C - H - 20}" y1="{H + 20}" x2="{C + 20}" y2="-20" stroke="url(#seam)" stroke-width="26" opacity="0.35" filter="url(#blur8)"/>')
add(f'<line x1="{C - H - 20}" y1="{H + 20}" x2="{C + 20}" y2="-20" stroke="url(#seam)" stroke-width="5"/>')

# ---------------- title
add('<g font-family="Georgia, Palatino Linotype, serif" text-anchor="middle" filter="url(#shadow)">')
add(f'<rect x="{W / 2 - 560}" y="{H / 2 - 150}" width="1120" height="300" rx="28" fill="#000" opacity="0.38"/>')
add(f'<text x="{W / 2 - 40}" y="{H / 2 + 10}" text-anchor="end" font-size="140" font-weight="bold" letter-spacing="10" fill="#7fdcff">CHIM</text>')
add(f'<text x="{W / 2 + 40}" y="{H / 2 + 10}" text-anchor="start" font-size="140" font-weight="bold" letter-spacing="6" fill="#ff8fb0">OStim</text>')
add(f'<text x="{W / 2}" y="{H / 2 + 100}" font-size="64" letter-spacing="34" fill="url(#titleGrad)">BRIDGE</text>')
add(f'<text x="{W / 2}" y="{H - 48}" font-size="34" letter-spacing="6" fill="#ffffff" opacity="0.85">by SaurOff</text>')
add('</g>')
add('</svg>')

here = os.path.dirname(os.path.abspath(__file__))
svg = "\n".join(out)
open(os.path.join(here, "banner.svg"), "w", encoding="utf-8").write(svg)
open(os.path.join(here, "banner.html"), "w", encoding="utf-8").write(
    '<!doctype html><html><head><meta charset="utf-8"><style>html,body{margin:0;padding:0;background:#000;overflow:hidden}</style></head><body>'
    + svg + "</body></html>")
print("written", os.path.join(here, "banner.html"))
