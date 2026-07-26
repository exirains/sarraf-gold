import 'dart:convert';
import 'package:http/http.dart' as http;

class MarketApi {
  static const String goldUrl =
      "https://api.genelpara.com/json/?list=altin&sembol=all";

  static const Map<String, String> _headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "application/json",
  };

  static Future<Map<String, dynamic>> fetchGoldPrices() async {
    final response = await http.get(
      Uri.parse(goldUrl),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json["data"];
    } else {
      throw Exception("Altın fiyatları yüklenemedi: ${response.statusCode}");
    }
  }

  static Future<Map<String, dynamic>> fetchCurrencies() async {
    final url = Uri.parse("https://api.genelpara.com/json/?list=doviz&sembol=USD,EUR,AED,USDT");

    final response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData["data"];
    }

    throw Exception("Döviz kurları yüklenemedi: ${response.statusCode}");
  }
}
