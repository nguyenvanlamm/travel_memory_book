import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../models/trip.dart';
import 'paper_background.dart';

class BookDayPage extends StatelessWidget {
  final Trip trip;
  final int dayNumber;
  final String dateStr;
  final int? pageNumber;
  final bool isLeft;

  const BookDayPage({
    super.key,
    required this.trip,
    required this.dayNumber,
    required this.dateStr,
    this.pageNumber,
    this.isLeft = false,
  });

  @override
  Widget build(BuildContext context) {
    return PaperBackground(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Label nhỏ letter-spaced
                  Text(
                    'D A Y',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      letterSpacing: 6,
                      fontWeight: FontWeight.w600,
                      color: BookInk.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Số ngày lớn kiểu chapter opener
                  Text(
                    '$dayNumber',
                    style: GoogleFonts.merriweather(
                      fontSize: 96,
                      fontWeight: FontWeight.w300,
                      color: BookInk.ink,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const BookOrnament(width: 150),
                  const SizedBox(height: 24),
                  Text(
                    dateStr,
                    style: GoogleFonts.merriweather(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      color: BookInk.ink,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  if (trip.cities.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.place_outlined,
                            size: 14, color: BookInk.inkFaint),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            trip.cities.join('  →  '),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              letterSpacing: 0.5,
                              color: BookInk.inkSoft,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          if (pageNumber != null)
            BookPageNumber(page: pageNumber!, isLeft: isLeft),
        ],
      ),
    );
  }
}
