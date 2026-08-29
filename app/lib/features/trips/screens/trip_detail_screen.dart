import '../../../models/trip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/section_header.dart';

import '../../../models/photo.dart';
import '../../../repositories/trip_repository.dart';
import '../../../repositories/photo_repository.dart';
import '../../photos/screens/add_photos_screen.dart';
import '../../photos/screens/photo_detail_screen.dart';
import '../../travel_book/screens/book_viewer_screen.dart';
import '../../memories/screens/memory_editor_screen.dart';

// Top-level helper classes
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatCard(
      {required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 28, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(value,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant))
          ],
        ),
      ),
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  final Photo photo;
  final VoidCallback onTap;
  const _PhotoThumbnail({required this.photo, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          photo.thumbnailPath.isNotEmpty
              ? Image.file(File(photo.thumbnailPath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: Colors.grey.shade200))
              : Container(color: Colors.grey.shade200),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4)),
              child: Text('${photo.day}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class TripDetailScreen extends ConsumerStatefulWidget {
  final int tripId;
  const TripDetailScreen({super.key, required this.tripId});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  Trip? _trip;
  List<Photo> _photos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final tripRepo = ref.read(tripRepositoryProvider);
      final photoRepo = ref.read(photoRepositoryProvider);
      final trip = await tripRepo.getById(widget.tripId);
      final photos = await photoRepo.getByTrip(widget.tripId);
      if (mounted) {
        setState(() {
          _trip = trip;
          _photos = photos;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading)
      return Scaffold(
          appBar: AppBar(title: const Text('Loading...')),
          body: const Center(child: CircularProgressIndicator()));
    if (_trip == null)
      return Scaffold(
          appBar: AppBar(title: const Text('Trip Not Found')),
          body: const Center(child: Text('Trip not found')));
    final trip = _trip!;
    final photoCount = _photos.length;
    final daysCount = _trip!.durationInDays;
    final citiesCount = _trip!.cities.length;
    return Scaffold(
      appBar: AppBar(title: Text(_trip!.title), actions: [
        IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.go('/trips/${_trip!.id}/edit')),
        PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete') {
                final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                            title: const Text('Delete Trip?'),
                            content: const Text(
                                'This will permanently delete the trip and all its photos.'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel')),
                              FilledButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Delete'))
                            ]));
                if (confirm == true) {
                  await ref.read(tripRepositoryProvider).delete(_trip!.id!);
                  if (mounted) context.go('/');
                }
              } else if (value == 'edit') {
                context.go('/trips/${_trip!.id}/edit');
              }
            },
            itemBuilder: (ctx) => [
                  const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                          leading: Icon(Icons.edit), title: Text('Edit'))),
                  const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Delete',
                              style: TextStyle(color: Colors.red))))
                ])
      ]),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(slivers: [
                SliverToBoxAdapter(child: _buildHeader(theme)),
                SliverToBoxAdapter(
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(children: [
                          Expanded(
                              child: _StatCard(
                                  icon: Icons.photo_library_outlined,
                                  label: 'Photos',
                                  value: '$photoCount')),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _StatCard(
                                  icon: Icons.location_on_outlined,
                                  label: 'Places',
                                  value: '$citiesCount')),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _StatCard(
                                  icon: Icons.calendar_today_outlined,
                                  label: 'Days',
                                  value: '$daysCount'))
                        ]))),
                SliverToBoxAdapter(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(children: [
                          Expanded(
                              child: OutlinedButton.icon(
                                  onPressed: () => context
                                      .go('/trips/${_trip!.id}/add-photos'),
                                  icon: const Icon(
                                      Icons.add_photo_alternate_outlined),
                                  label: const Text('Add Photos'))),
                          const SizedBox(width: 12),
                          Expanded(
                              child: FilledButton.icon(
                                  onPressed: () =>
                                      context.go('/trips/${_trip!.id}/book'),
                                  icon: const Icon(Icons.menu_book_outlined),
                                  label: const Text('Read Book')))
                        ]))),
                SliverToBoxAdapter(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(children: [
                          Expanded(
                              child: OutlinedButton.icon(
                                  onPressed: () =>
                                      context.go('/trips/${_trip!.id}/memory'),
                                  icon: const Icon(Icons.edit_note_outlined),
                                  label: const Text('Edit Memory')))
                        ]))),
                SliverToBoxAdapter(
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: SectionHeader(
                            title: 'Photos', subtitle: '$photoCount photos'))),
                _photos.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                                child: Column(children: [
                              Icon(Icons.photo_library_outlined,
                                  size: 48,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withOpacity(0.5)),
                              const SizedBox(height: 16),
                              Text('No photos yet',
                                  style: theme.textTheme.titleMedium),
                              const SizedBox(height: 8),
                              FilledButton.icon(
                                  onPressed: () => context
                                      .go('/trips/${_trip!.id}/add-photos'),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Photos'))
                            ]))))
                    : SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final photo = _photos[index];
                          return _PhotoThumbnail(
                              photo: photo,
                              onTap: () => context.go(
                                  '/trips/${_trip!.id}/photos/${photo.id}'));
                        }, childCount: _photos.length),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8)),
              ])),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Stack(children: [
      SizedBox(
          height: 240,
          width: double.infinity,
          child: _trip!.coverPhotoPath != null
              ? Image.file(File(_trip!.coverPhotoPath!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(theme))
              : _buildPlaceholder(theme)),
      SizedBox(
          height: 240,
          width: double.infinity,
          child: DecoratedBox(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.8)
              ])))),
      Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_trip!.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                          color: Colors.black54,
                          blurRadius: 4,
                          offset: Offset(0, 2))
                    ])),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.location_on_outlined, size: 16, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                  '${_trip!.country}${_trip!.cities.isNotEmpty ? ' • ${_trip!.cities.join(', ')}' : ''}',
                  style:
                      theme.textTheme.bodyMedium?.copyWith(color: Colors.white))
            ]),
            const SizedBox(height: 2),
            Text(_trip!.formattedDates,
                style:
                    theme.textTheme.bodyMedium?.copyWith(color: Colors.white70))
          ]))
    ]);
  }

  Widget _buildPlaceholder(ThemeData theme) => Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
          child: Icon(Icons.image_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5))));
}
