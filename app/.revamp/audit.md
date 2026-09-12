# UI audit — travel_memory_book

_Generated 2026-09-12 14:12 UTC by flutter-ui-revamp/scan_project.py_

## Shape of the project

| | |
|---|---|
| Type | flame_game |
| UI framework | material |
| State management | flutter_riverpod |
| Dart files scanned | 44 |
| Existing theme dir | yes |
| Dark theme | yes |
| Material 3 | yes |
| Bundled font families | none |
| UI/asset packages | google_fonts |
| Game packages | audioplayers |
| Asset files | 8 · 200.0 KB |

## Findings

| Severity | Code | Finding |
|---|---|---|
| HIGH | `HARDCODED_COLORS` | 80 hardcoded colors outside lib/theme/. |
| HIGH | `INLINE_TEXTSTYLE` | 5 inline TextStyle() outside lib/theme/. |
| MED | `RUNTIME_FONT` | google_fonts is used without bundled font files — fonts download at runtime (FOUT + offline break). |
| MED | `DEFAULT_ICONS` | 34 distinct default Material/Cupertino icons — no custom icon set. |
| MED | `NO_DENSITY_BUCKETS` | No 2.0x/3.0x density buckets — raster images will be resampled on most phones. |
| LOW | `PLAIN_LOADER` | 9 plain ProgressIndicator(s) — no branded loading state. |
| LOW | `NO_HAPTICS` | No HapticFeedback calls — buttons have no physical response. |
| LOW | `NO_ANIMATION` | No animation package (rive / lottie / flutter_animate). |
| LOW | `NO_WEBP` | 4 PNG(s) and no WebP — typically 25–35% of image bytes are wasted. |

## Icons in use (34 distinct, 58 occurrences)

| Icon | Uses | Files |
|---|---:|---|
| `Icons.add` | 5 | empty_state.dart, web_layout.dart, home_screen.dart +2 |
| `Icons.auto_stories` | 5 | web_layout.dart, home_screen.dart, book_cover_page.dart +2 |
| `Icons.broken_image` | 4 | image_helper.dart, photo_detail_screen.dart |
| `Icons.library_books_outlined` | 3 | web_layout.dart, profile_screen.dart |
| `Icons.edit_outlined` | 3 | photo_detail_screen.dart, trip_detail_screen.dart |
| `Icons.photo_library_outlined` | 3 | profile_screen.dart, trip_detail_screen.dart |
| `Icons.person` | 2 | web_layout.dart, profile_screen.dart |
| `Icons.arrow_back` | 2 | web_layout.dart, realistic_book_viewer.dart |
| `Icons.calendar_today_outlined` | 2 | photo_detail_screen.dart, trip_detail_screen.dart |
| `Icons.location_on_outlined` | 2 | photo_detail_screen.dart, trip_detail_screen.dart |
| `Icons.menu_book_outlined` | 2 | photo_detail_screen.dart, trip_detail_screen.dart |
| `Icons.place_outlined` | 2 | book_day_page.dart, book_photo_page.dart |
| `Icons.image_outlined` | 2 | book_photo_page.dart, trip_detail_screen.dart |
| `Icons.library_books` | 1 | web_layout.dart |
| `Icons.person_outline` | 1 | web_layout.dart |
| `Icons.settings_outlined` | 1 | web_layout.dart |
| `Icons.settings` | 1 | web_layout.dart |
| `Icons.sort` | 1 | home_screen.dart |
| `Icons.error_outlined` | 1 | home_screen.dart |
| `Icons.menu_book` | 1 | book_thumbnail.dart |
| `Icons.cloud_upload_outlined` | 1 | add_photos_screen.dart |
| `Icons.close` | 1 | add_photos_screen.dart |
| `Icons.arrow_forward` | 1 | add_photos_screen.dart |
| `Icons.delete_outlined` | 1 | photo_detail_screen.dart |
| `Icons.notes_outlined` | 1 | photo_detail_screen.dart |
| … | | 9 more in audit.json |

## Hardcoded colors (80 outside lib/theme/)

