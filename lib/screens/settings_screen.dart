import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../version.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ayarlar"),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return ListView(
            children: [
              _buildSectionHeader("Görünüm"),
              ListTile(
                title: const Text("Tema"),
                subtitle: Text(_getThemeName(provider.themeMode)),
                leading: const Icon(Icons.palette_outlined),
                onTap: () => _showThemeDialog(context, provider),
              ),
              const Divider(),
              _buildSectionHeader("Uygulama Ayarları"),
              ListTile(
                title: const Text("Otomatik Güncelleme"),
                subtitle: Text(provider.refreshIntervalMinutes == 0 
                    ? "Kapalı" 
                    : "${provider.refreshIntervalMinutes} dakikada bir"),
                leading: const Icon(Icons.refresh_rounded),
                onTap: () => _showRefreshDialog(context, provider),
              ),
              const Divider(),
              _buildSectionHeader("Hakkında"),
              const ListTile(
                title: Text("Versiyon"),
                subtitle: Text(appVersion),
                leading: Icon(Icons.info_outline),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.amber.shade800,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system: return "Sistem Varsayılanı";
      case ThemeMode.light: return "Aydınlık";
      case ThemeMode.dark: return "Karanlık";
    }
  }

  void _showThemeDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tema Seçin"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(_getThemeName(mode)),
              value: mode,
              groupValue: provider.themeMode,
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

  void _showRefreshDialog(BuildContext context, AppProvider provider) {
    final intervals = [0, 1, 5, 15, 30];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Güncelleme Aralığı"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: intervals.map((min) {
            return RadioListTile<int>(
              title: Text(min == 0 ? "Kapalı" : "$min Dakika"),
              value: min,
              groupValue: provider.refreshIntervalMinutes,
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
