// Goatmire 2026 presentation theme.
//
// Usage (from main.typ):
//   #import "template/theme.typ": *
//   #show: deck.with(title: "...", author: "...")
//
// Every *-slide function emits exactly one page. Everything else in this file
// is a component meant to be used inside a slide.
//
// Image paths: pass root-absolute strings like "/images/badge.svg". Relative
// paths would resolve against this file, not the caller.

// ---------------------------------------------------------------------------
// Tokens
// ---------------------------------------------------------------------------

#let palette = (
  ink: rgb("#15141A"),
  paper: rgb("#F6F2EA"),
  surface: rgb("#ECE5D8"),
  line: rgb("#D9D0BF"),
  muted: rgb("#6E6A62"),
  accent: rgb("#FF5B1F"),
  teal: rgb("#1F8A84"),
  yellow: rgb("#F2B632"),
  red: rgb("#D93A2B"),
)

#let brand-font = "New Amsterdam"
#let body-font = "Poppins"
#let mono-font = "DejaVu Sans Mono" // bundled with Typst, always available

#let event-name = "Goatmire 2026"

// ---------------------------------------------------------------------------
// Internals
// ---------------------------------------------------------------------------

#let _pad2(n) = if n < 10 { "0" + str(n) } else { str(n) }

#let _brand(body, size: 1em, ..args) = text(
  font: brand-font,
  weight: "regular",
  size: size,
  tracking: 0.02em,
  ..args,
  body,
)

// Footer: event mark on the left, "NN / TT" on the right.
// `pill` puts the page number on a paper-coloured chip, for slides where the
// footer sits on top of an image.
#let _footer(fg: palette.muted, mark: palette.accent, pill: false, brand: true) = context {
  let n = counter(page).get().first()
  let total = counter(page).final().first()
  let number = _brand(size: 15pt)[
    #_pad2(n)#h(0.25em)#text(fill: fg.transparentize(45%))[/#h(0.25em)#_pad2(total)]
  ]
  set text(fill: fg)
  grid(
    columns: (1fr, auto),
    align: (left + horizon, right + horizon),
    if brand { _brand(size: 15pt, tracking: 0.06em)[GOATMIRE #text(fill: mark)[2026]] },
    if pill {
      box(fill: palette.paper, inset: (x: 8pt, y: 4pt), radius: 99pt, text(fill: palette.ink, number))
    } else { number },
  )
}

// Thin accent bar across the top of regular slides.
#let _topbar(color: palette.accent) = place(top + left, rect(width: 100%, height: 5pt, fill: color))

#let _margin-x = 1.8cm

// Resolve an image argument: strings become images, content passes through.
#let _img(src, ..args) = if type(src) == str { image(src, ..args) } else { src }

// ---------------------------------------------------------------------------
// Document setup
// ---------------------------------------------------------------------------

#let deck(title: "", author: "", body) = {
  set document(title: title, author: author)
  set page(
    paper: "presentation-16-9",
    fill: palette.paper,
    margin: (x: _margin-x, top: 1.3cm, bottom: 1.6cm),
    footer: _footer(),
    footer-descent: 40%,
    background: _topbar(),
  )
  set text(font: body-font, size: 18pt, fill: palette.ink, lang: "en")
  set par(leading: 0.62em, spacing: 0.9em)

  set list(
    marker: (
      text(fill: palette.accent, size: 0.6em, baseline: -0.2em)[■],
      text(fill: palette.muted)[–],
    ),
    indent: 0.1em,
    body-indent: 0.6em,
    spacing: 0.75em,
  )
  set enum(
    numbering: n => _brand(size: 1.2em, fill: palette.accent)[#_pad2(n)],
    body-indent: 0.7em,
    spacing: 0.75em,
  )

  set table(stroke: none, inset: (x: 12pt, y: 9pt))

  show heading: set text(font: brand-font, weight: "regular")
  show heading.where(level: 1): set text(size: 88pt)
  show heading.where(level: 1): set par(leading: 0.1em)
  show heading.where(level: 2): it => block(below: 0.7em, text(size: 46pt, tracking: 0.01em, it.body))
  show heading.where(level: 3): set text(font: body-font, weight: "semibold", size: 19pt)
  show heading.where(level: 3): set block(above: 0.8em, below: 0.5em)

  show strong: set text(weight: "semibold")
  show link: it => underline(stroke: 1.5pt + palette.accent, offset: 3pt, it)

  show raw: set text(font: mono-font)
  // Typst shrinks raw text to 0.8em by default; bring inline code back up to
  // roughly match the surrounding body text.
  show raw.where(block: false): set text(size: 1.2em)
  show raw.where(block: false): it => box(
    fill: palette.surface,
    inset: (x: 4pt),
    outset: (y: 3pt),
    radius: 3pt,
    it,
  )
  show raw.where(block: true): it => block(
    fill: palette.surface,
    stroke: (left: 4pt + palette.accent),
    inset: (x: 16pt, y: 14pt),
    radius: (right: 6pt),
    width: 100%,
    text(size: 13pt, it),
  )

  body
}

// ---------------------------------------------------------------------------
// Slide layouts (each emits one page)
// ---------------------------------------------------------------------------

// Standard content slide. `kicker` is a small label above the title.
// `center: true` vertically centres the body in the remaining space.
#let slide(title: none, kicker: none, center: false, body) = page({
  if kicker != none {
    block(below: 0.5em, text(size: 12pt, weight: "semibold", tracking: 0.18em, fill: palette.accent, upper(kicker)))
  }
  if title != none { heading(level: 2, title) }
  if center { v(1fr) }
  body
  if center { v(1fr) }
})

