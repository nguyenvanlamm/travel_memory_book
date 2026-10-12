import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/memory_file_store.dart';

/// A colour in OKLCH (perceptual lightness, chroma, hue in degrees).
@immutable
class Oklch {
  final double l, c, h;
  const Oklch(this.l, this.c, this.h);

  static double _toLinear(double v) =>
      v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  static double _toSrgb(double v) => v <= 0.0031308
      ? 12.92 * v
      : 1.055 * math.pow(v, 1 / 2.4).toDouble() - 0.055;
  static double _cbrt(double v) =>
      v < 0 ? -math.pow(-v, 1 / 3).toDouble() : math.pow(v, 1 / 3).toDouble();

  /// OKLab (L, a, b) of an sRGB colour with channels in 0..1.
  static (double, double, double) labOf(double r, double g, double b) {
    r = _toLinear(r);
    g = _toLinear(g);
    b = _toLinear(b);
    final l = _cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b);
    final m = _cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b);
    final s = _cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b);
    return (
      0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
      1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
      0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s,
    );
  }

  factory Oklch.fromColor(Color c) {
    final (l, a, b) = labOf(c.r, c.g, c.b);
    return Oklch.fromLab(l, a, b);
  }

  factory Oklch.fromLab(double l, double a, double b) =>
      Oklch(l, math.sqrt(a * a + b * b), (math.atan2(b, a) * 180 / math.pi + 360) % 360);

  (double, double, double)? _rgb(double chroma) {
    final rad = h * math.pi / 180;
    final a = chroma * math.cos(rad), b = chroma * math.sin(rad);
    final l_ = l + 0.3963377774 * a + 0.2158037573 * b;
    final m_ = l - 0.1055613458 * a - 0.0638541728 * b;
    final s_ = l - 0.0894841775 * a - 1.2914855480 * b;
    final lc = l_ * l_ * l_, mc = m_ * m_ * m_, sc = s_ * s_ * s_;
    final r = 4.0767416621 * lc - 3.3077115913 * mc + 0.2309699292 * sc;
    final g = -1.2684380046 * lc + 2.6097574011 * mc - 0.3413193965 * sc;
    final bb = -0.0041960863 * lc - 0.7034186147 * mc + 1.7076956010 * sc;
    const e = 1e-4;
    if ([r, g, bb].any((v) => v < -e || v > 1 + e)) return null;
    return (_toSrgb(r.clamp(0, 1)), _toSrgb(g.clamp(0, 1)), _toSrgb(bb.clamp(0, 1)));
  }

  /// sRGB colour; chroma is reduced until it fits the gamut.
  Color toColor() {
    var chroma = c;
    while (true) {
      final rgb = _rgb(chroma);
      if (rgb != null) return Color.from(alpha: 1, red: rgb.$1, green: rgb.$2, blue: rgb.$3);
      chroma -= 0.005;
      if (chroma <= 0) {
        final g = _rgb(0)!;
        return Color.from(alpha: 1, red: g.$1, green: g.$2, blue: g.$3);
      }
    }
  }
}

/// The cloth of one book, derived from its cover photo
/// (rules in design-demos/b-tokens.md §2).
class BookCloth {
  /// Spine, mini-book, colour chip — light theme.
  final Color cloth;

  /// [cloth] in the dark theme (L −.03, C ×.95).
  final Color clothDark;

  /// Selected-book pane, trip header, selected row. Same in both themes.
  final Color deep;

  /// Secondary text on [deep].
  final Color mute;

  const BookCloth({
    required this.cloth,
    required this.clothDark,
    required this.deep,
    required this.mute,
  });

  static const _parch = Color(0xFFF3EAD9);

  factory BookCloth.fromOklch(Oklch o) {
    final c = Oklch(o.l.clamp(0.42, 0.64), o.c.clamp(0.03, 0.14), o.h);
    final cloth = c.toColor();
    // mute = parchment with 30% of the cloth, mixed in OKLab.
    final (pl, pa, pb) = Oklch.labOf(_parch.r, _parch.g, _parch.b);
    final (cl, ca, cb) = Oklch.labOf(cloth.r, cloth.g, cloth.b);
    return BookCloth(
      cloth: cloth,
      clothDark: Oklch(c.l - 0.03, c.c * 0.95, c.h).toColor(),
      deep: Oklch(0.255, math.min(c.c * 0.6, 0.035), c.h).toColor(),
      mute: Oklch.fromLab(
        pl * 0.7 + cl * 0.3,
        pa * 0.7 + ca * 0.3,
        pb * 0.7 + cb * 0.3,
      ).toColor(),
    );
  }

  /// A book without a cover photo yet: brand earth.
  static const earth = BookCloth(
    cloth: Color(0xFF63453A),
    clothDark: Color(0xFF593D33),
    deep: Color(0xFF2E1E19),
    mute: Color(0xFFC6B5A6),
  );

  /// [cloth] for the current theme.
  Color of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? clothDark : cloth;
}

/// Pick the strongest hue family of the cover and average its most
/// saturated third.
Future<BookCloth?> _sample(Uint8List bytes) async {
  final codec =
      await ui.instantiateImageCodec(bytes, targetWidth: 64, targetHeight: 64);
  final frame = await codec.getNextFrame();
  final data = await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);
  frame.image.dispose();
  if (data == null) return null;

  final bins = List.generate(12, (_) => <(double, double, double, double)>[]);
  for (var i = 0; i + 3 < data.lengthInBytes; i += 4) {
    final (l, a, b) = Oklch.labOf(data.getUint8(i) / 255,
        data.getUint8(i + 1) / 255, data.getUint8(i + 2) / 255);
    if (l < 0.15 || l > 0.92) continue; // shadow and blown-out sky
    final o = Oklch.fromLab(l, a, b);
    if (o.c < 0.02) continue;
    bins[(o.h ~/ 30) % 12].add((l, a, b, o.c));
  }
  final best = bins.reduce((x, y) =>
      x.fold(0.0, (s, p) => s + p.$4) >= y.fold(0.0, (s, p) => s + p.$4) ? x : y);
  if (best.isEmpty) return null;
  best.sort((x, y) => y.$4.compareTo(x.$4));
  final top = best.take(math.max(1, best.length ~/ 3)).toList();
  double avg(double Function((double, double, double, double)) f) =>
      top.fold(0.0, (s, p) => s + f(p)) / top.length;
  return BookCloth.fromOklch(
      Oklch.fromLab(avg((p) => p.$1), avg((p) => p.$2), avg((p) => p.$3)));
}

/// Cloth for a book, keyed by trip id and cover path. Kept for the session.
final bookClothProvider =
    FutureProvider.family<BookCloth, ({int tripId, String? cover})>(
        (ref, key) async {
  final bytes = MemoryFileStore.read(key.cover);
  if (bytes != null) {
    try {
      final sampled = await _sample(bytes);
      if (sampled != null) return sampled;
    } catch (_) {
      // Undecodable cover: fall through to earth.
    }
  }
  return BookCloth.earth;
});
