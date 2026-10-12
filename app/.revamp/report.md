# UI revamp — Travel Memory Book — 2026-10-12

Direction B (Day One reference), chosen from three drafts in `design-demos/`.
Branch `ui-revamp/2026-10-12-1647`, base `75531dd`.

| Category | Before | After |
|---|---|---|
| Layout | Top nav bar + centred page, decorative gradient backdrop | Drawer (≥1200) / rail (720–1199) / tab bar (<720) shell; library list + selected-book pane; trip chapters + memory pane |
| Fonts | Syne (titles) + Inter (UI) | Literata + Be Vietnam Pro, bundled, Vietnamese verified (Syne removed) |
| Colours | 72 hardcoded outside `lib/theme/` (audit 2026-10-12, before) | 41 (audit after); remaining are in the printed book pages (out of scope) and black shadows on book objects |
| Theme | Light parchment + dark slate/gold, built separately | One `AppPalette` extension, light + redrawn warm dark, contrast-checked tokens from `design-demos/b-tokens.md` |
| Book colour | none | Cloth per book sampled from its cover in OKLCH (`core/theme/book_cloth.dart`) |
| Icons | `lucide_icons` 0.257.0 — **does not compile on Flutter 3.47** (`IconData` is final) | `lucide_icons_flutter` 3.1.25, same 38 names (legacy aliases kept) |
| Empty library | unDraw people illustration | Empty cloth book + "Create your first book" (unDraw files removed) |
| Memories | No way to write one in the app | "Write a memory" sheet/dialog per day, via the existing `MemoryRepository` |
| Assets | 3.8 MB | 4.8 MB (+1.0 MB: 8 font files) |

Release APK size delta: not measured (`--analyze-size` not run).

## Checks

- `flutter analyze`: no errors or warnings. 65 infos, all pre-existing deprecations.
- `flutter test`: 2/2 pass. The old single test was rewritten for the new shell; it could not compile on this SDK before.
- `flutter build web --release`: built.
- `flutter build apk --debug`: see the handoff message.
- Screenshots of a seeded build were checked at 1440×900, 1024×768 and 390×844, in light and dark, with text scale 1.0, 1.3 and 2.0. No overflow.
- The seed entrypoint was temporary (`lib/main_demo.dart`) and is not committed. It loaded the `design-demos/spec.md` library.

## Beyond presentation (flag for review)

- `features/memories/widgets/memory_editor.dart` is a new UI. It calls the existing `MemoryRepository.create/update`; the repository itself is unchanged.
- The `/trips/:id/edit` route used to build `TripFormScreen(trip: null)`, an empty form. It now loads the trip through `TripEditScreen`.
- "Export PDF" outside the reader opens `/trips/:id/book?export=1`. The reader then starts its existing export (`autoExport` flag).
- `AppShell` reloads the trip list on every navigation. The drawer keeps `homeProvider` alive, so without the reload new books would not appear.
- New read-only view models: `library_provider.dart` (trip summaries, totals) and `bookClothProvider`.

## Manual follow-ups

- `app/build/web` (committed for Netlify) has **not** been rebuilt. The live site keeps the old UI until it is rebuilt and committed.
- The app has no route data, so the design's Route tab and loop diagram are not built.
- Several memories on one day are shown stacked. The design's "Memory 1 of 5" pager is not built.
- Printed book pages still use Inter / Merriweather / Playfair. Moving them to Literata is a separate decision.

## Rollback

    git switch main && git branch -D ui-revamp/2026-10-12-1647
