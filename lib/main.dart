import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'services/app_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://ewccxbjyilpwzeyfwhlf.supabase.co',
    publishableKey: 'sb_publishable_13edg66q8DeaYPEmdmKSKQ_R_82hTGF',
  );

  await initializeDateFormatting('tr', null);
  await initializeDateFormatting('en', null);
  await initializeDateFormatting('fa', null);
  
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
          locale: provider.locale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('tr'),
            Locale('en'),
            Locale('fa'),
          ],
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
