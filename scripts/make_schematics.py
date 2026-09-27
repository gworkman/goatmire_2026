"""Generate schematic drawings for the electronics basics section.

Writes SVGs into images/schematics/. Run from the repo root:
    python3 scripts/make_schematics.py
"""

import os

INK = "#15141A"
ACCENT = "#FF5B1F"
STROKE = 3
FONT = "Poppins, 'Helvetica Neue', Arial, sans-serif"
OUT = "images/schematics"


def svg(w, h, body):
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}">\n'
        f'<g fill="none" stroke="{INK}" stroke-width="{STROKE}" stroke-linecap="round" stroke-linejoin="round">\n'
        f"{body}\n</g>\n</svg>\n"
    )


def line(*pts, **attrs):
    extra = "".join(f' {k.replace("_", "-")}="{v}"' for k, v in attrs.items())
    return f'<polyline points="{" ".join(f"{x:g},{y:g}" for x, y in pts)}"{extra}/>'


def poly(*pts, fill=INK):
    return f'<polygon points="{" ".join(f"{x:g},{y:g}" for x, y in pts)}" fill="{fill}" stroke="none"/>'


def dot(x, y, r=5, fill=INK):
    return f'<circle cx="{x:g}" cy="{y:g}" r="{r}" fill="{fill}" stroke="none"/>'


def terminal(x, y, r=6):
    return f'<circle cx="{x:g}" cy="{y:g}" r="{r}" fill="#FFFFFF"/>'


def label(x, y, text, size=22, anchor="start", sub=None, fill=INK, weight=600):
    sub_svg = f'<tspan font-size="{size * 0.65:g}" dy="{size * 0.25:g}">{sub}</tspan>' if sub else ""
    return (
        f'<text x="{x:g}" y="{y:g}" font-family="{FONT}" font-size="{size}" font-weight="{weight}" '
        f'fill="{fill}" stroke="none" text-anchor="{anchor}" dominant-baseline="central">{text}{sub_svg}</text>'
    )


def zigzag_h(x0, x1, y, amp=16, peaks=6):
    step = (x1 - x0) / (peaks + 1)
    pts = [(x0, y)]
    for i in range(peaks):
        pts.append((x0 + step * (i + 0.5) + step / 2, y + (-amp if i % 2 == 0 else amp)))
    pts.append((x1, y))
    return pts


def zigzag_v(x, y0, y1, amp=16, peaks=6):
    return [(px, py) for py, px in [(p[0], p[1]) for p in zigzag_h(y0, y1, x, amp, peaks)]]


def arrow_right(x, y, size=10, fill=ACCENT):
    return poly((x + size, y), (x - size * 0.6, y - size * 0.8), (x - size * 0.6, y + size * 0.8), fill=fill)


# --- Symbols ---------------------------------------------------------------


def resistor():
    y = 50
    return svg(240, 100, line((10, y), (70, y)) + line(*zigzag_h(70, 170, y)) + line((170, y), (230, y)))


def capacitor():
    y = 60
    return svg(240, 120, "\n".join([
        line((10, y), (110, y)),
        line((110, 22), (110, 98), stroke_width=6),
        line((130, 22), (130, 98), stroke_width=6),
        line((130, y), (230, y)),
    ]))


def diode():
    y = 60
    return svg(240, 150, "\n".join([
        line((10, y), (90, y)),
        poly((90, 25), (90, 95), (150, y)),
        line((150, 25), (150, 95), stroke_width=5),
        line((150, y), (230, y)),
        label(30, 30, "A", size=20),
        label(210, 30, "K", size=20),
        # current direction
        line((70, 128), (160, 128), stroke=ACCENT),
        arrow_right(166, 128),
    ]))


def mosfet():
    """N-channel enhancement MOSFET."""
    return svg(220, 220, "\n".join([
        # gate
        line((20, 145), (80, 145)),
        line((80, 65), (80, 155), stroke_width=4),
        # channel segments
        line((95, 62), (95, 88), stroke_width=5),
        line((95, 98), (95, 122), stroke_width=5),
        line((95, 132), (95, 158), stroke_width=5),
        # drain
        line((95, 75), (145, 75), (145, 15)),
        # source + body tie
        line((95, 145), (145, 145), (145, 205)),
        line((95, 110), (145, 110), (145, 145)),
        dot(145, 145, r=4),
        # arrow into the channel (N-channel)
        poly((98, 110), (116, 101), (116, 119)),
        label(20, 125, "G", size=20),
        label(160, 25, "D", size=20),
        label(160, 195, "S", size=20),
    ]))


