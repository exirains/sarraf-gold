import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/gold_price.dart';
import '../models/user_profile.dart';
import 'market_api.dart';
import 'supabase_service.dart';

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
  Locale _locale = const Locale('tr');
  bool _languageSelected = false;
  bool _hasShownReminder = false;

  // Supabase Auth & Profile
  User? _user;
  UserProfile? _profile;

  List<GoldPrice> get goldPrices => _goldPrices;
  List<GoldPrice> get currencies => _currencies;
  Set<String> get favorites => _favorites;
  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdate => _lastUpdate;
  int get refreshIntervalMinutes => _refreshIntervalMinutes;
  FetchStatus get status => _status;
  int get selectedIndex => _selectedIndex;
  Locale get locale => _locale;
  bool get languageSelected => _languageSelected;
  bool get hasShownReminder => _hasShownReminder;

  User? get user => _user;
  UserProfile? get profile => _profile;
  bool get isAuthenticated => _user != null;

  AppProvider() {
    _initialize();
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    SupabaseService.authStateChanges.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      _user = session?.user;

      if (event == AuthChangeEvent.signedIn && _user != null) {
        _fetchUserProfile();
      } else if (event == AuthChangeEvent.signedOut) {
        _profile = null;
        _selectedIndex = 0;
      }
      notifyListeners();
    });
  }

  Future<void> refreshProfile() async {
    if (_user != null) {
      // Small delay to ensure DB record is ready after signup
      await Future.delayed(const Duration(milliseconds: 500));
      _profile = await SupabaseService.getProfile(_user!.id);
      
      // Retry if still null (useful for slow connections/DB replication)
      if (_profile == null) {
        await Future.delayed(const Duration(seconds: 1));
        _profile = await SupabaseService.getProfile(_user!.id);
      }
      notifyListeners();
    }
  }

  Future<void> _fetchUserProfile() async {
    await refreshProfile();
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void markReminderAsShown() {
    _hasShownReminder = true;
    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    _locale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
    notifyListeners();
  }

  Future<void> completeLanguageSelection() async {
    _languageSelected = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('languageSelected', true);
    notifyListeners();
  }

  Future<void> _initialize() async {
    await _loadSettings();
    await _loadCache();
    
    // Check for existing session on startup
    _user = SupabaseService.currentUser;
    if (_user != null) {
      await _fetchUserProfile();
    }
    
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
    
    final langCode = prefs.getString('languageCode') ?? 'tr';
    _locale = Locale(langCode);
    _languageSelected = prefs.getBool('languageSelected') ?? false;

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
      _goldPrices = data.entries.map((entry) => GoldPrice.fromJson(entry.key, entry.key, entry.value)).toList();
    }
    if (currencyCache != null) {
      final data = jsonDecode(currencyCache) as Map<String, dynamic>;
      _currencies = data.entries.map((entry) => GoldPrice.fromJson(entry.key, entry.key, entry.value)).toList();
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
          entry.key,
          entry.value,
        );
      }).toList();

      _currencies = currencyData.entries.map((entry) {
        return GoldPrice.fromJson(
          entry.key,
          entry.key,
          entry.value,
        );
      }).toList();

      _lastUpdate = DateTime.now();
      _status = FetchStatus.live;
      await _saveCache(goldData, currencyData);
      
      // Also refresh profile if logged in to update points
      if (_user != null) {
        await _fetchUserProfile();
      }
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
