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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    // After the first frame, we mark it as animated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _hasAnimated = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sarraf Gold"),
        actions: [
          Consumer<AppProvider>(
            builder: (context, provider, child) {
              IconData themeIcon;
              if (provider.themeMode == ThemeMode.light) {
                themeIcon = Icons.wb_sunny_rounded;
              } else if (provider.themeMode == ThemeMode.dark) {
                themeIcon = Icons.nightlight_round;
              } else {
                themeIcon = Icons.brightness_auto_rounded;
              }
              return IconButton(
                icon: Icon(themeIcon),
                onPressed: () {
                  if (provider.themeMode == ThemeMode.light) {
                    provider.setThemeMode(ThemeMode.dark);
                  } else if (provider.themeMode == ThemeMode.dark) {
                    provider.setThemeMode(ThemeMode.system);
                  } else {
                    provider.setThemeMode(ThemeMode.light);
                  }
                },
                tooltip: "Tema Değiştir",
              );
            },
          ),
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
      body: RepaintBoundary(
        child: Consumer<AppProvider>(
          builder: (context, provider, child) {
            final favorites = provider.favoritePrices.take(5).toList();

            return RefreshIndicator(
              onRefresh: provider.refreshAll,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _AnimatedEntry(
                    delay: 0,
                    shouldAnimate: !_hasAnimated,
                    child: _buildHeader(provider),
                  ),
                  const SizedBox(height: 20),
                  _AnimatedEntry(
                    delay: 100,
                    shouldAnimate: !_hasAnimated,
                    child: _buildQuickActions(context, provider),
                  ),
                  const SizedBox(height: 24),
                  if (favorites.isNotEmpty) ...[
                    _AnimatedEntry(
                      delay: 200,
                      shouldAnimate: !_hasAnimated,
                      child: Row(
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
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(favorites.length, (index) {
                      return _AnimatedEntry(
                        delay: 250 + (index * 50),
                        shouldAnimate: !_hasAnimated,
                        child: _buildPriceCard(favorites[index]),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                  _AnimatedEntry(
                    delay: 400,
                    shouldAnimate: !_hasAnimated,
                    child: const Text(
                      "Piyasa Özeti",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _AnimatedEntry(
                    delay: 450,
                    shouldAnimate: !_hasAnimated,
                    child: _buildSummarySection(provider),
                  ),
                  const SizedBox(height: 24),
                  _AnimatedEntry(
                    delay: 500,
                    shouldAnimate: !_hasAnimated,
                    child: _buildLastUpdate(provider),
                  ),
                ],
              ),
            );
          },
        ),
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

  Widget _buildQuickActions(BuildContext context, AppProvider provider) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _buildActionItem(context, provider, "Altın", Icons.savings_rounded, Colors.amber, 1),
        _buildActionItem(context, provider, "Döviz", Icons.monetization_on_rounded, Colors.blue, 2),
        _buildActionItem(context, provider, "Hesapla", Icons.calculate_rounded, Colors.green, 3),
        _buildActionItem(context, provider, "İletişim", Icons.contact_support_rounded, Colors.purple, 4),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, AppProvider provider, String title, IconData icon, Color color, int index) {
    return InkWell(
      onTap: () => provider.setSelectedIndex(index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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

class _AnimatedEntry extends StatelessWidget {
  final Widget child;
  final int delay;
  final bool shouldAnimate;

  const _AnimatedEntry({
    required this.child, 
    required this.delay,
    this.shouldAnimate = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!shouldAnimate) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
