import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_page_flip/book_page_flip.dart';
import '../../../models/photo.dart';
import '../../../models/travel_book.dart';
import '../../../models/trip.dart';
import '../services/page_flip_audio_service.dart';
import 'book_pages/book_cover_page.dart';
import 'book_pages/book_day_page.dart';
import 'book_pages/book_memory_page.dart';
import 'book_pages/book_photo_page.dart';
import 'book_pages/book_stats_back_cover.dart';

class RealisticBookViewer extends ConsumerStatefulWidget {
  final TravelBook book;
  final Trip trip;
  final List<Photo> photos;

  const RealisticBookViewer({
    super.key,
    required this.book,
    required this.trip,
    required this.photos,
  });

  @override
  ConsumerState<RealisticBookViewer> createState() =>
      _RealisticBookViewerState();
}

class _RealisticBookViewerState extends ConsumerState<RealisticBookViewer> {
  final BookFlipController _controller = BookFlipController();
  int _currentSpread = 0;
  bool _audioInitialized = false;
  bool _showCornerHint = true;

  @override
  void initState() {
    super.initState();
    _ensureAudioInit();
  }

  Future<void> _ensureAudioInit() async {
    if (_audioInitialized) return;
    final service = ref.read(pageFlipAudioServiceProvider);
    await service.init();
    _audioInitialized = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Widget> _buildPageWidgets() {
    final pages = widget.book.pages;
    final widgets = <Widget>[];

    for (int i = 0; i < pages.length; i++) {
      final page = pages[i];
      switch (page.type) {
        case 'cover':
          widgets.add(BookCoverPage(trip: widget.trip, book: widget.book));
          break;
        case 'day':
          widgets.add(BookDayPage(
            trip: widget.trip,
            dayNumber: page.dayNumber ?? 1,
            dateStr: page.subtitle ?? '',
          ));
          break;
        case 'photo':
          final photo =
              page.photoId != null ? _findPhoto(page.photoId!) : null;
          widgets.add(BookPhotoPage(photo: photo, caption: page.body));
          break;
        case 'memory':
        case 'trip_memory':
          widgets.add(BookMemoryPage(title: page.title, content: page.body ?? ''));
          break;
        default:
          widgets.add(const SizedBox.shrink());
      }
    }

    // Bìa sau: thêm trang thống kê
    widgets.add(BookStatsBackCover(
      trip: widget.trip,
      book: widget.book,
      photos: widget.photos,
    ));

    // BookFlip yêu cầu tối thiểu 2 trang
    while (widgets.length < 2) {
      widgets.add(const SizedBox.shrink());
    }

    return widgets;
  }

  Photo? _findPhoto(int photoId) {
    try {
      return widget.photos.firstWhere((p) => p.id == photoId);
    } catch (_) {
      return null;
    }
  }

  Size _calculatePageSize(Size screenSize) {
    final isLandscape = screenSize.width > screenSize.height;
    final maxWidth = screenSize.width * (isLandscape ? 0.95 : 0.92);
    final maxHeight = screenSize.height * (isLandscape ? 0.88 : 0.85);

    // Page aspect ratio: 2:3 (portrait) hoặc 3:4 khi landscape
    final aspectRatio = isLandscape ? 0.75 : 0.66;

    double pageWidth = maxWidth / 2;
    double pageHeight = pageWidth / aspectRatio;

    if (pageHeight > maxHeight) {
      pageHeight = maxHeight;
      pageWidth = pageHeight * aspectRatio;
    }

    return Size(pageWidth, pageHeight);
  }

  String _getCurrentTitle(int spread, List<BookPage> pages) {
    if (pages.isEmpty) return widget.trip.title;
    // Khi hiển thị 2 trang, lấy tiêu đề trang bên trái
    final leftPageIndex = spread * 2;
    if (leftPageIndex < pages.length) {
      final page = pages[leftPageIndex];
      if (page.type == 'cover') return widget.trip.title;
      if (page.title != null) return page.title!;
    }
    return widget.trip.title;
  }

  @override
  Widget build(BuildContext context) {
    final pageWidgets = _buildPageWidgets();
    if (pageWidgets.length < 2) {
      return const Center(child: Text('Book has no pages'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = Size(constraints.maxWidth, constraints.maxHeight);
        final pageSize = _calculatePageSize(screenSize);

        return Column(
          children: [
            _TopBar(
              title: _getCurrentTitle(_currentSpread, widget.book.pages),
              currentSpread: _currentSpread,
              totalSpreads: _controller.totalSpreads,
            ),
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    BookFlip.widgets(
                      pages: pageWidgets,
                      pageSize: pageSize,
                      controller: _controller,
                      material: BookFlipMaterial.paper,
                      curl: BookFlipCurl.gentle,
                      effects: const BookFlipEffects(
                        gloss: false,
                        grain: false,
                      ),
                      onSpreadChanged: (spread) {
                        setState(() => _currentSpread = spread);
                        if (spread > 0 && _showCornerHint) {
                          setState(() => _showCornerHint = false);
                        }
                      },
                      onFlipEnd: (spread) {
                        if (_audioInitialized) {
                          ref.read(pageFlipAudioServiceProvider).playFlip();
                        }
                      },
                    ),
                    if (_showCornerHint && _currentSpread == 0)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: _CornerHint(
                          onDismiss: () =>
                              setState(() => _showCornerHint = false),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            _BottomBar(
              currentPage: _currentSpread * 2 + 1,
              totalPages: _controller.totalPages,
              onPrev: () => _controller.previousSpread(),
              onNext: () => _controller.nextSpread(),
            ),
          ],
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final int currentSpread;
  final int totalSpreads;

  const _TopBar({
    required this.title,
    required this.currentSpread,
    required this.totalSpreads,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (totalSpreads > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                '${currentSpread + 1}/$totalSpreads',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _BottomBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrev,
            tooltip: 'Previous spread',
          ),
          Text(
            'Page ${currentPage + 1} of $totalPages',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
            tooltip: 'Next spread',
          ),
        ],
      ),
    );
  }
}

class _CornerHint extends StatefulWidget {
  final VoidCallback onDismiss;
  const _CornerHint({required this.onDismiss});

  @override
  State<_CornerHint> createState() => _CornerHintState();
}

class _CornerHintState extends State<_CornerHint>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Opacity(
          opacity: 0.5 + (_ctrl.value * 0.5),
          child: Material(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: widget.onDismiss,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Drag page corner to flip',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
