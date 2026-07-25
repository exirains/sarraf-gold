import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/gold_price.dart';
import '../services/app_provider.dart';

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
    final NumberFormat format = NumberFormat.decimalPattern('tr_TR');
    
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
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: trendColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
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
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _buildChangeBadge(trendColor, trendIcon),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${format.format(gold.sellingValue)} ${gold.symbol}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  "Satış Fiyatı",
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Consumer<AppProvider>(
              builder: (context, provider, child) {
                final isFav = provider.favorites.contains(gold.code);
                return IconButton(
                  icon: Icon(
                    isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isFav ? Colors.amber : Colors.grey.withValues(alpha: 0.4),
                    size: 22,
                  ),
                  onPressed: () => provider.toggleFavorite(gold.code),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeBadge(Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 2),
          Text(
            "${gold.direction == 'moneyUp' ? '+' : ''}${gold.change}%",
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
