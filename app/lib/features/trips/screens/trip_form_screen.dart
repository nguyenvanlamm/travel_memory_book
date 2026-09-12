import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/memory_file_store.dart';
import '../../../core/utils/image_helper.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/web_layout.dart';
import '../../../models/trip.dart';
import '../../../repositories/trip_repository.dart';

class TripFormScreen extends ConsumerStatefulWidget {
  final Trip? trip;
  const TripFormScreen({super.key, this.trip});

  @override
  ConsumerState<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends ConsumerState<TripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _countryController = TextEditingController();
  final _citiesController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  XFile? _coverImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.trip != null) {
      _titleController.text = widget.trip!.title;
      _descriptionController.text = widget.trip!.description;
      _countryController.text = widget.trip!.country;
      _citiesController.text = widget.trip!.cities.join(', ');
      _startDate = widget.trip!.startDate;
      _endDate = widget.trip!.endDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _countryController.dispose();
    _citiesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final initial = isStart ? _startDate : _endDate;
    final first = DateTime(2000);
    final last = DateTime(2100);
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: first,
      lastDate: last,
    );
    if (date != null && mounted) {
      setState(() {
        if (isStart) {
          _startDate = date;
          if (_endDate != null && _endDate!.isBefore(date)) _endDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select start and end dates')));
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End date must be after start date')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(tripRepositoryProvider);
      String? coverPath = widget.trip?.coverPhotoPath;
      if (_coverImage != null) {
        final ext = _coverImage!.name.split('.').last;
        coverPath = MemoryFileStore.put(
            'covers', ext, await _coverImage!.readAsBytes());
      }
      final cities = _citiesController.text
          .split(',')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toList();

      final trip = Trip(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        country: _countryController.text.trim(),
        cities: cities,
        coverPhotoPath: coverPath,
        createdAt: widget.trip?.createdAt,
        updatedAt: DateTime.now(),
      );

      Trip savedTrip;
      if (widget.trip == null) {
        savedTrip = await repo.create(trip);
      } else {
        savedTrip = await repo.update(trip);
      }

      if (mounted) context.go('/trips/${savedTrip.id}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.trip != null;
    return Scaffold(
      body: PageBody(
        maxWidth: 680,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: isEditing ? 'Edit Trip' : 'New Travel Book',
                subtitle: 'Fill in the details for your photo book.',
                onBack: () {
                  if (isEditing && widget.trip?.id != null) {
                    context.go('/trips/${widget.trip!.id}');
                  } else {
                    context.go('/');
                  }
                },
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Cover Photo'),
                        GestureDetector(
                          onTap: () async {
                            final picker = ImagePicker();
                            final image = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 85);
                            if (image != null && mounted) {
                              setState(() => _coverImage = image);
                            }
                          },
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: theme.colorScheme
                                    .surfaceContainerHighest
                                    .withOpacity(0.4),
                                border: Border.all(
                                    color: theme
                                        .colorScheme.outlineVariant)),
                            child: _coverImage != null
                                ? ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    child: xfileImage(_coverImage!,
                                        fit: BoxFit.cover,
                                        width: double.infinity))
                                : widget.trip?.coverPhotoPath != null
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        child: appImage(
                                            widget.trip!.coverPhotoPath,
                                            fit: BoxFit.cover,
                                            width: double.infinity))
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                            Icon(
                                                Icons
                                                    .add_photo_alternate_outlined,
                                                size: 40,
                                                color: theme.colorScheme
                                                    .onSurfaceVariant),
                                            const SizedBox(height: 8),
                                            Text(
                                                'Click to add cover photo',
                                                style: theme
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                        color: theme
                                                            .colorScheme
                                                            .onSurfaceVariant)),
                                          ]),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _label('Title *'),
                        TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                                hintText: 'e.g., Da Nang Summer Trip'),
                            validator: (v) => v?.trim().isEmpty == true
                                ? 'Title is required'
                                : null),
                        const SizedBox(height: 20),
                        Row(children: [
                          Expanded(
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                _label('Country *'),
                                TextFormField(
                                    controller: _countryController,
                                    decoration: const InputDecoration(
                                        hintText: 'e.g., Vietnam'),
                                    validator: (v) =>
                                        v?.trim().isEmpty == true
                                            ? 'Country is required'
                                            : null),
                              ])),
                          const SizedBox(width: 16),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                _label('Cities'),
                                TextFormField(
                                    controller: _citiesController,
                                    decoration: const InputDecoration(
                                        hintText: 'e.g., Da Nang, Hue')),
                              ])),
                        ]),
                        const SizedBox(height: 20),
                        _label('Dates *'),
                        Row(children: [
                          Expanded(
                              child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => _pickDate(context, true),
                                  child: InputDecorator(
                                      decoration: const InputDecoration(
                                          labelText: 'Start Date',
                                          prefixIcon: Icon(Icons
                                              .calendar_today_outlined)),
                                      child: Text(_startDate != null
                                          ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                          : 'Select')))),
                          const SizedBox(width: 16),
                          Expanded(
                              child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => _pickDate(context, false),
                                  child: InputDecorator(
                                      decoration: const InputDecoration(
                                          labelText: 'End Date',
                                          prefixIcon: Icon(Icons
                                              .calendar_today_outlined)),
                                      child: Text(_endDate != null
                                          ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                          : 'Select')))),
                        ]),
                        const SizedBox(height: 20),
                        _label('Description'),
                        TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                                hintText:
                                    'A short description of your trip...',
                                alignLabelWithHint: true)),
                        const SizedBox(height: 28),
                        PrimaryButton(
                            label: isEditing
                                ? 'Save Changes'
                                : 'Create Travel Book',
                            onPressed: _isLoading ? null : _submit,
                            isLoading: _isLoading,
                            icon:
                                isEditing ? Icons.save : Icons.auto_stories),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
