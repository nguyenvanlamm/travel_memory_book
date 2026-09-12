import 'package:flutter/material.dart';
import '../../../core/widgets/loading_view.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_page_flip/book_page_flip.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/memory_file_store.dart';
import '../../../models/photo.dart';
import '../../../models/travel_book.dart';
import '../../../models/trip.dart';
import '../services/page_flip_audio_service.dart';
import 'book_pages/book_cover_page.dart';
import 'book_pages/book_day_page.dart';
import 'book_pages/book_memory_page.dart';
import 'book_pages/book_photo_page.dart';
import 'book_pages/book_stats_back_cover.dart';
import 'book_pages/paper_background.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
  late List<Widget> _pageWidgets;
  Size? _pageSize;
  int _captureEpoch = 0;
  int _currentSpread = 0;
  int _lastTotalSpreads = 0;
  bool _audioInitialized = false;
  bool _imagesReady = false;
  bool _showCornerHint = true;

  @override
  void initState() {
    super.initState();
    _pageWidgets = _buildPageWidgets();
    _controller.addListener(_onBookChanged);
    _ensureAudioInit();
    _precacheImages();
  }

  // BookFlip rasterise page widget ngay frame đầu — Image.memory decode bất đồng
  // bộ nên ảnh chưa kịp vẽ sẽ bị capture trắng. Precache trước để cache hit ngay.
  Future<void> _precacheImages() async {
    final paths = <String>{
      if (widget.trip.coverPhotoPath != null) widget.trip.coverPhotoPath!,
      for (final p in widget.photos) p.filePath,
    };
    for (final path in paths) {
      final bytes = MemoryFileStore.read(path);
      if (bytes == null) continue;
      try {
        await precacheImage(MemoryImage(bytes), context);
      } catch (_) {}
      if (!mounted) return;
    }
    if (mounted) setState(() => _imagesReady = true);
  }

  @override
  void didUpdateWidget(RealisticBookViewer old) {
    super.didUpdateWidget(old);
    if (!identical(old.book, widget.book) ||
        !identical(old.trip, widget.trip) ||
        !identical(old.photos, widget.photos)) {
      _pageWidgets = _buildPageWidgets();
      _captureEpoch++;
      _currentSpread = 0;
    }
  }

  // BookFlip re-capture toàn bộ trang (và remount → reset về spread 0) mỗi khi
  // pageBuilder đổi identity. Method tear-off KHÔNG identical giữa các build —
  // phải giữ closure trong field final để cùng 1 object qua mọi rebuild.
  // ignore: prefer_function_declarations_over_variables
  late final Widget Function(BuildContext, int) _pageBuilder =
      (context, index) => _pageWidgets[index];

  void _onBookChanged() {
    final total = _controller.totalSpreads;
    if (total != _lastTotalSpreads && mounted) {
      setState(() => _lastTotalSpreads = total);
    }
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
      final isLeft = i.isEven;
      final pageNumber = i + 1;
      switch (page.type) {
        case 'cover':
          widgets.add(BookCoverPage(trip: widget.trip, book: widget.book));
          break;
        case 'day':
          widgets.add(BookDayPage(
            trip: widget.trip,
            dayNumber: page.dayNumber ?? 1,
            dateStr: page.subtitle ?? '',
            pageNumber: pageNumber,
            isLeft: isLeft,
          ));
          break;
        case 'photo':
          final photo =
              page.photoId != null ? _findPhoto(page.photoId!) : null;
          widgets.add(BookPhotoPage(
            photo: photo,
            caption: page.body,
            pageNumber: pageNumber,
            isLeft: isLeft,
          ));
          break;
        case 'memory':
        case 'trip_memory':
          widgets.add(BookMemoryPage(
            title: page.title,
            content: page.body ?? '',
            pageNumber: pageNumber,
            isLeft: isLeft,
          ));
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
      pageNumber: widgets.length + 1,
      isLeft: widgets.length.isEven,
    ));

    // BookFlip yêu cầu tối thiểu 2 trang
    while (widgets.length < 2) {
      widgets.add(const SizedBox.shrink());
    }
    // totalSpreads = pageCount ~/ 2 → số trang lẻ sẽ cắt mất trang cuối.
    // Pad thêm trang giấy trống (endpaper) để bìa sau luôn hiển thị.
    if (widgets.length.isOdd) {
      widgets.add(const PaperBackground());
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
    // Book viewer luôn landscape - dùng gần như toàn bộ màn hình
    // Subtract một chút padding cho top bar + bottom bar (~80px + 50px = 130px)
    final usableHeight = screenSize.height - 140;
    final usableWidth = screenSize.width - 32;

    // Page aspect ratio: 3:4 (giống sách bìa cứng) - width/height
    const aspectRatio = 0.75;

    // Spread width = 2 * page width, nên page width = usableWidth / 2
    double pageWidth = usableWidth / 2;
    double pageHeight = pageWidth / aspectRatio;

    if (pageHeight > usableHeight) {
      pageHeight = usableHeight;
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
    if (_pageWidgets.length < 2) {
      return const Center(child: Text('Book has no pages'));
    }
    if (!_imagesReady) {
      return const Center(child: LoadingView());
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            _controller.nextSpread(),
        const SingleActivator(LogicalKeyboardKey.space): () =>
            _controller.nextSpread(),
        const SingleActivator(LogicalKeyboardKey.pageDown): () =>
            _controller.nextSpread(),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            _controller.previousSpread(),
        const SingleActivator(LogicalKeyboardKey.pageUp): () =>
            _controller.previousSpread(),
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            context.go('/trips/${widget.trip.id}'),
      },
      child: Focus(
        autofocus: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenSize =
                Size(constraints.maxWidth, constraints.maxHeight);
            // Cache pageSize: mỗi thay đổi pageSize cũng trigger re-capture →
            // reset về trang đầu. BookFlip tự scale qua fit: contain khi resize.
            final pageSize =
                _pageSize ??= _calculatePageSize(screenSize);

            final dark =
                Theme.of(context).brightness == Brightness.dark;
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: dark
                      ? const [Color(0xFF16110D), Color(0xFF0A0A0A)]
                      : const [Color(0xFFEFE7D8), Color(0xFFFAF7F2)],
                ),
              ),
              // Vân giấy mờ + vignette nhẹ cho cảm giác "mặt bàn đọc sách"
              child: Stack(
                fit: StackFit.expand,
                children: [
                  IgnorePointer(
                    child: Opacity(
                      opacity: dark ? 0.03 : 0.05,
                      child: Image.asset(
                        'assets/images/book/paper-texture.png',
                        repeat: ImageRepeat.repeat,
                        fit: BoxFit.none,
                        errorBuilder: (_, __, ___) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          radius: 1.3,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(dark ? 0.35 : 0.12),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Column(
                children: [
                  _TopBar(
                    title: _getCurrentTitle(
                        _currentSpread, widget.book.pages),
                    currentSpread: _currentSpread,
                    totalSpreads: _lastTotalSpreads,
                    onBack: () =>
                        context.go('/trips/${widget.trip.id}'),
                  ),
                  Expanded(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                    BookFlip.builder(
                      key: ValueKey(_captureEpoch),
                      pageCount: _pageWidgets.length,
                      pageBuilder: _pageBuilder,
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
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final int currentSpread;
  final int totalSpreads;
  final VoidCallback? onBack;

  const _TopBar({
    required this.title,
    required this.currentSpread,
    required this.totalSpreads,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: onBack ??
                () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
            icon: const Icon(LucideIcons.arrowLeft, size: 18),
            label: const Text('Back'),
            style: TextButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 80,
            child: totalSpreads > 0
                ? Text(
                    '${currentSpread + 1}/$totalSpreads',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withOpacity(0.6),
                        ),
                  )
                : null,
          ),
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 4),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: theme.colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(LucideIcons.chevronLeft),
                onPressed: onPrev,
                tooltip: 'Previous (←)',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Page ${currentPage + 1} of $totalPages',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.chevronRight),
                onPressed: onNext,
                tooltip: 'Next (→)',
              ),
            ],
          ),
        ),
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
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: widget.onDismiss,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.mousePointerClick, color: Colors.white, size: 16),
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