// Opening slide on a dark background, with an optional visual on the right.
#let title-slide(
  title: [],
  subtitle: none,
  presenter: none,
  organization: none,
  date: none,
  location: none,
  visual: none,
) = page(fill: palette.ink, footer: none, background: none, {
  set text(fill: palette.paper)
  let left = {
    _brand(size: 26pt, fill: palette.accent, tracking: 0.12em)[#upper(event-name)]
    v(0.2em)
    block(below: 0.6em, par(leading: 0.18em, _brand(size: 104pt, title)))
    if subtitle != none {
      block(text(size: 22pt, weight: "light", subtitle))
    }
    v(1em)
    if presenter != none {
      block(below: 0.35em, text(size: 22pt, weight: "semibold", presenter))
    }
    if organization != none {
      block(below: 0.35em, text(size: 18pt, fill: palette.paper.transparentize(25%), organization))
    }
    let when-where = (date, location).filter(x => x != none)
    if when-where.len() > 0 {
      v(0.6em)
      set text(size: 14pt, fill: palette.paper.transparentize(45%))
      when-where.join[#h(0.6em)#text(fill: palette.accent)[·]#h(0.6em)]
    }
  }
  grid(
    columns: if visual != none { (1.4fr, 1fr) } else { (1fr,) },
    rows: (1fr,),
    column-gutter: 1.2cm,
    align: horizon,
    left,
    ..if visual != none { (align(center + horizon, _img(visual, height: 88%, fit: "contain")),) },
  )
})

// Big coloured section divider. Adds a level-1 heading (PDF bookmark).
#let section-slide(number: none, title, subtitle: none, fill: palette.accent) = page(
  fill: fill,
  background: none,
  footer: _footer(fg: palette.ink, mark: palette.paper),
  {
    set text(fill: palette.ink)
    grid(
      columns: if number != none { (auto, 1fr) } else { (1fr,) },
      rows: (1fr,),
      column-gutter: 1cm,
      align: horizon,
      ..if number != none {
        (_brand(size: 240pt, fill: palette.paper)[#_pad2(number)],)
      },
      {
        heading(level: 1, title)
        if subtitle != none {
          v(0.4em)
          text(size: 22pt, weight: "medium", subtitle)
        }
      },
    )
  },
)

// Agenda: items are (title, detail) pairs or plain content.
#let agenda-slide(title: [Agenda], columns: 2, ..items) = slide(title: title, {
  let cells = items.pos().enumerate().map(((i, item)) => {
    let (head, detail) = if type(item) == array { item } else { (item, none) }
    grid(
      columns: (auto, 1fr),
      column-gutter: 14pt,
      align: (left + top, left + horizon),
      _brand(size: 44pt, fill: palette.accent)[#_pad2(i + 1)],
      {
        text(size: 19pt, weight: "semibold", head)
        if detail != none { linebreak(); text(size: 14pt, fill: palette.muted, detail) }
      },
    )
  })
  v(0.3em)
  grid(columns: (1fr,) * columns, column-gutter: 1.2cm, row-gutter: 18pt, ..cells)
})

// One big statement, centred.
#let statement-slide(body, fill: palette.paper, fg: palette.ink) = page(fill: fill, {
  set text(fill: fg)
  v(1fr)
  align(center, par(leading: 0.1em, _brand(size: 84pt, body)))
  v(1fr)
})

