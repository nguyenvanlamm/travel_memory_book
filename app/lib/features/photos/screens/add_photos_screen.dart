import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/progress_overlay.dart';
import '../../../core/services/file_service.dart';
import '../../../core/services/exif_service.dart';
import '../../../models/photo.dart';
import '../../../models/trip.dart';
import '../../../repositories/photo_repository.dart';
import '../../../repositories/trip_repository.dart';

class AddPhotosScreen extends ConsumerStatefulWidget {
  final int tripId;
  const AddPhotosScreen({super.key, required this.tripId});

  @override ConsumerState<AddPhotosScreen> createState() => _AddPhotosScreenState();
}

class _AddPhotosScreenState extends ConsumerState<AddPhotosScreen> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  bool _isImporting = false;
  double _importProgress = 0;
  int _importedCount = 0;
  String _statusMessage = 'Select photos to import';

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Add Photos'), leading: _isImporting ? null : IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop())),
      body: _isImporting ? ProgressOverlay(message: _statusMessage, progress: _importProgress, current: _importedCount, total: _selectedImages.length) : Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: _pickFromGallery, icon: const Icon(Icons.photo_library_outlined), label: const Text('Gallery'))),
          const SizedBox(width: 12),
          Expanded(child: OutlinedButton.icon(onPressed: _takePhoto, icon: const Icon(Icons.camera_alt_outlined), label: const Text('Camera'))),
        ])),
        if (_selectedImages.isNotEmpty) ...[
          Padding(padding: const EdgeInsets.all(16), child: SectionHeader(title: 'Selected', subtitle: '${_selectedImages.length} photos')),
          SizedBox(height: 120, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: _selectedImages.length, itemBuilder: (context, index) {
            final image = _selectedImages[index];
            return Container(width: 100, margin: const EdgeInsets.only(right: 8), child: Stack(fit: StackFit.expand, children: [
              ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(image.path), fit: BoxFit.cover)),
              Positioned(top: 4, right: 4, child: InkWell(onTap: () => setState(() => _selectedImages.removeAt(index)), child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, size: 16, color: Colors.white)))),
            ]));
          })),
        ],
        const Spacer(),
        if (_selectedImages.isNotEmpty) Padding(padding: const EdgeInsets.all(16), child: PrimaryButton(label: 'Continue (${_selectedImages.length})', onPressed: _startImport, icon: Icons.arrow_forward)),
      ]),
    );
  }

  Future<void> _pickFromGallery() async { final images = await _picker.pickMultiImage(imageQuality: 85); if (images.isNotEmpty && mounted) setState(() => _selectedImages.addAll(images)); }
  Future<void> _takePhoto() async { final image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85); if (image != null && mounted) setState(() => _selectedImages.add(image)); }

  Future<void> _startImport() async {
    if (_selectedImages.isEmpty) return;
    setState(() { _isImporting = true; _importProgress = 0; _importedCount = 0; _statusMessage = 'Preparing...'; });
    try {
      final tripRepo = ref.read(tripRepositoryProvider);
      final photoRepo = ref.read(photoRepositoryProvider);
      final fileService = FileService();
      final exifService = ExifService();
      final trip = await tripRepo.getById(widget.tripId);
      if (trip == null) throw Exception('Trip not found');

      final total = _selectedImages.length;
      for (int i = 0; i < total; i++) {
        final image = _selectedImages[i];
        _statusMessage = 'Importing ${image.name}...';
        _importProgress = i / total;
        _importedCount = i;
        setState(() {});

        final exif = await exifService.readExif(image.path);
        final takenAt = exif?.dateTaken ?? DateTime.now();
        final lat = exif?.latitude;
        final lon = exif?.longitude;
        final locationName = lat != null && lon != null ? 'GPS: ${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}' : null;

        final day = trip.startDate.difference(takenAt).inDays.abs() + 1;
        final clampedDay = day.clamp(1, trip.durationInDays);

        final originalPath = await fileService.copyToTripPhotos(widget.tripId, image.path);
        final thumbPath = await fileService.generateThumbnail(originalPath, widget.tripId);

        final photo = Photo(tripId: widget.tripId, filePath: originalPath, thumbnailPath: thumbPath, takenAt: takenAt, latitude: lat, longitude: lon, locationName: locationName, day: clampedDay, sortOrder: i);
        await photoRepo.create(photo);
        _importedCount = i + 1;
        _importProgress = (i + 1) / total;
        setState(() {});
      }

      _statusMessage = 'Complete!';
      _importProgress = 1.0;
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) context.go('/trips/${widget.tripId}');
    } catch (e) { if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import failed: $e'))); setState(() => _isImporting = false); } }
  }
}
