import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/section_header.dart';
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
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Icon(icon, size: 32, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(value,
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(label,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant))
            ])));
  }
}

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
        photos += await ref.read(photoRepositoryProvider).countByTrip(trip.id!);
      }
      if (mounted)
        setState(() {
          _tripCount = trips.length;
          _photoCount = photos;
          _countryCount = countries.length;
          _cityCount = cities.length;
          _isLoading = false;
        });
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
        appBar: AppBar(title: const Text('Profile'), actions: [
          IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.go('/settings'))
        ]),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadStats,
                child: ListView(padding: const EdgeInsets.all(16), children: [
                  Card(
                      child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(children: [
                            CircleAvatar(
                                radius: 48,
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                child: Icon(Icons.person,
                                    size: 48,
                                    color:
                                        theme.colorScheme.onPrimaryContainer)),
                            const SizedBox(height: 16),
                            Text('Traveler',
                                style: theme.textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Text('Your journeys, preserved.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant)),
                          ]))),
                  const SizedBox(height: 24),
                  SectionHeader(title: 'Your Journey'),
                  Row(children: [
                    Expanded(
                        child: _StatCard(
                            icon: Icons.library_books_outlined,
                            label: 'Trips',
                            value: '$_tripCount')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _StatCard(
                            icon: Icons.public_outlined,
                            label: 'Countries',
                            value: '$_countryCount'))
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                        child: _StatCard(
                            icon: Icons.location_city_outlined,
                            label: 'Cities',
                            value: '$_cityCount')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _StatCard(
                            icon: Icons.photo_library_outlined,
                            label: 'Photos',
                            value: '$_photoCount'))
                  ]),
                  const SizedBox(height: 24),
                  SectionHeader(title: 'Quick Actions'),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                        child: OutlinedButton.icon(
                            onPressed: () => context.go('/trips/new'),
                            icon: const Icon(Icons.add),
                            label: const Text('New Trip'))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: OutlinedButton.icon(
                            onPressed: () => context.go('/trips'),
                            icon: const Icon(Icons.map_outlined),
                            label: const Text('View All Trips'))),
                  ]),
                  const SizedBox(height: 24),
                  SectionHeader(title: 'About'),
                  Card(
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Travel Memory Book',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Text(
                                    'A personal travel journal that turns your trips into digital photo books.',
                                    style: theme.textTheme.bodyMedium),
                                const SizedBox(height: 16),
                                Text('Version 1.0.0',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme
                                            .colorScheme.onSurfaceVariant)),
                                Text('Built with Flutter & Isar',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme
                                            .colorScheme.onSurfaceVariant)),
                              ]))),
                ])));
  }
}
