class GoldPrice {
  final String code;
  final String name;
  final String buying;
  final String selling;
  final String change;
  final String direction; // 'moneyUp', 'moneyDown', 'moneyNone'
  final String symbol;

  GoldPrice({
    required this.code,
    required this.name,
    required this.buying,
    required this.selling,
    required this.change,
    required this.direction,
    required this.symbol,
  });

  factory GoldPrice.fromJson(String code, String name, Map<String, dynamic> json) {
    return GoldPrice(
      code: code,
      name: name,
      buying: json['alis'] ?? '0.00',
      selling: json['satis'] ?? '0.00',
      change: json['degisim'] ?? '0.00',
      direction: json['yon'] ?? 'moneyNone',
      symbol: json['sembol'] ?? '₺',
    );
  }

  double get buyingValue => _parseValue(buying);
  double get sellingValue => _parseValue(selling);

  static double _parseValue(String valueStr) {
    if (valueStr.isEmpty) return 0.0;
    
    // Remove thousand separators (dots) and replace decimal separator (comma) with a dot
    // But be careful: if the string contains only ONE separator and it's a dot (e.g., 34.50), 
    // it's likely a decimal separator from a standard format, not a thousand separator from Turkish format.
    
    String normalized = valueStr.trim();
    
    // Check if it's Turkish format (has commas)
    if (normalized.contains(',')) {
      normalized = normalized.replaceAll('.', '').replaceAll(',', '.');
    } else {
      // Standard format or just numbers. No action needed if it's "1234.56"
    }
    
    return double.tryParse(normalized) ?? 0.0;
  }
}
