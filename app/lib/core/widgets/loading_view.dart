import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Branded loading state — pulsing book mark + thin accent spinner.
/// Replaces bare CircularProgressIndicator across the app.
class LoadingView extends StatefulWidget {
  final String? message;
  const LoadingView({super.key, this.message});

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.brightness == Brightness.dark
        ? AppTheme.gold
        : theme.colorScheme.primary;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) => Opacity(
              opacity: 0.55 + _ctrl.value * 0.45,
              child: child,
            ),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accent.withOpacity(0.6), width: 1.2),
              ),
              child: Icon(LucideIcons.bookOpen, size: 26, color: accent),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                minHeight: 3,
                color: accent,
                backgroundColor: accent.withOpacity(0.15),
              ),
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.message!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
