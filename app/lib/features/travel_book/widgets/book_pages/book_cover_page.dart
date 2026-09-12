import 'package:flutter/material.dart';
import '../../../../core/utils/image_helper.dart';
import '../../../../models/trip.dart';
import '../../../../models/travel_book.dart';
import 'leather_cover.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Premium hard-cover look: dark leather with grain + sheen, a gold
/// double frame, an optional "photo plate" (like a print pasted onto
/// the cover), and ivory serif typography.
class BookCoverPage extends StatelessWidget {
  final Trip trip;
  final TravelBook book;
  const BookCoverPage({super.key, required this.trip, required this.book});

  @override
  Widget build(BuildContext context) {
    final hasCover = appFileExists(trip.coverPhotoPath);
    const gold = LeatherCover.gold;
    const ivory = LeatherCover.ivory;

    return LeatherCover(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(34, 40, 34, 38),
        child: Column(
          children: [
            Text(
              'A  T R A V E L  M E M O R Y',
              style: TextStyle(fontFamily: 'Inter', 
                fontSize: 10,
                letterSpacing: 3,
                color: gold.withOpacity(0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            // Photo plate hoặc emblem
            if (hasCover)
              Container(
                width: 200,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ivory,
                  border:
                      Border.all(color: gold.withOpacity(0.9), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: appImage(trip.coverPhotoPath, fit: BoxFit.cover),
                ),
              )
            else
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: gold.withOpacity(0.7), width: 1.2),
                ),
                child: Icon(LucideIcons.bookOpen,
                    size: 30, color: gold.withOpacity(0.9)),
              ),
            const SizedBox(height: 24),
            // Tựa sách
            Text(
              trip.title,
              style: TextStyle(fontFamily: 'Playfair Display', 
                fontSize: 32,
                color: ivory,
                fontWeight: FontWeight.w600,
                height: 1.25,
                letterSpacing: 0.5,
                shadows: const [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            const CoverOrnament(),
            const SizedBox(height: 18),
            if (trip.cities.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  trip.cities.join('  ·  '),
                  style: TextStyle(fontFamily: 'Inter', 
                    fontSize: 13,
                    color: ivory.withOpacity(0.8),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Text(
              trip.country,
              style: TextStyle(fontFamily: 'Playfair Display', 
                fontSize: 17,
                color: ivory,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Năm + imprint
            Text(
              trip.startDate.year.toString(),
              style: TextStyle(fontFamily: 'Playfair Display', 
                fontSize: 24,
                color: gold,
                fontWeight: FontWeight.w400,
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'T R A V E L   M E M O R Y   B O O K',
              style: TextStyle(fontFamily: 'Inter', 
                fontSize: 8.5,
                letterSpacing: 2.5,
                color: gold.withOpacity(0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
