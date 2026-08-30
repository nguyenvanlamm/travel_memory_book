import 'package:flutter/material.dart';
import '../../../../models/trip.dart';
import 'paper_background.dart';

class BookDayPage extends StatelessWidget {
  final Trip trip;
  final int dayNumber;
  final String dateStr;
  const BookDayPage({
    super.key,
    required this.trip,
    required this.dayNumber,
    required this.dateStr,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PaperBackground(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  'DAY $dayNumber',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                dateStr,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w300,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (trip.cities.isNotEmpty)
                Text(
                  trip.cities.join(' → '),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
