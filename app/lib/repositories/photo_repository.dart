import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/photo.dart';
import '../../core/database/memory_store.dart';

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  return PhotoRepository(MemoryStore.instance);
});

class PhotoRepository {
  final MemoryStore _store;

  PhotoRepository(this._store);

  Future<Photo> create(Photo photo) async {
    photo.id = _store.nextId();
    _store.photos.add(photo);
    return photo;
  }

  Future<Photo?> getById(int id) async {
    for (final p in _store.photos) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<List<Photo>> getByTrip(int tripId, {bool descending = false}) async {
    final photos = _store.photos.where((p) => p.tripId == tripId).toList()
      ..sort((a, b) => descending
          ? b.takenAt.compareTo(a.takenAt)
          : a.takenAt.compareTo(b.takenAt));
    return photos;
  }

  Future<List<Photo>> getByDay(int tripId, int day) async {
    final photos = _store.photos
        .where((p) => p.tripId == tripId && p.day == day)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return photos;
  }

  Future<Photo> update(Photo photo) async {
    final updated = photo.copyWith();
    final i = _store.photos.indexWhere((p) => p.id == updated.id);
    if (i >= 0) _store.photos[i] = updated;
    return updated;
  }

  Future<void> delete(int id) async {
    _store.photos.removeWhere((p) => p.id == id);
  }

  Future<int> countByTrip(int tripId) async {
    return _store.photos.where((p) => p.tripId == tripId).length;
  }
}
