import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import 'dashboard_screen.dart';
import 'gold_screen.dart';
import 'currency_screen.dart';
import 'calculator_screen.dart';
import 'contact_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  late AppProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<AppProvider>(context, listen: false);
    _pageController = PageController(initialPage: _provider.selectedIndex);
    _provider.addListener(_onProviderChange);
  }

  void _onProviderChange() {
    if (_pageController.hasClients) {
      final currentPage = _pageController.page?.round();
      if (currentPage != _provider.selectedIndex) {
        _pageController.animateToPage(
          _provider.selectedIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChange);
    _pageController.dispose();
    super.dispose();
  }

  final List<Widget> _screens = const [
    DashboardScreen(),
    GoldScreen(),
    CurrencyScreen(),
    CalculatorScreen(),
    ContactScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          if (_provider.selectedIndex != index) {
            _provider.setSelectedIndex(index);
          }
        },
        physics: const BouncingScrollPhysics(),
        children: _screens.map((screen) => RepaintBoundary(child: screen)).toList(),
      ),
      bottomNavigationBar: Selector<AppProvider, int>(
        selector: (_, provider) => provider.selectedIndex,
        builder: (context, selectedIndex, child) {
          return BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) {
              _provider.setSelectedIndex(index);
            },
            selectedItemColor: Colors.amber[800],
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded),
                label: 'Panel',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Altın',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.attach_money_rounded),
                label: 'Döviz',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calculate_rounded),
                label: 'Hesapla',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.contact_support_rounded),
                label: 'İletişim',
              ),
            ],
          );
        },
      ),
    );
  }
}
