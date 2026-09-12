import '../../models/trip.dart';
import '../../models/photo.dart';
import '../../models/memory.dart';
import '../../models/travel_book.dart';

/// In-memory database for the app. Data lives for the current session only —
/// the app does not persist anything to disk or the cloud.
class MemoryStore {
  MemoryStore._();
  static final MemoryStore instance = MemoryStore._();

  final List<Trip> trips = [];
  final List<Photo> photos = [];
  final List<Memory> memorys = [];
  final List<TravelBook> travelBooks = [];

  int _nextId = 1;
  int nextId() => _nextId++;
}
