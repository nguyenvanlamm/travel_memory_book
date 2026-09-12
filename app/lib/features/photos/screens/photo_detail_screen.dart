import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/image_helper.dart';
import '../../../core/widgets/web_layout.dart';
import '../../../models/photo.dart';
import '../../../repositories/photo_repository.dart';

class PhotoDetailScreen extends ConsumerStatefulWidget {
  final int tripId;
  final int photoId;
  const PhotoDetailScreen(
      {super.key, required this.tripId, required this.photoId});

  @override
  ConsumerState<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends ConsumerState<PhotoDetailScreen> {
  Photo? _photo;
  bool _isLoading = true;
  bool _isEditingCaption = false;
  final _captionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPhoto();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _loadPhoto() async {
    setState(() => _isLoading = true);
    try {
      final photo =
          await ref.read(photoRepositoryProvider).getById(widget.photoId);
      if (mounted) {
        setState(() {
          _photo = photo;
          _captionController.text = photo?.caption ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _saveCaption() async {
    if (_photo == null) return;
    final repo = ref.read(photoRepositoryProvider);
    final updated = _photo!.copyWith(
        caption: _captionController.text.trim().isEmpty
            ? null
            : _captionController.text.trim());
    await repo.update(updated);
    if (mounted) {
      setState(() {
        _photo = updated;
        _isEditingCaption = false;
      });
    }
  }

  Future<void> _deletePhoto() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Photo?'),
        content: const Text('This will permanently delete the photo.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'))
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(photoRepositoryProvider).delete(widget.photoId);
      if (mounted) context.go('/trips/${widget.tripId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    if (_photo == null) {
      return Scaffold(
        body: PageBody(
          maxWidth: 640,
          child: Column(children: [
            PageHeader(
                title: 'Photo Not Found',
                onBack: () => context.go('/trips/${widget.tripId}')),
            const Text('This photo does not exist.'),
          ]),
        ),
      );
    }
    final photo = _photo!;

    return Scaffold(
      body: PageBody(
        child: Column(children: [
          PageHeader(
            title: 'Photo Details',
            subtitle: 'Day ${photo.day}',
            onBack: () => context.go('/trips/${widget.tripId}'),
            actions: [
              IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit caption',
                  onPressed: () =>
                      setState(() => _isEditingCaption = true)),
              IconButton(
                  icon:
                      const Icon(Icons.delete_outlined, color: Colors.red),
                  tooltip: 'Delete photo',
                  onPressed: _deletePhoto),
            ],
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              final wide = constraints.maxWidth >= 860;
              final imagePane = _buildImagePane(theme, photo);
              final infoPane = _isEditingCaption
                  ? _buildEditCard(theme)
                  : _buildInfoCard(theme, photo);
              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: imagePane),
                    const SizedBox(width: 24),
                    SizedBox(width: 320, child: infoPane),
                  ],
                );
              }
              return Column(children: [
                Expanded(child: imagePane),
                const SizedBox(height: 16),
                infoPane,
              ]);
            }),
          ),
        ]),
      ),
    );
  }

  Widget _buildImagePane(ThemeData theme, Photo photo) {
    return Container(
      height: double.infinity,
      constraints: const BoxConstraints(minHeight: 320),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4,
        child: photo.filePath.isNotEmpty
            ? Center(
                child: appImage(photo.filePath,
                    fit: BoxFit.contain,
                    fallback: const Center(
                        child: Icon(Icons.broken_image, size: 64))))
            : const Center(child: Icon(Icons.broken_image, size: 64)),
      ),
    );
  }

  Widget _infoRow(ThemeData theme, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ]),
    );
  }

  Widget _buildInfoCard(ThemeData theme, Photo photo) {
    final hasLocation = photo.latitude != null && photo.longitude != null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Details',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (photo.caption != null && photo.caption!.isNotEmpty)
              _infoRow(theme, Icons.notes_outlined, photo.caption!),
            _infoRow(
                theme,
                Icons.calendar_today_outlined,
                '${photo.takenAt.day}/${photo.takenAt.month}/${photo.takenAt.year} ${photo.takenAt.hour.toString().padLeft(2, '0')}:${photo.takenAt.minute.toString().padLeft(2, '0')}'),
            if (hasLocation)
              _infoRow(
                  theme,
                  Icons.location_on_outlined,
                  photo.locationName ??
                      'GPS: ${photo.latitude!.toStringAsFixed(4)}, ${photo.longitude!.toStringAsFixed(4)}'),
            _infoRow(theme, Icons.menu_book_outlined,
                'Day ${photo.day} of the trip'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                  onPressed: () =>
                      setState(() => _isEditingCaption = true),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit Caption')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Edit Caption',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(
                controller: _captionController,
                maxLines: 4,
                decoration:
                    const InputDecoration(hintText: 'Add a caption...'),
                autofocus: true),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: () =>
                          setState(() => _isEditingCaption = false),
                      child: const Text('Cancel'))),
              const SizedBox(width: 12),
              Expanded(
                  child: FilledButton(
                      onPressed: _saveCaption,
                      child: const Text('Save')))
            ]),
          ],
        ),
      ),
    );
  }
}
