import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/memory.dart';
import '../../../repositories/memory_repository.dart';

/// Opens the memory editor for one day of a trip. Returns true when saved.
///
/// Wide screens get a dialog, phones a full-height sheet.
Future<bool> showMemoryEditor(
  BuildContext context, {
  required int tripId,
  required int day,
  required DateTime date,
  String? route,
  Memory? existing,
}) async {
  final editor = _MemoryEditor(
    tripId: tripId,
    day: day,
    date: date,
    route: route,
    existing: existing,
  );
  final wide = MediaQuery.sizeOf(context).width >= AppBreakpoints.rail;
  final saved = wide
      ? await showDialog<bool>(
          context: context,
          useRootNavigator: true,
          builder: (_) => Dialog(
            insetPadding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640, maxHeight: 640),
              child: editor,
            ),
          ),
        )
      : await showModalBottomSheet<bool>(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          useSafeArea: true,
          showDragHandle: true,
          builder: (_) => Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom),
            child: editor,
          ),
        );
  return saved ?? false;
}

class _MemoryEditor extends ConsumerStatefulWidget {
  final int tripId;
  final int day;
  final DateTime date;
  final String? route;
  final Memory? existing;

  const _MemoryEditor({
    required this.tripId,
    required this.day,
    required this.date,
    this.route,
    this.existing,
  });

  @override
  ConsumerState<_MemoryEditor> createState() => _MemoryEditorState();
}

class _MemoryEditorState extends ConsumerState<_MemoryEditor> {
  late final TextEditingController _title =
      TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _content =
      TextEditingController(text: widget.existing?.content ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final content = _content.text.trim();
    if (content.isEmpty || _saving) return;
    setState(() => _saving = true);
    final repo = ref.read(memoryRepositoryProvider);
    final title = _title.text.trim().isEmpty ? null : _title.text.trim();
    final existing = widget.existing;
    if (existing == null) {
      await repo.create(Memory(
        tripId: widget.tripId,
        content: content,
        title: title,
        date: widget.date,
        createdAt: DateTime.now(),
      ));
    } else {
      await repo.update(existing.copyWith(content: content, title: title));
    }
    HapticFeedback.lightImpact();
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final scheme = theme.colorScheme;
    final heading =
        'Day ${widget.day} · ${DateFormat('EEE d MMM').format(widget.date)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(heading.toUpperCase(),
              style: text.labelMedium?.copyWith(color: scheme.primary)),
          if (widget.route != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(widget.route!, style: text.titleLarge),
          ],
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _title,
            textCapitalization: TextCapitalization.sentences,
            style: text.titleMedium,
            decoration: const InputDecoration(
              hintText: 'Title (optional) — e.g. Mã Pí Lèng, 7 giờ sáng',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Flexible(
            child: TextField(
              controller: _content,
              autofocus: widget.existing == null,
              minLines: 6,
              maxLines: 14,
              textCapitalization: TextCapitalization.sentences,
              style: AppTypography.memory(context),
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'What do you want to remember about this day?',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(LucideIcons.lock, size: 16, color: scheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('Only you read this.',
                    style: text.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton.icon(
                onPressed:
                    _content.text.trim().isEmpty || _saving ? null : _save,
                icon: const Icon(LucideIcons.check, size: 18),
                label: const Text('Save memory'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
