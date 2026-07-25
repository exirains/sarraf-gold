import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/market_api.dart';
import '../services/gold_names.dart';
import '../models/gold_price.dart';
import '../widgets/header_card.dart';
import '../widgets/price_card.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';

class GoldScreen extends StatefulWidget {
  const GoldScreen({super.key});

  @override
  State<GoldScreen> createState() => _GoldScreenState();
}

class _GoldScreenState extends State<GoldScreen> {
  late Future<List<GoldPrice>> goldPrices;
  DateTime lastUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  void _loadPrices() {
    setState(() {
      goldPrices = MarketApi.fetchGoldPrices().then((data) {
        lastUpdate = DateTime.now();
        return data.entries.map((entry) {
          return GoldPrice.fromJson(
            entry.key,
            GoldNames.getName(entry.key),
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
        title: const Text("Altın Piyasası"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPrices,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadPrices();
          await goldPrices;
        },
        child: FutureBuilder<List<GoldPrice>>(
          future: goldPrices,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingView();
            }

            if (snapshot.hasError) {
              return ErrorView(
                error: snapshot.error.toString(),
                onRetry: _loadPrices,
              );
            }

            final prices = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: prices.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: HeaderCard(),
                  );
                }

                if (index == prices.length + 1) {
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

                return PriceCard(gold: prices[index - 1]);
              },
            );
          },
        ),
      ),
    );
  }
}
