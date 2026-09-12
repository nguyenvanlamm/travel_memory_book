import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/image_helper.dart';
import '../../../../models/photo.dart';
import 'paper_background.dart';

class BookPhotoPage extends StatelessWidget {
  final Photo? photo;
  final String? caption;
  final int? pageNumber;
  final bool isLeft;

  const BookPhotoPage({
    super.key,
    this.photo,
    this.caption,
    this.pageNumber,
    this.isLeft = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasCaption = caption != null && caption!.isNotEmpty;
    return PaperBackground(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
            child: Column(
              children: [
                // Ảnh trong khung mat trắng kiểu polaroid
                Expanded(
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: photo != null && appFileExists(photo!.filePath)
                          ? appImage(
                              photo!.filePath,
                              fit: BoxFit.contain,
                              fallback: _buildPlaceholder(),
                            )
                          : _buildPlaceholder(),
                    ),
                ),
                const SizedBox(height: 18),
                // Caption serif italic
                if (hasCaption)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      caption!,
                      style: GoogleFonts.merriweather(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: BookInk.ink,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                // Dòng meta nhỏ
                if (photo != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (photo!.latitude != null &&
                          photo!.longitude != null) ...[
                        const Icon(Icons.place_outlined,
                            size: 12, color: BookInk.inkFaint),
                        const SizedBox(width: 3),
                        Text(
                          photo!.locationName ?? 'GPS location',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: BookInk.inkFaint),
                        ),
                        Text('   ·   ',
                            style: GoogleFonts.inter(
                                fontSize: 11, color: BookInk.inkFaint)),
                      ],
                      Text(
                        DateFormat('d MMM yyyy · HH:mm')
                            .format(photo!.takenAt),
                        style: GoogleFonts.inter(
                            fontSize: 11, color: BookInk.inkFaint),
                      ),
                    ],
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

  Widget _buildPlaceholder() => Container(
        width: double.infinity,
        height: double.infinity,
        color: BookInk.paper,
        child: const Center(
          child: Icon(Icons.image_outlined,
              size: 48, color: BookInk.inkFaint),
        ),
      );
}
