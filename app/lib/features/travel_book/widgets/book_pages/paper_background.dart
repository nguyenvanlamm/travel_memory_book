import 'package:flutter/material.dart';

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
    this.textureOpacity = 0.07,
    this.edgeShadowWidth = 32,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF2A2520) : const Color(0xFFF4E4C1);
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
                          Colors.black.withValues(alpha: 0.25),
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
                          Colors.black.withValues(alpha: 0.25),
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
