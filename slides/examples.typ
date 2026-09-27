// Example slides showing every layout and component in the theme.
// Content is placeholder: replace or delete once the real deck takes shape.

#import "../template/theme.typ": *

// --- Title -----------------------------------------------------------------

#title-slide(
  title: [Hack the\ Badge],
  subtitle: [A hands-on workshop with the Goatmire 2026 name badge],
  presenter: [Protolux],
  date: [Goatmire 2026],
  visual: "/images/badge.svg",
)

// --- Agenda ----------------------------------------------------------------

#agenda-slide(
  ([Meet the badge], [Hardware tour: ESP32-S3, LCD, sensors, keyboard]),
  ([Toolchain setup], [Getting code onto the device]),
  ([Hello, badge], [First program on the LCD]),
  ([Reading the keyboard], [69 keys, scan codes and shortcuts]),
  ([Sensors], [Reading onboard sensor data]),
  ([Build something], [Free hacking time and show & tell]),
)

// --- Section ---------------------------------------------------------------

#section-slide(number: 1, [Meet the badge], subtitle: [What's on the board and how it fits together])

// --- Bullets ---------------------------------------------------------------

#slide(title: [Bullet points], kicker: [Lists])[
  - Top-level bullets use a small accent square
  - Keep each point short enough to read at a glance
    - Nested points get a quieter dash
    - Two levels is usually plenty
  - *Bold* for emphasis, `inline code` for identifiers
  - Links look like #link("https://typst.app")[this]
]

#slide(title: [Numbered lists], kicker: [Lists])[
  #cols[
    + Plug the badge in over USB-C
    + Hold #key[BOOT] and tap #key[RESET]
    + Flash the firmware
    + Watch the LCD come alive
  ][
    #callout(kind: "tip")[
      Numbered lists use the brand font for the numbers, so they read well from the back of the room.
    ]
  ]
]

// --- Columns and cards -----------------------------------------------------

#slide(title: [Two columns], kicker: [Layout])[
  #cols(ratio: (1.2fr, 1fr))[
    === Text on the left
    Use `cols` for side-by-side content. Pass `ratio` to change the widths.

    - Any content fits in a column
    - Including lists, code and images
  ][
    #block(height: 8cm, image("/images/badge.svg", width: 100%))
  ]
]

#slide(title: [Cards], kicker: [Layout])[
  #cols(
    card(title: [ESP32-S3])[Dual-core Xtensa LX7 up to 240 MHz, with Wi-Fi and Bluetooth LE.],
    card(title: [LCD], accent: palette.teal)[Colour display for text, graphics and your name.],
    card(title: [Keyboard], accent: palette.yellow)[69 keys. Enough for a tiny terminal.],
    card(title: [Sensors], accent: palette.ink)[Onboard sensors you can read from your own code.],
    gutter: 14pt,
  )
]

// --- Callouts --------------------------------------------------------------

#slide(title: [Callouts], kicker: [Components])[
  #cols(gutter: 14pt)[
    #callout(kind: "note")[Neutral extra information that supports the slide.]
  ][
    #callout(kind: "tip")[A shortcut or trick worth knowing.]
  ][
    #callout(kind: "warning")[Something that will bite you if you skip it.]
  ]
  #v(0.6em)
  #callout(kind: "note", title: [Custom title])[
    Callouts take an optional `title`, and they work at any width.
  ]
]

// --- Stats -----------------------------------------------------------------

#slide(title: [By the numbers], kicker: [Big numbers], center: true)[
  #cols(
    stat[69][keys on the keyboard],
    stat(color: palette.teal)[240][MHz max clock],
    stat(color: palette.ink)[2][CPU cores],
    stat(color: palette.yellow.darken(15%))[1][badge per attendee],
  )
]

// --- Statement -------------------------------------------------------------

#statement-slide[Your name badge\ is a #text(fill: palette.accent)[computer]]

// --- Image layouts ---------------------------------------------------------

#image-slide(
  title: [Image with caption],
  kicker: [Images],
  "/images/badge.svg",
  caption: [The image scales to fill the space under the title.],
)

#bleed-slide(
  "/images/placeholder-photo.svg",
  title: [Full-bleed image],
  subtitle: [Background photo with a title on top],
)

#split-slide("/images/placeholder-photo.svg", title: [Split layout], kicker: [Images])[
  Half the slide is an edge-to-edge image; the other half is regular content.

  - Pass `side: left` to flip it
  - The page number gets a chip so it stays readable
]

#split-slide("/images/placeholder-photo.svg", side: left, title: [Flipped split], kicker: [Images])[
  Same layout with the image on the left.
]

#slide(title: [Image grid], kicker: [Images])[
  #cols(gutter: 14pt)[
    #captioned("/images/placeholder-photo.svg", [Soldering station], height: 5.2cm)
  ][
    #captioned(placeholder(label: [Photo TBD]), [Placeholder for a missing image], height: 5.2cm)
  ][
    #captioned("/images/badge.svg", [The badge], height: 5.2cm)
  ]
]

// --- Code ------------------------------------------------------------------

#section-slide(number: 2, [Writing code], subtitle: [Code blocks, keycaps and diagrams], fill: palette.teal)