// Quote with attribution.
#let quote-slide(body, attribution: none) = page(fill: palette.ink, background: none, footer: _footer(fg: palette.paper.transparentize(40%)), {
  set text(fill: palette.paper)
  v(1fr)
  block(width: 85%, {
    block(height: 40pt, place(top + left, dy: -12pt, _brand(size: 160pt, fill: palette.accent)[“]))
    par(leading: 0.55em, text(size: 34pt, weight: "light", body))
    if attribution != none {
      v(0.6em)
      text(size: 16pt, weight: "semibold", fill: palette.accent, upper[— #attribution])
    }
  })
  v(1fr)
})

// Title + one image fitted in the remaining space, with optional caption.
#let image-slide(title: none, kicker: none, src, caption: none) = slide(title: title, kicker: kicker, {
  block(height: 1fr, width: 100%, align(center + horizon, _img(src, height: 100%, fit: "contain")))
  if caption != none {
    align(center, text(size: 13pt, fill: palette.muted, caption))
  }
})

// Image fills the whole page, untouched: no title, overlay or top bar. For
// images that are already a finished 16:9 slide. Only the page number shows.
// `fit: "contain"` shows the whole image on `fill` instead of cropping it.
#let image-page(src, fit: "cover", fill: palette.paper) = page(
  fill: fill,
  background: _img(src, width: 100%, height: 100%, fit: fit),
  footer: _footer(pill: true, brand: false),
  [],
)

// Grid of images filling the slide. `none` leaves a cell empty but keeps its
// space, so consecutive slides can reveal images one at a time.
#let image-grid-slide(title: none, kicker: none, columns: 2, gutter: 16pt, ..items) = slide(
  title: title,
  kicker: kicker,
  grid(
    columns: (1fr,) * columns,
    rows: (1fr,),
    column-gutter: gutter,
    align: center + horizon,
    ..items.pos().map(src => if src == none { [] } else {
      _img(src, width: 100%, height: 100%, fit: "contain")
    }),
  ),
)

// Full-bleed background image with a title in the lower-left corner.
#let bleed-slide(src, title: none, subtitle: none) = page(
  background: {
    _img(src, width: 100%, height: 100%, fit: "cover")
    place(top + left, rect(
      width: 100%,
      height: 100%,
      fill: gradient.linear(angle: 90deg, palette.ink.transparentize(100%), palette.ink.transparentize(20%)),
    ))
  },
  footer: _footer(fg: palette.paper),
  {
    set text(fill: palette.paper)
    v(1fr)
    if title != none { par(leading: 0.1em, _brand(size: 72pt, title)) }
    if subtitle != none { v(0.2em); text(size: 20pt, subtitle) }
  },
)

// Half image (edge to edge), half content. `side` is left or right.
#let split-slide(src, side: right, title: none, kicker: none, body) = page(
  background: place(side, box(width: 46%, height: 100%, clip: true, _img(src, width: 100%, height: 100%, fit: "cover"))),
  footer: _footer(pill: side == right),
  {
    let content = block(width: 100%, {
      if kicker != none {
        block(below: 0.5em, text(size: 12pt, weight: "semibold", tracking: 0.18em, fill: palette.accent, upper(kicker)))
      }
      if title != none { heading(level: 2, title) }
      body
    })
    grid(
      columns: if side == right { (50%, 1fr) } else { (1fr, 48%) },
      rows: (1fr,),
      align: horizon,
      ..if side == right { (content, []) } else { ([], content) },
    )
  },
)

