import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/iap/iap_providers.dart';
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
  bool _bookExists = false;
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

      // Check if book already exists
      _book = await bookRepo.getByTrip(widget.tripId);
      _bookExists = _book != null;

      if (!_bookExists) {
        // Check if user can create a new book
        final canCreate = await bookRepo.canCreateNewBook();
        if (!canCreate) {
          if (mounted) {
            setState(() => _isLoading = false);
            _showPurchaseDialog();
          }
          return;
        }
        // Create the book
        _book = await bookRepo.assemble(widget.tripId);
        await bookRepo.incrementBookCount();
      }

      _trip = await tripRepo.getById(widget.tripId);
      _photos = await photoRepo.getByTrip(widget.tripId);
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showPurchaseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _UnlockTravelBooksDialog(),
    ).then((_) {
      if (mounted) {
        _loadBook(); // Reload after dialog closes
      }
    });
  }

  Photo? _getPhoto(int photoId) {
    try {
      return _photos.firstWhere((p) => p.id == photoId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading Book...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_book == null || _trip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Failed to load book')),
      );
    }
    final pages = _book!.pages;
    return Scaffold(
      appBar: AppBar(
        title: _currentPage == 0
            ? Text(_trip!.title, style: const TextStyle(fontWeight: FontWeight.w700))
            : pages[_currentPage].title != null
                ? Text(pages[_currentPage].title!, style: const TextStyle(fontWeight: FontWeight.w700))
                : Text('Page ${_currentPage + 1}'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemCount: pages.length,
        itemBuilder: (context, index) {
          final page = pages[index];
          switch (page.type) {
            case 'cover':
              return BookCover(trip: _trip!, book: _book!);
            case 'day':
              return BookDayPage(trip: _trip!, dayNumber: page.dayNumber!, dateStr: page.subtitle ?? '');
            case 'photo':
              final photo = page.photoId != null ? _getPhoto(page.photoId!) : null;
              return BookPhotoPage(photo: photo, caption: page.body);
            case 'memory':
            case 'trip_memory':
              return BookMemoryPage(title: page.title, content: page.body ?? '');
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

class _UnlockTravelBooksDialog extends ConsumerWidget {
  const _UnlockTravelBooksDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseState = ref.watch(purchaseNotifierProvider);
    final productAsync = ref.watch(unlockProductProvider);

    return productAsync.when(
      data: (product) => AlertDialog(
        title: const Text('Unlock Travel Books'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('You\'ve created your first travel book for free!'),
            const SizedBox(height: 16),
            const Text('Create unlimited travel books for a one-time purchase of'),
            const SizedBox(height: 8),
            Text(
              product?.price ?? '\$0.99',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 16),
            if (purchaseState.error != null)
              Text(
                purchaseState.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: purchaseState.isLoading ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: purchaseState.isLoading
                ? null
                : () async {
                    final success = await ref.read(purchaseNotifierProvider.notifier).purchaseUnlockTravelBooks();
                    if (success && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
            child: purchaseState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Unlock Now'),
          ),
        ],
      ),
      loading: () => AlertDialog(
        title: const Text('Unlock Travel Books'),
        content: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stack) => AlertDialog(
        title: const Text('Unlock Travel Books'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('You\'ve created your first travel book for free!'),
            const SizedBox(height: 16),
            const Text('Create unlimited travel books for \$0.99'),
            const SizedBox(height: 16),
            Text('Error loading product: $error', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ],
      ),
    );
  }
}