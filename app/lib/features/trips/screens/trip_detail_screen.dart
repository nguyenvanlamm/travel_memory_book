import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/image_helper.dart';
import '../../../core/widgets/book_widgets.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../repositories/trip_repository.dart';
import '../../home/providers/home_provider.dart';
import '../../home/providers/library_provider.dart';
import '../../home/widgets/selected_book_pane.dart';
import '../widgets/chapter_view.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  final int tripId;
  const TripDetailScreen({super.key, required this.tripId});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  int? _day;
  int _tab = 0;

  Future<void> _deleteTrip(TripSummary summary) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this book?'),
        content: Text(
            '“${summary.trip.title}” and all ${summary.photoCount} of its photos will be removed from this device.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(tripRepositoryProvider).delete(summary.trip.id);
      ref.invalidate(homeProvider);
      ref.invalidate(libraryTotalsProvider);
      if (mounted) context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(tripSummaryProvider(widget.tripId));
    final p = AppPalette.of(context);
    return async.when(
      loading: () => const LoadingView(),
      error: (e, _) => Center(child: Text('Could not open this book: $e')),
      data: (summary) {
        if (summary == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('This book does not exist.',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(LucideIcons.arrowLeft, size: 18),
                  label: const Text('Back to the library'),
                ),
              ],
            ),
          );
        }
        return LayoutBuilder(builder: (context, c) {
          final twoPane = c.maxWidth >= 1080;
          final day = (_day ??
                  (summary.chapters.where((ch) => ch.hasMemory).firstOrNull ??
                          summary.chapters.firstOrNull)
                      ?.day ??
                  1)
              .clamp(1, summary.dayCount);

          void selectDay(int d) {
            HapticFeedback.selectionClick();
            if (twoPane) {
              setState(() => _day = d);
            } else {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ChapterPage(tripId: summary.trip.id, day: d),
              ));
            }
          }

          final left = CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _TripHeader(summary: summary)),
              SliverToBoxAdapter(
                child: _TabBar(
                  tab: _tab,
                  onTab: (t) => setState(() => _tab = t),
                  summary: summary,
                  onDelete: () => _deleteTrip(summary),
                ),
              ),
              if (_tab == 0)
                SliverList.list(children: [
                  for (final ch in summary.chapters)
                    _ChapterRow(
                      summary: summary,
                      chapter: ch,
                      selected: twoPane && ch.day == day,
                      onTap: () => selectDay(ch.day),
                    ),
                ])
              else
                _PhotoGrid(summary: summary),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
            ],
          );

          if (!twoPane) return ColoredBox(color: p.paper1, child: left);
          final leftWidth = (c.maxWidth * 0.5).clamp(560.0, 660.0);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                  width: leftWidth,
                  child: ColoredBox(color: p.paper1, child: left)),
              VerticalDivider(width: 1, color: p.line),
              Expanded(
                child: summary.dayCount == 0
                    ? const SizedBox.shrink()
                    : ChapterView(
                        key: ValueKey('day-$day'),
                        summary: summary,
                        chapter: summary.chapters[day - 1],
                        onSelectDay: selectDay,
                      ),
              ),
            ],
          );
        });
      },
    );
  }
}

