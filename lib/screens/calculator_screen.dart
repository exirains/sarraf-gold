import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_provider.dart';
import '../services/localization_service.dart';
import '../models/gold_price.dart';

import '../services/gold_names.dart';
import '../services/currency_names.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _amountController = TextEditingController(text: "1");
  GoldPrice? _selectedAsset;
  bool _isConvertingToTry = true; 

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_calculate);
  }

  void _calculate() {
    setState(() {});
  }

  double _parseInput(String input) {
    if (input.isEmpty) return 0.0;
    String normalized = input.replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final NumberFormat numberFormat = NumberFormat.decimalPattern('tr_TR');

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.translate(context, 'calculate')),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final allAssets = [...provider.goldPrices, ...provider.currencies];
          if (allAssets.isEmpty) {
            return Center(child: Text(LocalizationService.translate(context, 'no_connection')));
          }

          _selectedAsset ??= allAssets.first;

          double amount = _parseInput(_amountController.text);
          double parsedPrice = _selectedAsset!.sellingValue;
          double result = _isConvertingToTry ? amount * parsedPrice : (parsedPrice > 0 ? amount / parsedPrice : 0);

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                LocalizationService.translate(context, 'converter'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                LocalizationService.translate(context, 'converter_subtitle'),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              _buildInputCard(context, allAssets),
              const SizedBox(height: 16),
              Center(
                child: IconButton.filled(
                  onPressed: () => setState(() => _isConvertingToTry = !_isConvertingToTry),
                  icon: const Icon(Icons.swap_vert_rounded, size: 32),
                  style: IconButton.styleFrom(backgroundColor: Colors.amber),
                ),
              ),
              const SizedBox(height: 16),
              _buildResultCard(context, result, allAssets, currencyFormat, numberFormat),
              const SizedBox(height: 40),
              Text(
                LocalizationService.translate(context, 'quick_calcs'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              _buildQuickCalc(context, LocalizationService.translate(context, 'gram_gold_10'), (provider.goldPrices.firstWhere((e) => e.code == "GA", orElse: () => provider.goldPrices.first).sellingValue) * 10, currencyFormat),
              _buildQuickCalc(context, LocalizationService.translate(context, 'dollar_100'), (provider.currencies.firstWhere((e) => e.code == "USD", orElse: () => provider.currencies.first).sellingValue) * 100, currencyFormat),
              _buildQuickCalc(context, LocalizationService.translate(context, 'quarter_gold_5'), (provider.goldPrices.firstWhere((e) => e.code == "C", orElse: () => provider.goldPrices.first).sellingValue) * 5, currencyFormat),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputCard(BuildContext context, List<GoldPrice> allAssets) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isConvertingToTry ? LocalizationService.translate(context, 'amount') : LocalizationService.translate(context, 'try_amount'),
              style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w800),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "0",
                    ),
                  ),
                ),
                if (_isConvertingToTry)
                  _buildAssetSelector(allAssets)
                else
                  const Text("₺ TRY", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.amber)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, double result, List<GoldPrice> allAssets, NumberFormat currencyFormat, NumberFormat numberFormat) {
    return Card(
      elevation: 0,
      color: Colors.amber.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.amber, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isConvertingToTry ? LocalizationService.translate(context, 'estimated_total') : LocalizationService.translate(context, 'purchasable_amount'),
              style: const TextStyle(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.w800),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _isConvertingToTry ? currencyFormat.format(result) : numberFormat.format(result),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                ),
                if (!_isConvertingToTry)
                  _buildAssetSelector(allAssets)
                else
                  const Text("₺ TRY", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.amber)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetSelector(List<GoldPrice> assets) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<GoldPrice>(
          value: _selectedAsset,
          onChanged: (val) => setState(() => _selectedAsset = val),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.amber),
          isDense: true,
          items: assets.map((asset) {
            final isGold = GoldNames.names.containsKey(asset.code);
            final localizedName = isGold 
                ? GoldNames.getName(context, asset.code)
                : CurrencyNames.getName(context, asset.code);
                
            return DropdownMenuItem(
              value: asset,
              child: Text(
                localizedName,
                style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.amber, fontSize: 14),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildQuickCalc(BuildContext context, String label, double value, NumberFormat currencyFormat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(
            currencyFormat.format(value),
            style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.amber),
          ),
        ],
      ),
    );
  }
}
