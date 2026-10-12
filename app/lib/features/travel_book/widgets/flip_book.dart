import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Drives a [FlipBook] from outside (buttons, keys, chapter jumps).
class FlipBookController extends ChangeNotifier {
  _FlipBookState? _state;

  int get spread => _state?._spread ?? 0;
  int get totalSpreads => _state?._totalSpreads ?? 0;

  void next() => _state?._turn(1);
  void previous() => _state?._turn(-1);
  void jumpTo(int spread) => _state?._jumpTo(spread);

  void _changed() => notifyListeners();
}

/// A book whose pages are live widgets — nothing is rasterised, so text stays
/// as sharp as the rest of the UI at any screen density.
///
/// Two-page mode: spread 0 is the front cover alone, spread k shows pages
/// 2k-1 | 2k, and the last page closes the book on the left. Single-page
/// mode shows one page per spread. The turning leaf rotates in 3D about the
/// spine; drag it, tap either half, or use the [controller].
class FlipBook extends StatefulWidget {
  final List<Widget> pages;
  final Size pageSize;
  final bool singlePage;
  final FlipBookController controller;
  final ValueChanged<int>? onSpreadChanged;

  /// Called when a turn completes (for the page sound).
  final VoidCallback? onTurned;

  const FlipBook({
    super.key,
    required this.pages,
    required this.pageSize,
    required this.controller,
    this.singlePage = false,
    this.onSpreadChanged,
    this.onTurned,
  });

  @override
  State<FlipBook> createState() => _FlipBookState();
}

