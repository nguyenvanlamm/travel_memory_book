import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared ink colors for book pages — fixed parchment palette, independent of
/// the app light/dark theme (a printed page looks the same either way).
class BookInk {
  static const Color ink = Color(0xFF4A3428);
  static const Color inkSoft = Color(0xB34A3428);
  static const Color inkFaint = Color(0x804A3428);
  static const Color rule = Color(0xFF8D6E63);
  static const Color paper = Color(0xFFF8F0DC);
}

class PaperBackground extends StatelessWidget {
  final Widget? child;
  final bool showLinedPattern;
  final double textureOpacity;
  final double edgeShadowWidth;
  final BorderRadius? borderRadius;

  const PaperBackground({
    super.key,
    this.child,
    this.showLinedPattern = false,
    this.textureOpacity = 0.10,
    this.edgeShadowWidth = 36,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Trang sách luôn màu giấy — không đổi theo dark mode của app.
    const baseColor = BookInk.paper;
    final textureAsset = showLinedPattern
        ? 'assets/images/book/lined-paper.png'
        : 'assets/images/book/paper-texture.png';

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Container(
        color: baseColor,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (showLinedPattern)
              Image.asset(
                'assets/images/book/lined-paper.png',
                fit: BoxFit.cover,
                repeat: ImageRepeat.repeat,
              )
            else
              Opacity(
                opacity: textureOpacity,
                child: Image.asset(
                  textureAsset,
                  fit: BoxFit.cover,
                  repeat: ImageRepeat.repeat,
                ),
              ),
            // Bóng mép gáy sách (2 phía — page nào cũng cần)
            Row(
              children: [
                SizedBox(
                  width: edgeShadowWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withOpacity(0.28),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: edgeShadowWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          Colors.black.withOpacity(0.28),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}

/// Số trang nhỏ ở góc ngoài dưới — như sách in thật.
/// `isLeft` = trang chẵn (bên trái gáy), số trang nằm góc trái.
class BookPageNumber extends StatelessWidget {
  final int page;
  final bool isLeft;

  const BookPageNumber({super.key, required this.page, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 10,
      left: isLeft ? 18 : null,
      right: isLeft ? null : 18,
      child: Text(
        '$page',
        style: GoogleFonts.inter(
          fontSize: 11,
          letterSpacing: 0.5,
          color: BookInk.inkFaint,
        ),
      ),
    );
  }
}

/// Đường kẻ + hình thoi trang trí dùng trong các trang sách.
class BookOrnament extends StatelessWidget {
  final double width;
  final Color color;

  const BookOrnament({super.key, this.width = 120, this.color = BookInk.rule});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
        children: [
          Expanded(child: Container(height: 0.8, color: color.withOpacity(0.6))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Transform.rotate(
              angle: 0.785398,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  border: Border.all(color: color, width: 1.2),
                ),
              ),
            ),
          ),
          Expanded(child: Container(height: 0.8, color: color.withOpacity(0.6))),
        ],
      ),
    );
  }
}
