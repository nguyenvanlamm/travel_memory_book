import '../../../models/trip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/image_helper.dart';
import '../../../core/widgets/web_layout.dart';

import '../../../models/photo.dart';
import '../../../repositories/trip_repository.dart';
import '../../../repositories/photo_repository.dart';

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
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, size: 26, color: theme.colorScheme.primary),
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
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            appImage(photo.thumbnailPath,
                fit: BoxFit.cover,
                fallback: Container(color: Colors.grey.shade200)),
            Positioned(
              bottom: 6,
              right: 6,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6)),
                child: Text('Day ${photo.day}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
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

  Future<void> _deleteTrip() async {
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
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.red),
                      child: const Text('Delete'))
                ]));
    if (confirm == true) {
      await ref.read(tripRepositoryProvider).delete(_trip!.id);
      if (mounted) context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    if (_trip == null) {
      return Scaffold(
        body: PageBody(
          maxWidth: 640,
          child: Column(
            children: [
              PageHeader(
                  title: 'Trip Not Found',
                  onBack: () => context.go('/')),
              const Text('This trip does not exist.'),
            ],
          ),
        ),
      );
    }
    final trip = _trip!;
    final photoCount = _photos.length;

    return Scaffold(
      body: PageBody(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: PageHeader(
                title: trip.title,
                subtitle:
                    '${trip.country}${trip.cities.isNotEmpty ? ' • ${trip.cities.join(', ')}' : ''} • ${trip.formattedDates}',
                onBack: () => context.go('/'),
                actions: [
                  IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit trip',
                      onPressed: () =>
                          context.go('/trips/${trip.id}/edit')),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'delete') _deleteTrip();
                    },
                    itemBuilder: (ctx) => const [
                      PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                              leading:
                                  Icon(Icons.delete, color: Colors.red),
                              title: Text('Delete',
                                  style: TextStyle(color: Colors.red))))
                    ],
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(child: _buildCover(theme, trip)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
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
                        value: '${trip.cities.length}')),
                const SizedBox(width: 12),
                Expanded(
                    child: _StatCard(
                        icon: Icons.calendar_today_outlined,
                        label: 'Days',
                        value: '${trip.durationInDays}')),
              ]),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: Row(children: [
                FilledButton.icon(
                    onPressed: () =>
                        context.go('/trips/${trip.id}/book'),
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('Read Book'),
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16))),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                    onPressed: () =>
                        context.go('/trips/${trip.id}/add-photos'),
                    icon: const Icon(
                        Icons.add_photo_alternate_outlined),
                    label: const Text('Add Photos'),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16))),
              ]),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            SliverToBoxAdapter(
              child: Text('Photos',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            _photos.isEmpty
                ? SliverToBoxAdapter(
                    child: Container(
                        padding: const EdgeInsets.all(48),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color:
                                  theme.colorScheme.outlineVariant),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(children: [
                          Icon(Icons.photo_library_outlined,
                              size: 48,
                              color: theme
                                  .colorScheme.onSurfaceVariant
                                  .withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text('No photos yet',
                              style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text('Add photos to fill your book.',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(
                                      color: theme.colorScheme
                                          .onSurfaceVariant)),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                              onPressed: () => context.go(
                                  '/trips/${trip.id}/add-photos'),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Photos'))
                        ])))
                : SliverGrid(
                    delegate:
                        SliverChildBuilderDelegate((context, index) {
                      final photo = _photos[index];
                      return _PhotoThumbnail(
                          photo: photo,
                          onTap: () => context.go(
                              '/trips/${trip.id}/photos/${photo.id}'));
                    }, childCount: _photos.length),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12)),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(ThemeData theme, Trip trip) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 300,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            trip.coverPhotoPath != null
                ? appImage(trip.coverPhotoPath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    fallback: _buildPlaceholder(theme))
                : _buildPlaceholder(theme),
            DecoratedBox(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.6)
                ]))),
            Positioned(
                bottom: 20,
                left: 24,
                right: 24,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trip.title,
                          style: theme.textTheme.headlineMedium
                              ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  shadows: [
                                const Shadow(
                                    color: Colors.black54,
                                    blurRadius: 4,
                                    offset: Offset(0, 2))
                              ])),
                      const SizedBox(height: 4),
                      Text(trip.formattedDates,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70))
                    ]))
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) => Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
          child: Icon(Icons.image_outlined,
              size: 64,
              color:
                  theme.colorScheme.onSurfaceVariant.withOpacity(0.5))));
}
