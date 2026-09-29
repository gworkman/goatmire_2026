# Goatmire 2026 badge workshop slides

Typst slide deck for the Goatmire 2026 name badge workshop (ESP32-S3, LCD, onboard sensors, 69-character keyboard).

## Build

Requires [Typst](https://typst.app) 0.13+.

```sh
make          # build/goatmire-2026.pdf and build/badge-tutorial.pdf
make watch    # rebuild on save
make open     # build and open the PDF
```

Or directly: `typst compile --font-path fonts main.typ build/goatmire-2026.pdf`

## Layout

```
main.typ              workshop deck: document setup + includes
tutorial.typ          3-minute badge tutorial deck
template/theme.typ    colours, fonts, slide layouts and components
slides/               slide content (one file per part of the talk)
images/               images and diagrams
fonts/                New Amsterdam (brand) and Poppins (body), both SIL OFL
build/                compiled PDF (git-ignored)
```

`slides/examples.typ` has one of every layout and component. Copy what you need from it, then drop it from `main.typ`.

## Slide layouts

Each of these emits one page:

| Function | Use |
|---|---|
| `title-slide` | Opening slide, dark background, optional visual |
| `agenda-slide` | Numbered agenda in columns |
| `section-slide` | Coloured divider with a big number (adds a PDF bookmark) |
| `slide` | Standard slide with `title`, `kicker`, optional `center: true` |
| `statement-slide` | One big line of text |
| `quote-slide` | Quote with attribution |
| `image-slide` | Title + fitted image + caption |
| `bleed-slide` | Full-bleed background image with title |
| `split-slide` | Half edge-to-edge image, half content (`side: left/right`) |
| `exercise-slide` | Hands-on task list with time box and hint |
| `end-slide` | Closing slide |

Components for use inside slides: `cols`, `card`, `callout` (note/tip/warning), `key` (keycaps), `stat`, `steps`, `tag`, `placeholder`, `captioned`, `data-table`, `node`.

## Images

Reference images with root-absolute paths (`"/images/badge.svg"`) so they resolve the same from any file. `images/badge.svg` and `images/placeholder-photo.svg` are placeholders.
