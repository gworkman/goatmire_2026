#import "../template/theme.typ": *

#section-slide(number: 1, [Electronics basics], subtitle: [Just enough theory to keep the magic smoke in])

// --- Components ------------------------------------------------------------

#let component-slide(name, symbol, symbol-width: 80%, ..rows) = page(grid(
  columns: (1fr, 1.45fr),
  rows: (1fr,),
  column-gutter: 1.2cm,
  align: horizon,
  block(
    width: 100%,
    height: 85%,
    fill: palette.surface,
    radius: 8pt,
    align(center + horizon, image(symbol, width: symbol-width)),
  ),
  {
    block(below: 0.5em, text(size: 12pt, weight: "semibold", tracking: 0.18em, fill: palette.accent)[COMPONENTS])
    heading(level: 2, name)
    spec-list(..rows)
  },
))

#component-slide(
  [Resistor],
  "/images/schematics/resistor.svg",
  ([Does], [Limits current. Turns current into a voltage drop (and a bit of heat)]),
  ([Unit], [Ohms (Ω)]),
  ([Used for], [LED current limiting, pull-ups and pull-downs, voltage dividers]),
)

#component-slide(
  [Capacitor],
  "/images/schematics/capacitor.svg",
  ([Does], [Stores charge. Blocks steady DC, passes changes]),
  ([Unit], [Farads (F)]),
  ([Used for], [Decoupling next to chips, smoothing power, filters and timing]),
)

#component-slide(
  [Diode],
  "/images/schematics/diode.svg",
  ([Does], [Lets current flow one way only]),
  ([Key spec], [Forward voltage drop]),
  ([Used for], [Blocking current from flowing backwards, making light (LEDs)]),
)

#component-slide(
  [MOSFET],
  "/images/schematics/mosfet.svg",
  symbol-width: 65%,
  ([Does], [A switch controlled by voltage]),
  ([Key spec], [Gate threshold voltage]),
  ([Used for], [Switching LEDs, motors and other loads from a GPIO pin]),
)

// --- Ohm's law -------------------------------------------------------------

#slide(title: [Ohm's law], kicker: [Electronics basics], center: true)[
  #cols(ratio: (1.25fr, 1fr), align: horizon)[
    #block(below: 18pt, text(font: brand-font, size: 96pt, top-edge: "cap-height", bottom-edge: "baseline")[V = I × R])
    #spec-list(
      ([V], [Voltage (volts): electrical "pressure"]),
      ([I], [Current (amps): how much flows]),
      ([R], [Resistance (ohms): how hard it is to flow]),
    )
  ][
    #align(center, image("/images/schematics/ohms-law.svg", height: 7cm))
  ]
]

// --- Voltage divider -------------------------------------------------------
// Derivation over two slides, then the result with an example.

#let Vin = var[V][in]
#let Vout = var[V][out]
#let R1 = var[R][1]
#let R2 = var[R][2]

#let eq(space: (0.5em, 0.7em), body) = block(above: space.at(0), below: space.at(1), text(size: 30pt, body))

#let divider-slide(drawing, body) = slide(title: [Voltage divider], kicker: [Electronics basics])[
  // Top-aligned so the drawing stays put while clicking through the steps.
  #cols(ratio: (1fr, 1.9fr), align: top)[
    #align(center, image(drawing, height: 9cm))
  ][
    #body
  ]
]

#divider-slide("/images/schematics/divider-current.svg")[
  === Step 1: Same current through both resistors
  #R1 and #R2 are in series, so their resistances add:
  #eq(space: (1.5em, 1.6em))[#var[R][total] = #R1 + #R2]
  Ohm's law on the whole string:
  #eq(space: (1.5em, 1.6em))[I = #frac(Vin, [#R1 + #R2])]
]

#divider-slide("/images/schematics/divider-r2.svg")[
  === Step 2: Voltage across #R2
  #Vout is the voltage across #R2. Ohm's law again:
  #eq(space: (1.5em, 1.6em))[#Vout = I × #R2]
  Plug in I from step 1:
  #eq(space: (1.5em, 1.6em))[#Vout = #frac(Vin, [#R1 + #R2]) × #R2]
  #eq(space: (1.5em, 1.6em))[#text(fill: palette.accent)[#Vout = #Vin × #frac(R2, [#R1 + #R2])]]
]

#divider-slide("/images/schematics/divider.svg")[
  #block(height: 9cm, align(horizon)[
    #text(size: 44pt)[#Vout = #Vin × #frac(R2, [#R1 + #R2])]
    #v(0.8em)
    #callout(kind: "tip", title: [Example: 12 V down to 3 V])[
      #R1 = 30 kΩ, #R2 = 10 kΩ \
      #Vout = 12 V × 10 ÷ (30 + 10) = *3 V*
    ]
  ])
]
