import 'package:flutter/material.dart';
import 'dart:io';
import '../../../models/travel_book.dart';
import '../../../models/trip.dart';

class BookCover extends StatelessWidget {
  final Trip trip; final TravelBook book;
  const BookCover({super.key, required this.trip, required this.book});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [theme.colorScheme.surface, theme.colorScheme.surfaceContainerHighest])), child: Stack(fit: StackFit.expand, children: [
      if (trip.coverPhotoPath != null && File(trip.coverPhotoPath!).existsSync()) Image.file(File(trip.coverPhotoPath!), fit: BoxFit.cover, color: Colors.black.withOpacity(0.3), colorBlendMode: BlendMode.darken) else Container(color: theme.colorScheme.primary.withOpacity(0.1), child: Center(child: Icon(Icons.menu_book, size: 80, color: theme.colorScheme.primary.withOpacity(0.5)))),
      Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.7)]))),
      Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Spacer(), Text(trip.title, style: theme.textTheme.displaySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700, shadows: [Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 2))]), textAlign: TextAlign.center), const SizedBox(height: 16), if (trip.cities.isNotEmpty) Text(trip.cities.join(', '), style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70), textAlign: TextAlign.center), const SizedBox(height: 4), Text(trip.country, style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w500), textAlign: TextAlign.center), const SizedBox(height: 8), Text(trip.startDate.year.toString(), style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w300, letterSpacing: 4)), const Spacer(), Text('Swipe to begin →', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white54, fontStyle: FontStyle.italic)), const SizedBox(height: 32)])),
    ]));
  }
}
