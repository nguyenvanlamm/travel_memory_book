import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/trip.dart';
import '../../core/database/memory_store.dart';

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepository(MemoryStore.instance);
});

class TripRepository {
  final MemoryStore _store;

  TripRepository(this._store);

  Future<Trip> create(Trip trip) async {
    trip.id = _store.nextId();
    _store.trips.add(trip);
    return trip;
  }

  Future<Trip?> getById(int id) async {
    for (final t in _store.trips) {
      if (t.id == id) return t;
    }
    return null;
  }

  Future<List<Trip>> getAll({bool descending = true}) async {
    final trips = List<Trip>.of(_store.trips)
      ..sort((a, b) => descending
          ? b.startDate.compareTo(a.startDate)
          : a.startDate.compareTo(b.startDate));
    return trips;
  }

  Future<Trip> update(Trip trip) async {
    final updated = trip.copyWith();
    final i = _store.trips.indexWhere((t) => t.id == updated.id);
    if (i >= 0) _store.trips[i] = updated;
    return updated;
  }

  Future<void> delete(int id) async {
    _store.trips.removeWhere((t) => t.id == id);
  }

  Future<int> count() async => _store.trips.length;
}
