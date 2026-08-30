import 'package:flutter/material.dart';
import 'paper_background.dart';

class BookMemoryPage extends StatelessWidget {
  final String? title;
  final String content;
  const BookMemoryPage({super.key, this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PaperBackground(
      showLinedPattern: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  content,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.7,
                    color: theme.colorScheme.onSurface,
                    fontFamily: 'serif',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
