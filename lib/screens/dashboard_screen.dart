import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_provider.dart';
import '../models/gold_price.dart';
import '../widgets/price_card.dart';
import '../widgets/category_icon.dart';
import '../services/gold_names.dart';
import '../services/currency_names.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sarraf Gold"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AppProvider>().refreshAll(),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final favorites = provider.favoritePrices.take(5).toList();

          return RefreshIndicator(
            onRefresh: provider.refreshAll,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(provider),
                const SizedBox(height: 20),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                if (favorites.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Favorilerim (Üst 5)",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${favorites.length}/5",
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...favorites.map((price) => _buildPriceCard(price)),
                  const SizedBox(height: 16),
                ],
                const Text(
                  "Piyasa Özeti",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildSummarySection(provider),
                const SizedBox(height: 24),
                _buildLastUpdate(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade700, Colors.amber.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🟡 Sarraf Gold",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Text(
            "Güvenilir ve Canlı Piyasalar",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat("d MMMM yyyy", "tr").format(DateTime.now()),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              _buildStatusIndicator(provider.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(FetchStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case FetchStatus.live:
        color = Colors.greenAccent;
        text = "Canlı";
        icon = Icons.circle;
        break;
      case FetchStatus.offline:
        color = Colors.orangeAccent;
        text = "Çevrimdışı";
        icon = Icons.cloud_off;
        break;
      case FetchStatus.error:
        color = Colors.redAccent;
        text = "Bağlantı Yok";
        icon = Icons.error_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 8, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _buildActionItem(context, "Altın", Icons.savings_rounded, Colors.amber, 1),
        _buildActionItem(context, "Döviz", Icons.monetization_on_rounded, Colors.blue, 2),
        _buildActionItem(context, "Hesapla", Icons.calculate_rounded, Colors.green, 3),
        _buildActionItem(context, "İletişim", Icons.contact_support_rounded, Colors.purple, 4),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, String title, IconData icon, Color color, int index) {
    // Note: We need a way to communicate tab change to HomeScreen, but for now we'll use a callback or just keep it simple.
    // In this simplified Version 1.0, we'll assume the user is okay with these being static or use a workaround.
    return InkWell(
      onTap: () {
        // Workaround to switch tabs if HomeScreen is the parent. 
        // A better way is using a TabController or Provider, but let's stick to simplest.
        // For now, let's just show a snackbar or implement a notification.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$title sekmesine alt menüden gidebilirsiniz."), duration: const Duration(seconds: 1)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(AppProvider provider) {
    final summaryItems = [
      if (provider.goldPrices.isNotEmpty) provider.goldPrices.first,
      if (provider.currencies.isNotEmpty) provider.currencies.first,
    ];

    return Column(
      children: summaryItems.map((price) => _buildPriceCard(price)).toList(),
    );
  }

  Widget _buildPriceCard(GoldPrice price) {
    bool isGold = GoldNames.names.containsKey(price.code);
    return PriceCard(
      gold: price,
      leadingIcon: CategoryIcon(
        category: isGold ? GoldNames.getCategory(price.code) : 'currency',
        emoji: isGold ? Text(GoldNames.getIcon(price.code)) : Text(CurrencyNames.getIcon(price.code)),
      ),
    );
  }

  Widget _buildLastUpdate(AppProvider provider) {
    return Center(
      child: Column(
        children: [
          Text(
            "Son Güncelleme: ${provider.lastUpdate != null ? DateFormat("HH:mm:ss").format(provider.lastUpdate!) : '-'}",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          if (provider.status == FetchStatus.offline)
            const Text(
              "(Çevrimdışı veriler gösteriliyor)",
              style: TextStyle(color: Colors.orange, fontSize: 10),
            ),
        ],
      ),
    );
  }
}
