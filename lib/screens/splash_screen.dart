import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/update_service.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    UpdateService.initLocalVersion();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    _handleStartup();
  }

  Future<void> _handleStartup() async {
    // Wait for at least the animation duration
    await Future.delayed(const Duration(milliseconds: 2000));

    try {
      final update = await UpdateService.checkUpdate();
      if (update != null && mounted) {
        _showUpdateDialog(update);
      } else {
        _navigateToHome();
      }
    } catch (e) {
      debugPrint("Update check failed: $e");
      _navigateToHome();
    }
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Versiyon: ${update.version}", style: const TextStyle(fontWeight: FontWeight.bold)),
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
              _navigateToHome();
            },
            child: const Text("Daha Sonra"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final url = Uri.parse(update.apkUrl);
                // Directly try to launch. On some devices, canLaunchUrl returns false 
                // even when it can actually launch due to strict OS checks.
                await launchUrl(
                  url, 
                  mode: LaunchMode.externalApplication,
                );
              } catch (e) {
                debugPrint("Could not launch update URL: $e");
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
            ),
            child: const Text("Güncelle"),
          ),
        ],
      ),
    );
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Image.asset('assets/icon.png'),
              ),
              const SizedBox(height: 24),
              const Text(
                "Sarraf Gold",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Canlı Altın ve Döviz",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
