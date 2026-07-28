import 'package:flutter/material.dart';
import 'localization_service.dart';

class CurrencyNames {
  static const Map<String, String> names = {
    "USD": "Dolar",
    "EUR": "Euro",
    "AED": "Dirhem",
    "USDT": "Tether (USDT)",
  };

  static const Map<String, String> icons = {
    "USD": "🇺🇸",
    "EUR": "🇪🇺",
    "AED": "🇦🇪",
    "USDT": "₮",
  };

  static String getName(BuildContext context, String code) {
    return LocalizationService.translate(context, 'code_$code');
  }

  static String getIcon(String code) => icons[code] ?? "💵";
}
