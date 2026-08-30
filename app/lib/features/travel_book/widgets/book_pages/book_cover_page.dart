import 'package:flutter/material.dart';
import 'dart:io';
import '../../../../models/trip.dart';
import '../../../../models/travel_book.dart';

class BookCoverPage extends StatelessWidget {
  final Trip trip;
  final TravelBook book;
  const BookCoverPage({super.key, required this.trip, required this.book});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (trip.coverPhotoPath != null &&
            File(trip.coverPhotoPath!).existsSync())
          Image.file(
            File(trip.coverPhotoPath!),
            fit: BoxFit.cover,
            color: Colors.black.withValues(alpha: 0.3),
            colorBlendMode: BlendMode.darken,
          )
        else
          Container(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: Center(
              child: Icon(
                Icons.menu_book,
                size: 100,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                trip.title,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (trip.cities.isNotEmpty)
                Text(
                  trip.cities.join(', '),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 4),
              Text(
                trip.country,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                trip.startDate.year.toString(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 4,
                    ),
              ),
              const Spacer(),
              Text(
                'Drag the page corner to begin →',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white54,
                      fontStyle: FontStyle.italic,
                    ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}
