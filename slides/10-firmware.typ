#import "../template/theme.typ": *

#section-slide(number: 4, [Inside the firmware], subtitle: [Writing your own page], fill: palette.yellow)

// Code walkthrough slides use a larger code size than the theme default.
#show raw.where(block: true): set text(size: 14pt)

// --- Architecture ----------------------------------------------------------

#let flow-arrow = text(font: mono-font, size: 22pt, fill: palette.muted)[→]
#let flow-node(name, caption, fill: palette.paper, fg: palette.ink) = box(
  width: 5.2cm,
  fill: fill,
  stroke: 1.5pt + palette.ink,
  inset: (x: 12pt, y: 12pt),
  radius: 6pt,
  align(center)[
    #text(size: 17pt, weight: "semibold", fill: fg, name) \
    #text(size: 13pt, fill: fg.transparentize(25%), caption)
  ],
)

#slide(title: [How it fits together], kicker: [Firmware], center: true)[
  #align(center, stack(
    dir: ltr,
    spacing: 10pt,
    flow-node([Keyboard], [scans the matrix]),
    align(horizon, flow-arrow),
    flow-node([Badge.UI], [holds page state], fill: palette.ink, fg: palette.paper),
    align(horizon, flow-arrow),
    flow-node([Your page], [handles keys, renders], fill: palette.accent, fg: palette.paper),
    align(horizon, flow-arrow),
    flow-node([Display], [draws the frame]),
  ))
  #v(1em)
  - The firmware is Elixir, running on AtomVM: a tiny Erlang VM for microcontrollers
  - A page is a *module, not a process*. `Badge.UI` keeps its state and calls its functions
]

// --- The Page behaviour ----------------------------------------------------

#slide(title: [A page is a behaviour], kicker: [Firmware])[
  #data-table(
    columns: (auto, 1fr, auto),
    [Callback], [What it does], [Default],
    [`title/0`], [Label under its icon on the home grid], [required],
    [`init/0`], [Fresh state, every time the page opens], [required],
    [`render/1`], [Turns state into a list of things to draw], [required],
    [`handle_key/2`], [Reacts to a key press], [ignore],
    [`tick/1`], [Reads the outside world, like sensors], [no change],
    [`refresh/1`], [Minimum time between frames, in ms], [100],
  )
  #v(0.3em)
  #text(size: 15pt, fill: palette.muted)[`use Badge.Page` fills in every default, so you only write what you need.]
]

// --- Key events --------------------------------------------------------------

#slide(title: [Key events], kicker: [Firmware])[
  #data-table(
    columns: (auto, 1fr),
    [Event], [Sent by],
    [`{:char, ?a}`], [Letters, numbers and symbols],
    [`{:edit, :backspace}`], [#key[⌫], #key[↵] and #key[Tab] (`:backspace`, `:newline`, `:tab`)],
    [`{:move, :up}`], [Arrow keys (`:up`, `:down`, `:left`, `:right`)],
    [`{:nav, :home}`], [#key[Esc]. Ignore it and the badge goes back home],
  )
  #v(0.3em)
  #text(size: 15pt, fill: palette.muted)[Return `{:ok, new_state}` to redraw with the new state, or `:ignore` to let the key go.]
]

// --- Counter page ------------------------------------------------------------

#slide(title: [A counter page], kicker: [Firmware])[
  #cols(ratio: (1.5fr, 1fr), align: top)[
    ```elixir
    defmodule Badge.Page.Counter do
      use Badge.Page
      alias Badge.Theme

      @impl true
      def title, do: "Counter"
      @impl true
      def init, do: %{count: 0}
      @impl true
      def render(%{count: count}) do
        n = :erlang.integer_to_binary(count)
        [{:text, 16, 40, :default16px,
          Theme.fg(), Theme.bg(), "Count: " <> n}]
      end
    end
    ```
  ][
    #set text(size: 16pt)
    - `use Badge.Page` supplies the defaults
    - The state is a plain map
    - `render/1` returns a list of display items: \ `{:text, x, y, font, fg, bg, text}`
    - AtomVM has no `String` module, so numbers become text with `:erlang.integer_to_binary/1`
  ]
]

