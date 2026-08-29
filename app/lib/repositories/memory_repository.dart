import 'package:isar/isar.dart';
import 'package:riverpod/riverpod.dart';
import '../../models/memory.dart';
import '../../core/database/isar_provider.dart';

final memoryRepositoryProvider = Provider<MemoryRepository>((ref) {
  return MemoryRepository(ref.read(isarProvider));
});

class MemoryRepository {
  final Future<Isar> _isarFuture;

  MemoryRepository(this._isarFuture);

  Future<Isar> get _isar => _isarFuture;

  Future<Memory> create(Memory memory) async {
    final isar = await _isar;
    await isar.writeTxn(() => isar.memorys.put(memory));
    return memory;
  }

  Future<Memory?> getById(int id) async {
    final isar = await _isar;
    return isar.memorys.get(id);
  }

  Future<List<Memory>> getByTrip(int tripId) async {
    final isar = await _isar;
    return isar.memorys.filter().tripIdEqualTo(tripId).sortByCreatedAt().findAll();
  }

  Future<Memory?> getByDate(int tripId, DateTime date) async {
    final isar = await _isar;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return isar.memorys
        .filter()
        .tripIdEqualTo(tripId)
        .dateBetween(startOfDay, endOfDay)
        .findFirst();
  }

  Future<Memory?> getTripMemory(int tripId) async {
    final isar = await _isar;
    return isar.memorys.filter().tripIdEqualTo(tripId).dateIsNull().findFirst();
  }

  Future<Memory> update(Memory memory) async {
    final isar = await _isar;
    await isar.writeTxn(() => isar.memorys.put(memory.copyWith()));
    return memory.copyWith();
  }

  Future<void> delete(int id) async {
    final isar = await _isar;
    await isar.writeTxn(() => isar.memorys.delete(id));
  }
}
