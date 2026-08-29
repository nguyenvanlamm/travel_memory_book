# Idea: Travel Memory Book

## Core Concept
A **personal Flutter app** that turns each of the user's trips into a **digital photo book** they can flip through, years later, to relive memories.

## Differentiator
This is **NOT a social network**. No likes, no comments, no followers, no feed, no sharing. The only audience is the user themselves.

## Primary Value
> "Many years from now, I can open this app, pick an old trip, and feel like I'm reading back a part of my life."

## Key Features (MVP)
1. **Home / My Travel Books** — a library of trip books
2. **Create Trip** — name, location, dates, description, cover
3. **Add Photos** — multi-select from gallery or camera
4. **Photo Timeline** — auto-sort by date, group by day
5. **Travel Book** — assemble photos into a book
6. **Book Viewer** — flip through pages like a real book
7. **Memory / Journal** — write notes per trip / per day / per place / per photo
8. **Photo Detail** — view photo with metadata, location, caption
9. **Local Storage** — fully offline-first, no backend needed for MVP

## Target User
The developer (Lãm) himself, and personal users who:
- Travel regularly
- Take lots of photos
- Want a private place to revisit memories
- Don't want another social app

## Style
**Premium Personal Travel Journal** — warm, personal, minimal, cinematic, nostalgic. Like a coffee-table photo book, not Instagram.

## Architecture
- Flutter (Dart)
- Riverpod state management
- Local DB (Isar or SQLite)
- Local file storage
- No backend, no auth, no cloud in MVP
- Phase 2: map, calendar, statistics, search, EXIF
- Phase 3: cloud backup, AI captions, print-on-demand
