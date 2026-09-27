"""Generate images/badge.svg: a portrait illustration of the Goatmire 2026 badge.

Drawn to scale at 5 SVG units per mm. Run from the repo root:
    python3 scripts/make_badge.py
"""

from xml.sax.saxutils import escape

U = 5  # SVG units per mm

# Badge body: 100 x 120 mm
W, H = 100 * U, 120 * U
PAD = 4  # margin around the body inside the viewBox
BODY_Y = 0

# 2.8" diagonal screen, 4:3 landscape -> 56.9 x 42.7 mm
DIAG = 2.8 * 25.4
SW, SH = DIAG * 0.8 * U, DIAG * 0.6 * U
SX, SY = (W - SW) / 2, BODY_Y + 13 * U
BEZEL = 1.4 * U

# Keyboard: 13-column grid in the lower half.
# Each row is a list of (width in grid columns, label) pairs. Widths may be
# fractional. Labels: text, a Shape, "" for a blank key, or None for an
# empty slot (no key drawn).
# Legends match the keyboard matrix in the badge schematic.
COLS = 13


class Shape:
    def __init__(self, kind, color):
        self.kind, self.color = kind, color


def row(labels):
    return [(1, label) for label in labels.split()]


SLOT = COLS / 9  # top row: 9 equal slots, middle one empty
ROWS = [
    [
        (SLOT, "Esc"),
        (SLOT, Shape("square", "#E5484D")),
        (SLOT, Shape("triangle", "#FF8A1F")),
        (SLOT, Shape("x", "#F2C12E")),
        (SLOT, None),
        (SLOT, Shape("circle", "#3FB36B")),
        (SLOT, Shape("clover", "#3B82F6")),
        (SLOT, Shape("diamond", "#9B6BE8")),
        (SLOT, "⌫"),
    ],
    row("~ 1 2 3 4 5 6 7 8 9 0 - ="),
    row("Tab Q W E R T Y U I O P [ ]"),
    row("Fn A S D F G H J K L ; ' ↵"),
    row("⇧ Z X C V B N M , . / ↑ ⇧"),
    row("Ctrl Super Alt \\") + [(5, "")] + row("Alt ← ↓ →"),
]

KEY_FILL = "#2A2830"
KEY_STROKE = "#15141A"
LEGEND = "#F6F2EA"
# Sans-serif monospace. Typst resolves DejaVu Sans Mono (bundled); other SVG
# viewers fall through to whatever sans mono the system has, never Courier.
KEY_FONT = "'DejaVu Sans Mono', Menlo, 'SF Mono', Monaco, Consolas, 'Roboto Mono', 'Liberation Mono', sans-serif"

KB_X0, KB_X1 = 6 * U, W - 6 * U
KB_Y0, KB_Y1 = BODY_Y + H / 2 + 4 * U, BODY_Y + H - 7 * U
GX, GY = 1.4 * U, 1.8 * U
KW = (KB_X1 - KB_X0 - (COLS - 1) * GX) / COLS
KH = (KB_Y1 - KB_Y0 - (len(ROWS) - 1) * GY) / len(ROWS)


def shape_svg(shape, cx, cy, size):
    """A filled symbol of roughly `size` units, centred on (cx, cy)."""
    h = size / 2
    fill = f'fill="{shape.color}"'
    if shape.kind == "square":
        s = size * 0.85
        return f'<rect x="{cx - s / 2:.1f}" y="{cy - s / 2:.1f}" width="{s:.1f}" height="{s:.1f}" rx="1.5" {fill}/>'
    if shape.kind == "circle":
        return f'<circle cx="{cx:.1f}" cy="{cy:.1f}" r="{h:.1f}" {fill}/>'
    if shape.kind == "triangle":
        pts = [(cx, cy - h), (cx + h * 1.1, cy + h * 0.85), (cx - h * 1.1, cy + h * 0.85)]
        return f'<polygon points="{" ".join(f"{x:.1f},{y:.1f}" for x, y in pts)}" {fill} stroke-linejoin="round"/>'
    if shape.kind == "diamond":
        pts = [(cx, cy - h * 1.15), (cx + h * 0.9, cy), (cx, cy + h * 1.15), (cx - h * 0.9, cy)]
        return f'<polygon points="{" ".join(f"{x:.1f},{y:.1f}" for x, y in pts)}" {fill}/>'
    if shape.kind == "x":
        d = h * 0.8
        return (
            f'<path d="M{cx - d:.1f} {cy - d:.1f} L{cx + d:.1f} {cy + d:.1f} M{cx + d:.1f} {cy - d:.1f} L{cx - d:.1f} {cy + d:.1f}" '
            f'stroke="{shape.color}" stroke-width="{size * 0.24:.1f}" stroke-linecap="round" fill="none"/>'
        )
    if shape.kind == "clover":
        r, o = size * 0.21, size * 0.3
        leaves = "".join(
            f'<circle cx="{cx + dx:.1f}" cy="{cy + dy:.1f}" r="{r:.1f}" {fill}/>'
            for dx, dy in [(0, -o), (o, 0), (0, o), (-o, 0)]
        )
        return leaves
    raise ValueError(shape.kind)


def keys_svg():
    out = []
    for r, keys in enumerate(ROWS):
        col = 0
        for span, label in keys:
            x = KB_X0 + col * (KW + GX)
            y = KB_Y0 + r * (KH + GY)
            w = span * KW + (span - 1) * GX
            col += span
            if label is None:
                continue
            out.append(
                f'<rect x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{KH:.1f}" rx="5" '
                f'fill="{KEY_FILL}" stroke="{KEY_STROKE}" stroke-width="1.5"/>'
            )
            if isinstance(label, Shape):
                out.append(shape_svg(label, x + w / 2, y + KH / 2, KH * 0.42))
            elif label:
                size = 20 if label in "⇧⌫" else 13 if len(label) == 1 else 9 if len(label) <= 4 else 7.5
                out.append(
                    f'<text x="{x + w / 2:.1f}" y="{y + KH / 2:.1f}" fill="{LEGEND}" '
                    f'font-family="{KEY_FONT}" font-size="{size}" font-weight="500" '
                    f'text-anchor="middle" dominant-baseline="central">{escape(label)}</text>'
                )
    return "\n  ".join(out)


def main():
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="{-PAD} {-PAD} {W + 2 * PAD} {H + 2 * PAD}">
  <rect x="0" y="{BODY_Y}" width="{W}" height="{H}" rx="{7 * U}" fill="#DDD7CC"/>
  <rect x="4" y="{BODY_Y + 4}" width="{W - 8}" height="{H - 8}" rx="{7 * U - 4}" fill="none" stroke="#CBC4B6" stroke-width="3"/>
  <rect x="{SX - BEZEL:.1f}" y="{SY - BEZEL:.1f}" width="{SW + 2 * BEZEL:.1f}" height="{SH + 2 * BEZEL:.1f}" rx="4" fill="#3A3842"/>
  <rect x="{SX:.1f}" y="{SY:.1f}" width="{SW:.1f}" height="{SH:.1f}" rx="1" fill="#050506"/>
  {keys_svg()}
</svg>
'''
    with open("images/badge.svg", "w") as f:
        f.write(svg)
    n = sum(1 for keys in ROWS for _, label in keys if label is not None)
    print(f"{n} keys, {KW / U:.1f} x {KH / U:.1f} mm each")


if __name__ == "__main__":
    main()
