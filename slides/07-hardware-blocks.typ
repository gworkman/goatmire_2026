#import "../template/theme.typ": *

#section-slide(number: 2, [Badge hardware], subtitle: [A tour of the schematic])

// Schematic sheet on the left, list of the circuit blocks it contains on the right.
// The row is as tall as the image and centred on the page; the text is
// top-aligned within it so it starts level with the top of the image.
#let schematic-slide(title, sheet, ..blocks) = page({
  v(1fr)
  grid(
    columns: (16cm, 1fr),
    column-gutter: 1cm,
    align: (left + top, left + top),
    block(
      fill: white,
      stroke: 0.5pt + palette.line,
      radius: 4pt,
      clip: true,
      image("/images/badge-schematic/" + sheet + ".png", width: 100%),
    ),
    {
      block(below: 0.5em, text(size: 12pt, weight: "semibold", tracking: 0.18em, fill: palette.accent)[BADGE HARDWARE])
      heading(level: 2, title)
      set text(size: 16pt)
      list(..blocks)
    },
  )
  v(1fr)
})

#schematic-slide(
  [Overview],
  "1-overview",
  [Top-level sheet linking power, USB, display, sensors, ESP32 and keyboard],
)

#schematic-slide(
  [Power],
  "2-power",
  [Battery connector with ESD and reverse polarity protection],
  [Power switch and battery / USB power path],
  [5 V boost converter],
  [Li-ion battery charger with charge and standby LEDs],
  [3.3 V buck converter],
)

#schematic-slide(
  [ESP32-S3],
  "3-esp32",
  [ESP32-S3-MINI-1 module],
  [Reset and boot buttons],
  [Battery voltage sense divider],
  [USB voltage sense divider],
)

#schematic-slide(
  [Keyboard],
  "4-keyboard",
  [6 × 13 keyboard matrix],
  [4 RGB LEDs (SK6812, NeoPixel-compatible), chained],
)

#schematic-slide(
  [Display],
  "5-display",
  [18-pin display connector (SPI)],
  [Backlight switch (P-channel MOSFET, PWM)],
  [Backlight LED resistors],
  [Resistive touch controller (not populated)],
)

#schematic-slide(
  [USB],
  "6-usb",
  [USB-C connector],
  [ESD protection diodes],
)

#schematic-slide(
  [Sensors],
  "7-sensors",
  [IR LED transmitter],
  [IR phototransistor receiver],
  [Temperature sensor (I²C)],
  [3-axis accelerometer (I²C)],
  [Qwiic I²C connector with pull-ups],
)
