import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/iap/iap_providers.dart';
import '../../../models/travel_book.dart';
import '../../../models/photo.dart';
import '../../../models/trip.dart';
import '../../../repositories/book_repository.dart';
import '../../../repositories/photo_repository.dart';
import '../../../repositories/trip_repository.dart';
import '../widgets/realistic_book_viewer.dart';

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

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  Future<void> _loadBook() async {
    setState(() => _isLoading = true);
    try {
      final bookRepo = ref.read(bookRepositoryProvider);
      final tripRepo = ref.read(tripRepositoryProvider);
      final photoRepo = ref.read(photoRepositoryProvider);

      _book = await bookRepo.getByTrip(widget.tripId);
      _bookExists = _book != null;

      if (!_bookExists) {
        final canCreate = await bookRepo.canCreateNewBook();
        if (!canCreate) {
          if (mounted) {
            setState(() => _isLoading = false);
            _showPurchaseDialog();
          }
          return;
        }
        _book = await bookRepo.assemble(widget.tripId);
        await bookRepo.incrementBookCount();
      }

      _trip = await tripRepo.getById(widget.tripId);
      _photos = await photoRepo.getByTrip(widget.tripId);
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
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
        _loadBook();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      body: RealisticBookViewer(
        book: _book!,
        trip: _trip!,
        photos: _photos,
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
            Text('Error loading product: $error',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ],
      ),
    );
  }
}
