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

  static String getName(String code) => names[code] ?? code;
  static String getIcon(String code) => icons[code] ?? "💵";
}
