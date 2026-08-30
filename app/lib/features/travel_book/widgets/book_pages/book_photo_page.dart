import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../../../../models/photo.dart';
import 'paper_background.dart';

class BookPhotoPage extends StatelessWidget {
  final Photo? photo;
  final String? caption;
  const BookPhotoPage({super.key, this.photo, this.caption});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PaperBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: photo != null &&
                        photo!.filePath.isNotEmpty &&
                        File(photo!.filePath).existsSync()
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(photo!.filePath),
                          fit: BoxFit.contain,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) =>
                              _buildPlaceholder(theme),
                        ),
                      )
                    : _buildPlaceholder(theme),
              ),
            ),
            if (caption != null && caption!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  caption!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (photo != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Column(
                  children: [
                    if (photo!.latitude != null && photo!.longitude != null)
                      Text(
                        '📍 ${photo!.locationName ?? 'GPS location'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('d MMM yyyy · HH:mm').format(photo!.takenAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ),
      );
}
