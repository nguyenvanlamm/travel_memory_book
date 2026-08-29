import 'package:isar/isar.dart';
import 'package:riverpod/riverpod.dart';
import '../../models/travel_book.dart';
import '../../models/photo.dart';
import 'photo_repository.dart';
import 'memory_repository.dart';
import 'trip_repository.dart';
import '../../core/database/isar_provider.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository(
    ref.read(isarProvider),
    ref.read(photoRepositoryProvider),
    ref.read(memoryRepositoryProvider),
    ref.read(tripRepositoryProvider),
  );
});

class BookRepository {
  final Future<Isar> _isarFuture;
  final PhotoRepository _photoRepo;
  final MemoryRepository _memoryRepo;
  final TripRepository _tripRepo;

  BookRepository(this._isarFuture, this._photoRepo, this._memoryRepo, this._tripRepo);

  Future<Isar> get _isar => _isarFuture;

  Future<TravelBook?> getByTrip(int tripId) async {
    final isar = await _isar;
    return isar.travelBooks.filter().tripIdEqualTo(tripId).findFirst();
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

    final isar = await _isar;
    await isar.writeTxn(() => isar.travelBooks.put(book));
    return book;
  }

  Future<TravelBook> regenerate(int tripId) async {
    final isar = await _isar;
    await isar.writeTxn(() => isar.travelBooks.filter().tripIdEqualTo(tripId).deleteAll());
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
