import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../widgets/web_layout.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/trips/screens/trip_form_screen.dart';
import '../../features/trips/screens/trip_detail_screen.dart';
import '../../features/photos/screens/add_photos_screen.dart';
import '../../features/photos/screens/photo_detail_screen.dart';
import '../../features/travel_book/screens/book_viewer_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _SiteShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/trips',
          name: 'trips',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/trips/new',
          name: 'trip_create',
          builder: (context, state) => const TripFormScreen(),
        ),
        GoRoute(
          path: '/trips/:tripId/edit',
          name: 'trip_edit',
          builder: (context, state) {
            return TripFormScreen(trip: null);
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
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    // Fullscreen book reader — no site chrome
    GoRoute(
      path: '/trips/:tripId/book',
      name: 'book_viewer',
      builder: (context, state) {
        final tripId = int.parse(state.pathParameters['tripId']!);
        return BookViewerScreen(tripId: tripId);
      },
    ),
  ],
);

class _SiteShell extends StatelessWidget {
  final Widget child;
  const _SiteShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SiteHeader(),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                const WebBackdrop(),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
