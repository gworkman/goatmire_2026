#import "../template/theme.typ": *

#section-slide(number: 5, [More information], subtitle: [Where to find everything from today])

// One repository: what it holds and where it lives.
// One repository: what it holds on the left, where it lives on the right.
#let repo-card(title, url, accent: palette.accent, body) = card(accent: accent)[
  #grid(
    columns: (1fr, auto),
    align: (left + horizon, right + horizon),
    column-gutter: 1cm,
    [#text(size: 19pt, weight: "semibold", title) \ #body],
    text(size: 19pt, weight: "semibold")[#link("https://" + url)[#url]],
  )
]

#slide(title: [Links], kicker: [More information], center: true)[
  #repo-card([Badge firmware], "github.com/protolux-electronics/avm_badge")[
    Elixir firmware, flashing tools and the simulator
  ]
  #v(0.6em)
  #repo-card([These slides], "github.com/gworkman/goatmire_2026", accent: palette.teal)[
    Typst source for this presentation
  ]
]