class _FlipBookState extends State<FlipBook> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  );
  int _spread = 0;
  int _dir = 0; // +1 forward, -1 back, 0 idle
  double _dragStartX = 0;

  int get _n => widget.pages.length;
  int get _totalSpreads => widget.singlePage ? _n : _n ~/ 2 + 1;

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
    _anim.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(FlipBook old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller._state = null;
      widget.controller._state = this;
    }
    if (old.singlePage != widget.singlePage) {
      // Keep the reader on the same page when switching modes.
      final page = old.singlePage ? _spread : math.max(0, _spread * 2 - 1);
      _spread = widget.singlePage ? page : (page + 1) ~/ 2;
      _dir = 0;
      _anim.value = 0;
    }
    _spread = _spread.clamp(0, _totalSpreads - 1);
  }

  @override
  void dispose() {
    if (widget.controller._state == this) widget.controller._state = null;
    _anim.dispose();
    super.dispose();
  }

  Widget? _page(int i) => i >= 0 && i < _n ? widget.pages[i] : null;
  Widget? _left(int s) => widget.singlePage ? null : (s == 0 ? null : _page(2 * s - 1));
  Widget? _right(int s) => widget.singlePage ? _page(s) : _page(2 * s);

  bool _can(int dir) => dir > 0 ? _spread < _totalSpreads - 1 : _spread > 0;

  void _settle(int spread) {
    setState(() {
      _spread = spread;
      _dir = 0;
      _anim.value = 0;
    });
    widget.controller._changed();
    widget.onSpreadChanged?.call(spread);
  }

  Future<void> _turn(int dir) async {
    if (_dir != 0 || !_can(dir)) return;
    setState(() => _dir = dir);
    await _anim.animateTo(1, curve: Curves.easeInOutCubic);
    if (!mounted) return;
    widget.onTurned?.call();
    _settle(_spread + dir);
  }

  void _jumpTo(int spread) {
    if (_dir != 0) return;
    final target = spread.clamp(0, _totalSpreads - 1);
    if (target == _spread) return;
    if ((target - _spread).abs() == 1) {
      _turn(target > _spread ? 1 : -1);
      return;
    }
    widget.onTurned?.call();
    _settle(target);
  }

  // ── gestures ────────────────────────────────────────────────────────────
  void _onDragStart(DragStartDetails d) {
    if (_dir != 0 && _anim.isAnimating) return;
    _dragStartX = d.localPosition.dx;
    _dir = 0;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_anim.isAnimating) return;
    final dx = d.localPosition.dx - _dragStartX;
    if (_dir == 0) {
      final dir = dx < 0 ? 1 : -1;
      if (dx.abs() < 4 || !_can(dir)) return;
      setState(() => _dir = dir);
    }
    final travel = widget.pageSize.width * (widget.singlePage ? 1 : 1.6);
    _anim.value = (-dx * _dir / travel).clamp(0.0, 1.0);
  }

  Future<void> _onDragEnd(DragEndDetails d) async {
    if (_dir == 0 || _anim.isAnimating) return;
    final v = -d.velocity.pixelsPerSecond.dx * _dir;
    final complete = _anim.value > 0.35 || v > 500;
    if (complete) {
      await _anim.animateTo(1, curve: Curves.easeOut);
      if (!mounted) return;
      widget.onTurned?.call();
      _settle(_spread + _dir);
    } else {
      await _anim.animateBack(0, curve: Curves.easeOut);
      if (mounted) setState(() => _dir = 0);
    }
  }

  void _onTapUp(TapUpDetails d, double width) {
    var dir = d.localPosition.dx < width / 2 ? -1 : 1;
    // A closed book (cover or back alone) turns whichever way it can.
    if (!_can(dir)) dir = -dir;
    _turn(dir);
  }

  // ── painting ────────────────────────────────────────────────────────────
  /// How far the book slides so a lone cover sits in the middle.
  double _offsetFor(int s) {
    if (widget.singlePage) return 0;
    final w = widget.pageSize.width;
    if (_left(s) == null) return -w / 2;
    if (_right(s) == null) return w / 2;
    return 0;
  }

  Widget _slot(Widget? page) => SizedBox.fromSize(
        size: widget.pageSize,
        child: page == null
            ? null
            : DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 28,
                      spreadRadius: -10,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: RepaintBoundary(child: page),
              ),
      );

  /// A page turning about [hingeLeft] (true: its left edge) by [angle].
  Widget _leaf(Widget? page, {required bool hingeLeft, required double angle}) {
    final shade = math.sin(angle.abs()).clamp(0.0, 1.0) * 0.28;
    return Transform(
      alignment: hingeLeft ? Alignment.centerLeft : Alignment.centerRight,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0011)
        ..rotateY(angle),
      child: Stack(
        children: [
          _slot(page),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: hingeLeft ? Alignment.centerLeft : Alignment.centerRight,
                    end: hingeLeft ? Alignment.centerRight : Alignment.centerLeft,
                    colors: [
                      Colors.black.withValues(alpha: shade),
                      Colors.black.withValues(alpha: shade * 0.35),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _spreadView() {
    final w = widget.pageSize.width;
    final t = _anim.value;
    final s = _spread;

    if (widget.singlePage) {
      final base = _dir > 0 ? _right(s + 1) : _right(s);
      final turning = _dir > 0 ? _right(s) : (_dir < 0 ? _right(s - 1) : null);
      final angle = _dir > 0 ? -math.pi / 2 * t : -math.pi / 2 * (1 - t);
      return Stack(
        children: [
          _slot(base),
          if (_dir != 0 && angle.abs() < math.pi / 2 - 0.01)
            _leaf(turning, hingeLeft: true, angle: angle),
        ],
      );
    }

    final target = s + _dir;
    final offset = _dir == 0 ? _offsetFor(s) : _offsetFor(s) + (_offsetFor(target) - _offsetFor(s)) * t;

    Widget? baseLeft, baseRight, front, back;
    if (_dir > 0) {
      baseLeft = _left(s);
      baseRight = _right(target);
      front = _right(s);
      back = _left(target);
    } else if (_dir < 0) {
      baseLeft = _left(target);
      baseRight = _right(s);
      front = _left(s);
      back = _right(target);
    } else {
      baseLeft = _left(s);
      baseRight = _right(s);
    }

    final children = <Widget>[
      Positioned(left: 0, top: 0, child: _slot(baseLeft)),
      Positioned(left: w, top: 0, child: _slot(baseRight)),
    ];
    if (_dir > 0) {
      children.add(t < 0.5
          ? Positioned(left: w, top: 0, child: _leaf(front, hingeLeft: true, angle: -math.pi * t))
          : Positioned(left: 0, top: 0, child: _leaf(back, hingeLeft: false, angle: math.pi * (1 - t))));
    } else if (_dir < 0) {
      children.add(t < 0.5
          ? Positioned(left: 0, top: 0, child: _leaf(front, hingeLeft: false, angle: math.pi * t))
          : Positioned(left: w, top: 0, child: _leaf(back, hingeLeft: true, angle: -math.pi * (1 - t))));
    }
    // The gutter: a soft fold shadow down the spine when both pages lie open.
    if (baseLeft != null && baseRight != null) {
      children.add(Positioned(
        left: w - 18,
        top: 0,
        width: 36,
        height: widget.pageSize.height,
        child: const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Color(0x00000000),
                Color(0x2E000000),
                Color(0x00000000),
              ]),
            ),
          ),
        ),
      ));
    }

    return Transform.translate(
      offset: Offset(offset, 0),
      child: SizedBox(
        width: w * 2,
        height: widget.pageSize.height,
        child: Stack(clipBehavior: Clip.none, children: children),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.pageSize.width * (widget.singlePage ? 1 : 2);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      onTapUp: (d) => _onTapUp(d, width),
      child: SizedBox(
        width: width,
        height: widget.pageSize.height,
        child: _spreadView(),
      ),
    );
  }
}
