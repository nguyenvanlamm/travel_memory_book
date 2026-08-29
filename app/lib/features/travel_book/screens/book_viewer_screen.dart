import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../models/travel_book.dart';
import '../../../models/photo.dart';
import '../../../models/trip.dart';
import '../../../repositories/book_repository.dart';
import '../../../repositories/photo_repository.dart';
import '../../../repositories/trip_repository.dart';
import '../widgets/book_cover.dart';
import '../widgets/book_page.dart';

class BookViewerScreen extends ConsumerStatefulWidget {
  final int tripId;
  const BookViewerScreen({super.key, required this.tripId});

  @override
  ConsumerState<BookViewerScreen> createState() => _BookViewerScreenState();
}

class _BookViewerScreenState extends ConsumerState<BookViewerScreen> {
  TravelBook? _book;
  Trip? _trip;
  List<Photo> _photos = [];
  bool _isLoading = true;
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void initState() { super.initState(); _loadBook(); }
  @override
  void dispose() { _pageController.dispose(); super.dispose(); }

  Future<void> _loadBook() async {
    setState(() => _isLoading = true);
    try {
      final bookRepo = ref.read(bookRepositoryProvider);
      final tripRepo = ref.read(tripRepositoryProvider);
      final photoRepo = ref.read(photoRepositoryProvider);
      _book = await bookRepo.getByTrip(widget.tripId);
      _book ??= await bookRepo.assemble(widget.tripId);
      _trip = await tripRepo.getById(widget.tripId);
      _photos = await photoRepo.getByTrip(widget.tripId);
      if (mounted) setState(() => _isLoading = false);
    } catch (e) { if (mounted) { setState(() => _isLoading = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'))); } }
  }

  Photo? _getPhoto(int photoId) { try { return _photos.firstWhere((p) => p.id == photoId); } catch (_) { return null; } }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) return Scaffold(appBar: AppBar(title: const Text('Loading Book...')), body: const Center(child: CircularProgressIndicator()));
    if (_book == null || _trip == null) return Scaffold(appBar: AppBar(title: const Text('Error')), body: const Center(child: Text('Failed to load book')));
    final pages = _book!.pages;
    return Scaffold(
      appBar: AppBar(title: _currentPage == 0 ? Text(_trip!.title, style: const TextStyle(fontWeight: FontWeight.w700)) : pages[_currentPage].title != null ? Text(pages[_currentPage].title!, style: const TextStyle(fontWeight: FontWeight.w700)) : Text('Page ${_currentPage + 1}'), leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop())),
      body: PageView.builder(controller: _pageController, onPageChanged: (index) => setState(() => _currentPage = index), itemCount: pages.length, itemBuilder: (context, index) {
        final page = pages[index];
        switch (page.type) {
          case 'cover': return BookCover(trip: _trip!, book: _book!);
          case 'day': return BookDayPage(trip: _trip!, dayNumber: page.dayNumber!, dateStr: page.subtitle ?? '');
          case 'photo': final photo = page.photoId != null ? _getPhoto(page.photoId!) : null; return BookPhotoPage(photo: photo, caption: page.body);
          case 'memory': case 'trip_memory': return BookMemoryPage(title: page.title, content: page.body ?? '');
          default: return const SizedBox.shrink();
        }
      }),
    );
  }
}
