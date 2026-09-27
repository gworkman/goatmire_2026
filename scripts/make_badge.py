"""Generate images/badge.svg: a portrait illustration of the Goatmire 2026 badge.

Drawn to scale at 5 SVG units per mm. Run from the repo root:
    python3 scripts/make_badge.py
"""

from xml.sax.saxutils import escape

U = 5  # SVG units per mm

# Badge body: 100 x 120 mm
W, H = 100 * U, 120 * U
TOP = 20  # room above the body so the outline isn't clipped
BODY_Y = TOP

# 2.8" diagonal screen, 4:3 landscape -> 56.9 x 42.7 mm
DIAG = 2.8 * 25.4
SW, SH = DIAG * 0.8 * U, DIAG * 0.6 * U
SX, SY = (W - SW) / 2, BODY_Y + 13 * U
BEZEL = 4 * U

# Keyboard: 13-column grid in the lower half.
# Each row is a list of (width in grid columns, label) pairs. Widths may be
# fractional; an empty label draws a blank key.
# NOTE: legends are placeholders until the real layout is known.
COLS = 13


def row(labels):
    return [(1, label) for label in labels.split()]


ROWS = [
    [(COLS / 8, "")] * 8,  # 8 wide, unlabelled keys across the full row
    row("Esc Q W E R T Y U I O P - ⌫"),
    row("Tab A S D F G H J K L ; ' ↵"),
    row("⇧ Z X C V B N M , . / ↑ Del"),
    row("Fn Ctrl Alt Sym") + [(5, "")] + row("Alt ← ↓ →"),
]

KEY_FILL = "#2A2830"
KEY_STROKE = "#15141A"
LEGEND = "#F6F2EA"
# Sans-serif monospace. Typst resolves DejaVu Sans Mono (bundled); other SVG
# viewers fall through to whatever sans mono the system has, never Courier.
KEY_FONT = "'DejaVu Sans Mono', Menlo, 'SF Mono', Monaco, Consolas, 'Roboto Mono', 'Liberation Mono', sans-serif"

KB_X0, KB_X1 = 6 * U, W - 6 * U
KB_Y0, KB_Y1 = BODY_Y + H / 2 + 7 * U, BODY_Y + H - 7 * U
GX, GY = 1.4 * U, 2.4 * U
KW = (KB_X1 - KB_X0 - (COLS - 1) * GX) / COLS
KH = (KB_Y1 - KB_Y0 - (len(ROWS) - 1) * GY) / len(ROWS)


def keys_svg():
    out = []
    for r, keys in enumerate(ROWS):
        col = 0
        for span, label in keys:
            x = KB_X0 + col * (KW + GX)
            y = KB_Y0 + r * (KH + GY)
            w = span * KW + (span - 1) * GX
            out.append(
                f'<rect x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{KH:.1f}" rx="5" '
                f'fill="{KEY_FILL}" stroke="{KEY_STROKE}" stroke-width="1.5"/>'
            )
            if label:
                size = 20 if label in "⇧⌫" else 13 if len(label) == 1 else 9
                out.append(
                    f'<text x="{x + w / 2:.1f}" y="{y + KH / 2:.1f}" fill="{LEGEND}" '
                    f'font-family="{KEY_FONT}" font-size="{size}" font-weight="500" '
                    f'text-anchor="middle" dominant-baseline="central">{escape(label)}</text>'
                )
            col += span
    return "\n  ".join(out)


def main():
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H + TOP}">
  <defs>
    <linearGradient id="scr" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#1F8A84"/><stop offset="1" stop-color="#0E3F3C"/>
    </linearGradient>
  </defs>
  <rect x="0" y="{BODY_Y}" width="{W}" height="{H}" rx="{7 * U}" fill="#DDD7CC"/>
  <rect x="4" y="{BODY_Y + 4}" width="{W - 8}" height="{H - 8}" rx="{7 * U - 4}" fill="none" stroke="#CBC4B6" stroke-width="3"/>
  <rect x="{SX - BEZEL:.1f}" y="{SY - BEZEL:.1f}" width="{SW + 2 * BEZEL:.1f}" height="{SH + 2 * BEZEL:.1f}" rx="10" fill="#15141A"/>
  <rect x="{SX:.1f}" y="{SY:.1f}" width="{SW:.1f}" height="{SH:.1f}" rx="3" fill="url(#scr)"/>
  <rect x="{SX + 22:.1f}" y="{SY + 34:.1f}" width="{SW * 0.55:.1f}" height="26" rx="3" fill="#F6F2EA" opacity="0.9"/>
  <rect x="{SX + 22:.1f}" y="{SY + 76:.1f}" width="{SW * 0.38:.1f}" height="16" rx="3" fill="#F6F2EA" opacity="0.5"/>
  <rect x="{SX + 22:.1f}" y="{SY + 104:.1f}" width="{SW * 0.46:.1f}" height="16" rx="3" fill="#F6F2EA" opacity="0.5"/>
  <circle cx="{SX + SW - 36:.1f}" cy="{SY + SH - 36:.1f}" r="20" fill="#FF5B1F"/>
  {keys_svg()}
</svg>
'''
    with open("images/badge.svg", "w") as f:
        f.write(svg)
    n = sum(len(keys) for keys in ROWS)
    print(f"{n} keys, {KW / U:.1f} x {KH / U:.1f} mm each")


if __name__ == "__main__":
    main()
