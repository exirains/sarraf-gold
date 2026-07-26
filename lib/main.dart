import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'services/app_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr', null);
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const GoldApp(),
    ),
  );
}

class GoldApp extends StatelessWidget {
  const GoldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Sarraf Gold",
          themeMode: provider.themeMode,
          theme: ThemeData(
            colorSchemeSeed: Colors.amber,
            useMaterial3: true,
            brightness: Brightness.light,
            textTheme: GoogleFonts.quicksandTextTheme(ThemeData.light().textTheme),
            fontFamily: GoogleFonts.quicksand().fontFamily,
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.amber,
            useMaterial3: true,
            brightness: Brightness.dark,
            textTheme: GoogleFonts.quicksandTextTheme(ThemeData.dark().textTheme),
            fontFamily: GoogleFonts.quicksand().fontFamily,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