| Value | Uses | First seen |
|---|---:|---|
| `Colors.black` | 20 | lib/features/home/widgets/book_thumbnail.dart:65 |
| `Colors.white` | 13 | lib/features/home/widgets/book_thumbnail.dart:198 |
| `Colors.transparent` | 10 | lib/core/widgets/web_layout.dart:143 |
| `Colors.red` | 5 | lib/features/photos/screens/photo_detail_screen.dart:86 |
| `0xFFE8A87C` | 2 | lib/core/widgets/web_layout.dart:191 |
| `0xFFC38D9E` | 2 | lib/core/widgets/web_layout.dart:201 |
| `0x11000000` | 1 | lib/core/utils/image_helper.dart:69 |
| `0xFF181209` | 1 | lib/core/widgets/web_layout.dart:172 |
| `0xFF0C0A08` | 1 | lib/core/widgets/web_layout.dart:172 |
| `0xFFFCF8F0` | 1 | lib/core/widgets/web_layout.dart:173 |
| `0xFFF1E6CF` | 1 | lib/core/widgets/web_layout.dart:173 |
| `0xFF0F0A06` | 1 | lib/features/home/widgets/book_thumbnail.dart:167 |
| `0xFF2A1F18` | 1 | lib/features/home/widgets/book_thumbnail.dart:167 |
| `0xFF1A1108` | 1 | lib/features/home/widgets/book_thumbnail.dart:168 |
| `0xFF3E2723` | 1 | lib/features/home/widgets/book_thumbnail.dart:168 |
| `0xFF2A2520` | 1 | lib/features/home/widgets/book_thumbnail.dart:293 |
| `0xFF1A1714` | 1 | lib/features/home/widgets/book_thumbnail.dart:294 |
| `0xFFF4E4C1` | 1 | lib/features/home/widgets/book_thumbnail.dart:322 |
| `0xFF3A3530` | 1 | lib/features/home/widgets/book_thumbnail.dart:323 |
| `0xFFD4B98C` | 1 | lib/features/travel_book/widgets/book_pages/leather_cover.dart:9 |
| `0xFFF5EBD7` | 1 | lib/features/travel_book/widgets/book_pages/leather_cover.dart:10 |
| `0xFF4E3A2B` | 1 | lib/features/travel_book/widgets/book_pages/leather_cover.dart:23 |
| `0xFF37271B` | 1 | lib/features/travel_book/widgets/book_pages/leather_cover.dart:24 |
| `0xFF241811` | 1 | lib/features/travel_book/widgets/book_pages/leather_cover.dart:25 |
| `0xFF4A3428` | 1 | lib/features/travel_book/widgets/book_pages/paper_background.dart:7 |

## Inline TextStyle (5 outside lib/theme/)

| File | Count |
|---|---:|
| lib/features/trips/screens/trip_detail_screen.dart | 2 |
| lib/core/widgets/web_layout.dart | 1 |
| lib/features/home/screens/home_screen.dart | 1 |
| lib/features/travel_book/widgets/realistic_book_viewer.dart | 1 |

## Assets

| Kind | Files | Bytes |
|---|---:|---:|
| audio | 2 | 16.1 KB |
| image | 4 | 180.9 KB |
| vector | 2 | 3.0 KB |
| **total** | **8** | **200.0 KB** |

## Suggested screen priority (by presentation density)

When `scope` is unset and the app is large, start with these files:

| File | Score | Icons | Colors | TextStyles |
|---|---:|---:|---:|---:|
| `lib/features/trips/screens/trip_detail_screen.dart` | 84 | 11 | 11 | 2 |
| `lib/features/photos/screens/photo_detail_screen.dart` | 38 | 9 | 2 | 0 |
| `lib/features/profile/screens/profile_screen.dart` | 34 | 7 | 0 | 0 |
| `lib/features/photos/screens/add_photos_screen.dart` | 24 | 3 | 2 | 0 |
| `lib/features/home/screens/home_screen.dart` | 20 | 4 | 0 | 1 |
| `lib/features/trips/screens/trip_form_screen.dart` | 20 | 2 | 0 | 0 |
| `lib/core/utils/image_helper.dart` | 7 | 2 | 1 | 0 |
| `lib/features/settings/screens/settings_screen.dart` | 7 | 0 | 0 | 0 |

## Next

Step 2 of the skill: lock the design direction before downloading anything.
Every claim in the final report should cite a row above.
