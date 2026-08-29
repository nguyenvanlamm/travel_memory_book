# Tasks — Travel Memory Book

## Sprint Overview

| Sprint | Focus | Tasks | MVP? |
|--------|-------|-------|------|
| Sprint 1 | Foundation | Setup project, models, DB, theme, routing | Part of MVP |
| Sprint 2 | Core Features | Trip CRUD, photo import, timeline, EXIF | Part of MVP |
| Sprint 3 | Book & Memory | Book assembly, viewer, memory/journal | Part of MVP |
| Sprint 4 | Polish & Test | Tests, dark mode, sort, error handling | Part of MVP |
| Sprint 5+ | Phase 2 | Map, calendar, statistics, search, PDF | Post-MVP |

**Critical Path**: 1.1 → 1.5 → 1.6 → 2.1 → 2.4 → 2.5 → 3.1 → 3.2 → 3.3 (project init → DB → models → trip CRUD → photo import → book → viewer)

---

## Sprint 1: Foundation

### Task 1.1: Initialize Flutter Project
**Description**: Bootstrap Flutter project với package name `com.lam.travelmemorybook`, Android-only initially, dependencies trong pubspec.yaml.

**Acceptance Criteria**:
- [ ] `flutter create` completed với org `com.lam` và name `travel_memory_book`
- [ ] pubspec.yaml includes: flutter_riverpod, go_router, isar, image_picker, exif, path_provider, image, intl, google_fonts
- [ ] `flutter pub get` thành công
- [ ] `flutter analyze` returns 0 issues
- [ ] Min SDK set to 21 in android/app/build.gradle

**Dependencies**: None

**PRD Reference**: Section 6.2 (Technology Stack)

**Effort**: S (1 day)

---

### Task 1.2: Set Up App Theme (Light + Dark)
**Description**: Tạo theme system với warm, cinematic colors. Light + Dark + System mode. Custom typography từ Google Fonts.

**Acceptance Criteria**:
- [ ] `lib/core/theme/app_theme.dart` defined
- [ ] Light theme uses warm palette (cream, brown, deep blue accent)
- [ ] Dark theme optimized for photo viewing (true black background)
- [ ] Typography: Serif cho titles, sans-serif cho body
- [ ] Theme mode persistence in SharedPreferences
- [ ] Toggle in settings

**Dependencies**: Task 1.1

**PRD Reference**: F10, Section 5.1 (Style)

**Effort**: M (2 days)

---

### Task 1.3: Define Data Models
**Description**: Tạo Isar collections: Trip, Photo, Memory, Location, TravelBook (với embedded BookPage).

**Acceptance Criteria**:
- [ ] `lib/models/trip.dart` với @collection annotation
- [ ] `lib/models/photo.dart` với @collection
- [ ] `lib/models/memory.dart` với @collection
- [ ] `lib/models/location.dart` với @collection
- [ ] `lib/models/travel_book.dart` với @collection + embedded BookPage
- [ ] Build runner generates .g.dart files without errors
- [ ] All models có copyWith, fromJson/toJson

**Dependencies**: Task 1.1

**PRD Reference**: Section 5.1 (Data Models)

**Effort**: M (2 days)

---

### Task 1.4: Set Up Isar Database
**Description**: Configure Isar instance, schema registration, provide qua Riverpod.

**Acceptance Criteria**:
- [ ] `lib/core/database/isar_provider.dart` với Isar singleton
- [ ] Provider initializes DB in main() before runApp
- [ ] App docs directory used for DB file
- [ ] Schema version tracked
- [ ] Test: write + read Trip passes

**Dependencies**: Task 1.1, 1.3

**PRD Reference**: F9

**Effort**: S (1 day)

---

### Task 1.5: Set Up GoRouter
**Description**: Configure navigation với go_router. Bottom nav: Home, Trips, Memories, Profile.

**Acceptance Criteria**:
- [ ] `lib/core/router/app_router.dart` with routes
- [ ] Bottom navigation shell với 4 tabs
- [ ] Placeholder screens for each tab
- [ ] Deep link support (future-proof)
- [ ] Back button works on Android

**Dependencies**: Task 1.1, 1.2

