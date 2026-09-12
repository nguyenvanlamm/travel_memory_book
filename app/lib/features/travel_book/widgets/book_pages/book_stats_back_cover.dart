import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../models/photo.dart';
import '../../../../models/trip.dart';
import '../../../../models/travel_book.dart';
import 'leather_cover.dart';

/// Back cover — same leather + gold material as the front cover.
class BookStatsBackCover extends StatelessWidget {
  final Trip trip;
  final TravelBook book;
  final List<Photo> photos;
  final int? pageNumber;
  final bool isLeft;

  const BookStatsBackCover({
    super.key,
    required this.trip,
    required this.book,
    required this.photos,
    this.pageNumber,
    this.isLeft = true,
  });

  @override
  Widget build(BuildContext context) {
    final photoCount = photos.length;
    final cities = trip.cities.length;
    final days = trip.durationInDays;
    final withLocation = photos.where((p) => p.hasLocation).length;
    const gold = LeatherCover.gold;
    const ivory = LeatherCover.ivory;

    return LeatherCover(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(34, 40, 34, 38),
        child: Column(
          children: [
            Text(
              'T H E   E N D',
              style: GoogleFonts.inter(
                fontSize: 10,
                letterSpacing: 4,
                fontWeight: FontWeight.w500,
                color: gold.withOpacity(0.85),
              ),
            ),
            const SizedBox(height: 14),
            const CoverOrnament(),
            const Spacer(),
            // Emblem
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: gold.withOpacity(0.7), width: 1.2),
              ),
              child: Icon(Icons.auto_stories,
                  size: 28, color: gold.withOpacity(0.9)),
            ),
            const SizedBox(height: 18),
            Text(
              trip.title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: ivory,
                shadows: const [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 8,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              '${trip.formattedDates} · ${trip.country}',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: ivory.withOpacity(0.7),
                letterSpacing: 0.4,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Stats table
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Stat(value: '$days', label: 'days'),
                _divider(),
                _Stat(value: '$photoCount', label: 'photos'),
                _divider(),
                _Stat(value: '$cities', label: 'places'),
                if (withLocation > 0) ...[
                  _divider(),
                  _Stat(value: '$withLocation', label: 'geo-tagged'),
                ],
              ],
            ),
            const Spacer(),
            Text(
              'M A D E   W I T H   L O V E   ·   T R A V E L   M E M O R Y   B O O K',
              style: GoogleFonts.inter(
                fontSize: 8,
                letterSpacing: 2,
                color: gold.withOpacity(0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _divider() =>
      Container(width: 0.8, height: 34, color: LeatherCover.gold.withOpacity(0.35));
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.playfairDisplay(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: LeatherCover.ivory,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 9,
            letterSpacing: 1.5,
            color: LeatherCover.gold.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
