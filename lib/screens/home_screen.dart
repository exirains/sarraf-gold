import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../services/localization_service.dart';
import 'dashboard_screen.dart';
import 'gold_screen.dart';
import 'currency_screen.dart';
import 'calculator_screen.dart';
import 'contact_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  late AppProvider _provider;
  final List<int> _history = [0];

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
        // Update history if it's a new tab
        if (_history.isEmpty || _history.last != _provider.selectedIndex) {
          _history.add(_provider.selectedIndex);
        }
        
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
    ProfileScreen(),
    ContactScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _history.length <= 1,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _history.length > 1) {
          setState(() {
            _history.removeLast();
            _provider.setSelectedIndex(_history.last);
          });
        }
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            if (_provider.selectedIndex != index) {
              _provider.setSelectedIndex(index);
              if (_history.isEmpty || _history.last != index) {
                _history.add(index);
              }
            }
          },
          physics: const BouncingScrollPhysics(),
          children: _screens.map((screen) => RepaintBoundary(child: screen)).toList(),
        ),
        bottomNavigationBar: Selector<AppProvider, int>(
          selector: (_, provider) => provider.selectedIndex,
          builder: (context, selectedIndex, child) {
            // Map selectedIndex to BottomNavigationBar index
            int barIndex;
            if (selectedIndex == 4) {
              barIndex = 0; // Profile highlights Home
            } else if (selectedIndex == 5) {
              barIndex = 4; // Contact
            } else {
              barIndex = selectedIndex;
            }

            return BottomNavigationBar(
              currentIndex: barIndex,
              onTap: (index) {
                int targetIndex = index;
                if (index == 4) targetIndex = 5; // Contact
                _provider.setSelectedIndex(targetIndex);
              },
              selectedItemColor: Colors.amber[800],
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.dashboard_rounded),
                  label: LocalizationService.translate(context, 'home'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_rounded),
                  label: LocalizationService.translate(context, 'gold'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.attach_money_rounded),
                  label: LocalizationService.translate(context, 'currency'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.calculate_rounded),
                  label: LocalizationService.translate(context, 'calculate'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.contact_support_rounded),
                  label: LocalizationService.translate(context, 'contact'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