#slide(title: [Handling keys], kicker: [Firmware])[
  #cols(ratio: (1.6fr, 1fr), align: top)[
    ```elixir
    @impl true
    def handle_key({:move, :up}, state),
      do: {:ok, %{state | count: state.count + 1}}

    def handle_key({:move, :down}, state),
      do: {:ok, %{state | count: state.count - 1}}

    def handle_key({:char, ?r}, _state),
      do: {:ok, init()}

    def handle_key(_event, _state), do: :ignore
    ```
  ][
    #set text(size: 16pt)
    - #key[↑] and #key[↓] change the count
    - #key[R] resets it
    - Everything else is ignored, including #key[Esc], which takes you home
    #v(0.4em)
    #callout(kind: "warning")[
      Keep the catch-all clause. A key with no matching clause crashes the UI and drops you back home.
    ]
  ]
]

// --- Home grid ---------------------------------------------------------------

// The six shape keys, drawn in their key colours.
#let shape(kind, size: 0.9cm) = {
  let s = size
  if kind == "square" { rect(width: s * 0.8, height: s * 0.8, fill: rgb("#E5484D"), radius: 2pt) }
  else if kind == "triangle" { polygon(fill: rgb("#FF8A1F"), (0pt, s * 0.85), (s / 2, 0pt), (s, s * 0.85)) }
  else if kind == "cross" {
    let st = (paint: rgb("#F2C12E"), thickness: s * 0.2, cap: "round")
    box(width: s, height: s, {
      place(line(start: (s * 0.15, s * 0.15), end: (s * 0.85, s * 0.85), stroke: st))
      place(line(start: (s * 0.85, s * 0.15), end: (s * 0.15, s * 0.85), stroke: st))
    })
  }
  else if kind == "circle" { circle(radius: s * 0.42, fill: rgb("#3FB36B")) }
  else if kind == "clover" {
    let r = s * 0.22
    box(width: s, height: s, {
      for (dx, dy) in ((0.5, 0.2), (0.8, 0.5), (0.5, 0.8), (0.2, 0.5)) {
        place(dx: s * dx - r, dy: s * dy - r, circle(radius: r, fill: rgb("#3B82F6")))
      }
    })
  }
  else if kind == "diamond" { polygon(fill: rgb("#9B6BE8"), (s / 2, 0pt), (s * 0.85, s / 2), (s / 2, s), (s * 0.15, s / 2)) }
}

#let grid-cell(kind, name, highlight: false) = block(
  width: 100%,
  height: 2.9cm,
  fill: if highlight { palette.accent.transparentize(85%) } else { palette.paper },
  stroke: if highlight { 2pt + palette.accent } else { 1pt + palette.line },
  radius: 6pt,
  align(center + horizon)[
    #box(height: 0.9cm, align(horizon, shape(kind)))
    #v(-0.2em)
    #text(size: 15pt, weight: if highlight { "semibold" } else { "regular" }, name)
  ],
)

#slide(title: [Add it to the home grid], kicker: [Firmware])[
  #cols(ratio: (1fr, 1fr), align: top)[
    ```elixir
    # lib/badge/pages.ex
    @pages [
      Badge.Page.Name,
      # ...
      Badge.Page.About,
      Badge.Page.Schedule,
      Badge.Page.Counter
    ]
    ```
    #v(0.2em)
    #set text(size: 16pt)
    - The grid shows six pages at a time, one per shape key
    - A page's place in the list picks its key
    - Counter is 12th: the second screen, on #box(baseline: 25%, shape("diamond", size: 0.5cm))
  ][
    #text(size: 13pt, weight: "semibold", tracking: 0.15em, fill: palette.muted)[HOME GRID, SCREEN 2]
    #v(-0.2em)
    #grid(
      columns: 3,
      gutter: 8pt,
      grid-cell("square", [Text]),
      grid-cell("triangle", [Agent]),
      grid-cell("cross", [Cluster]),
      grid-cell("circle", [About]),
      grid-cell("clover", [Schedule]),
      grid-cell("diamond", [Counter], highlight: true),
    )
  ]
]

// --- Try it ------------------------------------------------------------------

#slide(title: [Try it], kicker: [Firmware], center: true)[
  #shell(
    ("iex -S mix", "simulator: open localhost:3240"),
    ("mix atomvm.esp32.flash", "on the badge"),
  )
  #v(0.4em)
  #text(size: 16pt, fill: palette.muted)[The simulator runs the firmware against fake hardware in your browser, no badge needed.]
]
