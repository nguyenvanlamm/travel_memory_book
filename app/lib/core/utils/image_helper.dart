import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/memory_file_store.dart';
import 'package:lucide_icons/lucide_icons.dart';

bool _isUrl(String path) =>
    path.startsWith('blob:') ||
    path.startsWith('http:') ||
    path.startsWith('https:') ||
    path.startsWith('data:');

/// Whether an image can be displayed for [path].
bool appFileExists(String? path) =>
    path != null &&
    path.isNotEmpty &&
    (_isUrl(path) || MemoryFileStore.exists(path));

/// Display an image stored in [MemoryFileStore] or at a blob/http [path].
Widget appImage(
  String? path, {
  BoxFit? fit,
  double? width,
  double? height,
  Color? color,
  BlendMode? colorBlendMode,
  Widget? fallback,
}) {
  Widget fb() => fallback ?? const Icon(LucideIcons.imageOff, size: 64);
  if (path == null || path.isEmpty) return fb();

  final bytes = MemoryFileStore.read(path);
  if (bytes != null) {
    return Image.memory(
      bytes,
      fit: fit,
      width: width,
      height: height,
      color: color,
      colorBlendMode: colorBlendMode,
      errorBuilder: (_, __, ___) => fb(),
    );
  }
  if (_isUrl(path)) {
    return Image.network(
      path,
      fit: fit,
      width: width,
      height: height,
      color: color,
      colorBlendMode: colorBlendMode,
      errorBuilder: (_, __, ___) => fb(),
    );
  }
  return fb();
}

/// Display a picked [XFile] (preview before it is stored).
Widget xfileImage(
  XFile file, {
  BoxFit? fit,
  double? width,
  double? height,
}) {
  return FutureBuilder<Uint8List>(
    future: file.readAsBytes(),
    builder: (context, snapshot) {
      final bytes = snapshot.data;
      if (bytes == null) {
        return const ColoredBox(color: Color(0x11000000));
      }
      return Image.memory(
        bytes,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => const Icon(LucideIcons.imageOff, size: 64),
      );
    },
  );
}
