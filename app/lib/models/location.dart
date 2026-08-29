import 'package:isar/isar.dart';

part 'location.g.dart';

@collection
class Location {
  Id id = Isar.autoIncrement;

  @Index()
  late int tripId;

  late String name;

  double? latitude;

  double? longitude;

  String? description;

  Location({
    required this.tripId,
    required this.name,
    this.latitude,
    this.longitude,
    this.description,
  });

  bool get hasCoordinates => latitude != null && longitude != null;
}
