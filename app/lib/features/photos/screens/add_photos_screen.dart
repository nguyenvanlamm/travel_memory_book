import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/image_helper.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/progress_overlay.dart';
import '../../../core/widgets/web_layout.dart';
import '../../../core/services/exif_service.dart';
import '../../../core/services/memory_file_store.dart';
import '../../../core/utils/image_utils.dart';
import '../../../models/photo.dart';
import '../../../repositories/photo_repository.dart';
import '../../../repositories/trip_repository.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AddPhotosScreen extends ConsumerStatefulWidget {
  final int tripId;
  const AddPhotosScreen({super.key, required this.tripId});

  @override ConsumerState<AddPhotosScreen> createState() => _AddPhotosScreenState();
}

class _AddPhotosScreenState extends ConsumerState<AddPhotosScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];
  bool _isImporting = false;
  bool _dropHovered = false;
  double _importProgress = 0;
  int _importedCount = 0;
  String _statusMessage = 'Select photos to import';

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: _isImporting
          ? ProgressOverlay(message: _statusMessage, progress: _importProgress, current: _importedCount, total: _selectedImages.length)
          : PageBody(
              maxWidth: 760,
              child: Column(children: [
                PageHeader(
                  title: 'Add Photos',
                  subtitle: 'Select photos from your computer to add to this book.',
                  onBack: () => context.go('/trips/${widget.tripId}'),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _dropHovered = true),
                  onExit: (_) => setState(() => _dropHovered = false),
                  child: GestureDetector(
                    onTap: _pickFromGallery,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: _dropHovered
                            ? theme.colorScheme.primary.withOpacity(0.06)
                            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.35),
                        border: Border.all(
                          color: _dropHovered
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                          width: _dropHovered ? 2 : 1.5,
                        ),
                      ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(LucideIcons.uploadCloud, size: 48, color: theme.colorScheme.primary),
                      const SizedBox(height: 12),
                      Text('Click to select photos', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('You can select multiple photos at once', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ]),
                    ),
                  ),
                ),
                if (_selectedImages.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(children: [
                    Expanded(child: Text('Selected', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
                    Text('${_selectedImages.length} photos', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ]),
                  const SizedBox(height: 12),
                  SizedBox(height: 120, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: _selectedImages.length, itemBuilder: (context, index) {
                    final image = _selectedImages[index];
                    return Container(width: 100, margin: const EdgeInsets.only(right: 8), child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Stack(fit: StackFit.expand, children: [
                      xfileImage(image, fit: BoxFit.cover),
                      Positioned(top: 4, right: 4, child: InkWell(onTap: () => setState(() => _selectedImages.removeAt(index)), child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(LucideIcons.x, size: 14, color: Colors.white)))),
                    ])));
                  })),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(width: 220, child: PrimaryButton(label: 'Continue (${_selectedImages.length})', onPressed: _startImport, icon: LucideIcons.arrowRight)),
                  ),
                ],
              ]),
            ),
    );
  }

  Future<void> _pickFromGallery() async { final images = await _picker.pickMultiImage(imageQuality: 85); if (images.isNotEmpty && mounted) setState(() => _selectedImages.addAll(images)); }

  Future<void> _startImport() async {
    if (_selectedImages.isEmpty) return;
    setState(() { _isImporting = true; _importProgress = 0; _importedCount = 0; _statusMessage = 'Preparing...'; });
    try {
      final tripRepo = ref.read(tripRepositoryProvider);
      final photoRepo = ref.read(photoRepositoryProvider);
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

        final imageBytes = await image.readAsBytes();
        final exif = await exifService.readExif(imageBytes);
        final takenAt = exif?.dateTaken ?? DateTime.now();
        final lat = exif?.latitude;
        final lon = exif?.longitude;
        final locationName = lat != null && lon != null ? 'GPS: ${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}' : null;

        final day = trip.startDate.difference(takenAt).inDays.abs() + 1;
        final clampedDay = day.clamp(1, trip.durationInDays);

        final ext = image.name.split('.').last;
        final originalPath = MemoryFileStore.put(
            'trips/${widget.tripId}/photos', ext, imageBytes);
        final thumbBytes = makeThumbnail(imageBytes);
        final thumbPath = thumbBytes != null
            ? MemoryFileStore.put(
                'trips/${widget.tripId}/thumbnails', 'jpg', thumbBytes)
            : originalPath;

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