**PRD Reference**: Section 21 (Bottom Nav)

**Effort**: S (1 day)

---

### Task 1.6: Create Base UI Widgets
**Description**: Reusable widgets: PrimaryButton, SectionHeader, EmptyState, ProgressOverlay.

**Acceptance Criteria**:
- [ ] `lib/core/widgets/primary_button.dart` - styled button
- [ ] `lib/core/widgets/section_header.dart` - text + divider
- [ ] `lib/core/widgets/empty_state.dart` - icon + text + CTA
- [ ] `lib/core/widgets/progress_overlay.dart` - modal progress
- [ ] All widgets responsive to theme

**Dependencies**: Task 1.2

**PRD Reference**: Section 28 (Design)

**Effort**: S (1 day)

---

### Task 1.7: Create File Storage Service
**Description**: Service để manage files trong app docs directory. Copy originals, generate thumbnails.

**Acceptance Criteria**:
- [ ] `lib/core/services/file_service.dart` 
- [ ] `copyToTripPhotos(tripId, sourcePath)` returns destination path
- [ ] `generateThumbnail(sourcePath, tripId)` returns thumb path
- [ ] Thumbnails 512x512, JPEG quality 85
- [ ] Originals kept as-is (no re-compression)
- [ ] Test: file exists, thumbnail readable

**Dependencies**: Task 1.1

**PRD Reference**: Section 5.5 (Storage)

**Effort**: M (2 days)

---

### Task 1.8: Create EXIF Service
**Description**: Read EXIF metadata: date taken, GPS, camera model, lens.

**Acceptance Criteria**:
- [ ] `lib/core/services/exif_service.dart`
- [ ] `readExif(filePath)` returns ExifData object
- [ ] Handles missing EXIF gracefully
- [ ] Extracts: date, latitude, longitude, camera, lens, ISO, shutter, aperture
- [ ] Test: read from sample photo with EXIF

**Dependencies**: Task 1.1

**PRD Reference**: F11, Section 9

**Effort**: M (2 days)

---

## Sprint 2: Core Features

### Task 2.1: Trip Repository
**Description**: CRUD operations cho Trip model qua Isar.

**Acceptance Criteria**:
- [ ] `lib/repositories/trip_repository.dart`
- [ ] `create(trip)` - inserts new trip
- [ ] `getById(id)` - returns trip or null
- [ ] `getAll()` - returns all trips, sorted by startDate desc
- [ ] `update(trip)` - updates existing
- [ ] `delete(id)` - removes trip + its photos
- [ ] `count()` - returns total
- [ ] Test: all operations pass

**Dependencies**: Task 1.3, 1.4

**PRD Reference**: F1, F2

**Effort**: M (2 days)

---

### Task 2.2: Photo Repository
**Description**: CRUD operations cho Photo model.

**Acceptance Criteria**:
- [ ] `lib/repositories/photo_repository.dart`
- [ ] `create(photo)` - inserts
- [ ] `getByTrip(tripId)` - returns photos for trip, sorted by takenAt
- [ ] `getByDay(tripId, day)` - returns photos for specific day
- [ ] `update(photo)` - update caption, location
- [ ] `delete(id)` - removes photo + files
- [ ] `countByTrip(tripId)` - returns count
- [ ] Test: all operations pass

**Dependencies**: Task 1.3, 1.4

**PRD Reference**: F3, F4

**Effort**: M (2 days)

---

### Task 2.3: Memory Repository
**Description**: CRUD operations cho Memory model.

**Acceptance Criteria**:
- [ ] `lib/repositories/memory_repository.dart`
- [ ] `create(memory)` - inserts
- [ ] `getByTrip(tripId)` - all memories for trip
- [ ] `getByDate(tripId, date)` - memory for specific date
- [ ] `update(memory)` - update content
- [ ] `delete(id)` - removes
- [ ] Test: all operations pass

**Dependencies**: Task 1.3, 1.4

**PRD Reference**: F7

**Effort**: S (1 day)

---

### Task 2.4: Home Screen — Trip Library
**Description**: Grid view of all trips với cover photos, names, dates, photo counts.

