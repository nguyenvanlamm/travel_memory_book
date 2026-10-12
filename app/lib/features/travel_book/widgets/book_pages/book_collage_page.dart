import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/utils/image_helper.dart';
import '../../../../models/photo.dart';
import 'paper_background.dart';

/// A photo-book page holding one to three photos of the same day:
/// one fills the page, two stack, three are one large over two small.
class BookCollagePage extends StatelessWidget {
  final List<Photo?> photos;
  final List<String?> captions;
  final int? pageNumber;
  final bool isLeft;

  const BookCollagePage({
    super.key,
    required this.photos,
    this.captions = const [],
    this.pageNumber,
    this.isLeft = false,
  });

  @override
  Widget build(BuildContext context) {
    final first = photos.whereType<Photo>().firstOrNull;
    final caption = captions.whereType<String>().where((c) => c.isNotEmpty).firstOrNull;
    final places = <String>[];
    for (final p in photos.whereType<Photo>()) {
      final n = p.locationName?.trim();
      if (n != null && n.isNotEmpty && !places.contains(n)) places.add(n);
    }
    final meta = [
      if (places.isNotEmpty) places.join(' · '),
      if (first != null) DateFormat('d MMM yyyy').format(first.takenAt),
    ].join('   ·   ');

    return PaperBackground(
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(isLeft ? 30 : 36, 34, isLeft ? 36 : 30, 40),
            child: Column(
              children: [
                Expanded(child: _grid()),
                const SizedBox(height: 16),
                if (caption != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      caption,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Literata',
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                        color: BookInk.ink,
                      ),
                    ),
                  ),
                if (meta.isNotEmpty)
                  Text(
                    meta,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Be Vietnam Pro',
                      fontSize: 13,
                      letterSpacing: 0.3,
                      color: BookInk.inkSoft,
                    ),
                  ),
              ],
            ),
          ),
          if (pageNumber != null) BookPageNumber(page: pageNumber!, isLeft: isLeft),
        ],
      ),
    );
  }

  Widget _grid() {
    const gap = 10.0;
    switch (photos.length) {
      case 1:
        return _Print(photo: photos[0], fit: BoxFit.contain);
      case 2:
        return Column(
          children: [
            Expanded(child: _Print(photo: photos[0])),
            const SizedBox(height: gap),
            Expanded(child: _Print(photo: photos[1])),
          ],
        );
      default:
        return Column(
          children: [
            Expanded(flex: 3, child: _Print(photo: photos[0])),
            const SizedBox(height: gap),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(child: _Print(photo: photos[1])),
                  const SizedBox(width: gap),
                  Expanded(child: _Print(photo: photos[2])),
                ],
              ),
            ),
          ],
        );
    }
  }
}

/// A print pasted on the page: thin white border, soft shadow.
class _Print extends StatelessWidget {
  final Photo? photo;
  final BoxFit fit;
  const _Print({required this.photo, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    const placeholder = ColoredBox(
      color: Color(0xFFEDE3CC),
      child: Center(child: Icon(LucideIcons.image, size: 36, color: BookInk.inkFaint)),
    );
    final image = photo != null && appFileExists(photo!.filePath)
        ? appImage(photo!.filePath, fit: fit, fallback: placeholder)
        : placeholder;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: fit == BoxFit.cover
          ? ClipRect(child: SizedBox.expand(child: image))
          : Center(child: image),
    );
  }
}
