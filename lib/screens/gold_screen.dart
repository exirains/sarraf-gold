import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../services/gold_names.dart';
import '../services/localization_service.dart';
import '../widgets/price_card.dart';
import '../widgets/loading_view.dart';
import '../widgets/category_icon.dart';

class GoldScreen extends StatefulWidget {
  const GoldScreen({super.key});

  @override
  State<GoldScreen> createState() => _GoldScreenState();
}

class _GoldScreenState extends State<GoldScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.translate(context, 'gold')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: LocalizationService.translate(context, 'search_gold'),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.goldPrices.isEmpty) {
            return const LoadingView(emoji: "🪙");
          }

          final filteredPrices = provider.goldPrices.where((p) {
            return p.name.toLowerCase().contains(_searchQuery) ||
                p.code.toLowerCase().contains(_searchQuery);
          }).toList();

          return RefreshIndicator(
            onRefresh: provider.refreshAll,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredPrices.length,
              itemBuilder: (context, index) {
                final gold = filteredPrices[index];
                return PriceCard(
                  gold: gold,
                  leadingIcon: CategoryIcon(
                    category: GoldNames.getCategory(gold.code),
                    code: Text(gold.code),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