// Hands-on exercise: number, title, time box, tasks and an optional hint.
#let exercise-slide(number: 1, title: [], minutes: none, hint: none, ..tasks) = slide(
  kicker: [Hands-on #_pad2(number)],
  {
    grid(
      columns: (1fr, auto),
      align: (left + bottom, right + top),
      heading(level: 2, title),
      if minutes != none {
        box(fill: palette.ink, inset: (x: 16pt, y: 10pt), radius: 6pt, {
          set text(fill: palette.paper)
          _brand(size: 40pt, fill: palette.accent)[#minutes]
          h(4pt)
          _brand(size: 20pt)[MIN]
        })
      },
    )
    grid(
      columns: if hint != none { (1.4fr, 1fr) } else { (1fr,) },
      column-gutter: 1cm,
      {
        for t in tasks.pos() {
          block(below: 14pt, grid(
            columns: (auto, 1fr),
            column-gutter: 12pt,
            box(width: 18pt, height: 18pt, stroke: 2pt + palette.ink, radius: 3pt, baseline: 3pt),
            t,
          ))
        }
      },
      ..if hint != none {
        (block(fill: palette.surface, inset: 18pt, radius: 8pt, width: 100%, {
          text(size: 12pt, weight: "semibold", tracking: 0.15em, fill: palette.teal)[HINT]
          v(0.3em)
          set text(size: 15pt)
          hint
        }),)
      },
    )
  },
)

// Closing slide.
#let end-slide(title: [Thanks!], body) = page(fill: palette.ink, background: none, footer: _footer(fg: palette.paper.transparentize(40%)), {
  set text(fill: palette.paper)
  v(1fr)
  _brand(size: 140pt)[#title]
  v(0.2em)
  set text(size: 18pt)
  body
  v(1fr)
})

// ---------------------------------------------------------------------------
// Components (use inside slides)
// ---------------------------------------------------------------------------

// Columns. `cols(ratio: (2fr, 1fr))[a][b]`.
#let cols(ratio: auto, gutter: 1cm, align: top, ..cells) = {
  let n = cells.pos().len()
  grid(
    columns: if ratio == auto { (1fr,) * n } else { ratio },
    column-gutter: gutter,
    align: align,
    ..cells,
  )
}

// Surface card with an optional title and accent top border.
#let card(title: none, accent: palette.accent, fill: palette.surface, body) = block(
  width: 100%,
  height: auto,
  fill: fill,
  stroke: (top: 4pt + accent),
  inset: 16pt,
  radius: (bottom: 6pt),
  {
    if title != none {
      block(below: 0.5em, text(size: 17pt, weight: "semibold", title))
    }
    set text(size: 15pt)
    body
  },
)

// Callout box. kind: "note" | "tip" | "warning".
#let callout(kind: "note", title: none, body) = {
  let (color, label) = (
    note: (palette.teal, "Note"),
    tip: (palette.yellow.darken(25%), "Tip"),
    warning: (palette.red, "Heads up"),
  ).at(kind)
  block(
    width: 100%,
    fill: color.transparentize(88%),
    stroke: (left: 5pt + color),
    inset: (x: 16pt, y: 14pt),
    radius: (right: 6pt),
    {
      text(size: 12pt, weight: "semibold", tracking: 0.15em, fill: color, upper(if title != none { title } else { label }))
      v(0.2em)
      set text(size: 15pt)
      body
    },
  )
}

// Inline keycap: "Press #key[Fn] + #key[Esc]".
#let key(label) = box(
  fill: palette.paper,
  stroke: (paint: palette.ink, thickness: 1.2pt),
  inset: (x: 6pt, y: 3pt),
  outset: (bottom: 2pt),
  radius: 4pt,
  baseline: 3pt,
  text(font: mono-font, size: 0.75em, weight: "bold", label),
)

// Big number with a label underneath.
#let stat(value, label, color: palette.accent) = {
  _brand(size: 96pt, fill: color, value)
  linebreak()
  v(-0.4em)
  text(size: 15pt, fill: palette.muted, label)
}

// Horizontal numbered steps. Items are (title, description) pairs.
#let steps(..items) = {
  let items = items.pos()
  grid(
    columns: (1fr,) * items.len(),
    column-gutter: 14pt,
    ..items.enumerate().map(((i, (head, desc))) => block(
      width: 100%,
      stroke: (top: 3pt + if i == 0 { palette.accent } else { palette.ink }),
      inset: (top: 12pt),
      {
        _brand(size: 44pt, fill: if i == 0 { palette.accent } else { palette.ink })[#_pad2(i + 1)]
        linebreak()
        text(size: 17pt, weight: "semibold", head)
        linebreak()
        text(size: 13pt, fill: palette.muted, desc)
      },
    ))
  )
}

