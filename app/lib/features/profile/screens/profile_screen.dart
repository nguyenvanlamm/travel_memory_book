import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/book_widgets.dart';
import '../../../core/widgets/loading_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/web_layout.dart';
import '../../../repositories/trip_repository.dart';
import '../../../repositories/photo_repository.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _tripCount = 0, _photoCount = 0, _countryCount = 0, _cityCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final trips = await ref.read(tripRepositoryProvider).getAll();
      final countries = <String>{}, cities = <String>{};
      int photos = 0;
      for (final trip in trips) {
        countries.add(trip.country);
        cities.addAll(trip.cities);
        photos += await ref.read(photoRepositoryProvider).countByTrip(trip.id);
      }
      if (mounted) {
        setState(() {
          _tripCount = trips.length;
          _photoCount = photos;
          _countryCount = countries.length;
          _cityCount = cities.length;
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
    return Scaffold(
      body: _isLoading
          ? const Center(child: LoadingView())
          : PageBody(
              maxWidth: 760,
              child: ListView(children: [
                const PageHeader(
                    title: 'Journey stats',
                    subtitle: 'Everything you have kept, counted.'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Wrap(
                      spacing: 40,
                      runSpacing: AppSpacing.md,
                      children: [
                        StatBlock(value: '$_tripCount', label: 'books'),
                        StatBlock(value: '$_countryCount', label: 'countries'),
                        StatBlock(value: '$_cityCount', label: 'places'),
                        StatBlock(value: '$_photoCount', label: 'photos'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Quick Actions'),
                const SizedBox(height: 12),
                Row(children: [
                  FilledButton.icon(
                      onPressed: () => context.go('/trips/new'),
                      icon: const Icon(LucideIcons.plus),
                      label: const Text('New Book'),
                      style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16))),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(LucideIcons.library),
                      label: const Text('View Library'),
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16))),
                ]),
                const SizedBox(height: 24),
                const SectionHeader(title: 'About'),
                Card(
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text('Travel Memory Book',
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(
                                          fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Text(
                                  'A simple tool that turns your travel photos into digital flip books.',
                                  style: theme.textTheme.bodyMedium),
                              const SizedBox(height: 16),
                              Text('Version 1.0.0',
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(
                                          color: theme.colorScheme
                                              .onSurfaceVariant)),
                              Text('Built with Flutter',
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(
                                          color: theme.colorScheme
                                              .onSurfaceVariant)),
                            ]))),
                const SizedBox(height: 48),
              ]),
            ),
    );
  }
}
