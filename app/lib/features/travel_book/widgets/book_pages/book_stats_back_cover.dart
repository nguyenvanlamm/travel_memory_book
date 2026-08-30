import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/photo.dart';
import '../../../../models/trip.dart';
import '../../../../models/travel_book.dart';
import 'paper_background.dart';

class BookStatsBackCover extends StatelessWidget {
  final Trip trip;
  final TravelBook book;
  final List<Photo> photos;

  const BookStatsBackCover({
    super.key,
    required this.trip,
    required this.book,
    required this.photos,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photoCount = photos.length;
    final countries = <String>{trip.country}.where((c) => c.isNotEmpty).length;
    final cities = trip.cities.length;
    final days = trip.durationInDays;
    final withLocation = photos.where((p) => p.hasLocation).length;

    return PaperBackground(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'End of Journey',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              trip.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatRow(icon: Icons.calendar_today, label: 'Days', value: days.toString()),
                    const SizedBox(height: 18),
                    _StatRow(icon: Icons.photo_library, label: 'Photos', value: photoCount.toString()),
                    const SizedBox(height: 18),
                    _StatRow(icon: Icons.location_city, label: 'Cities', value: cities.toString()),
                    const SizedBox(height: 18),
                    _StatRow(icon: Icons.public, label: 'Countries', value: countries.toString()),
                    if (withLocation > 0) ...[
                      const SizedBox(height: 18),
                      _StatRow(icon: Icons.place, label: 'Geo-tagged', value: withLocation.toString()),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              DateFormat('d MMMM yyyy').format(trip.endDate),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Made with ❤️ using Travel Memory Book',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