**Acceptance Criteria**:
- [ ] `lib/features/home/screens/home_screen.dart`
- [ ] GridView với trip cards (2 columns)
- [ ] Each card: cover photo, title, year, photo count
- [ ] Empty state if 0 trips
- [ ] Pull-to-refresh
- [ ] Sort menu: newest, oldest, by year, by country
- [ ] FAB "+ New Travel Book"
- [ ] Tap card → trip detail

**Dependencies**: Task 1.5, 1.6, 2.1

**PRD Reference**: F1, F12, Section 5, 6

**Effort**: M (3 days)

---

### Task 2.5: Create Trip Screen
**Description**: Form to create new trip: title, location, dates, description, cover photo.

**Acceptance Criteria**:
- [ ] `lib/features/trips/screens/trip_form_screen.dart`
- [ ] TextField: title (required)
- [ ] TextField: location
- [ ] DatePicker: start date (required)
- [ ] DatePicker: end date (required)
- [ ] TextField: description (multiline)
- [ ] Image picker: cover photo
- [ ] Form validation: title + dates required, end >= start
- [ ] "Create" button → saves to DB
- [ ] On save, navigate to trip detail

**Dependencies**: Task 1.6, 2.1

**PRD Reference**: F2, F13, Section 7

**Effort**: M (2 days)

---

### Task 2.6: Trip Detail Screen
**Description**: Show trip info, photo count, places, "Add Photos" button, "Read Book" button, "Edit Memory" button.

**Acceptance Criteria**:
- [ ] `lib/features/trips/screens/trip_detail_screen.dart`
- [ ] Header: cover photo, title, location, dates
- [ ] Stats: photo count, place count, day count
- [ ] "Add Photos" button → opens picker
- [ ] "Read Book" button → opens book viewer
- [ ] "Edit Memory" button → opens memory editor
- [ ] Photo grid below header (thumbnails)
- [ ] Edit trip button
- [ ] Delete trip option

**Dependencies**: Task 1.5, 2.1, 2.2, 2.5

**PRD Reference**: F2, F3, Section 8

**Effort**: M (2 days)

---

### Task 2.7: Add Photos Screen
**Description**: Multi-image picker, progress bar, import flow.

**Acceptance Criteria**:
- [ ] `lib/features/photos/screens/add_photos_screen.dart`
- [ ] Source chooser: Gallery or Camera
- [ ] Gallery: multi-select via image_picker
- [ ] Camera: single photo capture
- [ ] Preview selected photos with count
- [ ] "Continue" button starts import
- [ ] Progress overlay shows N/M imported
- [ ] Background isolate for image processing
- [ ] On complete, photos in trip timeline

**Dependencies**: Task 1.7, 1.8, 2.2

**PRD Reference**: F3, Section 26

**Effort**: L (3 days)

---

### Task 2.8: Photo Timeline View
**Description**: Auto-group photos by day, show timeline.

**Acceptance Criteria**:
- [ ] `lib/features/photos/widgets/photo_timeline.dart`
- [ ] Photos sorted by takenAt ascending
- [ ] Grouped by day (section headers: "18 August")
- [ ] Within day, time shown
- [ ] Tap photo → photo detail
- [ ] Used in trip detail screen

**Dependencies**: Task 2.2, 2.6

**PRD Reference**: F4, Section 10

**Effort**: M (2 days)

---

### Task 2.9: Photo Detail Screen
**Description**: Full-screen photo with metadata, location, caption.

**Acceptance Criteria**:
- [ ] `lib/features/photos/screens/photo_detail_screen.dart`
- [ ] Full-screen photo (zoomable)
- [ ] Below: location name, date, time
- [ ] Caption (editable)
- [ ] "Edit" opens caption editor
- [ ] Camera info in collapsible section
- [ ] Delete photo option

**Dependencies**: Task 2.2

**PRD Reference**: F8, Section 16

**Effort**: M (2 days)

---

## Sprint 3: Book & Memory

### Task 3.1: Book Repository
**Description**: Assemble TravelBook from photos, manage book pages.

