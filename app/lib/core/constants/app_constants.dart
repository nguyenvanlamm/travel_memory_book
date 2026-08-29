class AppConstants {
  static const String appName = 'Travel Memory Book';
  static const String appTagline = 'Your journeys, preserved.';

  // Database
  static const String dbName = 'travel_memory_book.isar';

  // Storage paths
  static const String tripsDir = 'trips';
  static const String photosDir = 'photos';
  static const String thumbnailsDir = 'thumbnails';
  static const String coversDir = 'cover';

  // Thumbnail
  static const int thumbnailSize = 512;
  static const int thumbnailQuality = 85;

  // Pagination
  static const int tripsPerPage = 20;
  static const int photosPerPage = 50;

  // Animation
  static const Duration pageFlipDuration = Duration(milliseconds: 300);
  static const Duration fadeDuration = Duration(milliseconds: 200);
}
