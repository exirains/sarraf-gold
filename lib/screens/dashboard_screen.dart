import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/app_provider.dart';
import '../services/localization_service.dart';
import '../models/gold_price.dart';
import '../models/user_profile.dart';
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

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  bool _hasAnimated = false;
  late AnimationController _bubbleController;
  late AnimationController _floatController;
  late Animation<double> _bubbleOffset;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _bubbleOffset = Tween<double>(begin: -150, end: 0).animate(
      CurvedAnimation(parent: _bubbleController, curve: Curves.elasticOut),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _floatAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _hasAnimated = true);
        final provider = Provider.of<AppProvider>(context, listen: false);
        if (!provider.isAuthenticated && !provider.hasShownReminder) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted && !provider.isAuthenticated && !provider.hasShownReminder) {
              _bubbleController.forward();
              provider.markReminderAsShown();
              
              // Auto-dismiss after 6 seconds
              Future.delayed(const Duration(seconds: 6), () {
                if (mounted) _bubbleController.reverse();
              });
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.translate(context, 'app_name')),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => provider.setSelectedIndex(4), // Switch to Profile tab
            tooltip: LocalizationService.translate(context, 'profile'),
          ),
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
                tooltip: LocalizationService.translate(context, 'choose_theme'),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
            tooltip: LocalizationService.translate(context, 'settings'),
          ),
        ],
      ),
      body: Stack(
        children: [
          RepaintBoundary(
            child: RefreshIndicator(
              onRefresh: provider.refreshAll,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _AnimatedEntry(
                    delay: 0,
                    shouldAnimate: !_hasAnimated,
                    child: _buildHeader(context, provider),
                  ),
                  if (provider.isAuthenticated && provider.profile != null)
                    _AnimatedEntry(
                      delay: 50,
                      shouldAnimate: !_hasAnimated,
                      child: _buildPointsStrip(context, provider.profile!),
                    ),
                  const SizedBox(height: 20),
                  _AnimatedEntry(
                    delay: 100,
                    shouldAnimate: !_hasAnimated,
                    child: _buildQuickActions(context, provider),
                  ),
                  const SizedBox(height: 24),
                  if (provider.favoritePrices.isNotEmpty) ...[
                    _AnimatedEntry(
                      delay: 200,
                      shouldAnimate: !_hasAnimated,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            LocalizationService.translate(context, 'my_favorites'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            "${provider.favoritePrices.take(5).length}/5",
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(provider.favoritePrices.take(5).length, (index) {
                      return _AnimatedEntry(
                        delay: 250 + (index * 50),
                        shouldAnimate: !_hasAnimated,
                        child: _buildPriceCard(context, provider.favoritePrices[index]),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                  _AnimatedEntry(
                    delay: 400,
                    shouldAnimate: !_hasAnimated,
                    child: Text(
                      LocalizationService.translate(context, 'market_summary'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _AnimatedEntry(
                    delay: 450,
                    shouldAnimate: !_hasAnimated,
                    child: _buildSummarySection(context, provider),
                  ),
                  const SizedBox(height: 24),
                  _AnimatedEntry(
                    delay: 500,
                    shouldAnimate: !_hasAnimated,
                    child: _buildLastUpdate(context, provider),
                  ),
                ],
              ),
            ),
          ),
          
          // Signup Reminder Bubble
          AnimatedBuilder(
            animation: Listenable.merge([_bubbleOffset, _floatAnimation]),
            builder: (context, child) {
              return Positioned(
                top: _bubbleOffset.value + 16 + _floatAnimation.value,
                left: 16,
                right: 16,
                child: child!,
              );
            },
            child: GestureDetector(
              onTap: () {
                _bubbleController.reverse();
                provider.setSelectedIndex(4); // Switch to Profile tab
              },
              child: Material(
                elevation: 12,
                borderRadius: BorderRadius.circular(20),
                color: Colors.amber,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars_rounded, color: Colors.white, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              LocalizationService.translate(context, 'app_name'),
                              style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              LocalizationService.translate(context, 'signup_reminder'),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => _bubbleController.reverse(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
  );
}

  Widget _buildHeader(BuildContext context, AppProvider provider) {
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
          Text(
            "🟡 ${LocalizationService.translate(context, 'app_name')}",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          Text(
            LocalizationService.translate(context, 'reliable_market'),
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat("d MMMM yyyy", provider.locale.languageCode).format(DateTime.now()),
                style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
              ),
              _buildStatusIndicator(context, provider.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPointsStrip(BuildContext context, UserProfile profile) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars_rounded, color: Colors.amber, size: 20),
          const SizedBox(width: 12),
          Text(
            LocalizationService.translate(context, 'loyalty_points'),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            profile.points.toString(),
            style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.amber, fontSize: 18),
          ),
          const SizedBox(width: 4),
          const Text('pt', style: TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, FetchStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case FetchStatus.live:
        color = Colors.greenAccent;
        text = LocalizationService.translate(context, 'live');
        icon = Icons.circle;
        break;
      case FetchStatus.offline:
        color = Colors.orangeAccent;
        text = LocalizationService.translate(context, 'offline');
        icon = Icons.cloud_off;
        break;
      case FetchStatus.error:
        color = Colors.redAccent;
        text = LocalizationService.translate(context, 'no_connection');
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
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
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
        _buildActionItem(context, provider, LocalizationService.translate(context, 'gold'), FontAwesomeIcons.cubes, Colors.amber, 1),
        _buildActionItem(context, provider, LocalizationService.translate(context, 'currency'), Icons.monetization_on_rounded, Colors.blue, 2),
        _buildActionItem(context, provider, LocalizationService.translate(context, 'calculate'), Icons.calculate_rounded, Colors.green, 3),
        _buildActionItem(context, provider, LocalizationService.translate(context, 'contact'), Icons.contact_support_rounded, Colors.purple, 5),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, AppProvider provider, String title, dynamic icon, Color color, int index) {
    Widget iconWidget;
    if (icon is FaIconData) {
      iconWidget = FaIcon(icon, color: color, size: 20);
    } else if (icon is IconData) {
      iconWidget = Icon(icon, color: color, size: 20);
    } else {
      iconWidget = Icon(Icons.error, color: color, size: 20);
    }

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
            iconWidget,
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, AppProvider provider) {
    final summaryItems = [
      if (provider.goldPrices.isNotEmpty) provider.goldPrices.first,
      if (provider.currencies.isNotEmpty) provider.currencies.first,
    ];

    return Column(
      children: summaryItems.map((price) => _buildPriceCard(context, price)).toList(),
    );
  }

  Widget _buildPriceCard(BuildContext context, GoldPrice price) {
    bool isGold = GoldNames.names.containsKey(price.code);
    return PriceCard(
      gold: price,
      leadingIcon: CategoryIcon(
        category: isGold ? GoldNames.getCategory(price.code) : 'currency',
        emoji: isGold ? Text(GoldNames.getIcon(price.code)) : Text(CurrencyNames.getIcon(price.code)),
      ),
    );
  }

  Widget _buildLastUpdate(BuildContext context, AppProvider provider) {
    return Center(
      child: Column(
        children: [
          Text(
            "${LocalizationService.translate(context, 'last_update')}: ${provider.lastUpdate != null ? DateFormat("HH:mm:ss").format(provider.lastUpdate!) : '-'}",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          if (provider.status == FetchStatus.offline)
            Text(
              "(${LocalizationService.translate(context, 'offline_data')})",
              style: const TextStyle(color: Colors.orange, fontSize: 10),
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
