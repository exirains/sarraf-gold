import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  final String category;
  final dynamic code;
  final dynamic emoji;

  const CategoryIcon({
    super.key,
    required this.category,
    this.code,
    this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    Widget? codeWidget = code is String ? Text(code as String) : code as Widget?;
    Widget? emojiWidget = emoji is String ? Text(emoji as String) : emoji as Widget?;

    switch (category) {
      case 'karat':
        return _KaratIcon(karat: codeWidget);
      case 'stack_5':
        return const _StackIcon(multiplier: "5x");
      case 'stack_2_5':
        return const _StackIcon(multiplier: "2.5x");
      case 'silver':
        return const _BarIcon(color: Color(0xFFC0C0C0), label: "Ag");
      case 'ratio':
        return const _RatioIcon();
      case 'coin':
        return const _CoinIcon();
      case 'pure_gold':
        return const _BarIcon(color: Colors.amber, label: "999");
      case 'currency':
        return _EmojiCircle(emoji: emojiWidget ?? const Text("💵", style: TextStyle(fontSize: 20)));
      default:
        return _EmojiCircle(emoji: emojiWidget ?? const Text("🪙", style: TextStyle(fontSize: 20)));
    }
  }
}

class _KaratIcon extends StatelessWidget {
  final Widget? karat;
  const _KaratIcon({required this.karat});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 32,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.amber[700],
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 4,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4),
              ),
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    karat ?? const Text(""),
                    const Text("K"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StackIcon extends StatelessWidget {
  final String multiplier;
  const _StackIcon({required this.multiplier});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 10,
            left: 8,
            child: _MiniCoin(color: Colors.amber[400]!),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: _MiniCoin(color: Colors.amber[600]!),
          ),
          Positioned(
            top: 14,
            left: 16,
            child: _MiniCoin(color: Colors.amber[800]!),
          ),
          Positioned(
            bottom: 4,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                multiplier,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniCoin extends StatelessWidget {
  final Color color;
  const _MiniCoin({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
      ),
    );
  }
}

class _BarIcon extends StatelessWidget {
  final Color color;
  final String label;
  const _BarIcon({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 22,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.8),
            color,
            color.withValues(alpha: 1.2),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _RatioIcon extends StatelessWidget {
  const _RatioIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.amber, Color(0xFFC0C0C0)],
        ),
      ),
      child: const Icon(
        Icons.balance,
        color: Colors.white,
        size: 16,
      ),
    );
  }
}

class _CoinIcon extends StatelessWidget {
  const _CoinIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.amber[600],
        shape: BoxShape.circle,
        border: Border.all(color: Colors.amber[800]!, width: 2),
      ),
      child: Icon(
        Icons.account_balance_outlined,
        color: Colors.amber[900],
        size: 16,
      ),
    );
  }
}

class _EmojiCircle extends StatelessWidget {
  final Widget emoji;
  const _EmojiCircle({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(fontSize: 20),
      child: emoji,
    );
  }
}
