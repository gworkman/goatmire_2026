#import "../template/theme.typ": *

#let repo = "github.com/protolux-electronics/avm_badge"

// GitHub mark followed by org/repo.
#let gh(name, size: 15pt) = text(size: size, weight: "medium")[
  #box(baseline: 15%, image("/images/github.svg", height: 1em)) #name
]

// --- What it is --------------------------------------------------------------

#title-slide(
  title: [Meet the\ badge],
  subtitle: [A hackable name badge running Elixir on AtomVM],
  presenter: [Gus Workman],
  organization: [Protolux Electronics],
  visual: "/images/badge.svg",
)

#page(grid(
  columns: (1fr, 1.5fr),
  rows: (1fr,),
  column-gutter: 1.4cm,
  align: horizon,
  image("/images/badge.svg", width: 100%, height: 100%, fit: "contain"),
  {
    block(below: 0.5em, text(size: 12pt, weight: "semibold", tracking: 0.18em, fill: palette.accent)[WHAT IT IS])
    heading(level: 2)[Quick specs]
    spec-list(
      ([MCU], [ESP32-S3, dual-core 240 MHz]),
      ([Memory], [4 MB flash, 2 MB PSRAM]),
      ([Wireless], [Wi-Fi, Bluetooth LE]),
      ([Display], [2.8" LCD, 320 × 240]),
      ([Keyboard], [69 keys]),
      ([Extras], [4 NeoPixels, IR, accelerometer, temperature sensor]),
    )
  },
))

// --- Get started -----------------------------------------------------------

#slide(title: [Get started], kicker: [Flash your badge], center: true)[
  #gh(size: 26pt)[protolux-electronics/avm_badge]
  #v(0.2em)
  // Captions share the grid's second row so they line up.
  #grid(
    columns: (auto, 1fr),
    column-gutter: 0.7cm,
    row-gutter: 10pt,
    align: (center + horizon, left + horizon),
    image("/images/qr-avm-badge.svg", width: 5.3cm),
    shell(
      size: 13.5pt,
      "git clone https://" + repo,
      "cd avm_badge",
      "mix deps.get",
      none,
      "mix atomvm.esp32.flash",
    ),
    text(size: 14pt, fill: palette.muted)[Scan for the repo],
    text(size: 14pt, fill: palette.muted)[No esptool to install: the first flash downloads it],
  )
]

// --- Full re-flash -----------------------------------------------------------

#slide(title: [Start from scratch], kicker: [Re-flash everything], center: true)[
  #shell(
    ("mix atomvm.esp32.erase_flash", "wipe the whole chip"),
    ("mix badge.base", "bootloader, VM, boot.avm"),
    ("mix badge.assets --flash", "fonts, icons, splash logo"),
    ("mix atomvm.esp32.flash", "the firmware"),
  )
  #v(0.4em)
  #text(size: 15pt, fill: palette.muted)[Erasing also clears your saved profile, collected badges and Wi-Fi settings.]
]

// --- Simulator -----------------------------------------------------------------

#slide(title: [No badge? Simulate it], kicker: [Simulator], center: true)[
  #shell(
    ("iex -S mix", "then open localhost:3240"),
    ("mix test", "runs on your laptop, no board needed"),
  )
  #v(0.4em)
  #text(size: 17pt)[The real firmware runs against fake hardware, with the screen drawn in your browser.]
]

// --- Demo and photo ----------------------------------------------------------

#statement-slide[Demo]

#statement-slide[Group photo]

// --- Share -----------------------------------------------------------------------

#let share-row(where, what, accent: palette.accent) = block(
  width: 100%,
  fill: palette.surface,
  stroke: (left: 5pt + accent),
  radius: (right: 6pt),
  inset: (x: 20pt, y: 14pt),
  grid(
    columns: (4.2cm, 1fr),
    align: horizon,
    text(size: 13pt, weight: "semibold", tracking: 0.15em, fill: palette.muted, upper(where)),
    text(size: 22pt, weight: "semibold", what),
  ),
)

#slide(title: [Share what you build], kicker: [Show and tell], center: true)[
  #share-row([Discord], [Post it in #text(fill: palette.accent)[\#badge]])
  #share-row([Bluesky], [Use #text(fill: palette.teal)[\#goatmire]], accent: palette.teal)
  #share-row([Tag me], text(fill: rgb("#1185FE"))[\@gworkman.bsky.social], accent: palette.yellow)
  #v(0.4em)
  #text(size: 18pt)[Made something cool? I'd love to see it.]
]

// --- Links ---------------------------------------------------------------------

#let qr-card(src, what, name, url) = block(
  width: 100%,
  height: 7cm,
  fill: palette.surface,
  radius: 8pt,
  inset: (x: 6pt, y: 12pt),
  align(center + top)[
    #text(size: 11pt, weight: "semibold", tracking: 0.15em, fill: palette.accent, upper(what))
    #v(-0.3em)
    #image(src, width: 3.2cm)
    #v(0.1em)
    #text(size: 15pt, weight: "semibold", name) \
    #text(size: 10pt, fill: palette.muted, url)
  ],
)

#slide(title: [Thanks], kicker: [Links], center: true)[
  #grid(
    columns: (auto, 1fr),
    column-gutter: 1cm,
    row-gutter: 12pt,
    // Top-aligned so both headings share a line and the QR code lines up with the cards.
    // The link row is centred, as its two links are different sizes.
    align: (_, y) => if y == 1 { horizon } else { top },
    {
      text(size: 12pt, weight: "semibold", tracking: 0.15em, fill: palette.accent)[INSTRUCTIONS]
      v(0.2em)
      image("/images/qr-avm-badge.svg", width: 7cm)
    },
    {
      text(size: 12pt, weight: "semibold", tracking: 0.15em, fill: palette.accent)[OTHER STUFF I DO]
      v(0.2em)
      grid(
        columns: (1fr, 1fr, 1fr, 1fr),
        gutter: 8pt,
        qr-card("/images/qr-protolux.svg", [Hire me], [Protolux Electronics], "protolux.io"),
        qr-card("/images/qr-nerves-meetup.svg", [Meetup], [Nerves Meetup], "nervesmeetup.eu"),
        qr-card("/images/qr-macro-mayhem.svg", [Podcast], [Macro Mayhem], "macromayhem.fm"),
        qr-card("/images/qr-nerves-starter-kit.svg", [NSK], [Nerves Starter Kit], "protolux.io/store"),
      )
    },
    // Links share a row so they sit on one line.
    gh(size: 12pt)[protolux-electronics/avm_badge],
    [#text(size: 14pt, fill: palette.muted)[These slides:] #h(0.3em) #gh[gworkman/goatmire_2026]],
  )
]
