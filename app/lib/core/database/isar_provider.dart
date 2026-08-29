import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod/riverpod.dart';
import '../../models/trip.dart';
import '../../models/photo.dart';
import '../../models/memory.dart';
import '../../models/location.dart';
import '../../models/travel_book.dart';

final isarProvider = Provider<Future<Isar>>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [TripSchema, PhotoSchema, MemorySchema, LocationSchema, TravelBookSchema],
    directory: dir.path,
    inspector: true,
  );
});
