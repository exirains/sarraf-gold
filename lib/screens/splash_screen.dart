import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/update_service.dart';
import '../services/app_provider.dart';
import '../services/localization_service.dart';
import 'home_screen.dart';
import 'language_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.8, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _handleStartup();
  }

  Future<void> _handleStartup() async {
    // 1. Ensure local version is loaded into memory
    await UpdateService.initLocalVersion();

    // 2. Wait for at least the animation duration
    await Future.delayed(const Duration(milliseconds: 1500));

    try {
      // 3. Now safely check for updates
      final update = await UpdateService.checkUpdate();
      if (update != null && mounted) {
        _showUpdateDialog(update);
      } else {
        _proceedToNextScreen();
      }
    } catch (e) {
      debugPrint("Update check failed: $e");
      _proceedToNextScreen();
    }
  }

  void _proceedToNextScreen() {
    if (!mounted) return;
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    Widget nextScreen = provider.languageSelected 
        ? const HomeScreen() 
        : const LanguageSelectionScreen();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var curve = Curves.easeInOutQuart;
          var tween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
          
          return FadeTransition(
            opacity: animation.drive(tween),
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.1, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: curve),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  void _showUpdateDialog(UpdateInfo update) {
    // Format the list of notes into a string with bullet points
    final String formattedNotes = update.notes.isEmpty 
        ? "Yeni özellikler ve hata düzeltmeleri." 
        : update.notes.map((note) => "• $note").join("\n");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Yeni Versiyon Mevcut"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Mevcut Versiyon: ${UpdateService.localInfo?.version ?? '...'}", style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            Text("Yeni Versiyon: ${update.version}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.amber)),
            const SizedBox(height: 12),
            const Text("Yenilikler:", style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(formattedNotes, style: const TextStyle(fontSize: 14)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _proceedToNextScreen();
            },
            child: const Text("Daha Sonra"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final url = Uri.parse(update.apkUrl);
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } catch (e) {
                debugPrint("Could not launch update URL: $e");
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Güncelle"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(25),
                  child: Image.asset('assets/icon.png'),
                ),
                const SizedBox(height: 32),
                Text(
                  LocalizationService.translate(context, 'app_name'),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    LocalizationService.translate(context, 'reliable_market').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
