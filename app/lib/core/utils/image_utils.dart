import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Decode [bytes] and return a JPEG thumbnail (max 512px), or null if the
/// image cannot be decoded.
Uint8List? makeThumbnail(Uint8List bytes) {
  final image = img.decodeImage(bytes);
  if (image == null) return null;
  final thumbnail = img.copyResize(image, width: 512, height: 512);
  return img.encodeJpg(thumbnail, quality: 85);
}