**Acceptance Criteria**:
- [ ] `lib/repositories/book_repository.dart`
- [ ] `assemble(tripId)` - creates book from trip's photos
- [ ] Page order: cover → day 1 pages → day 2 pages → ... → memory
- [ ] Each photo = 1 page (or group if 1 day has many)
- [ ] `getByTrip(tripId)` - returns existing book
- [ ] `regenerate(tripId)` - rebuild book after photo changes
- [ ] Test: assemble returns valid book

**Dependencies**: Task 2.1, 2.2

**PRD Reference**: F5, Section 27

**Effort**: M (3 days)

---

### Task 3.2: Book Cover Page Widget
**Description**: Beautiful cover page với photo, title, year.

**Acceptance Criteria**:
- [ ] `lib/features/travel_book/widgets/book_cover.dart`
- [ ] Full-bleed cover photo
- [ ] Overlay: trip title (large, serif)
- [ ] Country below title
- [ ] Year at bottom
- [ ] "Read" hint at very bottom

**Dependencies**: Task 1.2, 1.6

**PRD Reference**: F6, Section 12

**Effort**: S (1 day)

---

### Task 3.3: Book Page Widget (Photo Page)
**Description**: Single page showing 1-2 photos + caption + location.

**Acceptance Criteria**:
- [ ] `lib/features/travel_book/widgets/book_page.dart`
- [ ] Photo(s) fills most of page
- [ ] Caption below photo
- [ ] Location + date
- [ ] Cream/sepia background option

**Dependencies**: Task 1.6

**PRD Reference**: F6

**Effort**: S (1 day)

---

### Task 3.4: Book Viewer Screen
**Description**: PageView-based book viewer với page-flip feel.

**Acceptance Criteria**:
- [ ] `lib/features/travel_book/screens/book_viewer_screen.dart`
- [ ] PageView with all book pages
- [ ] Smooth swipe animation
- [ ] Cover page first, memory last
- [ ] Tap right edge → next page
- [ ] Tap left edge → previous page
- [ ] Back button closes
- [ ] Loading state while assembling

**Dependencies**: Task 3.1, 3.2, 3.3

**PRD Reference**: F6, Section 12, 13

**Effort**: M (3 days)

---

### Task 3.5: Memory Editor Screen
**Description**: Write/edit memory for trip or specific day.

**Acceptance Criteria**:
- [ ] `lib/features/memories/screens/memory_editor_screen.dart`
- [ ] TextEditor (multi-line)
- [ ] Optional: date selector (whole trip vs specific day)
- [ ] Save button
- [ ] Auto-save every 30s
- [ ] Character count

**Dependencies**: Task 2.3

**PRD Reference**: F7, Section 14, 15

**Effort**: M (2 days)

---

### Task 3.6: Daily Journal Pages in Book
**Description**: When reading book, each day has a journal page after its photos.

**Acceptance Criteria**:
- [ ] Memory with `date == day` appears after that day's photos
- [ ] Memory page shows date + content
- [ ] If no memory for day, skip page

**Dependencies**: Task 3.1, 3.4, 3.5

**PRD Reference**: F7, Section 15

**Effort**: S (1 day)

---

### Task 3.7: Trip Memory Page (End of Book)
**Description**: At end of book, show whole-trip memory if exists.

**Acceptance Criteria**:
- [ ] Memory with `date == null` shown at end of book
- [ ] Page: "My Memory" title + content
- [ ] If no memory, skip

**Dependencies**: Task 3.1, 3.4, 3.5

**PRD Reference**: F7, Section 14

**Effort**: S (1 day)

---

### Task 3.8: Book Generation on Demand
**Description**: Book assembled when user first opens, cached, regenerated if photos change.

**Acceptance Criteria**:
- [ ] First "Read Book" tap → check if book exists
- [ ] If not, assemble (show brief loading)
- [ ] If exists, just show
- [ ] Adding/removing photos invalidates book
- [ ] Background regeneration if possible

**Dependencies**: Task 3.1, 2.7

**PRD Reference**: F5

**Effort**: M (2 days)

---

## Sprint 4: Polish & Test

### Task 4.1: Dark Mode Polish
**Description**: Make sure dark mode is beautiful for photo viewing.

