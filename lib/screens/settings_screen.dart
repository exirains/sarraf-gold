import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../services/update_service.dart';
import '../services/localization_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.translate(context, 'settings')),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return ListView(
            children: [
              _buildSectionHeader(context, LocalizationService.translate(context, 'appearance')),
              ListTile(
                title: Text(LocalizationService.translate(context, 'theme')),
                subtitle: Text(_getThemeName(context, provider.themeMode)),
                leading: const Icon(Icons.palette_outlined),
                onTap: () => _showThemeDialog(context, provider),
              ),
              ListTile(
                title: Text(LocalizationService.translate(context, 'language')),
                subtitle: Text(_getLanguageName(provider.locale.languageCode)),
                leading: const Icon(Icons.language_rounded),
                onTap: () => _showLanguageDialog(context, provider),
              ),
              const Divider(),
              _buildSectionHeader(context, LocalizationService.translate(context, 'app_settings')),
              ListTile(
                title: Text(LocalizationService.translate(context, 'auto_refresh')),
                subtitle: Text(provider.refreshIntervalMinutes == 0 
                    ? LocalizationService.translate(context, 'off') 
                    : "${provider.refreshIntervalMinutes} ${LocalizationService.translate(context, 'minutes')}"),
                leading: const Icon(Icons.refresh_rounded),
                onTap: () => _showRefreshDialog(context, provider),
              ),
              const Divider(),
              _buildSectionHeader(context, LocalizationService.translate(context, 'about')),
              ListTile(
                title: Text(LocalizationService.translate(context, 'version')),
                subtitle: Text(UpdateService.localInfo?.version ?? '...'),
                leading: const Icon(Icons.info_outline),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.amber.shade800,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }

  String _getThemeName(BuildContext context, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system: return LocalizationService.translate(context, 'system_default');
      case ThemeMode.light: return LocalizationService.translate(context, 'light');
      case ThemeMode.dark: return LocalizationService.translate(context, 'dark');
    }
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'tr': return 'Türkçe';
      case 'en': return 'English';
      case 'fa': return 'فارسی';
      default: return code;
    }
  }

  void _showThemeDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationService.translate(context, 'choose_theme')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(_getThemeName(context, mode)),
              value: mode,
              // ignore: deprecated_member_use
              groupValue: provider.themeMode,
              // ignore: deprecated_member_use
              onChanged: (val) {
                if (val != null) provider.setThemeMode(val);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, AppProvider provider) {
    final languages = [
      {'code': 'tr', 'name': 'Türkçe'},
      {'code': 'en', 'name': 'English'},
      {'code': 'fa', 'name': 'فارسی'},
    ];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationService.translate(context, 'choose_language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return RadioListTile<String>(
              title: Text(lang['name']!),
              value: lang['code']!,
              // ignore: deprecated_member_use
              groupValue: provider.locale.languageCode,
              // ignore: deprecated_member_use
              onChanged: (val) {
                if (val != null) provider.setLocale(val);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showRefreshDialog(BuildContext context, AppProvider provider) {
    final intervals = [0, 1, 5, 15, 30];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationService.translate(context, 'update_interval')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: intervals.map((min) {
            return RadioListTile<int>(
              title: Text(min == 0 ? LocalizationService.translate(context, 'off') : "$min ${LocalizationService.translate(context, 'minutes')}"),
              value: min,
              // ignore: deprecated_member_use
              groupValue: provider.refreshIntervalMinutes,
              // ignore: deprecated_member_use
              onChanged: (val) {
                if (val != null) provider.setRefreshInterval(val);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
