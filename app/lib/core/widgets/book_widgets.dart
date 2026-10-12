import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../models/trip.dart';
import '../theme/app_theme.dart';
import '../theme/book_cloth.dart';
import '../utils/image_helper.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// Cloth for [trip], falling back while its cover is being sampled.
BookCloth watchCloth(WidgetRef ref, Trip trip) =>
    ref
        .watch(bookClothProvider((tripId: trip.id, cover: trip.coverPhotoPath)))
        .valueOrNull ??
    BookCloth.earth;

Widget _cover(BuildContext context, String? path, {Color? tint}) {
  final p = AppPalette.of(context);
  final placeholder = ColoredBox(
    color: tint ?? p.paper2,
    child: Center(
      child: Icon(LucideIcons.image, size: 20, color: p.parch),
    ),
  );
  if (!appFileExists(path)) return placeholder;
  return appImage(path, fit: BoxFit.cover, fallback: placeholder);
}

/// Small book for list rows: cloth spine, cover photo, page edge whose
/// thickness follows the photo count.
class BookMini extends ConsumerWidget {
  final Trip trip;
  final int photoCount;
  final double width;
  final double height;

  const BookMini({
    super.key,
    required this.trip,
    required this.photoCount,
    this.width = 56,
    this.height = 76,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cloth = watchCloth(ref, trip);
    final p = AppPalette.of(context);
    final edge = 2 + (photoCount / 40).clamp(0, 6).toDouble();
    return Semantics(
      image: true,
      label: '${trip.title} book, $photoCount photos',
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(AppRadius.xs),
            right: Radius.circular(AppRadius.sm),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 6, color: Color.lerp(cloth.of(context), Colors.black, 0.25)),
            Expanded(child: _cover(context, trip.coverPhotoPath, tint: cloth.of(context))),
            Container(
              width: edge,
              decoration: BoxDecoration(
                color: p.parch,
                border: Border(left: BorderSide(color: p.line, width: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ribbon bookmark hanging from a book or marking a chapter.
class RibbonMark extends StatelessWidget {
  final double width;
  final double height;
  final Color? color;

  const RibbonMark({super.key, this.width = 12, this.height = 28, this.color});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size(width, height),
        painter: _RibbonPainter(color ?? AppPalette.of(context).sun),
      ),
    );
  }
}

class _RibbonPainter extends CustomPainter {
  final Color color;
  _RibbonPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final notch = size.width * 0.5;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height - notch)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_RibbonPainter old) => old.color != color;
}

/// The selected book as a cloth hardcover: inset photo, foil date, ribbon.
class Hardcover extends ConsumerWidget {
  final Trip trip;
  final double width;
  final bool ribbon;

  const Hardcover({
    super.key,
    required this.trip,
    this.width = 240,
    this.ribbon = true,
  });

  static const _months = [
    'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
    'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cloth = watchCloth(ref, trip);
    final p = AppPalette.of(context);
    final height = width * 1.38;
    final inset = width * 0.075;
    final date = '${_months[trip.startDate.month - 1]} ${trip.startDate.year}';
    // Stamp in foil or in the deep cloth, whichever reads better; small caps
    // need 4.5:1, a larger stamp 3:1, below that the date stays off the cover.
    final clothColor = cloth.of(context);
    final ink = _contrast(p.foil, clothColor) >= _contrast(cloth.deep, clothColor)
        ? p.foil
        : cloth.deep;
    final c = _contrast(ink, clothColor);
    final text = Theme.of(context).textTheme;
    final TextStyle? dateStyle = c >= 4.5
        ? text.labelMedium?.copyWith(color: ink, letterSpacing: width >= 180 ? 3 : 1.5)
        : c >= 3
            ? text.titleMedium?.copyWith(color: ink, fontSize: 19, letterSpacing: 1)
            : null;
    return SizedBox(
      width: width + 6,
      height: height + (ribbon ? 34 : 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Page block peeking out on the fore-edge.
          Positioned(
            left: 6,
            top: 4,
            bottom: (ribbon ? 34 : 0) + 4,
            width: width,
            child: Container(
              decoration: BoxDecoration(
                color: p.parch,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
          ),
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: cloth.of(context),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppRadius.sm),
                right: Radius.circular(AppRadius.md),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 30,
                  spreadRadius: -12,
                  offset: const Offset(0, 22),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: width * 0.06,
                  decoration: BoxDecoration(
                    color: Color.lerp(cloth.of(context), Colors.black, 0.22),
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(AppRadius.sm)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(inset, inset, inset, inset),
                    child: Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 1.3,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: p.gold.withValues(alpha: 0.7)),
                            ),
                            child: _cover(context, trip.coverPhotoPath,
                                tint: cloth.deep),
                          ),
                        ),
                        const Spacer(),
                        if (dateStyle != null)
                          ExcludeSemantics(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(date, maxLines: 1, style: dateStyle),
                            ),
                          ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(width: 28, height: 1, color: ink),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (ribbon)
            Positioned(
              left: width * 0.72,
              top: height - 4,
              child: const RibbonMark(width: 14, height: 38),
            ),
        ],
      ),
    );
  }
}

