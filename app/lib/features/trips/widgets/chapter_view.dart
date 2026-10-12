import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/image_helper.dart';
import '../../../core/widgets/book_widgets.dart';
import '../../../models/photo.dart';
import '../../home/providers/library_provider.dart';
import '../../home/widgets/selected_book_pane.dart';

String chapterHeading(ChapterSummary c) =>
    'Day ${c.day} · ${DateFormat('EEE d MMM y').format(c.date)}';

/// One chapter (day) of a trip: in the trip page's right pane on wide
/// screens, as its own page on phones.
class ChapterView extends ConsumerWidget {
  final TripSummary summary;
  final ChapterSummary chapter;
  final ValueChanged<int>? onSelectDay;

  /// Phones: the page brings its own back button.
  final bool standalone;

  const ChapterView({
    super.key,
    required this.summary,
    required this.chapter,
    this.onSelectDay,
    this.standalone = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    final trip = summary.trip;
    final memory = chapter.memory;
    final photos = chapter.photos;
    final lead = photos.isEmpty ? null : photos.first;
    final more = photos.skip(lead == null ? 0 : 1).toList();
    final hasPrev = chapter.day > 1;
    final hasNext = chapter.day < summary.dayCount;
    final narrow = MediaQuery.sizeOf(context).width < AppBreakpoints.rail;
    final pad = narrow ? AppSpacing.md : 40.0;

    void write() => writeChapterMemory(context, ref, trip, chapter);
    if (standalone && narrow) {
      return _PhoneChapter(
        summary: summary,
        chapter: chapter,
        onWrite: write,
        onSelectDay: onSelectDay,
      );
    }

    final topBar = Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: standalone ? AppSpacing.sm : pad),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.line)),
      ),
      child: Row(
        children: [
          if (standalone)
            IconButton(
              tooltip: 'Back to chapters',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(LucideIcons.arrowLeft),
            ),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                    text: 'Day ${chapter.day}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                TextSpan(
                    text:
                        '  ·  ${DateFormat('EEE d MMM y').format(chapter.date)}'),
                if (chapter.places != null && !narrow)
                  TextSpan(text: '  ·  ${chapter.places}'),
              ]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.bodyMedium?.copyWith(color: p.ink2),
            ),
          ),
          if (memory != null)
            IconButton(
              tooltip: 'Edit memory',
              onPressed: write,
              icon: const Icon(LucideIcons.pencil, size: 18),
            ),
        ],
      ),
    );

    Widget leadPhoto(double width, double height) => ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: SizedBox(
            width: width,
            height: height,
            child: InkWell(
              onTap: lead == null
                  ? null
                  : () => context.go('/trips/${trip.id}/photos/${lead.id}'),
              child: appImage(lead?.filePath ?? lead?.thumbnailPath,
                  fit: BoxFit.cover, fallback: ColoredBox(color: p.paper2)),
            ),
          ),
        );

    final exif = lead == null
        ? null
        : Row(
            children: [
              Icon(LucideIcons.camera, size: 14, color: p.ink3),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  [
                    DateFormat('d MMM y · HH:mm').format(lead.takenAt),
                    if (lead.locationName != null) lead.locationName!,
                  ].join(' · '),
                  style: text.bodySmall,
                ),
              ),
            ],
          );

    final writing = memory == null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NO MEMORY YET',
                  style: text.labelMedium?.copyWith(color: p.sunInk)),
              const SizedBox(height: AppSpacing.sm),
              Text('What do you want to remember about Day ${chapter.day}?',
                  style: text.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'A few lines are enough. They are printed on the page after this day’s photos.',
                style: text.bodyMedium?.copyWith(color: p.ink2),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: write,
                icon: const Icon(LucideIcons.edit3, size: 18),
                label: const Text('Write a memory'),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, m) in chapter.memories.indexed) ...[
                if (i > 0) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Divider(color: p.line),
                  const SizedBox(height: AppSpacing.lg),
                ],
                Text(
                    chapter.memories.length == 1
                        ? 'MEMORY'
                        : 'MEMORY ${i + 1} OF ${chapter.memories.length}',
                    style: text.labelMedium?.copyWith(color: p.sunInk)),
                const SizedBox(height: AppSpacing.sm),
                if (m.title != null || i == 0) ...[
                  Text(m.title ?? chapter.places ?? 'Day ${chapter.day}',
                      style: i == 0 ? text.headlineLarge : text.headlineSmall),
                  const SizedBox(height: AppSpacing.md),
                ],
                SelectableText(m.content, style: AppTypography.memory(context)),
              ],
            ],
          );

    final strip = more.isEmpty
        ? null
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('MORE FROM DAY ${chapter.day}',
                        style: text.labelMedium),
                  ),
                  Text('${chapter.photoCount} photos', style: text.bodySmall),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: more.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) =>
                      _StripPhoto(tripId: trip.id, photo: more[i], width: 140),
                ),
              ),
            ],
          );

    final footer = Container(
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: pad - 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.line)),
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: hasPrev ? () => onSelectDay?.call(chapter.day - 1) : null,
            icon: const Icon(LucideIcons.chevronLeft, size: 18),
            label: const Text('Previous day'),
          ),
          const Spacer(),
          if (!narrow) ...[
            SizedBox(
              width: 10,
              height: 10,
              child: ColoredBox(color: watchCloth(ref, trip).of(context)),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text('${trip.title} · Day ${chapter.day} of ${summary.dayCount}',
                style: text.bodySmall),
            const Spacer(),
          ],
          TextButton.icon(
            onPressed: hasNext ? () => onSelectDay?.call(chapter.day + 1) : null,
            icon: const Icon(LucideIcons.chevronRight, size: 18),
            label: const Text('Next day'),
          ),
        ],
      ),
    );

    final body = LayoutBuilder(builder: (context, c) {
      final spread = c.maxWidth >= 680 && lead != null;
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(pad, AppSpacing.lg, pad, AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (spread)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      leadPhoto(300, 400),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(width: 300, child: exif),
                    ],
                  ),
                  const SizedBox(width: 36),
                  Expanded(child: writing),
                ],
              )
            else ...[
              if (lead != null) ...[
                AspectRatio(
                  aspectRatio: 4 / 5,
                  child: LayoutBuilder(
                      builder: (_, b) => leadPhoto(b.maxWidth, b.maxHeight)),
                ),
                const SizedBox(height: AppSpacing.sm),
                exif!,
                const SizedBox(height: AppSpacing.lg),
              ],
              writing,
            ],
            if (strip != null) ...[
              const SizedBox(height: 36),
              strip,
            ],
          ],
        ),
      );
    });

    return ColoredBox(
      color: p.paper0,
      child: Column(
        children: [
          topBar,
          Expanded(child: body),
          footer,
        ],
      ),
    );
  }
}

