import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/widgets/loading_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/web_layout.dart';
import '../widgets/trip_card.dart';
import '../providers/home_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tripsAsync = ref.watch(homeProvider);
    final notifier = ref.read(homeProvider.notifier);

    return Scaffold(
      body: tripsAsync.when(
        data: (trips) {
          if (trips.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                child: PageBody(
                  maxWidth: 720,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 48),
                  child: _HeroEmpty(theme: theme),
                ),
              ),
            );
          }
          return PageBody(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHero(theme, trips.length)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Your Library',
                            style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        PopupMenuButton<String>(
                          initialValue: notifier.sortBy,
                          onSelected: notifier.setSortBy,
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                                value: 'newest',
                                child: Text('Newest first')),
                            PopupMenuItem(
                                value: 'oldest',
                                child: Text('Oldest first')),
                            PopupMenuItem(
                                value: 'year', child: Text('By year')),
                            PopupMenuItem(
                                value: 'country',
                                child: Text('By country')),
                          ],
                          icon: const Icon(LucideIcons.arrowUpDown),
                          tooltip: 'Sort trips',
                        ),
                      ],
                    ),
                  ),
                ),
                SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => TripCard(
                      trip: trips[index],
                      onTap: () =>
                          context.go('/trips/${trips[index].id}'),
                    ),
                    childCount: trips.length,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 240,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 48)),
              ],
            ),
          );
        },
        loading: () => const Center(child: LoadingView()),
        error: (error, stack) => EmptyState(
          icon: LucideIcons.alertTriangle,
          title: 'Error loading trips',
          message: error.toString(),
          actionLabel: 'Retry',
          onAction: notifier.loadTrips,
        ),
      ),
    );
  }

  Widget _buildHero(ThemeData theme, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Turn your trips into books',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Select your travel photos and flip through them like a real photo book.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroEmpty extends StatelessWidget {
  final ThemeData theme;
  const _HeroEmpty({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 260,
          child: SvgPicture.asset(
            'assets/illustrations/travelers.svg',
            fit: BoxFit.contain,
            semanticsLabel: 'Travel illustration',
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Turn your trips into books',
          style: theme.textTheme.displaySmall
              ?.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Select your travel photos and flip through them\nlike a real photo book.',
          style: theme.textTheme.bodyLarge
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        FilledButton.icon(
          onPressed: () => context.go('/trips/new'),
          icon: const Icon(LucideIcons.plus),
          label: const Text('Create your first book'),
          style: FilledButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            textStyle: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
