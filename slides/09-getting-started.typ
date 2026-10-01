#import "../template/theme.typ": *

#section-slide(number: 3, [Getting started], subtitle: [From a fresh laptop to a running badge], fill: palette.teal)

// --- Assembly --------------------------------------------------------------

// Emoji come from the system emoji font, whose tall metrics would stretch the line.
#let cry = box(height: 0.75em, text(top-edge: 0.75em, bottom-edge: 0em)[😢])

#slide(title: [Assemble the badge], kicker: [Getting started], center: true)[
  + Drop the silicone keyboard into the case
  + Peel the backing off the keypad and stick it to the PCB, lining it up carefully
  + Peel the protective film off the screen
  + Thread the display cable through the PCB cutout into its connector
  + Snap the PCB and screen into the case
  + #strike[Stick the battery to its marked spot and plug it in] #cry
  + #strike[Screw the backplate onto the standoffs] #cry
]

// --- Tools -----------------------------------------------------------------

#slide(title: [What you need], kicker: [Getting started], center: true)[
  - *Elixir and Erlang*, which you already have
  - *curl*, already on macOS and most Linux distributions
  - *No esptool.* The flash tasks run it through Pythonx, which downloads Python and esptool the first time you flash
  #v(0.4em)
  #callout(kind: "note", title: [Linux])[
    Add yourself to the `dialout` group so you can open the badge's serial port.
  ]
]

// --- Code ------------------------------------------------------------------

#slide(title: [Get the code], kicker: [Getting started], center: true)[
  #shell(
    "git clone https://github.com/protolux-electronics/avm_badge",
    "cd avm_badge",
    "mix deps.get",
  )
  #v(0.4em)
  #text(size: 16pt, fill: palette.muted)[#link("https://github.com/protolux-electronics/avm_badge")[github.com/protolux-electronics/avm_badge]]
]

// --- Flash -----------------------------------------------------------------

#slide(title: [Flash the badge], kicker: [Getting started], center: true)[
  Plug the badge in over USB, then from `avm_badge`:

  #v(0.3em)
  #shell(
    ("mix badge.base", "once: bootloader, VM, boot.avm"),
    ("mix badge.assets --flash", "once: fonts, icons, splash logo"),
    ("mix atomvm.esp32.flash", "the firmware, every time"),
  )
  #v(0.4em)
  #text(size: 15pt, fill: palette.muted)[The first flash downloads Python and esptool, so it needs a network connection.]
]

#slide(title: [Did it work?], kicker: [Getting started], center: true)[
  + The badge resets on its own after flashing
  + The splash logo appears, then the home grid
  + The shape keys open the pages; the arrow keys page through the grid
]
