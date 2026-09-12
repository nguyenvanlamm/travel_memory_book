import 'package:flutter/material.dart';

/// Shared hard-cover material: dark leather with grain, sheen, vignette
/// and a gold double frame. Used by both front and back covers.
class LeatherCover extends StatelessWidget {
  final Widget child;
  const LeatherCover({super.key, required this.child});

  static const gold = Color(0xFFD4B98C);
  static const ivory = Color(0xFFF5EBD7);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4E3A2B),
                Color(0xFF37271B),
                Color(0xFF241811),
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),
        Opacity(
          opacity: 0.08,
          child: Image.asset(
            'assets/images/book/paper-texture.png',
            repeat: ImageRepeat.repeat,
            fit: BoxFit.none,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.7),
              radius: 1.1,
              colors: [
                Colors.white.withOpacity(0.10),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 1.25,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.42),
              ],
              stops: const [0.55, 1.0],
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: gold.withOpacity(0.75), width: 1.4),
              ),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: gold.withOpacity(0.35), width: 0.8),
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Gold rule–diamond–rule divider used on the covers.
class CoverOrnament extends StatelessWidget {
  final double width;
  const CoverOrnament({super.key, this.width = 140});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(children: [
        Expanded(
            child:
                Container(height: 0.8, color: LeatherCover.gold.withOpacity(0.7))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Transform.rotate(
            angle: 0.785398,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                border: Border.all(color: LeatherCover.gold, width: 1.1),
              ),
            ),
          ),
        ),
        Expanded(
            child:
                Container(height: 0.8, color: LeatherCover.gold.withOpacity(0.7))),
      ]),
    );
  }
}
