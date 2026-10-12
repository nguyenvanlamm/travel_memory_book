import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../core/widgets/loading_view.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/memory_file_store.dart';
import '../../../models/photo.dart';
import '../../../models/travel_book.dart';
import '../../../models/trip.dart';
import '../services/page_flip_audio_service.dart';
import 'book_pages/book_collage_page.dart';
import 'book_pages/book_cover_page.dart';
import 'book_pages/book_day_page.dart';
import 'book_pages/book_memory_page.dart';
import 'book_pages/book_stats_back_cover.dart';
import 'book_pages/paper_background.dart';
import 'flip_book.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class RealisticBookViewer extends ConsumerStatefulWidget {
  final TravelBook book;
  final Trip trip;
  final List<Photo> photos;

  /// Start the PDF export as soon as the pages are ready.
  final bool autoExport;

  const RealisticBookViewer({
    super.key,
    required this.book,
    required this.trip,
    required this.photos,
    this.autoExport = false,
  });

  @override
  ConsumerState<RealisticBookViewer> createState() =>
      _RealisticBookViewerState();
}

class _RealisticBookViewerState extends ConsumerState<RealisticBookViewer> {
  final FlipBookController _controller = FlipBookController();
  late List<Widget> _pageWidgets;

  /// (label, page index) of each day opener, for the chapter bar.
  late List<(String, int)> _chapters;
  int _spread = 0;
  bool _twoPage = true;
  bool _exporting = false;
  int _exportDone = 0;
  List<GlobalKey> _exportKeys = const [];
  bool _audioInitialized = false;
  bool _imagesReady = false;

  @override
  void initState() {
    super.initState();
    _buildPages();
    _ensureAudioInit();
    _precacheImages();
  }

