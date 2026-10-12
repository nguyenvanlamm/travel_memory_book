# Design direction — locked 2026-10-12 (replaces dark-premium of 2026-09-12)

Source       design-demos/direction-approved.md (direction B, Day One reference),
             design-demos/b-tokens.md, b-reference.html, b-mobile.html
Style        Day One–style panes: drawer → list → detail; each book in its own
             cloth colour sampled from its cover photo
Palette      paper #FCFAF6 / #F8F3EC / #EFE9DF, ink #2C1E18 / #51453D / #6C6158,
             one action colour sun #A64F2B (dark: #DF8D64 with #25150E text),
             gold #D1BB92, foil #DAC49D, parch #F3EAD9; dark paper #231E19 /
             #1B1713 / #15110D — redrawn, not inverted
Cloth        OKLCH from the cover: L .42–.64, C .03–.14; deep = (.255, ≤.035, H);
             no cover → earth #63453A
Icons        Lucide via lucide_icons_flutter (ISC icons, MIT package)
Fonts        Literata 400/500/600 + italic (reading, titles, numbers) and
             Be Vietnam Pro 400/500/600/700 (interface) — OFL, bundled,
             full Vietnamese coverage
Illustration none — real photos and CSS-like book objects (cover, spine, ribbon)
Animation    built-in only; haptics on navigation and save
Spacing      4 / 8 / 16 / 24 / 32 / 48
Radius       2 / 4 (spines) · 6 (buttons, inputs) · 8 (panels) · pill
Breakpoints  ≥1200 drawer + list + detail · 720–1199 rail · <720 tab bar,
             pushed pages hide it
Dark mode    required, both brightnesses designed
Out of scope business logic, repositories, models, navigation structure,
             printed book pages (book_pages/ keep their fixed print colours)
Kept         realistic page-flip reader and its fonts (Inter, Merriweather,
             Playfair Display)