# --- Circuits --------------------------------------------------------------


def ohms_law():
    L, R, T, B = 80, 270, 70, 220
    mid = (T + B) / 2
    ax0, ax1, ay = (L + R) / 2 - 40, (L + R) / 2 + 34, T - 20
    return svg(340, 250, "\n".join([
        # battery on the left wire (long plate = +)
        line((L, T), (L, mid - 8)),
        line((L - 24, mid - 8), (L + 24, mid - 8)),
        line((L - 13, mid + 8), (L + 13, mid + 8), stroke_width=6),
        line((L, mid + 8), (L, B)),
        label(L - 36, mid - 22, "+", size=20),
        label(L - 58, mid + 2, "V", size=26, anchor="middle"),
        # resistor on the right wire
        line((R, T), (R, mid - 45)),
        line(*zigzag_v(R, mid - 45, mid + 45)),
        line((R, mid + 45), (R, B)),
        label(R + 30, mid, "R", size=26),
        # top and bottom wires
        line((L, T), (R, T)),
        line((L, B), (R, B)),
        # current: arrow running alongside the top wire
        line((ax0, ay), (ax1, ay), stroke=ACCENT),
        arrow_right(ax1 + 6, ay),
        label((ax0 + ax1) / 2 + 3, ay - 26, "I", size=26, anchor="middle", fill=ACCENT),
    ]))


def arrow_down(x, y, size=10, fill=ACCENT):
    return poly((x, y + size), (x - size * 0.8, y - size * 0.6), (x + size * 0.8, y - size * 0.6), fill=fill)


def divider(show_current=False, highlight_r2=False):
    """Two-resistor divider. Variants add the loop current or highlight R2."""
    x, top = 110, 30
    r1 = (70, 150)
    r2 = (200, 280)
    tap = (r1[1] + r2[0]) / 2
    gnd = 300
    r2_color = ACCENT if highlight_r2 else INK
    parts = [
        terminal(x, top),
        label(x - 24, top, "V", anchor="end", sub="in"),
        line((x, top + 6), (x, r1[0])),
        line(*zigzag_v(x, *r1)),
        label(x + 30, sum(r1) / 2, "R", sub="1"),
        line((x, r1[1]), (x, r2[0])),
        dot(x, tap),
        line((x, tap), (230, tap), stroke=ACCENT),
        terminal(236, tap),
        label(252, tap, "V", sub="out", fill=ACCENT),
        line(*zigzag_v(x, *r2), stroke=r2_color),
        label(x + 30, sum(r2) / 2, "R", sub="2", fill=r2_color),
        line((x, r2[1]), (x, gnd)),
        # ground
        line((x - 26, gnd), (x + 26, gnd)),
        line((x - 16, gnd + 10), (x + 16, gnd + 10)),
        line((x - 6, gnd + 20), (x + 6, gnd + 20)),
    ]
    if show_current:
        ax = x - 50
        parts += [
            line((ax, r1[0] + 5), (ax, r2[1] - 12), stroke=ACCENT),
            arrow_down(ax, r2[1] - 10, size=12),
            label(ax - 14, tap, "I", size=26, anchor="end", fill=ACCENT),
        ]
    return svg(320, 350, "\n".join(parts))


DRAWINGS = {
    "resistor": resistor,
    "capacitor": capacitor,
    "diode": diode,
    "mosfet": mosfet,
    "ohms-law": ohms_law,
    "divider": divider,
    "divider-current": lambda: divider(show_current=True),
    "divider-r2": lambda: divider(highlight_r2=True),
}


def main():
    os.makedirs(OUT, exist_ok=True)
    for name, fn in DRAWINGS.items():
        with open(f"{OUT}/{name}.svg", "w") as f:
            f.write(fn())
    print(f"wrote {len(DRAWINGS)} drawings to {OUT}/")


if __name__ == "__main__":
    main()
