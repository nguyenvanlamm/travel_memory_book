import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    if (!kIsWeb) {
      // Ép xoay ngang khi đọc sách
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      // Ẩn status bar & navigation bar để có trải nghiệm fullscreen
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
      );
    }
    _loadBook();
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      // Khôi phục orientation & system UI khi thoát
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      );
    }
    super.dispose();
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
        _book = await bookRepo.assemble(widget.tripId);
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
