import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'paper_background.dart';

class BookMemoryPage extends StatelessWidget {
  final String? title;
  final String content;
  final int? pageNumber;
  final bool isLeft;

  const BookMemoryPage({
    super.key,
    this.title,
    required this.content,
    this.pageNumber,
    this.isLeft = false,
  });

  @override
  Widget build(BuildContext context) {
    return PaperBackground(
      showLinedPattern: true,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(36, 32, 28, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: GoogleFonts.merriweather(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: BookInk.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const BookOrnament(width: 100),
                  const SizedBox(height: 16),
                ],
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      content,
                      style: GoogleFonts.merriweather(
                        fontSize: 14,
                        height: 1.8,
                        color: BookInk.ink,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (pageNumber != null)
            BookPageNumber(page: pageNumber!, isLeft: isLeft),
        ],
      ),
    );
  }
}
