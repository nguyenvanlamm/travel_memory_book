

class Memory {
  int id = 0;

  late int tripId;

  DateTime? date;

  String? title;

  late String content;

  int? locationId;

  DateTime? createdAt;

  DateTime? updatedAt;

  Memory({
    required this.tripId,
    required this.content,
    this.date,
    this.title,
    this.locationId,
    this.createdAt,
    this.updatedAt,
  });

  Memory.empty();

  bool get isTripMemory => date == null;

  Memory copyWith({
    int? tripId,
    DateTime? date,
    String? title,
    String? content,
    int? locationId,
  }) {
    return Memory(
      tripId: tripId ?? this.tripId,
      date: date ?? this.date,
      title: title ?? this.title,
      content: content ?? this.content,
      locationId: locationId ?? this.locationId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    )..id = id;
  }
}