**Acceptance Criteria**:
- [ ] True black background in dark mode
- [ ] Photos pop against dark
- [ ] Text readable
- [ ] Accent colors work in both modes
- [ ] Test all screens in both modes

**Dependencies**: Sprint 1, 2, 3

**PRD Reference**: F10, Section 29

**Effort**: M (2 days)

---

### Task 4.2: Trip Sort & Filter
**Description**: Sort trips by newest, oldest, year, country.

**Acceptance Criteria**:
- [ ] Sort menu in home
- [ ] Persists across sessions
- [ ] All 4 sort modes work
- [ ] Empty state handles 0 results

**Dependencies**: Task 2.4

**PRD Reference**: F12, Section 5

**Effort**: S (1 day)

---

### Task 4.3: Settings Screen
**Description**: Theme toggle, about, version.

**Acceptance Criteria**:
- [ ] `lib/features/settings/screens/settings_screen.dart`
- [ ] Theme toggle: Light / Dark / System
- [ ] About section
- [ ] App version
- [ ] Storage usage (Phase 3: backup option)

**Dependencies**: Task 1.2

**PRD Reference**: Section 25

**Effort**: S (1 day)

---

### Task 4.4: Profile Screen
**Description**: Personal stats view.

**Acceptance Criteria**:
- [ ] `lib/features/profile/screens/profile_screen.dart`
- [ ] Total trips count
- [ ] Total countries count
- [ ] Total cities count
- [ ] Total photos count
- [ ] Settings link
- [ ] "My memories" tagline

**Dependencies**: Task 2.1, 2.2

**PRD Reference**: Section 22

**Effort**: S (1 day)

---

### Task 4.5: Error Handling
**Description**: Graceful error states throughout.

**Acceptance Criteria**:
- [ ] All screens have loading + error states
- [ ] DB errors caught + shown
- [ ] File system errors caught
- [ ] No silent failures

**Dependencies**: Sprint 1, 2, 3

**PRD Reference**: NFR section

**Effort**: M (2 days)

---

### Task 4.6: Unit Tests
**Description**: Tests for models, repositories, key services.

**Acceptance Criteria**:
- [ ] Trip model tests
- [ ] Photo model tests
- [ ] TripRepository tests
- [ ] PhotoRepository tests
- [ ] MemoryRepository tests
- [ ] ExifService tests
- [ ] FileService tests
- [ ] Coverage > 60%

**Dependencies**: Sprint 1, 2, 3

**PRD Reference**: Test strategy

**Effort**: M (2 days)

---

### Task 4.7: Widget Tests
**Description**: Tests for key screens.

**Acceptance Criteria**:
- [ ] Home screen test (empty + populated)
- [ ] Trip form test
- [ ] Book viewer test (mock data)
- [ ] Photo detail test

**Dependencies**: Sprint 2, 3

**PRD Reference**: Test strategy

**Effort**: M (2 days)

---

### Task 4.8: Integration Test — Create Trip Flow
**Description**: E2E test: create trip → add 3 photos → view book.

**Acceptance Criteria**:
- [ ] Test creates trip via form
- [ ] Test imports 3 mock photos
- [ ] Test opens book viewer
- [ ] Test swipes through pages
- [ ] Test writes memory

**Dependencies**: Sprint 2, 3

**PRD Reference**: Test strategy

**Effort**: M (2 days)

---

### Task 4.9: Performance Optimization
**Description**: Verify performance targets met.

**Acceptance Criteria**:
- [ ] Cold start < 2s
- [ ] Photo import non-blocking
- [ ] Timeline loads < 300ms
- [ ] Book page flip 60fps
- [ ] Memory under 200MB for 100-photo trip

**Dependencies**: Sprint 2, 3

**PRD Reference**: NFR Performance

**Effort**: M (2 days)

---

## Sprint 5+: Phase 2 Features (Post-MVP)

| Task | Description | PRD Ref |
|------|-------------|---------|
| 5.1 | Map view with flutter_map | F14 |
| 5.2 | Calendar view | F15 |
| 5.3 | Statistics dashboard | F16 |
| 5.4 | Search trips & photos | F17 |
| 5.5 | Export to PDF | F18 |
| 5.6 | Photo editing basics | Phase 2 |
| 5.7 | Auto-group photos by location | Section 27 |

