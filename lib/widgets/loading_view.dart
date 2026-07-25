import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final String message;
  final String emoji;

  const LoadingView({
    super.key,
    this.message = "Fiyatlar güncelleniyor...",
    this.emoji = "🪙",
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
          const SizedBox(height: 8),
          Text(message),
        ],
      ),
    );
  }
}