class _TripHeader extends ConsumerWidget {
  final TripSummary summary;
  const _TripHeader({required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    final trip = summary.trip;
    final cloth = watchCloth(ref, trip);
    final narrow = MediaQuery.sizeOf(context).width < AppBreakpoints.rail;
    if (narrow) return _PhoneTripHeader(summary: summary);
    final pad = narrow ? AppSpacing.md : 32.0;
    final ghost = OutlinedButton.styleFrom(
      foregroundColor: p.parch,
      backgroundColor: Colors.transparent,
      side: BorderSide(color: p.parch.withValues(alpha: 0.38)),
    );
    final firstUnwritten = summary.unwrittenChapters
            .where((c) => c.photoCount > 0)
            .firstOrNull ??
        summary.unwrittenChapters.firstOrNull;
    final place = [
      if (trip.cities.isNotEmpty) trip.cities.first,
      if (trip.country.isNotEmpty) trip.country,
    ].join(', ');

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: cloth.mute,
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          onPressed: () => context.go('/'),
          icon: const Icon(LucideIcons.arrowLeft, size: 16),
          label: Text('Library  /  ${trip.startDate.year}'),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(trip.title,
            style: (narrow ? text.displaySmall : text.displayLarge)
                ?.copyWith(color: p.parch)),
        const SizedBox(height: 12),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: 4,
          children: [
            if (place.isNotEmpty)
              _IconText(
                  icon: LucideIcons.mapPin, text: place, color: cloth.mute),
            _IconText(
                icon: LucideIcons.calendar,
                text: trip.formattedDates,
                color: cloth.mute),
          ],
        ),
        if (trip.description.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(trip.description.trim(),
              style: AppTypography.aside(context, color: p.parch)),
        ],
        const SizedBox(height: 20),
        Wrap(
          spacing: 28,
          runSpacing: AppSpacing.sm,
          children: [
            StatBlock(
                value: '${summary.dayCount}',
                label: 'days',
                color: p.parch,
                labelColor: cloth.mute),
            StatBlock(
                value: '${summary.photoCount}',
                label: 'photos',
                color: p.parch,
                labelColor: cloth.mute),
            StatBlock(
                value: '${summary.memoryCount}',
                label: 'memories',
                color: p.parch,
                labelColor: cloth.mute),
            StatBlock(
                value: '${summary.placeCount}',
                label: 'places',
                color: p.parch,
                labelColor: cloth.mute),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: () => context.go('/trips/${trip.id}/book'),
              icon: const Icon(LucideIcons.bookOpen, size: 18),
              label: const Text('Open the book'),
            ),
            OutlinedButton.icon(
              style: ghost,
              onPressed: () => context.go('/trips/${trip.id}/add-photos'),
              icon: const Icon(LucideIcons.imagePlus, size: 18),
              label: const Text('Add photos'),
            ),
            if (firstUnwritten != null)
              OutlinedButton.icon(
                style: ghost,
                onPressed: () =>
                    writeChapterMemory(context, ref, trip, firstUnwritten),
                icon: const Icon(LucideIcons.edit3, size: 18),
                label: const Text('Write a memory'),
              ),
          ],
        ),
      ],
    );

    return Container(
      color: cloth.deep,
      padding: EdgeInsets.fromLTRB(pad, AppSpacing.md, pad, 28),
      child: LayoutBuilder(builder: (context, c) {
        if (c.maxWidth < 520) return details;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: details),
            const SizedBox(width: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Hardcover(trip: trip, width: 132, ribbon: false),
            ),
          ],
        );
      }),
    );
  }
}

