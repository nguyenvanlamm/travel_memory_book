import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/trip_repository.dart';
import '../../../models/trip.dart';

final homeProvider = StateNotifierProvider<HomeNotifier, AsyncValue<List<Trip>>>((ref) {
  return HomeNotifier(ref.read(tripRepositoryProvider));
});

class HomeNotifier extends StateNotifier<AsyncValue<List<Trip>>> {
  final TripRepository _repository;
  String _sortBy = 'newest';

  HomeNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTrips();
  }

  String get sortBy => _sortBy;

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    loadTrips();
  }

  Future<void> loadTrips() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final trips = await _repository.getAll();
      return _sortTrips(trips);
    });
  }

  List<Trip> _sortTrips(List<Trip> trips) {
    switch (_sortBy) {
      case 'newest':
        return trips..sort((a, b) => b.startDate.compareTo(a.startDate));
      case 'oldest':
        return trips..sort((a, b) => a.startDate.compareTo(b.startDate));
      case 'year':
        return trips..sort((a, b) => b.startDate.year.compareTo(a.startDate.year));
      case 'country':
        return trips..sort((a, b) => a.country.compareTo(b.country));
      default:
        return trips;
    }
  }

  Future<void> createTrip(Trip trip) async {
    await _repository.create(trip);
    await loadTrips();
  }

  Future<void> deleteTrip(int id) async {
    await _repository.delete(id);
    await loadTrips();
  }
}
