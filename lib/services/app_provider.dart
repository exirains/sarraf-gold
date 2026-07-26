import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gold_price.dart';
import 'market_api.dart';
import 'gold_names.dart';
import 'currency_names.dart';

enum FetchStatus { live, offline, error }

class AppProvider with ChangeNotifier {
  List<GoldPrice> _goldPrices = [];
  List<GoldPrice> _currencies = [];
  Set<String> _favorites = {};
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = false;
  DateTime? _lastUpdate;
  Timer? _refreshTimer;
  int _refreshIntervalMinutes = 0;
  FetchStatus _status = FetchStatus.offline;
  int _selectedIndex = 0;

  List<GoldPrice> get goldPrices => _goldPrices;
  List<GoldPrice> get currencies => _currencies;
  Set<String> get favorites => _favorites;
  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdate => _lastUpdate;
  int get refreshIntervalMinutes => _refreshIntervalMinutes;
  FetchStatus get status => _status;
  int get selectedIndex => _selectedIndex;

  AppProvider() {
    _initialize();
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> _initialize() async {
    await _loadSettings();
    await _loadCache();
    refreshAll();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _favorites = prefs.getStringList('favorites')?.toSet() ?? {};
    final themeStr = prefs.getString('themeMode') ?? 'system';
    _themeMode = ThemeMode.values.firstWhere(
      (e) => e.name == themeStr,
      orElse: () => ThemeMode.system,
    );
    _refreshIntervalMinutes = prefs.getInt('refreshInterval') ?? 0;
    _startTimer();
    notifyListeners();
  }

  Future<void> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final goldCache = prefs.getString('gold_cache');
    final currencyCache = prefs.getString('currency_cache');
    final lastUpdateStr = prefs.getString('last_update');

    if (goldCache != null) {
      final data = jsonDecode(goldCache) as Map<String, dynamic>;
      _goldPrices = data.entries.map((entry) => GoldPrice.fromJson(entry.key, GoldNames.getName(entry.key), entry.value)).toList();
    }
    if (currencyCache != null) {
      final data = jsonDecode(currencyCache) as Map<String, dynamic>;
      _currencies = data.entries.map((entry) => GoldPrice.fromJson(entry.key, CurrencyNames.getName(entry.key), entry.value)).toList();
    }
    if (lastUpdateStr != null) {
      _lastUpdate = DateTime.parse(lastUpdateStr);
    }
    notifyListeners();
  }

  Future<void> _saveCache(Map<String, dynamic> goldData, Map<String, dynamic> currencyData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gold_cache', jsonEncode(goldData));
    await prefs.setString('currency_cache', jsonEncode(currencyData));
    await prefs.setString('last_update', DateTime.now().toIso8601String());
  }

  void _startTimer() {
    _refreshTimer?.cancel();
    if (_refreshIntervalMinutes > 0) {
      _refreshTimer = Timer.periodic(Duration(minutes: _refreshIntervalMinutes), (timer) {
        refreshAll();
      });
    }
  }

  Future<void> setRefreshInterval(int minutes) async {
    _refreshIntervalMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('refreshInterval', minutes);
    _startTimer();
    notifyListeners();
  }

  Future<void> toggleFavorite(String code) async {
    if (_favorites.contains(code)) {
      _favorites.remove(code);
    } else {
      _favorites.add(code);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites.toList());
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
    notifyListeners();
  }

  Future<void> refreshAll() async {
    _isLoading = true;
    notifyListeners();

    try {
      final goldData = await MarketApi.fetchGoldPrices();
      final currencyData = await MarketApi.fetchCurrencies();

      _goldPrices = goldData.entries.map((entry) {
        return GoldPrice.fromJson(
          entry.key,
          GoldNames.getName(entry.key),
          entry.value,
        );
      }).toList();

      _currencies = currencyData.entries.map((entry) {
        return GoldPrice.fromJson(
          entry.key,
          CurrencyNames.getName(entry.key),
          entry.value,
        );
      }).toList();

      _lastUpdate = DateTime.now();
      _status = FetchStatus.live;
      await _saveCache(goldData, currencyData);
    } catch (e) {
      debugPrint("Error refreshing data: $e");
      _status = _lastUpdate != null ? FetchStatus.offline : FetchStatus.error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<GoldPrice> get favoritePrices {
    final all = [..._goldPrices, ..._currencies];
    return all.where((p) => _favorites.contains(p.code)).toList();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
