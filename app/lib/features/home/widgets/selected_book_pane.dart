import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/image_helper.dart';
import '../../../core/widgets/book_widgets.dart';
import '../../../models/trip.dart';
import '../../memories/widgets/memory_editor.dart';
import '../providers/library_provider.dart';

/// Opens the memory editor for [chapter] and refreshes the counts on save.
Future<void> writeChapterMemory(
  BuildContext context,
  WidgetRef ref,
  Trip trip,
  ChapterSummary chapter,
) async {
  final saved = await showMemoryEditor(
    context,
    tripId: trip.id,
    day: chapter.day,
    date: chapter.date,
    route: chapter.places,
    existing: chapter.memory,
  );
  if (saved) {
    ref.invalidate(tripSummaryProvider(trip.id));
    ref.invalidate(libraryTotalsProvider);
  }
}

/// Right pane of the library: the selected book in its own cloth.
class SelectedBookPane extends ConsumerWidget {
  final Trip trip;
  final bool isNewest;

  const SelectedBookPane({super.key, required this.trip, this.isNewest = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    final cloth = watchCloth(ref, trip);
    final summary = ref.watch(tripSummaryProvider(trip.id)).valueOrNull;
    final wideCover = MediaQuery.sizeOf(context).width >= 1320;

    final ghostOnCloth = TextButton.styleFrom(foregroundColor: p.parch);
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isNewest ? 'NEWEST BOOK' : 'BOOK',
            style: text.labelMedium?.copyWith(color: p.gold)),
        const SizedBox(height: AppSpacing.sm),
        Text(trip.title,
            style: text.displayMedium?.copyWith(color: p.parch)),
        const SizedBox(height: AppSpacing.sm),
        Text(
          [
            [if (trip.cities.isNotEmpty) trip.cities.first, trip.country]
                .where((s) => s.isNotEmpty)
                .join(', '),
            trip.formattedDates,
          ].where((s) => s.isNotEmpty).join('\n'),
          style: text.bodyMedium?.copyWith(color: cloth.mute, height: 1.6),
        ),
        if (trip.description.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(trip.description.trim(),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.aside(context, color: p.parch)),
        ],
        const SizedBox(height: 20),
        Container(height: 1, color: p.parch.withValues(alpha: 0.18)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 28,
          runSpacing: AppSpacing.md,
          children: [
            StatBlock(
                value: '${trip.durationInDays}',
                label: 'days',
                color: p.parch,
                labelColor: cloth.mute),
            StatBlock(
                value: '${summary?.photoCount ?? '–'}',
                label: 'photos',
                color: p.parch,
                labelColor: cloth.mute),
            StatBlock(
                value: '${summary?.memoryCount ?? '–'}',
                label: 'memories',
                color: p.parch,
                labelColor: cloth.mute),
            StatBlock(
                value: '${trip.cities.length}',
                label: 'places',
                color: p.parch,
                labelColor: cloth.mute),
          ],
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => context.go('/trips/${trip.id}/book'),
          icon: const Icon(LucideIcons.bookOpen, size: 18),
          label: const Text('Open the book'),
        ),
      ],
    );

    return ColoredBox(
      color: cloth.deep,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(48, 20, 32, 40),
            sliver: SliverList.list(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      style: ghostOnCloth,
                      onPressed: () =>
                          context.go('/trips/${trip.id}/book?export=1'),
                      icon: const Icon(LucideIcons.fileDown, size: 18),
                      label: const Text('Export PDF'),
                    ),
                    TextButton.icon(
                      style: ghostOnCloth,
                      onPressed: () => context.go('/trips/${trip.id}/edit'),
                      icon: const Icon(LucideIcons.pencil, size: 16),
                      label: const Text('Edit'),
                    ),
                    TextButton.icon(
                      style: ghostOnCloth,
                      onPressed: () => context.go('/trips/${trip.id}'),
                      icon: const Icon(LucideIcons.arrowUpRight, size: 18),
                      label: const Text('Chapters'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (wideCover)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hardcover(trip: trip, width: 232),
                      const SizedBox(width: 44),
                      Expanded(child: info),
                    ],
                  )
                else ...[
                  Hardcover(trip: trip, width: 180),
                  const SizedBox(height: AppSpacing.lg),
                  info,
                ],
                const SizedBox(height: 36),
                if (summary != null) ContinueCard(summary: summary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "2 of 4 days still have no memory written" — the after-trip to-do.
///
/// On paper inside the selected-book pane; on the book's own cloth when it
/// heads the phone library ([onCloth]).
class ContinueCard extends ConsumerWidget {
  final TripSummary summary;
  final int maxDays;
  final bool onCloth;

  const ContinueCard({
    super.key,
    required this.summary,
    this.maxDays = 2,
    this.onCloth = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    final trip = summary.trip;
    final cloth = watchCloth(ref, trip);
    final unwritten = summary.unwrittenChapters;
    final narrow = MediaQuery.sizeOf(context).width < AppBreakpoints.rail;
    final ink = onCloth ? p.parch : p.ink1;

    final String headline;
    Widget? action;
    if (summary.photoCount == 0) {
      headline = 'This book has no photos yet.';
      action = FilledButton.icon(
        onPressed: () => context.go('/trips/${trip.id}/add-photos'),
        icon: const Icon(LucideIcons.imagePlus, size: 18),
        label: const Text('Add photos'),
      );
    } else if (unwritten.isEmpty) {
      headline = 'Every day of this book has a memory.';
    } else {
      headline =
          '${unwritten.length} of ${summary.dayCount} ${summary.dayCount == 1 ? 'day' : 'days'} still ${unwritten.length == 1 ? 'has' : 'have'} no memory written.';
    }

    return Container(
      padding: EdgeInsets.all(narrow ? AppSpacing.md : AppSpacing.lg),
      decoration: BoxDecoration(
        color: onCloth ? cloth.deep : p.paper0,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: onCloth ? null : Border.all(color: p.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CONTINUE · ${trip.title.toUpperCase()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.labelMedium
                            ?.copyWith(color: onCloth ? p.gold : p.sunInk)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(headline, style: text.titleLarge?.copyWith(color: ink)),
                    if (summary.dayCount <= 10 &&
                        summary.photoCount > 0 &&
                        (onCloth || narrow)) ...[
                      const SizedBox(height: 12),
                      _DayProgress(summary: summary, onCloth: onCloth),
                    ],
                  ],
                ),
              ),
              if (onCloth)
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.md),
                  child: Hardcover(trip: trip, width: 48, ribbon: false),
                )
              else if (summary.dayCount <= 10 &&
                  summary.photoCount > 0 &&
                  !narrow) ...[
                const SizedBox(width: AppSpacing.md),
                _DayProgress(summary: summary, onCloth: false),
              ],
            ],
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.md),
            action,
          ],
          for (final c in unwritten.where((c) => c.photoCount > 0).take(maxDays)) ...[
            const SizedBox(height: 12),
            Divider(color: onCloth ? p.parch.withValues(alpha: 0.18) : p.line),
            const SizedBox(height: 12),
            _UnwrittenDay(trip: trip, chapter: c, compact: narrow, onCloth: onCloth),
          ],
        ],
      ),
    );
  }
}

