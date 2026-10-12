import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/memory.dart';
import '../../../models/photo.dart';
import '../../../models/trip.dart';
import '../../../repositories/memory_repository.dart';
import '../../../repositories/photo_repository.dart';
import '../../../repositories/trip_repository.dart';

/// One day of a trip, shown as a chapter of its book.
class ChapterSummary {
  final int day;
  final DateTime date;
  final List<Photo> photos;

  /// Memories dated on this day, oldest first.
  final List<Memory> memories;

  const ChapterSummary({
    required this.day,
    required this.date,
    required this.photos,
    this.memories = const [],
  });

  int get photoCount => photos.length;
  Memory? get memory => memories.firstOrNull;
  bool get hasMemory => memories.isNotEmpty;
  String? get thumbnailPath => photos.isEmpty ? null : photos.first.thumbnailPath;

  /// Up to two place names read from the day's photos.
  String? get places {
    final names = <String>[];
    for (final p in photos) {
      final n = p.locationName?.trim();
      if (n != null && n.isNotEmpty && !names.contains(n)) names.add(n);
      if (names.length == 2) break;
    }
    return names.isEmpty ? null : names.join(' · ');
  }

  /// What the chapter is called: the memory's title, else its places.
  String get title => memory?.title ?? places ?? 'Day $day';
}

/// Read-only view of a trip with the counts the library and book pages show.
class TripSummary {
  final Trip trip;
  final List<ChapterSummary> chapters;
  final List<Photo> photos;
  final List<Memory> memories;

  const TripSummary({
    required this.trip,
    required this.chapters,
    required this.photos,
    required this.memories,
  });

  int get photoCount => photos.length;
  int get memoryCount => memories.length;
  int get dayCount => chapters.length;
  int get placeCount => trip.cities.length;
  List<ChapterSummary> get unwrittenChapters =>
      chapters.where((c) => !c.hasMemory).toList();
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

Future<TripSummary> _summarise(Ref ref, Trip trip) async {
  final photos = await ref.read(photoRepositoryProvider).getByTrip(trip.id);
  final memories = await ref.read(memoryRepositoryProvider).getByTrip(trip.id);
  final start = DateTime(trip.startDate.year, trip.startDate.month, trip.startDate.day);
  final chapters = <ChapterSummary>[
    for (var day = 1; day <= trip.durationInDays; day++)
      () {
        final date = start.add(Duration(days: day - 1));
        return ChapterSummary(
          day: day,
          date: date,
          photos: photos.where((p) => p.day == day).toList(),
          memories: memories
              .where((m) => m.date != null && _sameDay(m.date!, date))
              .toList(),
        );
      }(),
  ];
  return TripSummary(
    trip: trip,
    chapters: chapters,
    photos: photos,
    memories: memories,
  );
}

/// Summary of one trip; invalidate it after writing a memory or adding photos.
final tripSummaryProvider =
    FutureProvider.autoDispose.family<TripSummary?, int>((ref, tripId) async {
  final trip = await ref.read(tripRepositoryProvider).getById(tripId);
  if (trip == null) return null;
  return _summarise(ref, trip);
});

/// Totals across the whole library (books, days, countries, photos, memories).
class LibraryTotals {
  final int books;
  final int days;
  final int countries;
  final int photos;
  final int memories;

  /// Days and photos per year shelf.
  final Map<int, ({int days, int photos})> byYear;

  /// Books per country, most books first.
  final Map<String, int> byCountry;

  const LibraryTotals({
    required this.books,
    required this.days,
    required this.countries,
    required this.photos,
    required this.memories,
    this.byYear = const {},
    this.byCountry = const {},
  });
}

final libraryTotalsProvider =
    FutureProvider.autoDispose<LibraryTotals>((ref) async {
  final trips = await ref.read(tripRepositoryProvider).getAll();
  final summaries = [for (final t in trips) await _summarise(ref, t)];
  final byYear = <int, ({int days, int photos})>{};
  final countries = <String, int>{};
  for (final s in summaries) {
    final y = s.trip.startDate.year;
    final prev = byYear[y] ?? (days: 0, photos: 0);
    byYear[y] = (days: prev.days + s.dayCount, photos: prev.photos + s.photoCount);
    final c = s.trip.country.trim();
    if (c.isNotEmpty) countries[c] = (countries[c] ?? 0) + 1;
  }
  final byCountry = Map.fromEntries(
      countries.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
  return LibraryTotals(
    byYear: byYear,
    byCountry: byCountry,
    books: trips.length,
    days: summaries.fold(0, (sum, s) => sum + s.dayCount),
    countries: trips.map((t) => t.country.trim().toLowerCase()).toSet().length,
    photos: summaries.fold(0, (sum, s) => sum + s.photoCount),
    memories: summaries.fold(0, (sum, s) => sum + s.memoryCount),
  );
});

/// Year shelf chosen in the drawer; null shows every book.
final libraryYearProvider = StateProvider<int?>((ref) => null);

/// Book shown in the library's detail pane; null means the first in the list.
final selectedBookProvider = StateProvider<int?>((ref) => null);

/// Library search text (title, place, country).
final librarySearchProvider = StateProvider<String>((ref) => '');
