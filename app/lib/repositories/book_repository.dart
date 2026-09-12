import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/travel_book.dart';
import '../../models/photo.dart';
import 'photo_repository.dart';
import 'memory_repository.dart';
import 'trip_repository.dart';
import '../../core/database/memory_store.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository(
    MemoryStore.instance,
    ref.read(photoRepositoryProvider),
    ref.read(memoryRepositoryProvider),
    ref.read(tripRepositoryProvider),
  );
});

class BookRepository {
  final MemoryStore _store;
  final PhotoRepository _photoRepo;
  final MemoryRepository _memoryRepo;
  final TripRepository _tripRepo;

  BookRepository(this._store, this._photoRepo, this._memoryRepo, this._tripRepo);

  Future<TravelBook?> getByTrip(int tripId) async {
    for (final b in _store.travelBooks) {
      if (b.tripId == tripId) return b;
    }
    return null;
  }

  Future<TravelBook> assemble(int tripId) async {
    final trip = await _tripRepo.getById(tripId);
    if (trip == null) throw Exception('Trip not found');

    final photos = await _photoRepo.getByTrip(tripId);
    final memories = await _memoryRepo.getByTrip(tripId);
    final tripMemory = await _memoryRepo.getTripMemory(tripId);

    final pages = <BookPage>[];
    int order = 0;

    // Cover page
    pages.add(BookPage.cover(order: order++, coverPhoto: trip.coverPhotoPath));

    // Group photos by day
    final photosByDay = <int, List<Photo>>{};
    for (final photo in photos) {
      photosByDay.putIfAbsent(photo.day, () => []).add(photo);
    }

    final sortedDays = photosByDay.keys.toList()..sort();

    for (final day in sortedDays) {
      final dayPhotos = photosByDay[day]!;
      final dayStart = trip.startDate.add(Duration(days: day - 1));

      // Day header page
      pages.add(BookPage.day(
        order: order++,
        dayNumber: day,
        dateStr: '${dayStart.day} ${_monthName(dayStart.month)} ${dayStart.year}',
      ));

      // Photo pages for this day
      for (final photo in dayPhotos) {
        pages.add(BookPage.photo(
          order: order++,
          photoId: photo.id,
          caption: photo.caption,
        ));
      }

      // Day memory if exists
      final dayMemory = memories.where((m) => m.date != null && _isSameDay(m.date!, dayStart)).firstOrNull;
      if (dayMemory != null) {
        pages.add(BookPage.memory(
          order: order++,
          title: dayMemory.title,
          content: dayMemory.content,
          date: dayMemory.date,
        ));
      }
    }

    // Trip memory at the end
    if (tripMemory != null) {
      pages.add(BookPage.memory(
        order: order++,
        title: tripMemory.title,
        content: tripMemory.content,
        date: null,
      ));
    }

    final book = TravelBook(
      tripId: tripId,
      coverPhoto: trip.coverPhotoPath,
      pages: pages,
    );

    book.id = _store.nextId();
    _store.travelBooks.removeWhere((b) => b.tripId == tripId);
    _store.travelBooks.add(book);
    return book;
  }

  Future<TravelBook> regenerate(int tripId) async {
    _store.travelBooks.removeWhere((b) => b.tripId == tripId);
    return assemble(tripId);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
