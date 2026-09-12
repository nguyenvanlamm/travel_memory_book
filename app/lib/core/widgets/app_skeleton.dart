import 'package:flutter/material.dart';

/// Shimmer placeholder for loading lists/grids.
class AppSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final double radius;

  const AppSkeleton({
    super.key,
    this.width,
    this.height,
    this.radius = 12,
  });

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.7);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + _ctrl.value * 2, 0),
              end: Alignment(0 + _ctrl.value * 2, 0),
              colors: [base, Color.alphaBlend(highlight, base), base],
            ),
          ),
        );
      },
    );
  }
}