/// Phone page: the day's photo bleeds to the edges, the writing follows,
/// previous/next sit at the bottom for the thumb.
class _PhoneChapter extends ConsumerWidget {
  final TripSummary summary;
  final ChapterSummary chapter;
  final VoidCallback onWrite;
  final ValueChanged<int>? onSelectDay;

  const _PhoneChapter({
    required this.summary,
    required this.chapter,
    required this.onWrite,
    this.onSelectDay,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    final trip = summary.trip;
    final photos = chapter.photos;
    final lead = photos.firstOrNull;
    final more = photos.skip(1).take(3).toList();
    final rest = photos.length - 1 - more.length;
    const overlay = Color(0x8C000000);

    Widget roundButton(Widget child, String tip, VoidCallback onTap) => Tooltip(
          message: tip,
          child: Material(
            color: overlay,
            shape: const StadiumBorder(),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Center(widthFactor: 1, child: child),
                ),
              ),
            ),
          ),
        );

    return ColoredBox(
      color: p.paper0,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: 300,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      lead == null
                          ? ColoredBox(color: watchCloth(ref, trip).deep)
                          : InkWell(
                              onTap: () => context
                                  .go('/trips/${trip.id}/photos/${lead.id}'),
                              child: appImage(lead.filePath,
                                  fit: BoxFit.cover,
                                  fallback: ColoredBox(color: p.paper2)),
                            ),
                      const IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment(0, -0.3),
                              colors: [Color(0x66000000), Color(0x00000000)],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 12,
                        child: roundButton(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.chevronLeft,
                                  size: 18, color: p.parch),
                              Text('Day ${chapter.day}',
                                  style: text.labelLarge
                                      ?.copyWith(color: p.parch)),
                            ],
                          ),
                          'Back to chapters',
                          () => Navigator.of(context).maybePop(),
                        ),
                      ),
                      if (chapter.hasMemory)
                        Positioned(
                          top: 10,
                          right: 12,
                          child: roundButton(
                            Icon(LucideIcons.pencil, size: 18, color: p.parch),
                            'Edit memory',
                            onWrite,
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (lead != null)
                        Row(
                          children: [
                            Icon(LucideIcons.camera, size: 14, color: p.ink3),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                [
                                  DateFormat('d MMM y · HH:mm').format(lead.takenAt),
                                  if (lead.locationName != null) lead.locationName!,
                                ].join(' · '),
                                style: text.bodySmall
                                    ?.copyWith(fontFeatures: AppTypography.figures),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),
                      Text(
                          'DAY ${chapter.day} · ${DateFormat('EEE d MMM y').format(chapter.date).toUpperCase()}',
                          style: text.labelMedium?.copyWith(color: p.sunInk)),
                      const SizedBox(height: AppSpacing.sm),
                      if (!chapter.hasMemory) ...[
                        Text(
                            'What do you want to remember about Day ${chapter.day}?',
                            style: text.headlineSmall),
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: onWrite,
                            icon: const Icon(LucideIcons.edit3, size: 18),
                            label: const Text('Write a memory'),
                          ),
                        ),
                      ],
                      for (final (i, m) in chapter.memories.indexed) ...[
                        if (i > 0) ...[
                          const SizedBox(height: 20),
                          Divider(color: p.line),
                          const SizedBox(height: 20),
                        ],
                        if (m.title != null || i == 0) ...[
                          Text(m.title ?? chapter.places ?? 'Day ${chapter.day}',
                              style: (i == 0 ? text.headlineMedium : text.titleLarge)
                                  ?.copyWith(fontSize: i == 0 ? 26 : null)),
                          const SizedBox(height: 12),
                        ],
                        SelectableText(m.content,
                            style: AppTypography.memory(context)),
                      ],
                      if (more.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: Text('MORE FROM DAY ${chapter.day}',
                                  style: text.labelMedium),
                            ),
                            Text('${chapter.photoCount} photos',
                                style: text.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            for (final ph in more)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: SizedBox(
                                    height: 60,
                                    child: _StripPhoto(tripId: trip.id, photo: ph),
                                  ),
                                ),
                              ),
                            if (rest > 0)
                              Expanded(
                                child: Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: p.paper2,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.sm),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('+$rest photos',
                                      textAlign: TextAlign.center,
                                      style: text.bodySmall
                                          ?.copyWith(color: p.ink2)),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: p.paper0,
              border: Border(top: BorderSide(color: p.line)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Previous day',
                  onPressed: chapter.day > 1
                      ? () => onSelectDay?.call(chapter.day - 1)
                      : null,
                  icon: const Icon(LucideIcons.chevronLeft),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text('Day ${chapter.day} of ${summary.dayCount}',
                          style: text.titleSmall?.copyWith(
                              fontFamily: AppTypography.serif, fontSize: 15)),
                      Text(trip.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Next day',
                  onPressed: chapter.day < summary.dayCount
                      ? () => onSelectDay?.call(chapter.day + 1)
                      : null,
                  icon: const Icon(LucideIcons.chevronRight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StripPhoto extends StatelessWidget {
  final int tripId;
  final Photo photo;
  final double? width;
  const _StripPhoto({required this.tripId, required this.photo, this.width});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: SizedBox(
        width: width,
        child: InkWell(
          onTap: () => context.go('/trips/$tripId/photos/${photo.id}'),
          child: appImage(photo.thumbnailPath,
              fit: BoxFit.cover, fallback: ColoredBox(color: p.paper2)),
        ),
      ),
    );
  }
}

/// Phone page for one chapter, pushed over the trip page.
class ChapterPage extends ConsumerStatefulWidget {
  final int tripId;
  final int day;
  const ChapterPage({super.key, required this.tripId, required this.day});

  @override
  ConsumerState<ChapterPage> createState() => _ChapterPageState();
}

class _ChapterPageState extends ConsumerState<ChapterPage> {
  late int _day = widget.day;

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(tripSummaryProvider(widget.tripId)).valueOrNull;
    if (summary == null) return const Scaffold(body: SizedBox.shrink());
    final chapter = summary.chapters[(_day - 1).clamp(0, summary.dayCount - 1)];
    return Scaffold(
      body: SafeArea(
        child: ChapterView(
          summary: summary,
          chapter: chapter,
          standalone: true,
          onSelectDay: (d) => setState(() => _day = d),
        ),
      ),
    );
  }
}
