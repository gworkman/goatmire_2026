#import "../template/theme.typ": *

#page(grid(
  columns: (1fr, 1.5fr),
  rows: (1fr,),
  column-gutter: 1.4cm,
  align: horizon,
  image("/images/badge.svg", width: 100%, height: 100%, fit: "contain"),
  {
    block(below: 0.5em, text(size: 12pt, weight: "semibold", tracking: 0.18em, fill: palette.accent)[HARDWARE])
    heading(level: 2)[Meet the badge]
    spec-list(
      ([MCU], [ESP32-S3]),
      ([CPU], [Dual-core Xtensa LX7, 240 MHz]),
      ([Memory], [4 MB flash, 2 MB PSRAM]),
      ([Wireless], [Wi-Fi 802.11 b/g/n, Bluetooth LE 5]),
      ([Display], [2.8" LCD]),
      ([Keyboard], [56 keys, 69 characters]),
      ([Sensors], [3-axis accelerometer, temperature]),
      ([Size], [100 × 120 mm]),
    )
  },
))
