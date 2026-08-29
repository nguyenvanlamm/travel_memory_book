import 'package:flutter/material.dart';
import 'dart:io';
import '../../../models/photo.dart';
import '../../../models/trip.dart';

class BookPhotoPage extends StatelessWidget {
  final Photo? photo;
  final String? caption;
  const BookPhotoPage({super.key, this.photo, this.caption});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(color: theme.colorScheme.surface, child: Column(children: [
      Expanded(flex: 4, child: Padding(padding: const EdgeInsets.all(24), child: photo != null && photo!.filePath.isNotEmpty && File(photo!.filePath!).existsSync() ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(photo!.filePath!), fit: BoxFit.contain, width: double.infinity, errorBuilder: (_, __, ___) => _buildPlaceholder(theme))) : _buildPlaceholder(theme))),
      if (caption != null && caption!.isNotEmpty) Expanded(flex: 1, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), child: Center(child: Text(caption!, style: theme.textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic, color: theme.colorScheme.onSurfaceVariant), textAlign: TextAlign.center)))),
      if (photo != null) Padding(padding: const EdgeInsets.only(bottom: 24), child: Column(children: [
        if (photo!.latitude != null && photo!.longitude != null) Text('📍 ${photo!.locationName ?? 'GPS location'}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text('${photo!.takenAt.day}/${photo!.takenAt.month}/${photo!.takenAt.year} ${photo!.takenAt.hour.toString().padLeft(2, '0')}:${photo!.takenAt.minute.toString().padLeft(2, '0')}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ])),
    ]));
  }
  Widget _buildPlaceholder(ThemeData theme) => Container(width: double.infinity, decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)), child: Center(child: Icon(Icons.image_outlined, size: 64, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5))));
}

class BookDayPage extends StatelessWidget {
  final Trip trip;
  final int dayNumber;
  final String dateStr;
  const BookDayPage({super.key, required this.trip, required this.dayNumber, required this.dateStr});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(color: theme.colorScheme.surface, child: Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(50)), child: Text('DAY $dayNumber', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.w700, letterSpacing: 2))),
      const SizedBox(height: 24),
      Text(dateStr, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w300, color: theme.colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
      const SizedBox(height: 8),
      if (trip.cities.isNotEmpty) Text(trip.cities.join(' → '), style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
    ]))));
  }
}

class BookMemoryPage extends StatelessWidget {
  final String? title;
  final String content;
  const BookMemoryPage({super.key, this.title, required this.content});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(color: theme.colorScheme.surface, child: Padding(padding: const EdgeInsets.all(32), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (title != null) ...[Text(title!, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.primary)), const SizedBox(height: 16)],
      Expanded(child: SingleChildScrollView(child: Text(content, style: theme.textTheme.bodyLarge?.copyWith(height: 1.6, color: theme.colorScheme.onSurface)))),
    ])));
  }
}