## Sprint 6+: Phase 3 Features (Long-term)

| Task | Description | PRD Ref |
|------|-------------|---------|
| 6.1 | Cloud backup (Supabase/Firebase) | F19 |
| 6.2 | Multi-device sync | F20 |
| 6.3 | AI caption generation | Phase 3 |
| 6.4 | AI cover suggestion | Phase 3 |
| 6.5 | Print-on-demand integration | Section 35 |

---

## Dependency Table

| Task ID | Depends On |
|---------|------------|
| 1.1 | None |
| 1.2 | 1.1 |
| 1.3 | 1.1 |
| 1.4 | 1.1, 1.3 |
| 1.5 | 1.1, 1.2 |
| 1.6 | 1.2 |
| 1.7 | 1.1 |
| 1.8 | 1.1 |
| 2.1 | 1.3, 1.4 |
| 2.2 | 1.3, 1.4 |
| 2.3 | 1.3, 1.4 |
| 2.4 | 1.5, 1.6, 2.1 |
| 2.5 | 1.6, 2.1 |
| 2.6 | 1.5, 2.1, 2.2, 2.5 |
| 2.7 | 1.7, 1.8, 2.2 |
| 2.8 | 2.2, 2.6 |
| 2.9 | 2.2 |
| 3.1 | 2.1, 2.2 |
| 3.2 | 1.2, 1.6 |
| 3.3 | 1.6 |
| 3.4 | 3.1, 3.2, 3.3 |
| 3.5 | 2.3 |
| 3.6 | 3.1, 3.4, 3.5 |
| 3.7 | 3.1, 3.4, 3.5 |
| 3.8 | 3.1, 2.7 |
| 4.1 | All 1-3 |
| 4.2 | 2.4 |
| 4.3 | 1.2 |
| 4.4 | 2.1, 2.2 |
| 4.5 | All 1-3 |
| 4.6 | All 1-3 |
| 4.7 | 2, 3 |
| 4.8 | 2, 3 |
| 4.9 | 2, 3 |

---

## Ambiguous Requirements

| Requirement | Question | Default |
|-------------|----------|---------|
| Cover photo size ratio | 1:1, 16:9, or aspect-fit? | 16:9 default |
| Photo sort within day | By time ascending or user-defined? | Ascending for MVP |
| Trip with 1 photo | Show in book or just card? | Show in book (1 page) |
| Memory for whole trip | Same as memory for day 1? | Separate `date == null` memory |
| Book page count limit | 100 pages max or unlimited? | Unlimited for MVP |
| Multi-trip memories | Show all or filter by trip? | Filter by trip |

---

## Critical Path Summary

The longest dependency chain (from project start to working book viewer):

```
1.1 (init) → 1.3 (models) → 1.4 (DB) → 2.1 (trip repo) → 2.4 (home) 
→ 2.5 (form) → 2.6 (detail) → 2.7 (add photos) → 3.1 (book repo) 
→ 3.4 (viewer)
```

**Estimated time**: 1 + 2 + 1 + 2 + 3 + 2 + 2 + 3 + 3 + 3 = **22 days** for one developer.

This represents the minimum time to a working end-to-end MVP.

---

## Total Effort Estimate

| Sprint | Tasks | Total Effort |
|--------|-------|--------------|
| Sprint 1 | 8 | ~12 days |
| Sprint 2 | 9 | ~21 days |
| Sprint 3 | 8 | ~15 days |
| Sprint 4 | 9 | ~15 days |
| **Total MVP** | **34** | **~63 days** |

For 1 developer working ~4 hours/day (personal project pace), this is ~4-5 months.

With parallelization (where independent), could compress to ~45 days.

---

## Next Steps

1. Start Sprint 1, Task 1.1 — Initialize Flutter project
2. After Sprint 1, verify project builds and runs
3. Sprint 2 introduces core data flow
4. Sprint 3 delivers the main experience (book)
5. Sprint 4 polishes + tests
6. After MVP, decide on Phase 2 priorities
