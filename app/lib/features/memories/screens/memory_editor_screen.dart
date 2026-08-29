import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../../models/memory.dart';
import '../../../models/trip.dart';
import '../../../repositories/memory_repository.dart';
import '../../../repositories/trip_repository.dart';

class MemoryEditorScreen extends ConsumerStatefulWidget {
  final int tripId;
  final DateTime? date;
  const MemoryEditorScreen({super.key, required this.tripId, this.date});
  @override ConsumerState<MemoryEditorScreen> createState() => _MemoryEditorScreenState();
}

class _MemoryEditorScreenState extends ConsumerState<MemoryEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;
  Memory? _existingMemory;
  Trip? _trip;

  @override void initState() { super.initState(); _loadData(); }
  @override void dispose() { _titleController.dispose(); _contentController.dispose(); super.dispose(); }

  Future<void> _loadData() async {
    try {
      final trip = await ref.read(tripRepositoryProvider).getById(widget.tripId);
      if (trip == null) throw Exception('Trip not found');
      Memory? memory;
      if (widget.date == null) memory = await ref.read(memoryRepositoryProvider).getTripMemory(widget.tripId);
      else memory = await ref.read(memoryRepositoryProvider).getByDate(widget.tripId, widget.date!);
      if (mounted) setState(() { _trip = trip; _existingMemory = memory; if (memory != null) { _titleController.text = memory.title ?? ''; _contentController.text = memory.content; } });
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'))); }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(memoryRepositoryProvider);
      final content = _contentController.text.trim();
      if (_existingMemory != null) await repo.update(_existingMemory!.copyWith(title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(), content: content));
      else await repo.create(Memory(tripId: widget.tripId, date: widget.date, title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(), content: content));
      if (mounted) context.pop();
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'))); }
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTripMemory = widget.date == null;
    final dateStr = widget.date != null ? '${widget.date!.day}/${widget.date!.month}/${widget.date!.year}' : 'Whole Trip';
    return Scaffold(appBar: AppBar(title: Text(isTripMemory ? 'Trip Memory' : 'Daily Journal - $dateStr'), actions: [TextButton(onPressed: _isLoading ? null : _save, child: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'))]), body: Form(key: _formKey, child: Column(children: [Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [SectionHeader(title: isTripMemory ? 'Trip Memory' : 'Daily Journal', subtitle: dateStr), const SizedBox(height: 16), TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title (optional)', hintText: 'e.g., Best day ever!'), maxLines: 1), const SizedBox(height: 16), TextFormField(controller: _contentController, decoration: const InputDecoration(labelText: 'Your memory *', hintText: 'Write your thoughts, feelings, highlights...', alignLabelWithHint: true), maxLines: 20, minLines: 10, validator: (v) => v?.trim().isEmpty == true ? 'Please write something' : null), const SizedBox(height: 16), Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text('${_contentController.text.length} characters', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))]), const SizedBox(height: 32), Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(Icons.save_outlined, size: 20, color: theme.colorScheme.onSurfaceVariant), const SizedBox(width: 8), Text('Auto-saves every 30 seconds', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))]))])), Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: theme.colorScheme.surface, border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant))), child: SafeArea(child: PrimaryButton(label: 'Save Memory', onPressed: _isLoading ? null : _save, isLoading: _isLoading, icon: Icons.save)))])));
  }
}
