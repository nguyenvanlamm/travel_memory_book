import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Top navigation bar shown on every page (except the fullscreen book reader).
class SiteHeader extends StatelessWidget {
  const SiteHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final location = GoRouterState.of(context).uri.path;
    final compact = MediaQuery.sizeOf(context).width < 720;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                InkWell(
                  onTap: () => context.go('/'),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.bookOpen,
                            color: theme.colorScheme.primary, size: 26),
                        if (!compact) ...[
                          const SizedBox(width: 10),
                          Text(
                            'Travel Memory Book',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                _NavItem(
                  label: 'Library',
                  icon: LucideIcons.library,
                  activeIcon: LucideIcons.library,
                  active: location == '/' ||
                      location.startsWith('/trips'),
                  compact: compact,
                  onTap: () => context.go('/'),
                ),
                _NavItem(
                  label: 'Profile',
                  icon: LucideIcons.user,
                  activeIcon: LucideIcons.user,
                  active: location.startsWith('/profile'),
                  compact: compact,
                  onTap: () => context.go('/profile'),
                ),
                _NavItem(
                  label: 'Settings',
                  icon: LucideIcons.settings,
                  activeIcon: LucideIcons.settings,
                  active: location.startsWith('/settings'),
                  compact: compact,
                  onTap: () => context.go('/settings'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => context.go('/trips/new'),
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: Text(compact ? 'New' : 'New Book'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool active;
  final bool compact;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.active,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = active
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(active ? activeIcon : icon, size: 20, color: color),
        label: compact
            ? const SizedBox.shrink()
            : Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
        style: TextButton.styleFrom(
          backgroundColor: active
              ? theme.colorScheme.primary.withOpacity(0.08)
              : Colors.transparent,
          padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 14, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

/// Decorative site backdrop: warm gradient, faint paper grain and two
/// soft colour glows — replaces the flat scaffold colour on wide screens.
class WebBackdrop extends StatelessWidget {
  const WebBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? const [Color(0xFF101A2E), Color(0xFF0B1220)]
                    : const [Color(0xFFFCF8F0), Color(0xFFF1E6CF)],
              ),
            ),
          ),
          Opacity(
            opacity: dark ? 0.04 : 0.07,
            child: Image.asset(
              'assets/images/book/paper-texture.png',
              repeat: ImageRepeat.repeat,
              fit: BoxFit.none,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          Positioned(
            top: -220,
            right: -160,
            child: _Glow(
              color: dark
                  ? const Color(0xFFD4AF37).withOpacity(0.12)
                  : const Color(0xFFE8A87C).withOpacity(0.30),
              size: 620,
            ),
          ),
          Positioned(
            bottom: -240,
            left: -200,
            child: _Glow(
              color: dark
                  ? const Color(0xFF38BDF8).withOpacity(0.08)
                  : const Color(0xFFC38D9E).withOpacity(0.22),
              size: 640,
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;

  const _Glow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
        ),
      ),
    );
  }
}

/// Centers page content at a readable max width with consistent padding.
class PageBody extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const PageBody({
    super.key,
    required this.child,
    this.maxWidth = 1080,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (onBack != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton.filledTonal(
                onPressed: onBack,
                icon: const Icon(LucideIcons.arrowLeft),
                tooltip: 'Back',
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
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
