import 'package:isar/isar.dart';

part 'travel_book.g.dart';

@collection
class TravelBook {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int tripId;

  String? coverPhoto;

  late List<BookPage> pages;

  DateTime? createdAt;

  DateTime? updatedAt;

  TravelBook({
    required this.tripId,
    required this.pages,
    this.coverPhoto,
    this.createdAt,
    this.updatedAt,
  });

  TravelBook.empty();

  TravelBook copyWith({
    int? tripId,
    String? coverPhoto,
    List<BookPage>? pages,
  }) {
    return TravelBook(
      tripId: tripId ?? this.tripId,
      coverPhoto: coverPhoto ?? this.coverPhoto,
      pages: pages ?? this.pages,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

@embedded
class BookPage {
  String? type;
  int? dayNumber;
  int? photoId;
  String? title;
  String? subtitle;
  String? body;
  int? order;

  BookPage({
    this.type,
    this.dayNumber,
    this.photoId,
    this.title,
    this.subtitle,
    this.body,
    this.order,
  });

  BookPage.empty();

  static BookPage cover({required int order, String? coverPhoto}) {
    return BookPage(
      type: 'cover',
      order: order,
      title: coverPhoto != null ? 'Cover' : null,
    );
  }

  static BookPage day({required int order, required int dayNumber, required String dateStr}) {
    return BookPage(
      type: 'day',
      order: order,
      dayNumber: dayNumber,
      title: 'Day $dayNumber',
      subtitle: dateStr,
    );
  }

  static BookPage photo({required int order, required int photoId, String? caption}) {
    return BookPage(
      type: 'photo',
      order: order,
      photoId: photoId,
      body: caption,
    );
  }

  static BookPage memory({required int order, String? title, required String content, DateTime? date}) {
    return BookPage(
      type: date == null ? 'trip_memory' : 'memory',
      order: order,
      title: title ?? (date == null ? 'My Memory' : 'Daily Journal'),
      body: content,
    );
  }
}
