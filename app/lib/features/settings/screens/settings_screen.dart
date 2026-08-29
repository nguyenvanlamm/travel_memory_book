import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/widgets/section_header.dart';

class SettingsScreen extends ConsumerStatefulWidget { const SettingsScreen({super.key}); @override ConsumerState<SettingsScreen> createState() => _SettingsScreenState(); }

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  ThemeMode _themeMode = ThemeMode.system; bool _notificationsEnabled = false;
  @override void initState() { super.initState(); _loadSettings(); }
  Future<void> _loadSettings() async { final prefs = await SharedPreferences.getInstance(); if (mounted) setState(() { _themeMode = ThemeMode.values[prefs.getInt('theme_mode') ?? 0]; _notificationsEnabled = prefs.getBool('notifications') ?? false; }); }
  Future<void> _saveThemeMode(ThemeMode mode) async { final prefs = await SharedPreferences.getInstance(); await prefs.setInt('theme_mode', mode.index); if (mounted) setState(() => _themeMode = mode); }
  Future<void> _saveNotifications(bool enabled) async { final prefs = await SharedPreferences.getInstance(); await prefs.setBool('notifications', enabled); if (mounted) setState(() => _notificationsEnabled = enabled); }

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(appBar: AppBar(title: const Text('Settings')), body: ListView(padding: const EdgeInsets.all(16), children: [
      SectionHeader(title: 'Appearance'),
      Card(child: Column(children: [RadioListTile<ThemeMode>(title: const Text('Light'), subtitle: const Text('Always use light theme'), value: ThemeMode.light, groupValue: _themeMode, onChanged: (v) => _saveThemeMode(v!)), RadioListTile<ThemeMode>(title: const Text('Dark'), subtitle: const Text('Always use dark theme'), value: ThemeMode.dark, groupValue: _themeMode, onChanged: (v) => _saveThemeMode(v!)), RadioListTile<ThemeMode>(title: const Text('System'), subtitle: const Text('Follow system setting'), value: ThemeMode.system, groupValue: _themeMode, onChanged: (v) => _saveThemeMode(v!))])),
      const SizedBox(height: 24), SectionHeader(title: 'Notifications'),
      Card(child: SwitchListTile(title: const Text('Enable Notifications'), subtitle: const Text('Receive reminders and updates'), value: _notificationsEnabled, onChanged: (v) async { final prefs = await SharedPreferences.getInstance(); await prefs.setBool('notifications', v); if (mounted) setState(() => _notificationsEnabled = v); })),
      const SizedBox(height: 24), SectionHeader(title: 'Storage'),
      Card(child: ListTile(leading: const Icon(Icons.storage_outlined), title: const Text('Manage Storage'), subtitle: const Text('View and clear cached data'), trailing: const Icon(Icons.chevron_right), onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Storage management coming soon'))))),
      const SizedBox(height: 24), SectionHeader(title: 'Backup & Sync'),
      Card(child: ListTile(leading: const Icon(Icons.cloud_upload_outlined), title: const Text('Cloud Backup'), subtitle: const Text('Backup your data to the cloud (coming in Phase 3)'), trailing: const Icon(Icons.chevron_right), onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cloud backup coming in Phase 3'))))),
      const SizedBox(height: 24), SectionHeader(title: 'About'),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Travel Memory Book', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)), const SizedBox(height: 8), Text('A personal travel journal that turns your trips into digital photo books.', style: theme.textTheme.bodyMedium), const SizedBox(height: 16), Text('Version 1.0.0', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)), Text('Built with Flutter & Isar', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)), const SizedBox(height: 16), Text('Your memories. Your stories. Preserved forever.', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic))]))),
    ]));
  }
}
