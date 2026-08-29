import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class FileService {
  final _uuid = const Uuid();

  Future<String> get _appDir async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<String> copyToTripPhotos(int tripId, String sourcePath) async {
    final appDir = await _appDir;
    final destDir = Directory('$appDir/trips/$tripId/photos');
    if (!await destDir.exists()) await destDir.create(recursive: true);
    final ext = sourcePath.split('.').last;
    final destPath = '$appDir/trips/$tripId/photos/${_uuid.v4()}.$ext';
    await File(sourcePath).copy(destPath);
    return destPath;
  }

  Future<String> copyToTripCover(int tripId, String sourcePath) async {
    final appDir = await _appDir;
    final destDir = Directory('$appDir/trips/$tripId/cover');
    if (!await destDir.exists()) await destDir.create(recursive: true);
    final ext = sourcePath.split('.').last;
    final destPath = '$appDir/trips/$tripId/cover/cover.$ext';
    await File(sourcePath).copy(destPath);
    return destPath;
  }

  Future<String> generateThumbnail(String sourcePath, int tripId) async {
    final appDir = await _appDir;
    final destDir = Directory('$appDir/trips/$tripId/thumbnails');
    if (!await destDir.exists()) await destDir.create(recursive: true);
    final image = img.decodeImage(File(sourcePath).readAsBytesSync());
    if (image == null) return sourcePath;
    final thumbnail = img.copyResize(image, width: 512, height: 512);
    final destPath = '$appDir/trips/$tripId/thumbnails/thumb_${_uuid.v4()}.jpg';
    await File(destPath).writeAsBytes(img.encodeJpg(thumbnail, quality: 85));
    return destPath;
  }
}
