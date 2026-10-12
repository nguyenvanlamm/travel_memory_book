import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/book_widgets.dart';
import '../../../models/trip.dart';
import '../providers/home_provider.dart';
import '../providers/library_provider.dart';

const _monthsShort = [
  'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
  'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
];

/// Middle column: search, totals, sort, books grouped by year.
class LibraryList extends ConsumerWidget {
  final List<Trip> trips;

  /// Wide layout: rows select into the detail pane instead of navigating.
  final bool selectable;
  final int? selectedId;
  final Widget? header;

  const LibraryList({
    super.key,
    required this.trips,
    required this.selectable,
    this.selectedId,
    this.header,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    final byYear = <int, List<Trip>>{};
    for (final t in trips) {
      byYear.putIfAbsent(t.startDate.year, () => []).add(t);
    }
    final narrow = MediaQuery.sizeOf(context).width < AppBreakpoints.rail;
    final pad = narrow ? AppSpacing.md : AppSpacing.lg;

    return ColoredBox(
      color: p.paper1,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(pad, pad, pad, AppSpacing.md),
            sliver: SliverList.list(
              children: narrow
                  ? [
                      Row(
                        children: [
                          Expanded(
                              child: Text('Library', style: text.displaySmall)),
                          FilledButton.icon(
                            onPressed: () => context.go('/trips/new'),
                            icon: const Icon(LucideIcons.plus, size: 18),
                            label: const Text('New Book'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Expanded(child: _SearchField()),
                          SizedBox(width: AppSpacing.sm),
                          _SortMenu(),
                        ],
                      ),
                      if (header != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        header!,
                      ],
                    ]
                  : [
                      if (header != null) ...[header!, const SizedBox(height: 20)],
                      const _SearchField(),
                      const SizedBox(height: 20),
                      Text('Library', style: text.displaySmall),
                      const SizedBox(height: AppSpacing.xs),
                      const _TotalsLine(),
                      const SizedBox(height: AppSpacing.md),
                      const _SortRow(),
                    ],
            ),
          ),
          if (trips.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(pad),
                child: Text('No books match this shelf or search.',
                    style: text.bodyMedium?.copyWith(color: p.ink3)),
              ),
            ),
          for (final entry in byYear.entries) ...[
            SliverToBoxAdapter(
              child: _YearHeader(year: entry.key, count: entry.value.length),
            ),
            SliverList.list(
              children: [
                for (final t in entry.value)
                  LibraryRow(
                    trip: t,
                    selected: selectable && t.id == selectedId,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      if (selectable) {
                        ref.read(selectedBookProvider.notifier).state = t.id;
                      } else {
                        context.go('/trips/${t.id}');
                      }
                    },
                  ),
              ],
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        ],
      ),
    );
  }
}

class _SearchField extends ConsumerWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AppPalette.of(context);
    return TextField(
      onChanged: (v) => ref.read(librarySearchProvider.notifier).state = v,
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Search books, places…',
        prefixIcon: Icon(LucideIcons.search, size: 18, color: p.ink3),
      ),
    );
  }
}

class _TotalsLine extends ConsumerWidget {
  const _TotalsLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = ref.watch(libraryTotalsProvider).valueOrNull;
    final p = AppPalette.of(context);
    final base = Theme.of(context).textTheme.bodyMedium?.copyWith(color: p.ink2);
    if (totals == null) return SizedBox(height: base?.fontSize ?? 15);
    String plural(int n, String one, String many) => '$n ${n == 1 ? one : many}';
    final parts = [
      plural(totals.books, 'book', 'books'),
      plural(totals.days, 'day', 'days'),
      plural(totals.countries, 'country', 'countries'),
      plural(totals.photos, 'photo', 'photos'),
      plural(totals.memories, 'memory', 'memories'),
    ];
    return Text.rich(
      TextSpan(children: [
        for (var i = 0; i < parts.length; i++) ...[
          if (i > 0) TextSpan(text: '  /  ', style: TextStyle(color: p.line)),
          TextSpan(
            text: parts[i].split(' ').first,
            style: TextStyle(color: p.ink1, fontWeight: FontWeight.w600),
          ),
          TextSpan(text: ' ${parts[i].split(' ').last}'),
        ],
      ]),
      style: base,
    );
  }
}

class _SortRow extends ConsumerWidget {
  const _SortRow();

