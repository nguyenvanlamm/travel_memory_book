import 'package:isar/isar.dart';
import 'package:riverpod/riverpod.dart';
import '../../models/photo.dart';
import '../../core/database/isar_provider.dart';

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  return PhotoRepository(ref.read(isarProvider));
});

class PhotoRepository {
  final Future<Isar> _isarFuture;

  PhotoRepository(this._isarFuture);

  Future<Isar> get _isar => _isarFuture;

  Future<Photo> create(Photo photo) async {
    final isar = await _isar;
    await isar.writeTxn(() => isar.photos.put(photo));
    return photo;
  }

  Future<Photo?> getById(int id) async {
    final isar = await _isar;
    return isar.photos.get(id);
  }

  Future<List<Photo>> getByTrip(int tripId, {bool descending = false}) async {
    final isar = await _isar;
    if (descending) {
      return isar.photos.filter().tripIdEqualTo(tripId).sortByTakenAtDesc().findAll();
    }
    return isar.photos.filter().tripIdEqualTo(tripId).sortByTakenAt().findAll();
  }

  Future<List<Photo>> getByDay(int tripId, int day) async {
    final isar = await _isar;
    return isar.photos
        .filter()
        .tripIdEqualTo(tripId)
        .dayEqualTo(day)
        .sortBySortOrder()
        .findAll();
  }

  Future<Photo> update(Photo photo) async {
    final isar = await _isar;
    await isar.writeTxn(() => isar.photos.put(photo.copyWith()));
    return photo.copyWith();
  }

  Future<void> delete(int id) async {
    final isar = await _isar;
    await isar.writeTxn(() => isar.photos.delete(id));
  }

  Future<int> countByTrip(int tripId) async {
    final isar = await _isar;
    return isar.photos.filter().tripIdEqualTo(tripId).count();
  }
}
