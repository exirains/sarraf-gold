import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_provider.dart';
import '../models/gold_price.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _amountController = TextEditingController(text: "1");
  GoldPrice? _selectedAsset;
  bool _isConvertingToTry = true; 

  // Turkish Locale for Number Formatting: . for thousands, , for decimals
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
  final NumberFormat _numberFormat = NumberFormat.decimalPattern('tr_TR');

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
    // Handle both dot and comma as decimal separator
    String normalized = input.replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hesap Makinesi"),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final allAssets = [...provider.goldPrices, ...provider.currencies];
          if (allAssets.isEmpty) {
            return const Center(child: Text("Fiyatlar yükleniyor..."));
          }

          _selectedAsset ??= allAssets.first;

          double amount = _parseInput(_amountController.text);
          double parsedPrice = _selectedAsset!.sellingValue;
          double result = _isConvertingToTry ? amount * parsedPrice : (parsedPrice > 0 ? amount / parsedPrice : 0);

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                "Dönüştürücü",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Miktarı girin ve varlığı seçin.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              _buildInputCard(allAssets),
              const SizedBox(height: 16),
              Center(
                child: IconButton.filled(
                  onPressed: () => setState(() => _isConvertingToTry = !_isConvertingToTry),
                  icon: const Icon(Icons.swap_vert_rounded, size: 32),
                  style: IconButton.styleFrom(backgroundColor: Colors.amber),
                ),
              ),
              const SizedBox(height: 16),
              _buildResultCard(result, allAssets),
              const SizedBox(height: 40),
              const Text(
                "Hızlı Hesaplamalar",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildQuickCalc("10 Gram Altın", (provider.goldPrices.firstWhere((e) => e.code == "GA", orElse: () => provider.goldPrices.first).sellingValue) * 10),
              _buildQuickCalc("100 Dolar", (provider.currencies.firstWhere((e) => e.code == "USD", orElse: () => provider.currencies.first).sellingValue) * 100),
              _buildQuickCalc("5 Çeyrek Altın", (provider.goldPrices.firstWhere((e) => e.code == "C", orElse: () => provider.goldPrices.first).sellingValue) * 5),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputCard(List<GoldPrice> allAssets) {
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
              _isConvertingToTry ? "Miktar" : "TL Tutarı",
              style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "0",
                    ),
                  ),
                ),
                if (_isConvertingToTry)
                  _buildAssetSelector(allAssets)
                else
                  const Text("₺ TRY", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(double result, List<GoldPrice> allAssets) {
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
              _isConvertingToTry ? "Tahmini Tutar (TL)" : "Alınabilecek Miktar",
              style: const TextStyle(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _isConvertingToTry ? _currencyFormat.format(result) : _numberFormat.format(result),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                if (!_isConvertingToTry)
                  _buildAssetSelector(allAssets)
                else
                  const Text("₺ TRY", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
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
      child: DropdownButton<GoldPrice>(
        value: _selectedAsset,
        onChanged: (val) => setState(() => _selectedAsset = val),
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.amber),
        items: assets.map((asset) {
          return DropdownMenuItem(
            value: asset,
            child: Text(asset.code, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickCalc(String label, double value) {
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            _currencyFormat.format(value),
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
          ),
        ],
      ),
    );
  }
}
