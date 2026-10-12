import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../features/home/providers/home_provider.dart';
import '../../features/home/providers/library_provider.dart';
import '../../models/trip.dart';
import '../theme/app_theme.dart';
import 'book_widgets.dart';

final _tripPath = RegExp(r'^/trips/(\d+)');

int? _tripIdIn(String location) {
  final m = _tripPath.firstMatch(location);
  return m == null ? null : int.tryParse(m.group(1)!);
}

enum _Section { library, stats, settings }

_Section _sectionOf(String location) {
  if (location.startsWith('/profile')) return _Section.stats;
  if (location.startsWith('/settings')) return _Section.settings;
  return _Section.library;
}

void _goSection(BuildContext context, _Section s) {
  HapticFeedback.selectionClick();
  context.go(switch (s) {
    _Section.library => '/',
    _Section.stats => '/profile',
    _Section.settings => '/settings',
  });
}

/// Day One–style frame: drawer (wide), rail (medium) or tab bar (phone).
class AppShell extends ConsumerStatefulWidget {
  final String location;
  final Widget child;

  const AppShell({super.key, required this.location, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  @override
  void didUpdateWidget(AppShell old) {
    super.didUpdateWidget(old);
    if (old.location == widget.location) return;
    // The drawer and rail keep the trip list alive across pages, so reload it
    // after every navigation: books created, edited or deleted elsewhere show up.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(homeProvider.notifier).loadTrips();
      ref.invalidate(libraryTotalsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = widget.location;
    final child = widget.child;
    final width = MediaQuery.sizeOf(context).width;
    final section = _sectionOf(location);
    final tripId = _tripIdIn(location);

    if (width < AppBreakpoints.rail) {
      // Pushed pages (a book, a form, a photo) give the screen to the content.
      final topLevel = !location.startsWith('/trips/');
      return Scaffold(
        body: SafeArea(bottom: !topLevel, child: child),
        bottomNavigationBar: !topLevel ? null : NavigationBar(
          selectedIndex: section.index,
          onDestinationSelected: (i) => _goSection(context, _Section.values[i]),
          destinations: const [
            NavigationDestination(
                icon: Icon(LucideIcons.library), label: 'Library'),
            NavigationDestination(
                icon: Icon(LucideIcons.barChart2), label: 'Journey stats'),
            NavigationDestination(
                icon: Icon(LucideIcons.settings2), label: 'Settings'),
          ],
        ),
      );
    }

    final useDrawer = width >= AppBreakpoints.drawer && tripId == null;
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          useDrawer
              ? LibraryDrawer(section: section)
              : BookRail(section: section, currentTripId: tripId),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  final bool withName;
  const _BrandMark({this.withName = true});

  @override
  Widget build(BuildContext context) {
    final mark = SvgPicture.asset(
      'assets/images/logo-mark.svg',
      width: 30,
      height: 30,
      semanticsLabel: 'Travel Memory Book',
    );
    if (!withName) return mark;
    return Row(
      children: [
        mark,
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            'Travel Memory Book',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontSize: 16),
          ),
        ),
      ],
    );
  }
}

/// "Kept on this device…" — the promise the whole product rests on.
class PrivacyNote extends StatelessWidget {
  final Color? color;
  const PrivacyNote({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppPalette.of(context).ink3;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(LucideIcons.lock, size: 15, color: c),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Kept on this device. No account, no cloud. Only you read these books.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c),
          ),
        ),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? p.paper0 : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: selected ? p.line : Colors.transparent),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: selected ? p.ink1 : p.ink2),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(label,
                        style: text.bodyMedium?.copyWith(
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                          color: selected ? p.ink1 : p.ink2,
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Wide-screen drawer: brand, New Book, sections, shelves by year.
class LibraryDrawer extends ConsumerWidget {
  final _Section section;
  const LibraryDrawer({super.key, required this.section});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    final trips = ref.watch(homeProvider).valueOrNull ?? const <Trip>[];
    final totals = ref.watch(libraryTotalsProvider).valueOrNull;
    final year = ref.watch(libraryYearProvider);
    final byYear = <int, List<Trip>>{};
    for (final t in trips) {
      byYear.putIfAbsent(t.startDate.year, () => []).add(t);
    }
    final years = byYear.keys.toList()..sort((a, b) => b.compareTo(a));

    return Container(
      width: 256,
      decoration: BoxDecoration(
        color: p.paper2,
        border: Border(right: BorderSide(color: p.line)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _BrandMark(),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: () => context.go('/trips/new'),
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('New Book'),
          ),
          const SizedBox(height: AppSpacing.md),
          _NavTile(
            icon: LucideIcons.library,
            label: 'Library',
            selected: section == _Section.library,
            onTap: () => _goSection(context, _Section.library),
          ),
          _NavTile(
            icon: LucideIcons.barChart2,
            label: 'Journey stats',
            selected: section == _Section.stats,
            onTap: () => _goSection(context, _Section.stats),
          ),
          _NavTile(
            icon: LucideIcons.settings2,
            label: 'Settings',
            selected: section == _Section.settings,
            onTap: () => _goSection(context, _Section.settings),
          ),
          if (trips.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: AppSpacing.sm),
              child: Text('SHELVES', style: text.labelMedium),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _ShelfTile(
                    label: 'All books',
                    count: trips.length,
                    trips: trips,
                    selected: section == _Section.library && year == null,
                    onTap: () {
                      ref.read(libraryYearProvider.notifier).state = null;
                      _goSection(context, _Section.library);
                    },
                  ),
                  for (final y in years)
                    _ShelfTile(
                      label: '$y',
                      detail: totals?.byYear[y] == null
                          ? null
                          : '${totals!.byYear[y]!.days} days · ${totals.byYear[y]!.photos} photos',
                      count: byYear[y]!.length,
                      trips: byYear[y]!,
                      selected: section == _Section.library && year == y,
                      onTap: () {
                        ref.read(libraryYearProvider.notifier).state = y;
                        _goSection(context, _Section.library);
                      },
                    ),
                  if (totals != null && totals.byCountry.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 20, 12, 6),
                      child: Text('COUNTRIES', style: text.labelMedium),
                    ),
                    for (final e in totals.byCountry.entries)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(e.key,
                                  style: text.bodyMedium?.copyWith(color: p.ink2)),
                            ),
                            Text('${e.value}', style: text.bodySmall),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
            Divider(color: p.line),
          ] else
            const Spacer(),
          const SizedBox(height: AppSpacing.md),
          const PrivacyNote(),
        ],
      ),
    );
  }
}

