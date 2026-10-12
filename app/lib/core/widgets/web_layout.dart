import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_theme.dart';

/// Centers page content at a readable max width with consistent padding.
class PageBody extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const PageBody({
    super.key,
    required this.child,
    this.maxWidth = 1080,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < AppBreakpoints.rail;
    return ColoredBox(
      color: AppPalette.of(context).paper1,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: padding ??
                EdgeInsets.symmetric(
                  horizontal: narrow ? AppSpacing.md : AppSpacing.xl,
                  vertical: narrow ? AppSpacing.md : AppSpacing.xl,
                ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Page-level heading used inside [PageBody] instead of a mobile AppBar.
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final VoidCallback? onBack;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    final narrow = MediaQuery.sizeOf(context).width < AppBreakpoints.rail;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (onBack != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton.outlined(
                onPressed: onBack,
                style: IconButton.styleFrom(side: BorderSide(color: p.line)),
                icon: const Icon(LucideIcons.arrowLeft, size: 18),
                tooltip: 'Back',
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: narrow ? text.headlineMedium : text.displaySmall),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!,
                      style: text.bodyMedium?.copyWith(color: p.ink2)),
                ],
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}
