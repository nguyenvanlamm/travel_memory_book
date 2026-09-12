# Design direction — locked 2026-09-12

Style        dark-premium (dark-first, light kept warm-parchment)
Seed         #D4AF37 gold accent (matches leather cover gold #D4B98C);
             slate surface world #0F172A family for dark surfaces
Icons        Lucide (ISC) — const IconData via lucide_icons, thin strokes
Fonts        Syne 600/700 (headings, OFL, bundled) + Inter 400/500/600/700
             (body, OFL, bundled) — replace google_fonts runtime fetch
Illustration optional unDraw travel illo, recoloured gold, transparent
Animation    built-in only — fade-through route transitions, skeleton
             loaders, hover/press-scale micro-interactions; no Rive/Lottie
Spacing      4 / 8 / 16 / 24 / 32 / 48
Radius       12 / 16 / 20 / pill
Surfaces     surface / surfaceContainerHigh hierarchy; hairline borders;
             soft shadows, no heavy elevation
Dark mode    PRIMARY — designed dark-first; light keeps parchment warmth
Out of scope business logic, state management, repositories, models,
             navigation structure, book page fixed print colours
             (leather/parchment/gold in book_pages/ stay fixed — they
             represent printed matter, not app chrome)
Kept         book page palette (BookInk, LeatherCover), WebBackdrop
             gradient direction (retinted), page-flip mechanics