/// A book's colour as a small spine chip (rail, shelves).
class ClothChip extends ConsumerWidget {
  final Trip trip;
  final bool selected;
  final double width;
  final double height;

  const ClothChip({
    super.key,
    required this.trip,
    this.selected = false,
    this.width = 28,
    this.height = 36,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cloth = watchCloth(ref, trip);
    final p = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: selected ? p.ink1 : Colors.transparent,
          width: 2,
        ),
      ),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: cloth.of(context),
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(AppRadius.xs),
            right: Radius.circular(AppRadius.sm),
          ),
        ),
        alignment: Alignment.centerLeft,
        child: Container(
          width: 5,
          color: Colors.black.withValues(alpha: 0.22),
        ),
      ),
    );
  }
}

/// "186 / photos" — a number set like a page count, with its label beneath.
class StatBlock extends StatelessWidget {
  final String value;
  final String label;
  final Color? color;
  final Color? labelColor;

  const StatBlock({
    super.key,
    required this.value,
    required this.label,
    this.color,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: text.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: color,
              height: 1.1,
            )),
        const SizedBox(height: 2),
        Text(label, style: text.bodySmall?.copyWith(color: labelColor)),
      ],
    );
  }
}

/// A book that does not exist yet: earth cloth, a dashed slot for the cover
/// photo, "New Book" stamped in foil.
class EmptyHardcover extends StatelessWidget {
  final double width;
  const EmptyHardcover({super.key, this.width = 220});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    final cloth = BookCloth.earth;
    final height = width * 1.38;
    final inset = width * 0.1;
    return ExcludeSemantics(
      child: SizedBox(
        width: width + 6,
        height: height + 30,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 6,
              top: 4,
              bottom: 34,
              width: width,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: p.parch,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            ),
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: cloth.of(context),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(AppRadius.sm),
                  right: Radius.circular(AppRadius.md),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 30,
                    spreadRadius: -12,
                    offset: const Offset(0, 22),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: width * 0.07,
                    color: Color.lerp(cloth.of(context), Colors.black, 0.22),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(inset),
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1.25,
                            child: CustomPaint(
                              painter: _DashedRect(p.foil.withValues(alpha: 0.75)),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(LucideIcons.imagePlus,
                                        size: width * 0.11, color: p.foil),
                                    const SizedBox(height: AppSpacing.sm),
                                    FittedBox(
                                      child: Text('COVER PHOTO',
                                          style: text.labelMedium
                                              ?.copyWith(color: p.foil)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          FittedBox(
                            child: Text('New Book',
                                style: text.headlineSmall
                                    ?.copyWith(color: p.foil)),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Container(width: 28, height: 1, color: p.foil),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: width * 0.72,
              top: height - 4,
              child: const RibbonMark(width: 14, height: 34),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedRect extends CustomPainter {
  final Color color;
  _DashedRect(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const dash = 4.0, gap = 3.0;
    void line(Offset a, Offset b) {
      final total = (b - a).distance;
      final dir = (b - a) / total;
      for (var d = 0.0; d < total; d += dash + gap) {
        canvas.drawLine(a + dir * d, a + dir * (d + dash).clamp(0, total), paint);
      }
    }

    final r = Offset.zero & size;
    line(r.topLeft, r.topRight);
    line(r.topRight, r.bottomRight);
    line(r.bottomRight, r.bottomLeft);
    line(r.bottomLeft, r.topLeft);
  }

  @override
  bool shouldRepaint(_DashedRect old) => old.color != color;
}
