# UI audit — travel_memory_book

_Generated 2026-10-12 10:23 UTC by flutter-ui-revamp/scan_project.py_

## Shape of the project

| | |
|---|---|
| Type | flame_game |
| UI framework | material |
| State management | flutter_riverpod |
| Dart files scanned | 52 |
| Existing theme dir | yes |
| Dark theme | yes |
| Material 3 | yes |
| Bundled font families | Inter, Literata, Be Vietnam Pro, Playfair Display, Merriweather |
| UI/asset packages | flutter_svg, lucide_icons_flutter |
| Game packages | audioplayers |
| Asset files | 31 · 4.8 MB |

## Findings

| Severity | Code | Finding |
|---|---|---|
| HIGH | `HARDCODED_COLORS` | 41 hardcoded colors outside lib/theme/. |
| HIGH | `INLINE_TEXTSTYLE` | 29 inline TextStyle() outside lib/theme/. |
| MED | `ORPHAN_ASSETS` | 21 asset file(s) on disk but not declared in pubspec.yaml. |
| MED | `HEAVY_ASSETS` | 3 asset(s) over the size threshold. |
| LOW | `PLAIN_LOADER` | 4 plain ProgressIndicator(s) — no branded loading state. |
| LOW | `NO_HERO` | No Hero transitions — screen changes are hard cuts. |
| LOW | `NO_ANIMATION` | No animation package (rive / lottie / flutter_animate). |

## Icons in use (0 distinct, 0 occurrences)

_None found._

## Hardcoded colors (41 outside lib/theme/)

| Value | Uses | First seen |
|---|---:|---|
| `Colors.black` | 17 | lib/core/widgets/book_widgets.dart:70 |
| `Colors.white` | 6 | lib/core/widgets/app_skeleton.dart:43 |
| `0x11000000` | 1 | lib/core/utils/image_helper.dart:70 |
| `0xFFD4B98C` | 1 | lib/features/travel_book/widgets/book_pages/leather_cover.dart:9 |
| `0xFFF5EBD7` | 1 | lib/features/travel_book/widgets/book_pages/leather_cover.dart:10 |
| `0xFF4E3A2B` | 1 | lib/features/travel_book/widgets/book_pages/leather_cover.dart:23 |
| `0xFF37271B` | 1 | lib/features/travel_book/widgets/book_pages/leather_cover.dart:24 |
| `0xFF241811` | 1 | lib/features/travel_book/widgets/book_pages/leather_cover.dart:25 |
| `0xFF4A3428` | 1 | lib/features/travel_book/widgets/book_pages/paper_background.dart:6 |
| `0xB34A3428` | 1 | lib/features/travel_book/widgets/book_pages/paper_background.dart:7 |
| `0x804A3428` | 1 | lib/features/travel_book/widgets/book_pages/paper_background.dart:8 |
| `0xFF8D6E63` | 1 | lib/features/travel_book/widgets/book_pages/paper_background.dart:9 |
| `0xFFF8F0DC` | 1 | lib/features/travel_book/widgets/book_pages/paper_background.dart:10 |
| `0xFF16110D` | 1 | lib/features/travel_book/widgets/realistic_book_viewer.dart:368 |
| `0xFF0A0A0A` | 1 | lib/features/travel_book/widgets/realistic_book_viewer.dart:368 |
| `0xFFEFE7D8` | 1 | lib/features/travel_book/widgets/realistic_book_viewer.dart:369 |
| `0xFFFAF7F2` | 1 | lib/features/travel_book/widgets/realistic_book_viewer.dart:369 |
| `0x8C000000` | 1 | lib/features/trips/widgets/chapter_view.dart:324 |
| `0x66000000` | 1 | lib/features/trips/widgets/chapter_view.dart:373 |
| `0x00000000` | 1 | lib/features/trips/widgets/chapter_view.dart:373 |

## Inline TextStyle (29 outside lib/theme/)

| File | Count |
|---|---:|
| lib/features/travel_book/widgets/book_pages/book_cover_page.dart | 6 |
| lib/features/travel_book/widgets/book_pages/book_stats_back_cover.dart | 6 |
| lib/features/travel_book/widgets/book_pages/book_day_page.dart | 4 |
| lib/features/travel_book/widgets/book_pages/book_photo_page.dart | 4 |
| lib/features/home/widgets/library_list.dart | 2 |
| lib/features/travel_book/widgets/book_pages/book_memory_page.dart | 2 |
| lib/features/home/widgets/selected_book_pane.dart | 1 |
| lib/features/travel_book/widgets/book_pages/paper_background.dart | 1 |
| lib/features/travel_book/widgets/realistic_book_viewer.dart | 1 |
| lib/features/trips/screens/trip_detail_screen.dart | 1 |
| lib/features/trips/widgets/chapter_view.dart | 1 |

## Assets

| Kind | Files | Bytes |
|---|---:|---:|
| audio | 2 | 16.1 KB |
| font | 20 | 4.6 MB |
| image | 4 | 180.9 KB |
| other | 3 | 9.8 KB |
| vector | 2 | 3.0 KB |
| **total** | **31** | **4.8 MB** |

**Heavy files**

- `assets/fonts/merriweather-regular.ttf` — 581.7 KB
- `assets/fonts/merriweather-italic.ttf` — 572.3 KB
- `assets/fonts/merriweather-bold.ttf` — 572.2 KB

**Orphans** (on disk, not declared — dead weight or a broken reference): 21

- `assets/CREDITS.md`
- `assets/fonts/be_vietnam_pro_bold.ttf`
- `assets/fonts/be_vietnam_pro_medium.ttf`
- `assets/fonts/be_vietnam_pro_regular.ttf`
- `assets/fonts/be_vietnam_pro_semibold.ttf`
- `assets/fonts/inter-bold.ttf`
- `assets/fonts/inter-medium.ttf`
- `assets/fonts/inter-regular.ttf`
- `assets/fonts/inter-semibold.ttf`
- `assets/fonts/literata_italic.ttf`
- `assets/fonts/literata_medium.ttf`
- `assets/fonts/literata_regular.ttf`
- `assets/fonts/literata_semibold.ttf`
- `assets/fonts/merriweather-bold.ttf`
- `assets/fonts/merriweather-italic.ttf`
- `assets/fonts/merriweather-regular.ttf`
- `assets/fonts/playfair-bold.ttf`
- `assets/fonts/playfair-italic.ttf`
- `assets/fonts/playfair-medium.ttf`
- `assets/fonts/playfair-regular.ttf`
- `assets/fonts/playfair-semibold.ttf`

## Suggested screen priority (by presentation density)

When `scope` is unset and the app is large, start with these files:

| File | Score | Icons | Colors | TextStyles |
|---|---:|---:|---:|---:|
| `lib/features/trips/screens/trip_detail_screen.dart` | 49 | 0 | 0 | 1 |
| `lib/features/home/screens/home_screen.dart` | 21 | 0 | 0 | 0 |
| `lib/features/trips/screens/trip_form_screen.dart` | 17 | 0 | 0 | 0 |
| `lib/features/photos/screens/photo_detail_screen.dart` | 14 | 0 | 0 | 0 |
| `lib/features/photos/screens/add_photos_screen.dart` | 11 | 0 | 0 | 0 |
| `lib/features/profile/screens/profile_screen.dart` | 11 | 0 | 0 | 0 |
| `lib/features/settings/screens/settings_screen.dart` | 8 | 0 | 0 | 0 |
| `lib/core/utils/image_helper.dart` | 3 | 0 | 1 | 0 |

## Next

Step 2 of the skill: lock the design direction before downloading anything.
Every claim in the final report should cite a row above.
