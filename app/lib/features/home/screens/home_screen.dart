import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/empty_state.dart';
import '../widgets/trip_card.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(homeProvider);
    final notifier = ref.read(homeProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Memory Book'),
        actions: [PopupMenuButton<String>(initialValue: notifier.sortBy, onSelected: notifier.setSortBy, itemBuilder: (context) => const [PopupMenuItem(value: 'newest', child: Text('Newest first')), PopupMenuItem(value: 'oldest', child: Text('Oldest first')), PopupMenuItem(value: 'year', child: Text('By year')), PopupMenuItem(value: 'country', child: Text('By country'))], icon: const Icon(Icons.sort), tooltip: 'Sort trips')],
      ),
      body: tripsAsync.when(
        data: (trips) {
          if (trips.isEmpty) return EmptyState(icon: Icons.library_books_outlined, title: 'No trips yet', message: 'Start preserving your travel memories by creating your first trip.', actionLabel: 'Create your first trip', onAction: () => context.go('/trips/new'));
          return RefreshIndicator(onRefresh: notifier.loadTrips, child: GridView.builder(padding: const EdgeInsets.all(16), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 16, mainAxisSpacing: 16), itemCount: trips.length, itemBuilder: (context, index) => TripCard(trip: trips[index], onTap: () => context.go('/trips/${trips[index].id}'))));
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => EmptyState(icon: Icons.error_outlined, title: 'Error loading trips', message: error.toString(), actionLabel: 'Retry', onAction: notifier.loadTrips),
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => context.go('/trips/new'), icon: const Icon(Icons.add), label: const Text('New Trip')),
    );
  }
}
