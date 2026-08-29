import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Root shell with bottom nav
    ShellRoute(
      builder: (context, state, child) => _BottomNavShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const _HomePlaceholder(),
        ),
        GoRoute(
          path: '/trips',
          name: 'trips',
          builder: (context, state) => const _TripsPlaceholder(),
        ),
        GoRoute(
          path: '/memories',
          name: 'memories',
          builder: (context, state) => const _MemoriesPlaceholder(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const _ProfilePlaceholder(),
        ),
      ],
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
    if (location.startsWith('/trips')) currentIndex = 1;
    else if (location.startsWith('/memories')) currentIndex = 2;
    else if (location.startsWith('/profile')) currentIndex = 3;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0: context.go('/'); break;
            case 1: context.go('/trips'); break;
            case 2: context.go('/memories'); break;
            case 3: context.go('/profile'); break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Trips'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Memories'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Travel Memory Book')),
    body: const Center(child: Text('Home - Trip Library')),
    floatingActionButton: FloatingActionButton(
      onPressed: () => context.go('/trips/new'),
      child: const Icon(Icons.add),
    ),
  );
}

class _TripsPlaceholder extends StatelessWidget {
  const _TripsPlaceholder();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My Trips')),
    body: const Center(child: Text('Trips List')),
  );
}

class _MemoriesPlaceholder extends StatelessWidget {
  const _MemoriesPlaceholder();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Memories')),
    body: const Center(child: Text('Memories')),
  );
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: const Center(child: Text('Profile')),
  );
}