  static const _options = {
    'newest': 'Newest first',
    'oldest': 'Oldest first',
    'year': 'By year',
    'country': 'By country',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(homeProvider.notifier);
    ref.watch(homeProvider);
    final p = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 4,
      children: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Icon(LucideIcons.arrowUpDown, size: 16, color: p.ink3),
          ),
          for (final e in _options.entries)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Material(
                color: notifier.sortBy == e.key ? p.ink1 : Colors.transparent,
                shape: const StadiumBorder(),
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: () => notifier.setSortBy(e.key),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      e.value,
                      style: text.labelLarge?.copyWith(
                        color: notifier.sortBy == e.key ? p.paper0 : p.ink2,
                        fontWeight: notifier.sortBy == e.key
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

/// Phone: sorting folds into an icon button beside search.
class _SortMenu extends ConsumerWidget {
  const _SortMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(homeProvider.notifier);
    ref.watch(homeProvider);
    final p = AppPalette.of(context);
    return PopupMenuButton<String>(
      tooltip: 'Sort books',
      initialValue: notifier.sortBy,
      onSelected: notifier.setSortBy,
      itemBuilder: (_) => [
        for (final e in _SortRow._options.entries)
          PopupMenuItem(value: e.key, child: Text(e.value)),
      ],
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: p.paper0,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: p.line),
        ),
        child: Icon(LucideIcons.arrowUpDown, size: 18, color: p.ink2),
      ),
    );
  }
}

class _YearHeader extends StatelessWidget {
  final int year;
  final int count;
  const _YearHeader({required this.year, required this.count});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    final pad = MediaQuery.sizeOf(context).width < AppBreakpoints.rail
        ? AppSpacing.md
        : AppSpacing.lg;
    return Container(
      padding: EdgeInsets.fromLTRB(pad, 14, pad, 6),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.line)),
      ),
      child: Row(
        children: [
          Expanded(
              child: Text('$year',
                  style: text.titleMedium?.copyWith(fontSize: 16))),
          Text('$count ${count == 1 ? 'book' : 'books'}', style: text.bodySmall),
        ],
      ),
    );
  }
}

/// One book in the list: date column, title, counts, mini book.
class LibraryRow extends ConsumerWidget {
  final Trip trip;
  final bool selected;
  final VoidCallback onTap;

  const LibraryRow({
    super.key,
    required this.trip,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    final summary = ref.watch(tripSummaryProvider(trip.id)).valueOrNull;
    final cloth = watchCloth(ref, trip);
    final s = trip.startDate, e = trip.endDate;
    final month = s.month == e.month
        ? _monthsShort[s.month - 1]
        : '${_monthsShort[s.month - 1]}–${_monthsShort[e.month - 1]}';
    final days = s.day == e.day && s.month == e.month ? '${s.day}' : '${s.day}–${e.day}';
    final ink = selected ? p.parch : p.ink1;
    final ink2 = selected ? cloth.mute : p.ink2;
    final ink3 = selected ? cloth.mute : p.ink3;
    final place = [
      if (trip.cities.isNotEmpty) trip.cities.first,
      if (trip.country.isNotEmpty) trip.country,
    ].join(', ');
    final meta = [
      '${trip.durationInDays} ${trip.durationInDays == 1 ? 'day' : 'days'}',
      if (summary != null) '${summary.photoCount} photos',
      if (summary != null)
        '${summary.memoryCount} ${summary.memoryCount == 1 ? 'memory' : 'memories'}',
    ].join(' · ');
    final pad = MediaQuery.sizeOf(context).width < AppBreakpoints.rail
        ? AppSpacing.md
        : AppSpacing.lg;

    return Material(
      color: selected ? cloth.deep : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 92),
          padding: EdgeInsets.symmetric(horizontal: pad, vertical: 8),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: selected ? cloth.deep : p.line)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 62,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(month,
                        style: text.labelMedium?.copyWith(color: ink3)),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(days,
                          style: text.titleLarge?.copyWith(
                              fontWeight: FontWeight.w500, color: ink)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trip.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium?.copyWith(color: ink)),
                    if (place.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(place,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyMedium?.copyWith(color: ink2)),
                    ],
                    const SizedBox(height: 2),
                    Text(meta, style: text.bodySmall?.copyWith(color: ink3)),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              BookMini(trip: trip, photoCount: summary?.photoCount ?? 0),
            ],
          ),
        ),
      ),
    );
  }
}
