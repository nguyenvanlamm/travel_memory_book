# UI Revamp Report — flutter-ui-revamp

## Direction
`dark-premium` — keeps the printed-travel-journal identity of the book pages,
wraps the site chrome in a slate + gold premium scheme. Light mode stays warm
parchment; dark mode is `#0B1220` slate with `#D4AF37` gold accent.

## Assets added (licence-verified, see assets/CREDITS.md)
- lucide_icons (ISC) — replaced all default Material icons
- Inter 400–700 (OFL, bundled) — UI body font
- Syne 600–700 (OFL, bundled) — UI display font
- Playfair Display + Merriweather (OFL, bundled) — book typography,
  replacing runtime google_fonts fetches (fixes FOUT + offline + capture bugs)
- unDraw travelers.svg (unDraw licence) — home empty-state illustration,
  recolored to the gold accent

## What changed
- `app_theme.dart` rewritten: AppSpacing/AppRadius tokens, warm light +
  slate/gold dark schemes, bundled font families, styled cards/fields/
  buttons/snackbars/scrollbars.
- `WebBackdrop`: warm gradient + paper grain + soft colour glows behind every
  page; dark variant with gold/blue glows.
- Shared widgets: `LoadingView`, `AppSkeleton`, `HoverScale`; `EmptyState`
  now supports SVG illustrations.
- Icon migration: all `Icons.*` in app code → `LucideIcons.*`.
- Book pages: google_fonts → bundled `fontFamily` ('Playfair Display',
  'Merriweather', 'Inter').
- Add-photos dropzone: hover highlight (border + tint animation).
- Fixed: `homeProvider` → `autoDispose` so the library refreshes after
  creating/deleting a trip (previously showed a stale empty state).

## Verification
- `flutter analyze`: 0 issues
- `flutter build web`: OK (fonts bundled, Lucide tree-shaken to 396 KB)
- Headless Chrome end-to-end: create trip → import 4 photos → open book →
  flip 1/4→4/4 → back cover → Back → library. 0 console errors.
- Dark mode verified via Settings → Dark (persists via shared_preferences).

## Notes
- Book pages intentionally keep fixed "print" colours (leather/parchment/
  gold) — they do not follow dark mode, by design.
- Site header nav items use TextButton — they don't appear in the headless
  flt-semantics DOM but are clickable and keyboard-focusable.
