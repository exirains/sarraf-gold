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
}
