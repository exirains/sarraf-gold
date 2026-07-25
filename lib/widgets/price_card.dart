import 'package:flutter/material.dart';
import '../models/gold_price.dart';

class PriceCard extends StatelessWidget {
  final GoldPrice gold;
  final Widget leadingIcon;

  const PriceCard({
    super.key,
    required this.gold,
    required this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    Color trendColor = Colors.grey;
    IconData trendIcon = Icons.remove;

    if (gold.direction == 'moneyUp') {
      trendColor = Colors.green;
      trendIcon = Icons.arrow_upward;
    } else if (gold.direction == 'moneyDown') {
      trendColor = Colors.red;
      trendIcon = Icons.arrow_downward;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Center(child: leadingIcon),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gold.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(trendIcon, color: trendColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "%${gold.change}",
                        style: TextStyle(
                          color: trendColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _PriceRow(label: "Alış", value: gold.buying, symbol: gold.symbol),
                const SizedBox(height: 4),
                _PriceRow(label: "Satış", value: gold.selling, symbol: gold.symbol),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final String symbol;

  const _PriceRow({
    required this.label,
    required this.value,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          "$value $symbol",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
