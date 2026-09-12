import 'package:flutter/material.dart';
import '../../../core/utils/image_helper.dart';
import '../../../models/trip.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BookThumbnail extends StatefulWidget {
  final Trip trip;
  final VoidCallback onTap;

  const BookThumbnail({
    super.key,
    required this.trip,
    required this.onTap,
  });

  @override
  State<BookThumbnail> createState() => _BookThumbnailState();
}

class _BookThumbnailState extends State<BookThumbnail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _openController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _openController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _openController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (_openController.isAnimating) return;
    _openController.forward(from: 0).then((_) {
      if (mounted) widget.onTap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _openController,
        builder: (context, _) {
          final openProgress = _openController.value;
          final hoverScale = _isHovered ? 1.03 : 1.0;
          final pressScale = 1.0 - (openProgress * 0.05);
          final scale = hoverScale * pressScale;

          return Transform.scale(
            scale: scale,
            child: Material(
              elevation: _isHovered ? 12 : 6,
              shadowColor: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(4),
              child: InkWell(
                onTap: _onTap,
                borderRadius: BorderRadius.circular(4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final spineWidth = constraints.maxWidth * 0.08;
                      final edgesWidth = constraints.maxWidth * 0.05;
                      return _buildBook(
                        constraints: constraints,
                        spineWidth: spineWidth,
                        edgesWidth: edgesWidth,
                        isDark: isDark,
                        openProgress: openProgress,
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBook({
    required BoxConstraints constraints,
    required double spineWidth,
    required double edgesWidth,
    required bool isDark,
    required double openProgress,
  }) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;

    // Slide cover sang trái khi mở sách
    final slideOffset = -openProgress * (width - spineWidth) * 0.6;
    final coverOpacity = 1.0 - (openProgress * 0.3);

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // Lớp 1: Mép giấy ngà (page edges) - 3 đường ngang mờ
          Positioned(
            right: 0,
            top: 4,
            bottom: 4,
            width: edgesWidth,
            child: AnimatedBuilder(
              animation: _openController,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(slideOffset * 0.5, 0),
                  child: _PageEdges(
                    width: edgesWidth,
                    isDark: isDark,
                  ),
                );
              },
            ),
          ),

          // Lớp 2: Bìa chính (cover) - ảnh + overlay + tiêu đề
          Positioned(
            left: spineWidth,
            right: edgesWidth,
            top: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: _openController,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(slideOffset, 0),
                  child: Opacity(
                    opacity: coverOpacity,
                    child: _buildCover(isDark: isDark),
                  ),
                );
              },
            ),
          ),

          // Lớp 3: Gáy sách (spine) - gradient nâu trơn
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: spineWidth,
            child: _buildSpine(isDark: isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildSpine({required bool isDark}) {
    final darkColor1 = isDark ? const Color(0xFF0F0A06) : const Color(0xFF2A1F18);
    final darkColor2 = isDark ? const Color(0xFF1A1108) : const Color(0xFF3E2723);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [darkColor1, darkColor2],
        ),
        border: Border(
          right: BorderSide(
            color: Colors.black.withOpacity(0.4),
            width: 1,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Highlight bên trái của gáy (1px sáng)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCover({required bool isDark}) {
    final trip = widget.trip;
    final theme = Theme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Ảnh cover hoặc placeholder
        if (appFileExists(trip.coverPhotoPath))
          appImage(
            trip.coverPhotoPath,
            fit: BoxFit.cover,
            fallback: _buildEmptyCover(theme),
          )
        else
          _buildEmptyCover(theme),

        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
              stops: const [0.5, 1.0],
            ),
          ),
        ),

        // Tiêu đề + meta ở dưới
        Positioned(
          left: 8,
          right: 8,
          bottom: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                trip.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${trip.startDate.year} • ${trip.country}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCover(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF2A2520),
                  const Color(0xFF1A1714),
                ]
              : [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.primary.withOpacity(0.3),
                ],
        ),
      ),
      child: Center(
        child: Icon(
          LucideIcons.bookOpen,
          size: 48,
          color: (isDark ? Colors.white : theme.colorScheme.primary)
              .withOpacity(0.5),
        ),
      ),
    );
  }
}

class _PageEdges extends StatelessWidget {
  final double width;
  final bool isDark;

  const _PageEdges({required this.width, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final lightEdge = const Color(0xFFF4E4C1);
    final darkEdge = const Color(0xFF3A3530);
    final baseColor = isDark ? darkEdge : lightEdge;

    return CustomPaint(
      size: Size(width, double.infinity),
      painter: _PageEdgesPainter(baseColor: baseColor, isDark: isDark),
    );
  }
}

class _PageEdgesPainter extends CustomPainter {
  final Color baseColor;
  final bool isDark;

  _PageEdgesPainter({required this.baseColor, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // Nền mép giấy
    final bgPaint = Paint()..color = baseColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 3 đường ngang mờ mô phỏng các lớp giấy
    final lineColor = isDark
        ? Colors.white.withOpacity(0.15)
        : Colors.black.withOpacity(0.15);

    for (int i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      final paint = Paint()
        ..color = lineColor
        ..strokeWidth = 0.5;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Bóng trái (tối dần về phía cover)
    final shadowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.black.withOpacity(isDark ? 0.4 : 0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
