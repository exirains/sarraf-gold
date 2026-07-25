import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/market_api.dart';
import '../services/currency_names.dart';
import '../models/gold_price.dart';
import '../widgets/header_card.dart';
import '../widgets/price_card.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';
import '../widgets/category_icon.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  late Future<List<GoldPrice>> currencies;
  DateTime lastUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  void _loadCurrencies() {
    setState(() {
      currencies = MarketApi.fetchCurrencies().then((data) {
        lastUpdate = DateTime.now();
        return data.entries.map((entry) {
          return GoldPrice.fromJson(
            entry.key,
            CurrencyNames.getName(entry.key),
            entry.value,
          );
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Döviz Kurları"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCurrencies,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadCurrencies();
          await currencies;
        },
        child: FutureBuilder<List<GoldPrice>>(
          future: currencies,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingView(
                message: "Kurlar güncelleniyor...",
                emoji: "💵",
              );
            }

            if (snapshot.hasError) {
              return ErrorView(
                error: snapshot.error.toString(),
                onRetry: _loadCurrencies,
              );
            }

            final data = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: HeaderCard(emoji: "💵"),
                  );
                }

                if (index == data.length + 1) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        "Son güncelleme: ${DateFormat("HH:mm:ss").format(lastUpdate)}",
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  );
                }

                final currency = data[index - 1];
                return PriceCard(
                  gold: currency,
                  leadingIcon: CategoryIcon(
                    category: 'currency',
                    emoji: Text(CurrencyNames.getIcon(currency.code)),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
