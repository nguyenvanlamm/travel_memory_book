

class Photo {
  int id = 0;

  late int tripId;

  late String filePath;

  late String thumbnailPath;

  late DateTime takenAt;

  double? latitude;

  double? longitude;

  String? locationName;

  String? caption;

  late int day;

  late int sortOrder;

  Photo({
    required this.tripId,
    required this.filePath,
    required this.thumbnailPath,
    required this.takenAt,
    this.latitude,
    this.longitude,
    this.locationName,
    this.caption,
    required this.day,
    required this.sortOrder,
  });

  Photo.empty();

  Photo copyWith({
    int? tripId,
    String? filePath,
    String? thumbnailPath,
    DateTime? takenAt,
    double? latitude,
    double? longitude,
    String? locationName,
    String? caption,
    int? day,
    int? sortOrder,
  }) {
    return Photo(
      tripId: tripId ?? this.tripId,
      filePath: filePath ?? this.filePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      takenAt: takenAt ?? this.takenAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      caption: caption ?? this.caption,
      day: day ?? this.day,
      sortOrder: sortOrder ?? this.sortOrder,
    )..id = id;
  }

  bool get hasLocation => latitude != null && longitude != null;
}