  // Decode every photo before the book opens so pages never flash empty.
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
    if (mounted && widget.autoExport) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _exportPdf();
      });
    }
  }

  // Kích thước logic của 1 trang khi xuất PDF (aspect 0.75 như trên màn hình).
  static const _exportSize = Size(750, 1000);

  Future<void> _exportPdf() async {
    if (_exporting) return;
    setState(() {
      _exporting = true;
      _exportDone = 0;
      _exportKeys = List.generate(
          _pageWidgets.length, (_) => GlobalKey());
    });
    try {
      // Đợi các trang ẩn paint xong (post-frame, retry nhẹ nếu chưa layout).
      List<Uint8List>? jpgs;
      for (var attempt = 0; attempt < 8 && jpgs == null; attempt++) {
        await WidgetsBinding.instance.endOfFrame;
        final boundaries = <RenderRepaintBoundary>[];
        var ready = true;
        for (final key in _exportKeys) {
          final obj = key.currentContext?.findRenderObject();
          if (obj is! RenderRepaintBoundary) {
            ready = false;
            break;
          }
          boundaries.add(obj);
        }
        if (!ready || !mounted) continue;
        jpgs = [];
        for (var i = 0; i < boundaries.length; i++) {
          final page = await boundaries[i].toImage(pixelRatio: 2.0);
          final data =
              await page.toByteData(format: ui.ImageByteFormat.png);
          page.dispose();
          if (data == null) throw StateError('capture failed');
          // JPEG nhẹ hơn PNG nhiều với ảnh chụp — đủ nét để in ở q88.
          final decoded = img.decodePng(data.buffer.asUint8List());
          if (decoded == null) throw StateError('decode failed');
          jpgs.add(img.encodeJpg(decoded, quality: 88));
          // Nhường 1 frame giữa các trang để UI không bị đơ.
          if (mounted) {
            setState(() => _exportDone = i + 1);
            await WidgetsBinding.instance.endOfFrame;
          }
        }
      }
      if (jpgs == null || jpgs.isEmpty) {
        throw StateError('Could not capture pages');
      }

      final doc = pw.Document();
      for (final jpg in jpgs) {
        doc.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (_) => pw.Center(
            child: pw.Image(pw.MemoryImage(jpg), fit: pw.BoxFit.contain),
          ),
        ));
        // doc.addPage chạy đồng bộ — nhường event loop để UI mượt.
        await Future.delayed(Duration.zero);
      }
      final safeTitle = widget.trip.title
          .replaceAll(RegExp(r'[^\w\- ]'), '')
          .trim()
          .replaceAll(RegExp(r'\s+'), '_');
      await Printing.sharePdf(
          bytes: await doc.save(),
          filename: '${safeTitle.isEmpty ? 'travel_book' : safeTitle}.pdf');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Export failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
          _exportDone = 0;
          _exportKeys = const [];
        });
      }
    }
  }

  @override
  void didUpdateWidget(RealisticBookViewer old) {
    super.didUpdateWidget(old);
    if (!identical(old.book, widget.book) ||
        !identical(old.trip, widget.trip) ||
        !identical(old.photos, widget.photos)) {
      _buildPages();
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

  /// Lay the assembled book out as photo-book pages: consecutive photos of a
  /// day share a page (three, then two or one for the remainder), so a
  /// 186-photo trip reads as about 70 pages instead of 190.
  void _buildPages() {
    final pages = widget.book.pages;
    final widgets = <Widget>[];
    final chapters = <(String, int)>[];
    int number() => widgets.length; // page 0 is the cover, unnumbered
    bool left() => widgets.length.isOdd;

    void flushPhotos(List<BookPage> run) {
      var i = 0;
      while (i < run.length) {
        final rest = run.length - i;
        final take = rest == 4 ? 2 : math.min(3, rest);
        final chunk = run.sublist(i, i + take);
        widgets.add(BookCollagePage(
          photos: [for (final p in chunk) p.photoId == null ? null : _findPhoto(p.photoId!)],
          captions: [for (final p in chunk) p.body],
          pageNumber: number(),
          isLeft: left(),
        ));
        i += take;
      }
    }

    final run = <BookPage>[];
    for (final page in pages) {
      if (page.type == 'photo') {
        run.add(page);
        continue;
      }
      flushPhotos(run);
      run.clear();
      switch (page.type) {
        case 'cover':
          widgets.add(BookCoverPage(trip: widget.trip, book: widget.book));
        case 'day':
          chapters.add(('Day ${page.dayNumber ?? chapters.length + 1}', widgets.length));
          widgets.add(BookDayPage(
            trip: widget.trip,
            dayNumber: page.dayNumber ?? 1,
            dateStr: page.subtitle ?? '',
            pageNumber: number(),
            isLeft: left(),
          ));
        case 'memory':
        case 'trip_memory':
          widgets.add(BookMemoryPage(
            title: page.title,
            content: page.body ?? '',
            pageNumber: number(),
            isLeft: left(),
          ));
      }
    }
    flushPhotos(run);
    if (widgets.isEmpty) {
      widgets.add(BookCoverPage(trip: widget.trip, book: widget.book));
    }
    // The back cover closes the book on the left, so it needs an odd index.
    if (widgets.length.isEven) widgets.add(const PaperBackground());
    widgets.add(BookStatsBackCover(
      trip: widget.trip,
      book: widget.book,
      photos: widget.photos,
      pageNumber: number(),
      isLeft: left(),
    ));

    _pageWidgets = widgets;
    _chapters = chapters;
    _spread = 0;
  }

  Photo? _findPhoto(int photoId) {
    for (final p in widget.photos) {
      if (p.id == photoId) return p;
    }
    return null;
  }

  int _spreadOf(int page) => _twoPage ? (page + 1) ~/ 2 : page;

  /// Pages on screen now, as (first, last) indexes.
  (int, int) _visible() {
    if (!_twoPage) return (_spread, _spread);
    final l = _spread == 0 ? 0 : 2 * _spread - 1;
    final r = math.min(_spread == 0 ? 0 : 2 * _spread, _pageWidgets.length - 1);
    return (l, r);
  }

  String _currentTitle() {
    final (_, last) = _visible();
    String? label;
    for (final (name, index) in _chapters) {
      if (index <= last) label = name;
    }
    return label == null ? widget.trip.title : '${widget.trip.title} · $label';
  }

  /// The largest page that fits, at the 3:4 of a hardcover photo book.
  Size _pageSizeFor(Size screen, bool twoPage) {
    final usableH = screen.height - 150;
    final usableW = screen.width - 48;
    var w = twoPage ? usableW / 2 : usableW;
    var h = w / 0.75;
    if (h > usableH) {
      h = usableH;
      w = h * 0.75;
    }
    return Size(w.floorToDouble(), h.floorToDouble());
  }

  void _onTurned() {
    if (_audioInitialized) ref.read(pageFlipAudioServiceProvider).playFlip();
  }

  @override
  Widget build(BuildContext context) {
    if (!_imagesReady) {
      return const Center(child: LoadingView());
    }
    final dark = Theme.of(context).brightness == Brightness.dark;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowRight): _controller.next,
        const SingleActivator(LogicalKeyboardKey.space): _controller.next,
        const SingleActivator(LogicalKeyboardKey.pageDown): _controller.next,
        const SingleActivator(LogicalKeyboardKey.arrowLeft): _controller.previous,
        const SingleActivator(LogicalKeyboardKey.pageUp): _controller.previous,
        const SingleActivator(LogicalKeyboardKey.home): () => _controller.jumpTo(0),
        const SingleActivator(LogicalKeyboardKey.end): () =>
            _controller.jumpTo(_controller.totalSpreads - 1),
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            context.go('/trips/${widget.trip.id}'),
      },
      child: Focus(
        autofocus: true,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: dark
                  ? const [Color(0xFF16110D), Color(0xFF0A0A0A)]
                  : const [Color(0xFFEFE7D8), Color(0xFFFAF7F2)],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 1.3,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: dark ? 0.35 : 0.12),
                      ],
                      stops: const [0.6, 1.0],
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  _TopBar(
                    title: _currentTitle(),
                    onBack: () => context.go('/trips/${widget.trip.id}'),
                    onExport: _exportPdf,
                    exporting: _exporting,
                  ),
                  Expanded(
                    child: LayoutBuilder(builder: (context, c) {
                      final screen = Size(c.maxWidth, c.maxHeight + 150);
                      final twoPage = c.maxWidth >= 760 && c.maxWidth > c.maxHeight;
                      if (twoPage != _twoPage) {
                        // Mode follows the window; FlipBook keeps the page.
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              _twoPage = twoPage;
                              _spread = _controller.spread;
                            });
                          }
                        });
                      }
                      final size = _pageSizeFor(screen, twoPage);
                      return Center(
                        child: FlipBook(
                          pages: _pageWidgets,
                          pageSize: size,
                          singlePage: !twoPage,
                          controller: _controller,
                          onTurned: _onTurned,
                          onSpreadChanged: (s) => setState(() => _spread = s),
                        ),
                      );
                    }),
                  ),
                  _BottomBar(
                    visible: _visible(),
                    totalPages: _pageWidgets.length,
                    chapters: _chapters,
                    currentChapterPage: _visible().$1,
                    onPrev: _controller.previous,
                    onNext: _controller.next,
                    onChapter: (page) => _controller.jumpTo(_spreadOf(page)),
                  ),
                ],
              ),
              // Pages rendered off-screen under an opaque cover so the PDF
              // export can capture each one.
              if (_exporting)
                Positioned.fill(
                  child: Stack(
                    children: [
                      for (var i = 0; i < _pageWidgets.length; i++)
                        Positioned(
                          left: 0,
                          top: 0,
                          width: _exportSize.width,
                          height: _exportSize.height,
                          child: RepaintBoundary(
                            key: _exportKeys[i],
                            child: _pageWidgets[i],
                          ),
                        ),
                      Positioned.fill(
                        child: ColoredBox(
                          color: Theme.of(context).colorScheme.surface,
                          child: LoadingView(
                              message:
                                  'Exporting PDF… $_exportDone/${_pageWidgets.length}'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onExport;
  final bool exporting;

  const _TopBar({
    required this.title,
    required this.onBack,
    required this.onExport,
    this.exporting = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(LucideIcons.arrowLeft, size: 18),
            label: const Text('Close'),
          ),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton.icon(
            onPressed: exporting ? null : onExport,
            icon: const Icon(LucideIcons.fileDown, size: 18),
            label: const Text('PDF'),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final (int, int) visible;
  final int totalPages;
  final List<(String, int)> chapters;
  final int currentChapterPage;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<int> onChapter;

  const _BottomBar({
    required this.visible,
    required this.totalPages,
    required this.chapters,
    required this.currentChapterPage,
    required this.onPrev,
    required this.onNext,
    required this.onChapter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (first, last) = visible;
    final label = first == 0 && last == 0
        ? 'Cover'
        : first == last
            ? 'Page $first of ${totalPages - 1}'
            : 'Pages $first–$last of ${totalPages - 1}';
    int? current;
    for (var i = 0; i < chapters.length; i++) {
      if (chapters[i].$2 <= last) current = i;
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 14),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.chevronLeft),
                  onPressed: onPrev,
                  tooltip: 'Previous (←)',
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 120),
                  child: Text(label,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.chevronRight),
                  onPressed: onNext,
                  tooltip: 'Next (→)',
                ),
              ],
            ),
          ),
          if (chapters.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var i = 0; i < chapters.length; i++)
                  ChoiceChip(
                    label: Text(chapters[i].$1),
                    selected: i == current,
                    labelStyle: theme.textTheme.labelLarge?.copyWith(
                      color: i == current ? scheme.surface : scheme.onSurface,
                    ),
                    onSelected: (_) => onChapter(chapters[i].$2),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
