import 'package:isar/isar.dart';

part 'trip.g.dart';

@collection
class Trip {
  Id id = Isar.autoIncrement;

  @Index()
  late String title;

  late String description;

  String? coverPhotoPath;

  @Index()
  late DateTime startDate;

  late DateTime endDate;

  late String country;

  late List<String> cities;

  @Index()
  DateTime? createdAt;

  DateTime? updatedAt;

  Trip({
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.country,
    required this.cities,
    this.coverPhotoPath,
    this.createdAt,
    this.updatedAt,
  });

  Trip.empty();

  Trip copyWith({
    String? title,
    String? description,
    String? coverPhotoPath,
    DateTime? startDate,
    DateTime? endDate,
    String? country,
    List<String>? cities,
  }) {
    return Trip(
      title: title ?? this.title,
      description: description ?? this.description,
      coverPhotoPath: coverPhotoPath ?? this.coverPhotoPath,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      country: country ?? this.country,
      cities: cities ?? this.cities,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  int get durationInDays => endDate.difference(startDate).inDays + 1;

  String get formattedDates {
    if (startDate.year == endDate.year) {
      if (startDate.month == endDate.month) {
        return '${startDate.day} – ${endDate.day} ${_monthName(startDate.month)} ${startDate.year}';
      }
      return '${startDate.day} ${_monthName(startDate.month)} – ${endDate.day} ${_monthName(endDate.month)} ${endDate.year}';
    }
    return '${startDate.day} ${_monthName(startDate.month)} ${startDate.year} – ${endDate.day} ${_monthName(endDate.month)} ${endDate.year}';
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
