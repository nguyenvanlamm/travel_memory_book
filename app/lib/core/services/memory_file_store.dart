import 'dart:typed_data';
import 'package:uuid/uuid.dart';

/// In-memory file store. Picked/imported images are kept here for the
/// duration of the session — nothing is written to disk or uploaded.
/// Keys look like `mem://trips/1/photos/x.jpg`.
class MemoryFileStore {
  MemoryFileStore._();
  static final Map<String, Uint8List> files = {};
  static const _uuid = Uuid();

  static String put(String dirPath, String extension, Uint8List bytes) {
    final path = 'mem://$dirPath/${_uuid.v4()}.$extension';
    files[path] = bytes;
    return path;
  }

  static String putNamed(String path, Uint8List bytes) {
    files[path] = bytes;
    return path;
  }

  static Uint8List? read(String? path) => path == null ? null : files[path];

  static bool exists(String? path) => path != null && files.containsKey(path);

  static void remove(String? path) {
    if (path != null) files.remove(path);
  }
}