class _ShelfTile extends StatelessWidget {
  final String label;
  final String? detail;
  final int count;
  final List<Trip> trips;
  final bool selected;
  final VoidCallback onTap;

  const _ShelfTile({
    required this.label,
    this.detail,
    required this.count,
    required this.trips,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: selected ? p.paper0.withValues(alpha: 0.7) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Row(
                      children: [
                        for (final t in trips.take(4))
                          Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: _SpineBar(trip: t),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(label,
                            style: text.bodyMedium?.copyWith(
                              color: selected ? p.ink1 : p.ink2,
                              fontWeight:
                                  selected ? FontWeight.w600 : FontWeight.w500,
                            )),
                        if (detail != null)
                          Text(detail!, style: text.bodySmall),
                      ],
                    ),
                  ),
                  Text('$count',
                      style: text.bodySmall
                          ?.copyWith(color: selected ? p.ink1 : p.ink3)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpineBar extends ConsumerWidget {
  final Trip trip;
  const _SpineBar({required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cloth = watchCloth(ref, trip);
    return Container(
      width: 5,
      height: 18,
      decoration: BoxDecoration(
        color: cloth.of(context),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

/// Collapsed drawer: section icons and one cloth chip per book.
class BookRail extends ConsumerWidget {
  final _Section section;
  final int? currentTripId;

  const BookRail({super.key, required this.section, this.currentTripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AppPalette.of(context);
    final trips = ref.watch(homeProvider).valueOrNull ?? const <Trip>[];

    Widget navButton(IconData icon, String label, _Section s) {
      final selected = section == s && currentTripId == null;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: IconButton(
          tooltip: label,
          onPressed: () => _goSection(context, s),
          isSelected: selected,
          style: IconButton.styleFrom(
            backgroundColor: selected ? p.paper0 : Colors.transparent,
            side: BorderSide(color: selected ? p.line : Colors.transparent),
          ),
          icon: Icon(icon, size: 20, color: selected ? p.ink1 : p.ink2),
        ),
      );
    }

    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: p.paper2,
        border: Border(right: BorderSide(color: p.line)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Tooltip(
            message: 'Library',
            child: InkWell(
              onTap: () => _goSection(context, _Section.library),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: _BrandMark(withName: false),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          IconButton.filled(
            tooltip: 'New Book',
            onPressed: () => context.go('/trips/new'),
            icon: const Icon(LucideIcons.plus, size: 20),
          ),
          const SizedBox(height: AppSpacing.sm),
          navButton(LucideIcons.library, 'Library', _Section.library),
          navButton(LucideIcons.barChart2, 'Journey stats', _Section.stats),
          navButton(LucideIcons.settings2, 'Settings', _Section.settings),
          if (trips.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(width: 32, child: Divider(color: p.line)),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final t in trips)
                    Center(
                      child: Tooltip(
                        message: t.title,
                        child: InkWell(
                          onTap: () => context.go('/trips/${t.id}'),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: ClothChip(
                                trip: t, selected: t.id == currentTripId),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
