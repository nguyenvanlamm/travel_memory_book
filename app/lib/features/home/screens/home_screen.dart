import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/book_cloth.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/book_widgets.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../models/trip.dart';
import '../providers/home_provider.dart';
import '../providers/library_provider.dart';
import '../widgets/library_list.dart';
import '../widgets/selected_book_pane.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(homeProvider);
    return tripsAsync.when(
      loading: () => const LoadingView(),
      error: (error, _) => EmptyState(
        icon: LucideIcons.alertTriangle,
        title: 'The library could not be opened',
        message: error.toString(),
        actionLabel: 'Retry',
        onAction: ref.read(homeProvider.notifier).loadTrips,
      ),
      data: (trips) =>
          trips.isEmpty ? const LibraryEmpty() : _Library(trips: trips),
    );
  }
}

class _Library extends ConsumerWidget {
  final List<Trip> trips;
  const _Library({required this.trips});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final year = ref.watch(libraryYearProvider);
    final query = ref.watch(librarySearchProvider).trim().toLowerCase();
    final shown = trips.where((t) {
      if (year != null && t.startDate.year != year) return false;
      if (query.isEmpty) return true;
      return [t.title, t.country, ...t.cities]
          .any((s) => s.toLowerCase().contains(query));
    }).toList();
    final newestId = (trips.toList()
          ..sort((a, b) => b.startDate.compareTo(a.startDate)))
        .first
        .id;

    return LayoutBuilder(builder: (context, constraints) {
      final narrow = MediaQuery.sizeOf(context).width < AppBreakpoints.rail;
      if (constraints.maxWidth < 900) {
        return LibraryList(
          trips: shown,
          selectable: false,
          header: narrow ? _PhoneHeader(newestId: newestId) : null,
        );
      }
      final selectedId = ref.watch(selectedBookProvider);
      final selected = shown.where((t) => t.id == selectedId).firstOrNull ??
          (shown.isEmpty ? null : shown.first);
      final listWidth = (constraints.maxWidth * 0.44).clamp(380.0, 520.0);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: listWidth,
            child: LibraryList(
              trips: shown,
              selectable: true,
              selectedId: selected?.id,
            ),
          ),
          VerticalDivider(width: 1, color: AppPalette.of(context).line),
          Expanded(
            child: selected == null
                ? const SizedBox.shrink()
                : SelectedBookPane(
                    key: ValueKey(selected.id),
                    trip: selected,
                    isNewest: selected.id == newestId,
                  ),
          ),
        ],
      );
    });
  }
}

/// Phone: the after-trip to-do for the newest book, in its cloth.
class _PhoneHeader extends ConsumerWidget {
  final int newestId;
  const _PhoneHeader({required this.newestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(tripSummaryProvider(newestId)).valueOrNull;
    if (summary == null || summary.unwrittenChapters.isEmpty) {
      return const SizedBox.shrink();
    }
    return ContinueCard(summary: summary, onCloth: true);
  }
}

/// No books yet. Wide: the three panes stay, with a New Book row and the
/// empty book in earth cloth. Narrow: the empty book on a band, then the CTA.
class LibraryEmpty extends StatelessWidget {
  const LibraryEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth >= 900) return const _EmptyWide();
      return const _EmptyNarrow();
    });
  }
}

void _create(BuildContext context) => context.go('/trips/new');

class _EmptyCopy extends StatelessWidget {
  final bool onCloth;
  const _EmptyCopy({required this.onCloth});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    final narrow = MediaQuery.sizeOf(context).width < AppBreakpoints.rail;
    final mute = onCloth ? BookCloth.earth.mute : p.ink2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onCloth) ...[
          Text('YOUR FIRST BOOK', style: text.labelMedium?.copyWith(color: p.gold)),
          const SizedBox(height: AppSpacing.sm),
        ],
        Text('Turn your trips into books',
            style: (narrow ? text.headlineMedium : text.displaySmall)
                ?.copyWith(color: onCloth ? p.parch : p.ink1)),
        const SizedBox(height: 12),
        Text(
          'Select your travel photos and flip through them like a real photo book.',
          style: text.bodyLarge?.copyWith(color: mute),
        ),
        const SizedBox(height: AppSpacing.lg),
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: narrow ? double.infinity : null,
            child: FilledButton.icon(
              onPressed: () => _create(context),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Create your first book'),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        PrivacyNote(color: onCloth ? mute : null),
      ],
    );
  }
}

class _EmptyWide extends StatelessWidget {
  const _EmptyWide();

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    final earth = BookCloth.earth;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 440,
          child: ColoredBox(
            color: p.paper1,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Library', style: text.displaySmall),
                      const SizedBox(height: AppSpacing.xs),
                      Text('No books yet',
                          style: text.bodyMedium?.copyWith(color: p.ink2)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Material(
                  color: earth.deep,
                  child: InkWell(
                    onTap: () => _create(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: earth.mute),
                            ),
                            child: Icon(LucideIcons.plus,
                                size: 18, color: p.parch),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('New Book',
                                    style: text.titleMedium
                                        ?.copyWith(color: p.parch)),
                                Text('No photos yet',
                                    style: text.bodyMedium
                                        ?.copyWith(color: earth.mute)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Icon(LucideIcons.library, size: 16, color: p.ink3),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                            'Books are shelved here by year, newest first.',
                            style: text.bodyMedium?.copyWith(color: p.ink2)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        VerticalDivider(width: 1, color: p.line),
        Expanded(
          child: ColoredBox(
            color: earth.deep,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(48),
                child: Wrap(
                  spacing: 48,
                  runSpacing: AppSpacing.xl,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const EmptyHardcover(width: 230),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: const _EmptyCopy(onCloth: true),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyNarrow extends StatelessWidget {
  const _EmptyNarrow();

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    return ColoredBox(
      color: p.paper1,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, 20),
            child: Text('Library', style: text.displaySmall),
          ),
          Container(
            color: BookCloth.earth.deep,
            padding: const EdgeInsets.symmetric(vertical: 36),
            alignment: Alignment.center,
            child: const EmptyHardcover(width: 170),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: const _EmptyCopy(onCloth: false),
            ),
          ),
        ],
      ),
    );
  }
}
