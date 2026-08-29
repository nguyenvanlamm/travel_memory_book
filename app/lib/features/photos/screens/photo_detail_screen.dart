import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
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
    if (_isLoading)
      return Scaffold(
          appBar: AppBar(title: const Text('Loading...')),
          body: const Center(child: CircularProgressIndicator()));
    if (_photo == null)
      return Scaffold(
          appBar: AppBar(title: const Text('Photo Not Found')),
          body: const Center(child: Text('Photo not found')));
    final photo = _photo!;
    final hasLocation = photo.latitude != null && photo.longitude != null;
    return Scaffold(
        appBar: AppBar(title: const Text('Photo Details'), actions: [
          IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditingCaption = true)),
          IconButton(
              icon: const Icon(Icons.delete_outlined, color: Colors.red),
              onPressed: _deletePhoto)
        ]),
        body: _isEditingCaption
            ? _buildEditView(theme)
            : _buildView(theme, hasLocation, photo));
  }

  Widget _buildView(ThemeData theme, bool hasLocation, Photo photo) {
    return Column(children: [
      Expanded(
          child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: photo.filePath.isNotEmpty
                  ? Image.file(File(photo.filePath),
                      fit: BoxFit.contain,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image, size: 64)))
                  : const Center(child: Icon(Icons.broken_image, size: 64)))),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
                top: BorderSide(color: theme.colorScheme.outlineVariant))),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (photo.caption != null && photo.caption!.isNotEmpty) ...[
                Text('Caption',
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text(photo.caption!, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
              ],
              Row(children: [
                Icon(Icons.calendar_today_outlined,
                    size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                    '${photo.takenAt.day}/${photo.takenAt.month}/${photo.takenAt.year} ${photo.takenAt.hour.toString().padLeft(2, '0')}:${photo.takenAt.minute.toString().padLeft(2, '0')}',
                    style: theme.textTheme.bodyMedium),
              ]),
              if (hasLocation) ...[
                const SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.location_on_outlined,
                      size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(
                          photo.locationName ??
                              'GPS: ${photo.latitude!.toStringAsFixed(4)}, ${photo.longitude!.toStringAsFixed(4)}',
                          style: theme.textTheme.bodyMedium)),
                ]),
              ],
              const SizedBox(height: 16),
              Divider(),
              const SizedBox(height: 8),
              Text('Day ${photo.day} • Sort: ${photo.sortOrder}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant))
            ]),
      )
    ]);
  }

  Widget _buildEditView(ThemeData theme) {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const Text('Edit Caption',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          TextField(
              controller: _captionController,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Add a caption...'),
              autofocus: true),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                child: OutlinedButton(
                    onPressed: () => setState(() => _isEditingCaption = false),
                    child: const Text('Cancel'))),
            const SizedBox(width: 12),
            Expanded(
                child: FilledButton(
                    onPressed: _saveCaption, child: const Text('Save')))
          ])
        ]));
  }
}