// Small pill label.
#let tag(body, color: palette.ink) = box(
  fill: color,
  inset: (x: 10pt, y: 4pt),
  radius: 99pt,
  text(size: 11pt, weight: "semibold", tracking: 0.08em, fill: palette.paper, upper(body)),
)

// Striped stand-in for an image that doesn't exist yet.
#let placeholder(label: [Image], width: 100%, height: 100%) = block(
  width: width,
  height: height,
  radius: 6pt,
  clip: true,
  fill: tiling(size: (14pt, 14pt), {
    place(rect(width: 14pt, height: 14pt, fill: palette.surface))
    place(line(start: (0pt, 14pt), end: (14pt, 0pt), stroke: 1pt + palette.line))
  }),
  stroke: 1pt + palette.line,
  align(center + horizon, text(size: 13pt, weight: "medium", fill: palette.muted, upper(label))),
)

// Image (or placeholder content) with a caption below.
#let captioned(src, caption, height: auto) = {
  block(width: 100%, height: height, radius: 6pt, clip: true, _img(src, width: 100%, height: if height == auto { auto } else { 100% }, fit: "cover"))
  v(-0.3em)
  text(size: 12pt, fill: palette.muted, caption)
}

// Styled table: first row is the header.
#let data-table(columns: auto, ..cells) = table(
  columns: columns,
  fill: (_, y) => if y == 0 { palette.ink } else if calc.even(y) { palette.surface } else { none },
  stroke: (_, y) => if y > 0 { (bottom: 0.5pt + palette.line) },
  table.header(..cells.pos().slice(0, if type(columns) == int { columns } else { columns.len() }).map(c => text(fill: palette.paper, weight: "semibold", size: 14pt, c))),
  ..cells.pos().slice(if type(columns) == int { columns } else { columns.len() }).map(c => text(size: 15pt, c)),
)

// Label / value rows, e.g. hardware specs. Items are (label, value) pairs.
#let spec-list(..items) = grid(
  columns: (auto, 1fr),
  column-gutter: 18pt,
  row-gutter: 0pt,
  stroke: (_, y) => (bottom: 0.5pt + palette.line),
  inset: (x: 0pt, y: 9pt),
  align: (left + horizon, left + horizon),
  ..items.pos().map(((label, value)) => (
    text(size: 12pt, weight: "semibold", tracking: 0.15em, fill: palette.accent, upper(label)),
    text(size: 17pt, value),
  )).flatten(),
)

// Stacked fraction in the body font (Typst's math fonts are all serif).
// The bar sits at roughly the height of a "=" or "×" sign.
#let frac(num, den) = context {
  // Extra room above the bar: subscripts drop below the baseline, which
  // `measure` doesn't account for.
  let gap-above = 0.4em.to-absolute()
  let gap-below = 0.15em.to-absolute()
  let bar = 0.06em.to-absolute()
  let width = calc.max(measure(num).width, measure(den).width) + 0.3em.to-absolute()
  box(
    baseline: measure(den).height + gap-below + bar / 2 - 0.3em.to-absolute(),
    stack(
      align(center, num),
      v(gap-above),
      line(length: width, stroke: bar + palette.ink),
      v(gap-below),
      align(center, den),
    ),
  )
}

// Subscript helper for variable names like V_out: #var[V][out].
#let var(name, sub) = [#name#text(size: 0.6em, baseline: 0.25em, sub)]

// "I²C" with a synthesized superscript: New Amsterdam has no ² glyph, so the
// real character falls back to another font.
#let i2c = [I#h(0.05em)#super(typographic: false)[2]#h(0.03em)C]

// Boxed node for simple block diagrams.
#let node(body, fill: palette.paper, fg: palette.ink, width: auto) = box(
  width: width,
  fill: fill,
  stroke: 1.5pt + palette.ink,
  inset: (x: 14pt, y: 10pt),
  radius: 6pt,
  align(center, text(size: 15pt, weight: "semibold", fill: fg, body)),
)
