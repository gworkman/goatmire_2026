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


# --- Keyboard matrix ---------------------------------------------------------

MX_COLS = [160, 290, 420]
MX_ROWS = [86, 196, 306]
MX_LEFT, MX_RIGHT, MX_TOP, MX_BOTTOM = 110, 490, 36, 326
KEY = 30  # key box size


def _key_anchor(c, r):
    """Where a key connects: (column tap y, key box x0, row tap x)."""
    x, y = MX_COLS[c], MX_ROWS[r]
    return y - 35, x + 30, x + 45


def matrix(active_col=None, pressed=(), ghost=None, path=None):
    """3x3 slice of the keyboard matrix. Columns are driven, rows are read."""
    parts = []
    if path:
        parts.append(line(*path, stroke=ACCENT, stroke_width=12, stroke_opacity=0.25))
    for c, x in enumerate(MX_COLS):
        color = ACCENT if c == active_col else INK
        parts.append(line((x, MX_TOP), (x, MX_BOTTOM), stroke=color))
        parts.append(label(x, MX_TOP - 22, f"COL{c}", size=18, anchor="middle", fill=color))
    for r, y in enumerate(MX_ROWS):
        parts.append(line((MX_LEFT, y), (MX_RIGHT, y)))
        parts.append(label(MX_LEFT - 12, y, f"ROW{r}", size=18, anchor="end"))
    for c, x in enumerate(MX_COLS):
        for r, y in enumerate(MX_ROWS):
            ty, bx, rx = _key_anchor(c, r)
            is_ghost = ghost == (c, r)
            fill = ACCENT if (c, r) in pressed else "#FFFFFF"
            stroke = ACCENT if is_ghost else INK
            dash = ' stroke-dasharray="5 4"' if is_ghost else ""
            parts += [
                line((x, ty), (bx, ty)),
                f'<rect x="{bx}" y="{ty - KEY / 2}" width="{KEY}" height="{KEY}" rx="4" fill="{fill}" stroke="{stroke}"{dash}/>',
                line((rx, ty + KEY / 2), (rx, y)),
                dot(x, ty, r=4),
                dot(rx, y, r=4),
            ]
            if is_ghost:
                parts.append(label(bx + KEY / 2, ty, "?", size=18, anchor="middle", fill=ACCENT))
    return svg(520, 346, "\n".join(parts))


def matrix_scan():
    # COL1 driven low, key (COL1, ROW1) pressed: ROW1 is pulled low.
    ty, bx, rx = _key_anchor(1, 1)
    path = [(MX_COLS[1], MX_TOP), (MX_COLS[1], ty), (rx, ty), (rx, MX_ROWS[1]), (MX_LEFT, MX_ROWS[1])]
    return matrix(active_col=1, pressed={(1, 1)}, path=path)


# --- I2C bus -------------------------------------------------------------------


def i2c_bus():
    sda, scl = 130, 185
    x0, x1 = 170, 760
    devices = [(380, "Temperature", "0x70"), (530, "Accelerometer", "0x19"), (680, "Qwiic port", "")]
    parts = [
        # controller
        f'<rect x="20" y="{sda - 30}" width="150" height="{scl - sda + 60}" rx="6" fill="#FFFFFF"/>',
        label(95, (sda + scl) / 2, "ESP32-S3", size=20, anchor="middle"),
        # 3.3 V rail and pull-ups
        line((215, 40), (300, 40)),
        label(258, 20, "3.3 V", size=18, anchor="middle"),
        line((230, 40), (230, 55)), line(*zigzag_v(230, 55, 105, amp=10, peaks=5)), line((230, 105), (230, sda)),
        line((285, 40), (285, 55)), line(*zigzag_v(285, 55, 105, amp=10, peaks=5)), line((285, 105), (285, scl)),
        dot(230, sda), dot(285, scl),
        # bus lines
        line((x0, sda), (x1, sda), stroke=ACCENT),
        line((x0, scl), (x1, scl), stroke=ACCENT),
        label(x1 + 12, sda, "SDA", size=18, fill=ACCENT),
        label(x1 + 12, scl, "SCL", size=18, fill=ACCENT),
    ]
    for cx, name, addr in devices:
        top = 235
        parts += [
            line((cx - 20, sda), (cx - 20, top)), dot(cx - 20, sda),
            line((cx + 20, scl), (cx + 20, top)), dot(cx + 20, scl),
            f'<rect x="{cx - 65}" y="{top}" width="130" height="62" rx="6" fill="#FFFFFF"/>',
            label(cx, top + (20 if addr else 31), name, size=16, anchor="middle"),
        ]
        if addr:
            parts.append(label(cx, top + 43, addr, size=16, anchor="middle", fill=ACCENT))
    return svg(830, 310, "\n".join(parts))


TEAL = "#1F8A84"


def switch(x, y0, closed=False, color=INK):
    """Vertical switch from (x, y0) down to (x, y0 + 40)."""
    tip = (x, y0 + 40) if closed else (x + 20, y0 + 34)
    return "\n".join([
        dot(x, y0, r=4, fill=color),
        line((x, y0), tip, stroke=color),
        dot(x, y0 + 40, r=4, fill=color),
    ])


def ground(x, y, color=INK):
    return "\n".join([
        line((x - 16, y), (x + 16, y), stroke=color),
        line((x - 10, y + 7), (x + 10, y + 7), stroke=color),
        line((x - 4, y + 14), (x + 4, y + 14), stroke=color),
    ])