class _DayProgress extends StatelessWidget {
  final TripSummary summary;
  final bool onCloth;
  const _DayProgress({required this.summary, required this.onCloth});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    // Written days are filled; empty days are outlined in sunrise.
    final done = onCloth ? p.gold : p.ink2;
    final todo = onCloth ? AppPalette.dawn : p.sunInk;
    return Semantics(
      label:
          '${summary.dayCount - summary.unwrittenChapters.length} of ${summary.dayCount} days written',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final c in summary.chapters)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Column(
                  children: [
                    Container(
                      width: 30,
                      height: 7,
                      decoration: BoxDecoration(
                        color: c.hasMemory ? done : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                            color: c.hasMemory ? done : todo, width: 1.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('D${c.day}',
                        style: text.labelSmall?.copyWith(
                            color: c.hasMemory
                                ? (onCloth ? p.parch : p.ink3)
                                : todo,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UnwrittenDay extends ConsumerWidget {
  final Trip trip;
  final ChapterSummary chapter;
  final bool compact;
  final bool onCloth;

  const _UnwrittenDay({
    required this.trip,
    required this.chapter,
    required this.compact,
    required this.onCloth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    final mute = onCloth ? watchCloth(ref, trip).mute : p.ink3;
    final button = OutlinedButton.icon(
      style: onCloth
          ? OutlinedButton.styleFrom(
              foregroundColor: p.parch,
              backgroundColor: Colors.transparent,
              side: BorderSide(color: p.parch.withValues(alpha: 0.38)),
            )
          : null,
      onPressed: () => writeChapterMemory(context, ref, trip, chapter),
      icon: Icon(LucideIcons.edit3, size: 16, color: onCloth ? p.parch : p.sunInk),
      label: Text(compact ? 'Write' : 'Write a memory',
          style: TextStyle(color: onCloth ? p.parch : p.sunInk)),
    );
    final thumb = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: SizedBox(
        width: compact ? 56 : 92,
        height: compact ? 56 : 72,
        child: appImage(chapter.thumbnailPath,
            fit: BoxFit.cover, fallback: ColoredBox(color: p.paper2)),
      ),
    );
    return Row(
      children: [
        thumb,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'DAY ${chapter.day} · ${DateFormat('EEE d MMM').format(chapter.date).toUpperCase()}',
                  style: text.labelMedium?.copyWith(color: mute)),
              const SizedBox(height: 2),
              Text(chapter.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: (compact ? text.titleSmall : text.titleMedium)?.copyWith(
                      fontFamily: AppTypography.serif,
                      fontSize: compact ? 16 : null,
                      color: onCloth ? p.parch : p.ink1)),
              if (!compact) ...[
                const SizedBox(height: 2),
                Text('${chapter.photoCount} photos · no memory yet',
                    style: text.bodySmall?.copyWith(color: mute)),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        button,
      ],
    );
  }
}
