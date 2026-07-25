import 'dart:convert';
import 'package:http/http.dart' as http;

class MarketApi {
  static const String goldUrl =
      "https://api.genelpara.com/json/?list=altin&sembol=all";

  static Future<Map<String, dynamic>> fetchGoldPrices() async {
    final response = await http.get(
      Uri.parse(goldUrl),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json["data"];
    } else {
      throw Exception("Altın fiyatları yüklenemedi");
    }
  }

  static Future<Map<String, dynamic>> fetchCurrencies() async {
    final url = Uri.parse("https://api.genelpara.com/json/?list=doviz&sembol=USD,EUR,AED,USDT");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData["data"];
    }

    throw Exception("Döviz kurları yüklenemedi");
  }
}