def open_drain():
    """One bus line, a pull-up, and three devices that can only pull it low."""
    bus, rail = 150, 40
    rx = 110
    devices = [(290, "ESP32", False), (430, "Temperature", True), (570, "Accelerometer", False)]
    active = next(x for x, _, closed in devices if closed)
    parts = [
        # current path: pull-up, along the bus, through the closed switch
        line((rx, rail + 10), (rx, bus), (active, bus), (active, 250), stroke=ACCENT, stroke_width=12, stroke_opacity=0.25),
        line((rx - 40, rail), (rx + 40, rail)),
        label(rx, rail - 20, "3.3 V", size=18, anchor="middle"),
        line((rx, rail), (rx, rail + 15)),
        line(*zigzag_v(rx, rail + 15, bus - 25, amp=12, peaks=5)),
        line((rx, bus - 25), (rx, bus)),
        label(rx - 22, (rail + bus) / 2 - 4, "pull-up", size=16, anchor="end"),
        dot(rx, bus),
        line((rx, bus), (680, bus), stroke=ACCENT),
        label(692, bus, "SDA", size=18, fill=ACCENT),
    ]
    for x, name, closed in devices:
        color = ACCENT if closed else INK
        parts += [
            dot(x, bus),
            line((x, bus), (x, 200), stroke=color),
            switch(x, 200, closed=closed, color=color),
            line((x, 240), (x, 262), stroke=color),
            ground(x, 262, color=color),
            label(x, 305, name, size=16, anchor="middle", fill=color),
        ]
    return svg(740, 325, "\n".join(parts))


def i2c_timing():
    """SCL/SDA waveforms: START, address 0x70, write bit, ACK, STOP."""
    scl_hi, scl_lo = 70, 120
    sda_hi, sda_lo = 190, 240
    x_start, x_end = 90, 1000
    t_start = 140          # SDA falls while SCL is high
    first = 190            # first bit period starts here
    period = 80
    edge = 6
    bits = [1, 1, 1, 0, 0, 0, 0, 0, 0]  # 0x70, write (0), ACK (0)
    names = ["1", "1", "1", "0", "0", "0", "0", "W", "ACK"]
    t_stop_clk = first + len(bits) * period + 20
    t_stop = t_stop_clk + 30

    # SCL
    scl = [(x_start, scl_hi), (first - 30, scl_hi), (first - 30 + edge, scl_lo)]
    for i in range(len(bits)):
        xb = first + i * period
        scl += [(xb + 20, scl_lo), (xb + 20 + edge, scl_hi), (xb + 60, scl_hi), (xb + 60 + edge, scl_lo)]
    scl += [(t_stop_clk, scl_lo), (t_stop_clk + edge, scl_hi), (x_end, scl_hi)]

    # SDA
    level = 1
    sda = [(x_start, sda_hi), (t_start, sda_hi), (t_start + edge, sda_lo)]
    level = 0

    def y(l):
        return sda_hi if l else sda_lo

    for i, b in enumerate(bits):
        xb = first + i * period
        if b != level:
            sda += [(xb, y(level)), (xb + edge, y(b))]
            level = b
    sda += [(t_stop, y(level)), (t_stop + edge, sda_hi), (x_end, sda_hi)]

    ack_x = first + 8 * period
    # SDA is sampled while SCL is high: mark each rising clock edge
    sample_lines = [
        line((first + i * period + 20 + edge / 2, 40), (first + i * period + 20 + edge / 2, 262),
             stroke="#6E6A62", stroke_width=2, stroke_opacity=0.5, stroke_dasharray="4 5")
        for i in range(len(bits))
    ]
    parts = sample_lines + [
        label(20, (scl_hi + scl_lo) / 2, "SCL", size=20),
        label(20, (sda_hi + sda_lo) / 2, "SDA", size=20),
        # START / STOP markers
        line((t_start + 3, 30), (t_start + 3, 262), stroke=ACCENT, stroke_width=2, stroke_dasharray="6 5"),
        label(t_start + 3, 18, "START", size=16, anchor="middle", fill=ACCENT),
        line((t_stop + 3, 30), (t_stop + 3, 262), stroke=ACCENT, stroke_width=2, stroke_dasharray="6 5"),
        label(t_stop + 3, 18, "STOP", size=16, anchor="middle", fill=ACCENT),
        # ACK: the device holds SDA low
        f'<rect x="{ack_x + 3}" y="{sda_hi - 8}" width="{period - 6}" height="{sda_lo - sda_hi + 16}" rx="4" fill="{TEAL}" fill-opacity="0.15" stroke="none"/>',
        line(*scl),
        line(*sda),
    ]
    for i, n in enumerate(names):
        cx = first + i * period + 40
        fill = TEAL if n == "ACK" else INK
        parts.append(label(cx, 160, n, size=16, anchor="middle", fill=fill))
    # bracket under the address bits
    a0, a1 = first + 4, first + 7 * period - 4
    parts += [
        line((a0, 262), (a0, 270), (a1, 270), (a1, 262), stroke_width=2),
        label((a0 + a1) / 2, 292, "Address 0x70", size=16, anchor="middle"),
    ]
    return svg(1020, 305, "\n".join(parts))


DRAWINGS = {
    "resistor": resistor,
    "capacitor": capacitor,
    "diode": diode,
    "mosfet": mosfet,
    "ohms-law": ohms_law,
    "divider": divider,
    "divider-current": lambda: divider(show_current=True),
    "divider-r2": lambda: divider(highlight_r2=True),
    "matrix": matrix,
    "matrix-scan": matrix_scan,
    "i2c-bus": i2c_bus,
    "i2c-open-drain": open_drain,
    "i2c-timing": i2c_timing,
}


def main():
    os.makedirs(OUT, exist_ok=True)
    for name, fn in DRAWINGS.items():
        with open(f"{OUT}/{name}.svg", "w") as f:
            f.write(fn())
    print(f"wrote {len(DRAWINGS)} drawings to {OUT}/")


if __name__ == "__main__":
    main()
