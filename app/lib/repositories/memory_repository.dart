import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/memory.dart';
import '../../core/database/memory_store.dart';

final memoryRepositoryProvider = Provider<MemoryRepository>((ref) {
  return MemoryRepository(MemoryStore.instance);
});

class MemoryRepository {
  final MemoryStore _store;

  MemoryRepository(this._store);

  Future<Memory> create(Memory memory) async {
    memory.id = _store.nextId();
    _store.memorys.add(memory);
    return memory;
  }

  Future<Memory?> getById(int id) async {
    for (final m in _store.memorys) {
      if (m.id == id) return m;
    }
    return null;
  }

  Future<List<Memory>> getByTrip(int tripId) async {
    final list = _store.memorys.where((m) => m.tripId == tripId).toList()
      ..sort((a, b) {
        final ac = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bc = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return ac.compareTo(bc);
      });
    return list;
  }

  Future<Memory?> getByDate(int tripId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    for (final m in _store.memorys) {
      final d = m.date;
      if (m.tripId == tripId &&
          d != null &&
          !d.isBefore(startOfDay) &&
          d.isBefore(endOfDay)) {
        return m;
      }
    }
    return null;
  }

  Future<Memory?> getTripMemory(int tripId) async {
    for (final m in _store.memorys) {
      if (m.tripId == tripId && m.date == null) return m;
    }
    return null;
  }

  Future<Memory> update(Memory memory) async {
    final updated = memory.copyWith();
    final i = _store.memorys.indexWhere((m) => m.id == updated.id);
    if (i >= 0) _store.memorys[i] = updated;
    return updated;
  }

  Future<void> delete(int id) async {
    _store.memorys.removeWhere((m) => m.id == id);
  }
}
