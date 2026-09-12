import 'package:exif/exif.dart';

class ExifData {
  final DateTime? dateTaken;
  final double? latitude;
  final double? longitude;
  final String? camera;
  final String? lens;
  final int? iso;
  final String? shutter;
  final String? aperture;

  ExifData({this.dateTaken, this.latitude, this.longitude, this.camera, this.lens, this.iso, this.shutter, this.aperture});
}

class ExifService {
  Future<ExifData?> readExif(List<int> bytes) async {
    try {
      final tags = await readExifFromBytes(bytes);
      if (tags.isEmpty) return null;

      DateTime? dateTaken;
      if (tags['EXIF DateTimeOriginal'] != null) {
        dateTaken = _parseDate(tags['EXIF DateTimeOriginal']!.printable);
      } else if (tags['EXIF DateTimeDigitized'] != null) {
        dateTaken = _parseDate(tags['EXIF DateTimeDigitized']!.printable);
      } else if (tags['Image DateTime'] != null) {
        dateTaken = _parseDate(tags['Image DateTime']!.printable);
      }

      double? lat, lon;
      if (tags['GPS GPSLatitude'] != null && tags['GPS GPSLongitude'] != null) {
        lat = _parseGpsCoord(tags['GPS GPSLatitude']!, tags['GPS GPSLatitudeRef']!);
        lon = _parseGpsCoord(tags['GPS GPSLongitude']!, tags['GPS GPSLongitudeRef']!);
      }

      return ExifData(
        dateTaken: dateTaken,
        latitude: lat,
        longitude: lon,
        camera: tags['Image Model']?.printable,
        lens: tags['EXIF LensModel']?.printable,
        iso: int.tryParse(tags['EXIF ISOSpeedRatings']?.printable ?? ''),
        shutter: tags['EXIF ExposureTime']?.printable,
        aperture: tags['EXIF FNumber']?.printable,
      );
    } catch (e) {
      return null;
    }
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null) return null;
    try {
      return DateTime.parse(dateStr.replaceAll(':', '-'));
    } catch (_) {
      return null;
    }
  }

  double _parseGpsCoord(dynamic coord, dynamic ref) {
    final parts = coord.toString().split(', ');
    if (parts.length != 3) return 0.0;
    final deg = double.parse(parts[0].trim());
    final min = double.parse(parts[1].trim());
    final secStr = parts[2].trim();
    double sec;
    if (secStr.contains('/')) {
      final parts2 = secStr.split('/');
      sec = double.parse(parts2[0]) / double.parse(parts2[1]);
    } else {
      sec = double.parse(secStr);
    }
    var result = deg + min / 60 + sec / 3600;
    final refStr = ref.toString().trim();
    if (refStr == 'S' || refStr == 'W') result = -result;
    return result;
  }
}