/// Phone: cover beside the title, one wide primary action, three tiles.
class _PhoneTripHeader extends ConsumerWidget {
  final TripSummary summary;
  const _PhoneTripHeader({required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    final trip = summary.trip;
    final cloth = watchCloth(ref, trip);
    final place = [
      if (trip.cities.isNotEmpty) trip.cities.first,
      if (trip.country.isNotEmpty) trip.country,
    ].join(', ');
    final firstUnwritten = summary.unwrittenChapters
            .where((c) => c.photoCount > 0)
            .firstOrNull ??
        summary.unwrittenChapters.firstOrNull;

    Widget tile(IconData icon, String label, VoidCallback? onTap) => Expanded(
          child: OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: p.parch,
              backgroundColor: Colors.transparent,
              side: BorderSide(color: p.parch.withValues(alpha: 0.38)),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              minimumSize: const Size(0, 56),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18),
                const SizedBox(height: 4),
                Text(label,
                    textAlign: TextAlign.center,
                    style: text.labelSmall?.copyWith(
                        color: p.parch, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );

    return Container(
      color: cloth.deep,
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 4, AppSpacing.md, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                    foregroundColor: p.parch,
                    padding: const EdgeInsets.symmetric(horizontal: 4)),
                onPressed: () => context.go('/'),
                icon: const Icon(LucideIcons.chevronLeft, size: 20),
                label: const Text('Library'),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Edit details',
                onPressed: () => context.go('/trips/${trip.id}/edit'),
                icon: Icon(LucideIcons.pencil, size: 18, color: p.parch),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hardcover(trip: trip, width: 72),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trip.title,
                        style: text.headlineLarge?.copyWith(color: p.parch)),
                    const SizedBox(height: AppSpacing.sm),
                    if (place.isNotEmpty)
                      _IconText(
                          icon: LucideIcons.mapPin,
                          text: place,
                          color: cloth.mute),
                    const SizedBox(height: 2),
                    Text(trip.formattedDates,
                        style: text.bodyMedium?.copyWith(color: cloth.mute)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: p.parch.withValues(alpha: 0.18)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatBlock(
                  value: '${summary.dayCount}',
                  label: 'days',
                  color: p.parch,
                  labelColor: cloth.mute),
              StatBlock(
                  value: '${summary.photoCount}',
                  label: 'photos',
                  color: p.parch,
                  labelColor: cloth.mute),
              StatBlock(
                  value: '${summary.memoryCount}',
                  label: 'memories',
                  color: p.parch,
                  labelColor: cloth.mute),
              StatBlock(
                  value: '${summary.placeCount}',
                  label: 'places',
                  color: p.parch,
                  labelColor: cloth.mute),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
            onPressed: () => context.go('/trips/${trip.id}/book'),
            icon: const Icon(LucideIcons.bookOpen, size: 18),
            label: const Text('Open the book'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              tile(LucideIcons.imagePlus, 'Add photos',
                  () => context.go('/trips/${trip.id}/add-photos')),
              const SizedBox(width: AppSpacing.sm),
              tile(
                  LucideIcons.edit3,
                  'Write a memory',
                  firstUnwritten == null
                      ? null
                      : () => writeChapterMemory(
                          context, ref, trip, firstUnwritten)),
              const SizedBox(width: AppSpacing.sm),
              tile(LucideIcons.fileDown, 'Export PDF',
                  () => context.go('/trips/${trip.id}/book?export=1')),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _IconText({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text(text,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: color)),
      ],
    );
  }
}

class _TabBar extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onTab;
  final TripSummary summary;
  final VoidCallback onDelete;

  const _TabBar({
    required this.tab,
    required this.onTab,
    required this.summary,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final trip = summary.trip;
    final narrow = MediaQuery.sizeOf(context).width < AppBreakpoints.rail;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: narrow ? AppSpacing.md : AppSpacing.lg, vertical: 10),
      decoration: BoxDecoration(
        color: p.paper1,
        border: Border(bottom: BorderSide(color: p.line)),
      ),
      child: Row(
        children: [
          SegmentedButton<int>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                  value: 0,
                  icon: Icon(LucideIcons.listOrdered, size: 16),
                  label: Text('Chapters')),
              ButtonSegment(
                  value: 1,
                  icon: Icon(LucideIcons.layoutGrid, size: 16),
                  label: Text('Photos')),
            ],
            selected: {tab},
            onSelectionChanged: (s) => onTab(s.first),
          ),
          const Spacer(),
          if (!narrow)
            TextButton.icon(
              onPressed: () => context.go('/trips/${trip.id}/book?export=1'),
              icon: const Icon(LucideIcons.fileDown, size: 18),
              label: const Text('Export PDF'),
            ),
          PopupMenuButton<String>(
            tooltip: 'More',
            icon: Icon(LucideIcons.moreHorizontal, color: p.ink2),
            onSelected: (v) {
              switch (v) {
                case 'edit':
                  context.go('/trips/${trip.id}/edit');
                case 'export':
                  context.go('/trips/${trip.id}/book?export=1');
                case 'delete':
                  onDelete();
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                    leading: Icon(LucideIcons.pencil, size: 18),
                    title: Text('Edit details')),
              ),
              if (narrow)
                const PopupMenuItem(
                  value: 'export',
                  child: ListTile(
                      leading: Icon(LucideIcons.fileDown, size: 18),
                      title: Text('Export PDF')),
                ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(LucideIcons.trash2,
                      size: 18, color: Theme.of(ctx).colorScheme.error),
                  title: Text('Delete book',
                      style:
                          TextStyle(color: Theme.of(ctx).colorScheme.error)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChapterRow extends ConsumerWidget {
  final TripSummary summary;
  final ChapterSummary chapter;
  final bool selected;
  final VoidCallback onTap;

  const _ChapterRow({
    required this.summary,
    required this.chapter,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    final narrow = MediaQuery.sizeOf(context).width < AppBreakpoints.rail;
    final d = chapter.date;
    final n = chapter.memories.length;
    final status = chapter.hasMemory
        ? '$n ${n == 1 ? 'memory' : 'memories'}'
        : chapter.photoCount == 0
            ? 'no photos yet'
            : 'no memory yet';

    return Material(
      color: selected ? p.paper0 : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: narrow ? AppSpacing.md : AppSpacing.lg, vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: p.line)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                child: Column(
                  children: [
                    if (selected)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: RibbonMark(width: 12, height: 22),
                      ),
                    Text(DateFormat('EEE').format(d).toUpperCase(),
                        style: text.labelMedium),
                    Text('${d.day}',
                        style: text.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w500)),
                    Text(DateFormat('MMM').format(d).toUpperCase(),
                        style: text.labelMedium),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DAY ${chapter.day}',
                        style: text.labelMedium?.copyWith(color: p.sunInk)),
                    const SizedBox(height: 2),
                    Text(chapter.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleLarge),
                    if (chapter.places != null &&
                        chapter.places != chapter.title) ...[
                      const SizedBox(height: 2),
                      Text(chapter.places!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyMedium?.copyWith(color: p.ink2)),
                    ],
                    const SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      children: [
                        Text('${chapter.photoCount} photos · $status',
                            style: text.bodySmall?.copyWith(
                                color: chapter.hasMemory ? p.ink2 : p.ink3)),
                        if (!chapter.hasMemory && chapter.photoCount > 0)
                          InkWell(
                            onTap: () => writeChapterMemory(
                                context, ref, summary.trip, chapter),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 2),
                              child: Text('Write one',
                                  style: text.bodySmall?.copyWith(
                                      color: p.sunInk,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: SizedBox(
                  width: narrow ? 88 : 140,
                  height: narrow ? 66 : 88,
                  child: appImage(chapter.thumbnailPath,
                      fit: BoxFit.cover,
                      fallback: ColoredBox(
                        color: p.paper2,
                        child: Icon(LucideIcons.image, color: p.ink3, size: 20),
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  final TripSummary summary;
  const _PhotoGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    final trip = summary.trip;
    if (summary.photos.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Icon(LucideIcons.image, size: 40, color: p.ink3),
              const SizedBox(height: AppSpacing.md),
              Text('No photos in this book yet', style: text.titleMedium),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: () => context.go('/trips/${trip.id}/add-photos'),
                icon: const Icon(LucideIcons.imagePlus, size: 18),
                label: const Text('Add photos'),
              ),
            ],
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.md),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final photo = summary.photos[i];
            return ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: InkWell(
                onTap: () => context.go('/trips/${trip.id}/photos/${photo.id}'),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    appImage(photo.thumbnailPath,
                        fit: BoxFit.cover,
                        fallback: ColoredBox(color: p.paper2)),
                    Positioned(
                      left: 6,
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: p.ink1.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text('Day ${photo.day}',
                            style: text.labelSmall?.copyWith(color: p.paper0)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: summary.photos.length,
        ),
      ),
    );
  }
}
