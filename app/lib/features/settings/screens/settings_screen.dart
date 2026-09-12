import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/providers/theme_mode_provider.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/web_layout.dart';
import '../../travel_book/services/page_flip_audio_service.dart';

class SettingsScreen extends ConsumerStatefulWidget { const SettingsScreen({super.key}); @override ConsumerState<SettingsScreen> createState() => _SettingsScreenState(); }

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pageFlipSoundEnabled = true;
  @override void initState() { super.initState(); _loadSettings(); }
  Future<void> _loadSettings() async { final audioService = ref.read(pageFlipAudioServiceProvider); await audioService.init(); if (mounted) setState(() { _pageFlipSoundEnabled = audioService.enabled; }); }
  Future<void> _saveThemeMode(ThemeMode mode) async { final prefs = await SharedPreferences.getInstance(); await prefs.setInt('theme_mode', mode.index); ref.read(themeModeProvider.notifier).state = mode; }
  Future<void> _savePageFlipSound(bool enabled) async { await ref.read(pageFlipAudioServiceProvider).setEnabled(enabled); if (mounted) setState(() => _pageFlipSoundEnabled = enabled); }

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(body: PageBody(maxWidth: 640, child: ListView(children: [
      const PageHeader(title: 'Settings'),
      const SectionHeader(title: 'Appearance'),
      Card(child: Column(children: [
        RadioListTile<ThemeMode>(title: const Text('Light'), subtitle: const Text('Always use light theme'), value: ThemeMode.light, groupValue: themeMode, onChanged: (v) => _saveThemeMode(v!)),
        RadioListTile<ThemeMode>(title: const Text('Dark'), subtitle: const Text('Always use dark theme'), value: ThemeMode.dark, groupValue: themeMode, onChanged: (v) => _saveThemeMode(v!)),
        RadioListTile<ThemeMode>(title: const Text('System'), subtitle: const Text('Follow system setting'), value: ThemeMode.system, groupValue: themeMode, onChanged: (v) => _saveThemeMode(v!)),
      ])),
      const SizedBox(height: 24), const SectionHeader(title: 'Reading Experience'),
      Card(child: SwitchListTile(title: const Text('Page Flip Sound'), subtitle: const Text('Play a soft sound when turning pages'), value: _pageFlipSoundEnabled, onChanged: _savePageFlipSound)),
      const SizedBox(height: 24), const SectionHeader(title: 'About'),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Travel Memory Book', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text('A simple tool that turns your travel photos into digital flip books.', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 16),
        Text('Version 1.0.0', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        Text('Built with Flutter', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Text('Your memories. Your stories. Preserved forever.', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic)),
      ]))),
      const SizedBox(height: 48),
    ])));
  }
}
