#import "../template/theme.typ": *

// Drawing on the left, explanation on the right.
#let dive-slide(title, drawing, drawing-width: 100%, ratio: (1fr, 1fr), align: horizon, body) = slide(
  title: title,
  kicker: [Deep dive],
  center: true,
)[
  #cols(ratio: ratio, align: align)[
    #std.align(center, image(drawing, width: drawing-width))
  ][
    #body
  ]
]

// --- Keyboard matrix -----------------------------------------------------------

#dive-slide([Keyboard matrix], "/images/schematics/matrix.svg")[
  - Every key sits where a row crosses a column
  - Pressing a key connects its row to its column
  - 6 rows + 13 columns = 19 GPIOs for 69 keys
]

#dive-slide([Scanning the matrix], "/images/schematics/matrix-scan.svg", align: top)[
  + Rows are inputs with pull-ups, so they read *high*
  + Drive one column *low*
  + Read every row: a *low* row means the key at that row and column is pressed
  + Release the column and move on to the next

]

// --- I2C ---------------------------------------------------------------------------

#slide(title: [#i2c], kicker: [Deep dive])[
  #align(center, image("/images/schematics/i2c-bus.svg", width: 66%))
  #v(0.4em)
  #set text(size: 16pt)
  #cols(gutter: 1cm)[
    - Two shared wires: *SCL* (clock) and *SDA* (data)
  ][
    - The ESP32 is the controller and drives the clock
  ][
    - Every device answers to its own 7-bit address
  ]
]

#dive-slide([Pull down only], "/images/schematics/i2c-open-drain.svg", ratio: (1.6fr, 1fr))[
  - Devices can only pull a line *low*, never drive it high
  - Let go, and the pull-up brings it back high
  - Two devices pulling low at once is harmless, so many devices can share the bus
]

#slide(title: [Clock and data], kicker: [Deep dive])[
  #align(center, image("/images/schematics/i2c-timing.svg", width: 88%))
  #v(0.4em)
  #set text(size: 16pt)
  #cols(gutter: 1.2cm)[
    - SDA only changes while SCL is low, and is read while SCL is high
    - The device pulls SDA low on the 9th clock to acknowledge (ACK)
  ][
    - *START:* SDA falls while SCL is high
    - *STOP:* SDA rises while SCL is high
  ]
]

// A frame cell: who sends it decides the colour.
#let cell(body, width: 2.4cm, device: false) = box(
  width: width,
  height: 1.6cm,
  fill: if device { palette.teal } else { palette.ink },
  radius: 3pt,
  align(center + horizon, text(size: 15pt, weight: "medium", fill: palette.paper, body)),
)
#let frame(..cells) = stack(dir: ltr, spacing: 4pt, ..cells)
#let wide = 5cm

#slide(title: [An #i2c transaction], kicker: [Deep dive], center: true)[
  Reading the temperature sensor at address `0x70`:

  === 1. Point at the temperature register
  #frame(
    cell[Start],
    cell(width: wide)[Address 0x70],
    cell[Write],
    cell(device: true)[ACK],
    cell(width: wide)[Register 0x00],
    cell(device: true)[ACK],
  )

  === 2. Read it back
  #frame(
    cell[Restart],
    cell(width: wide)[Address 0x70],
    cell[Read],
    cell(device: true)[ACK],
    cell(width: wide, device: true)[Temperature],
    cell[NACK],
    cell[Stop],
  )

  #v(0.6em)
  #text(size: 14pt)[
    #box(width: 12pt, height: 12pt, fill: palette.ink, radius: 2pt, baseline: 1pt) ESP32 sends
    #h(1.2em)
    #box(width: 12pt, height: 12pt, fill: palette.teal, radius: 2pt, baseline: 1pt) Device sends
  ]
]

#slide(title: [#i2c addresses on the badge], kicker: [Deep dive])[
  #data-table(
    columns: (1fr, auto, auto, 1.2fr),
    [Device], [Part], [Address], [Notes],
    [Temperature sensor], [TMP103], [`0x70`], [],
    [Accelerometer], [SC7A20], [`0x19`], [],
    [Touch controller], [NS2009], [`0x48`], [Not populated],
    [Qwiic port], [—], [—], [Your own devices; pick addresses that don't clash],
  )
]
