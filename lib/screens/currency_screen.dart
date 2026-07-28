import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../services/currency_names.dart';
import '../services/localization_service.dart';
import '../widgets/price_card.dart';
import '../widgets/loading_view.dart';
import '../widgets/category_icon.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.translate(context, 'currency')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: LocalizationService.translate(context, 'search_currency'),
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
          if (provider.isLoading && provider.currencies.isEmpty) {
            return const LoadingView(emoji: "💵");
          }

          final filteredCurrencies = provider.currencies.where((p) {
            return p.name.toLowerCase().contains(_searchQuery) ||
                p.code.toLowerCase().contains(_searchQuery);
          }).toList();

          return RefreshIndicator(
            onRefresh: provider.refreshAll,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredCurrencies.length,
              itemBuilder: (context, index) {
                final currency = filteredCurrencies[index];
                return PriceCard(
                  gold: currency,
                  leadingIcon: CategoryIcon(
                    category: 'currency',
                    emoji: Text(CurrencyNames.getIcon(currency.code)),
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
