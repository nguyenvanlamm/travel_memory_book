import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../features/home/screens/home_screen.dart';
import '../../features/trips/screens/trip_form_screen.dart';
import '../../features/trips/screens/trip_detail_screen.dart';
import '../../features/photos/screens/add_photos_screen.dart';
import '../../features/photos/screens/photo_detail_screen.dart';
import '../../features/travel_book/screens/book_viewer_screen.dart';
import '../../features/memories/screens/memory_editor_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _BottomNavShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/trips',
          name: 'trips',
          builder: (context, state) => const HomeScreen(), // Redirect to home
        ),
        GoRoute(
          path: '/memories',
          name: 'memories',
          builder: (context, state) => const _MemoriesPlaceholder(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    // Trip routes
    GoRoute(
      path: '/trips/new',
      name: 'trip_create',
      builder: (context, state) => const TripFormScreen(),
    ),
    GoRoute(
      path: '/trips/:tripId/edit',
      name: 'trip_edit',
      builder: (context, state) {
        final tripId = int.parse(state.pathParameters['tripId']!);
        return TripFormScreen(trip: null); // We'll load the trip in the screen
      },
    ),
    GoRoute(
      path: '/trips/:tripId',
      name: 'trip_detail',
      builder: (context, state) {
        final tripId = int.parse(state.pathParameters['tripId']!);
        return TripDetailScreen(tripId: tripId);
      },
    ),
    GoRoute(
      path: '/trips/:tripId/add-photos',
      name: 'add_photos',
      builder: (context, state) {
        final tripId = int.parse(state.pathParameters['tripId']!);
        return AddPhotosScreen(tripId: tripId);
      },
    ),
    GoRoute(
      path: '/trips/:tripId/photos/:photoId',
      name: 'photo_detail',
      builder: (context, state) {
        final tripId = int.parse(state.pathParameters['tripId']!);
        final photoId = int.parse(state.pathParameters['photoId']!);
        return PhotoDetailScreen(tripId: tripId, photoId: photoId);
      },
    ),
    GoRoute(
      path: '/trips/:tripId/book',
      name: 'book_viewer',
      builder: (context, state) {
        final tripId = int.parse(state.pathParameters['tripId']!);
        return BookViewerScreen(tripId: tripId);
      },
    ),
    GoRoute(
      path: '/trips/:tripId/memory',
      name: 'trip_memory',
      builder: (context, state) {
        final tripId = int.parse(state.pathParameters['tripId']!);
        return MemoryEditorScreen(tripId: tripId, date: null);
      },
    ),
    GoRoute(
      path: '/trips/:tripId/memory/:date',
      name: 'day_memory',
      builder: (context, state) {
        final tripId = int.parse(state.pathParameters['tripId']!);
        final dateStr = state.pathParameters['date']!;
        final date = DateTime.parse(dateStr);
        return MemoryEditorScreen(tripId: tripId, date: date);
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

class _BottomNavShell extends StatelessWidget {
  final Widget child;
  const _BottomNavShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    int currentIndex = 0;
    if (location.startsWith('/memories')) currentIndex = 1;
    else if (location.startsWith('/profile')) currentIndex = 2;
    else if (location.startsWith('/settings')) currentIndex = 3;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0: context.go('/'); break;
            case 1: context.go('/memories'); break;
            case 2: context.go('/profile'); break;
            case 3: context.go('/settings'); break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.library_books_outlined), activeIcon: Icon(Icons.library_books), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), activeIcon: Icon(Icons.favorite), label: 'Memories'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => context.go('/trips/new'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _MemoriesPlaceholder extends StatelessWidget {
  const _MemoriesPlaceholder();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Memories')),
    body: const Center(child: Text('Memories - Coming Soon')),
  );
}
