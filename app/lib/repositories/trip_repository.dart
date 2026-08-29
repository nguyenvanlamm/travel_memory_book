import 'package:isar/isar.dart';
import 'package:riverpod/riverpod.dart';
import '../../models/trip.dart';
import '../../core/database/isar_provider.dart';

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepository(ref.read(isarProvider));
});

class TripRepository {
  final Future<Isar> _isarFuture;

  TripRepository(this._isarFuture);

  Future<Isar> get _isar => _isarFuture;

  Future<Trip> create(Trip trip) async {
    final isar = await _isar;
    await isar.writeTxn(() => isar.trips.put(trip));
    return trip;
  }

  Future<Trip?> getById(int id) async {
    final isar = await _isar;
    return isar.trips.get(id);
  }

  Future<List<Trip>> getAll({bool descending = true}) async {
    final isar = await _isar;
    if (descending) {
      return isar.trips.where().sortByStartDateDesc().findAll();
    }
    return isar.trips.where().sortByStartDate().findAll();
  }

  Future<Trip> update(Trip trip) async {
    final isar = await _isar;
    await isar.writeTxn(() => isar.trips.put(trip.copyWith()));
    return trip.copyWith();
  }

  Future<void> delete(int id) async {
    final isar = await _isar;
    await isar.writeTxn(() => isar.trips.delete(id));
  }

  Future<int> count() async {
    final isar = await _isar;
    return isar.trips.where().count();
  }
}