#slide(title: [Code blocks], kicker: [Code])[
  #cols(ratio: (1.5fr, 1fr))[
    ```elixir
    defmodule Badge.Hello do
      def run(display) do
        display
        |> Display.clear(:black)
        |> Display.text("Hello, Goatmire!")
        |> Display.flush()
      end
    end
    ```
  ][
    Code blocks get syntax highlighting and an accent rule.

    #callout(kind: "note")[
      Example code only. Swap in the real badge API.
    ]
  ]
]

#slide(title: [Two languages side by side], kicker: [Code])[
  #cols[
    === C
    ```c
    void app_main(void) {
        lcd_init();
        lcd_print(10, 20, "Hello!");
    }
    ```
  ][
    === Python
    ```python
    import badge

    badge.lcd.clear()
    badge.lcd.text("Hello!", 10, 20)
    ```
  ]
]

// --- Keycaps ---------------------------------------------------------------

#slide(title: [Keyboard shortcuts], kicker: [Keycaps])[
  #data-table(
    columns: (auto, 1fr),
    [Keys], [Action],
    [#key[Fn] + #key[Esc]], [Back to the launcher],
    [#key[Fn] + #key[↑] / #key[↓]], [Adjust LCD brightness],
    [#key[Ctrl] + #key[C]], [Stop the running program],
    [#key[BOOT] + #key[RESET]], [Enter download mode],
  )
  #v(0.4em)
  #text(size: 13pt, fill: palette.muted)[Example bindings only.]
]

// --- Table -----------------------------------------------------------------

#slide(title: [Spec table], kicker: [Tables])[
  #data-table(
    columns: (auto, 1fr, auto),
    [Part], [Details], [Status],
    [MCU], [ESP32-S3, dual-core Xtensa LX7 up to 240 MHz], tag(color: palette.teal)[Confirmed],
    [Radio], [Wi-Fi 802.11 b/g/n, Bluetooth LE 5], tag(color: palette.teal)[Confirmed],
    [Display], [LCD], tag(color: palette.muted)[Size TBD],
    [Input], [69-key keyboard], tag(color: palette.teal)[Confirmed],
    [Sensors], [Onboard sensors], tag(color: palette.muted)[TBD],
  )
]

// --- Diagram ---------------------------------------------------------------

#slide(title: [Block diagram], kicker: [Diagrams], center: true)[
  #let arrow(s) = text(font: mono-font, size: 24pt, fill: palette.muted, s)
  #align(center, grid(
    columns: 5,
    column-gutter: 10pt,
    row-gutter: 10pt,
    align: center + horizon,
    [], [], node[LCD], [], [],
    [], [], arrow[↕], [], [],
    node[Onboard sensors], arrow[↔], node(fill: palette.accent, fg: palette.paper, width: 5cm)[ESP32-S3], arrow[↔], node[USB-C / power],
    [], [], arrow[↕], [], [],
    [], [], node[69-key keyboard], [], [],
  ))
]

// --- Steps -----------------------------------------------------------------

#slide(title: [Process steps], kicker: [Sequences], center: true)[
  #steps(
    ([Install], [Set up the toolchain on your laptop]),
    ([Connect], [Plug the badge in over USB-C]),
    ([Flash], [Build and upload your first program]),
    ([Hack], [Change it, break it, fix it]),
  )
]

// --- Comparison ------------------------------------------------------------

#slide(title: [Do and don't], kicker: [Comparison])[
  #cols[
    #card(title: [#text(fill: palette.teal)[✓] Do], accent: palette.teal)[
      - Unplug before bending the board
      - Save your work often
      - Ask for help early
    ]
  ][
    #card(title: [#text(fill: palette.red)[✗] Don't], accent: palette.red)[
      - Short the battery terminals
      - Flash someone else's badge without asking
      - Lick the LCD
    ]
  ]
]

// --- Quote -----------------------------------------------------------------

#quote-slide(attribution: [Not Arthur C. Clarke])[
  Any sufficiently advanced name badge is indistinguishable from a laptop.
]

// --- Exercise --------------------------------------------------------------

#section-slide(number: 3, [Hands-on], subtitle: [Exercises for the workshop], fill: palette.yellow)

#exercise-slide(
  number: 1,
  title: [Hello, badge],
  minutes: 15,
  hint: [If the badge doesn't show up as a serial port, hold #key[BOOT] while plugging it in.],
  [Flash the example firmware],
  [Change the greeting to your own name],
  [Make the text change colour when you press #key[Space]],
  [Bonus: show the reading from one onboard sensor],
)

// --- Misc text -------------------------------------------------------------

#slide(title: [Tags and inline elements], kicker: [Components])[
  #tag[Beginner] #tag(color: palette.teal)[Hardware] #tag(color: palette.accent)[New]

  Inline elements mix with text: press #key[Fn] + #key[F1], call `badge.lcd.text()`, or read the #link("https://docs.espressif.com/projects/esp-idf/en/latest/esp32s3/")[ESP32-S3 docs].

  #v(0.5em)
  #text(size: 28pt, weight: "light")[Light weight for a lede or intro paragraph.]

  #text(size: 14pt, fill: palette.muted)[Small muted text for footnotes and sources.]
]

// --- End -------------------------------------------------------------------

#end-slide[
  Questions? \
  #text(fill: palette.accent)[protolux.io]
]
