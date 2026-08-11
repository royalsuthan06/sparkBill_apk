import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/pos_provider.dart';
import 'views/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => POSProvider(),
      child: const SparkBillPOSApp(),
    ),
  );
}

class SparkBillPOSApp extends StatelessWidget {
  const SparkBillPOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arun Crackers POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFB90538), // Rose Crimson Primary
          secondary: Color(0xFF515F74), // Industrial slate secondary
          background: Color(0xFFF7F9FB), // Tonal low surface
          surface: Colors.white,
          error: Color(0xFFEF4444), // Destructive Orange-Red
        ),
        scaffoldBackgroundColor: const Color(0xFFF2F4F6),
        textTheme: GoogleFonts.workSansTextTheme(
          Theme.of(context).textTheme.copyWith(
            bodyLarge: const TextStyle(color: Color(0xFF0F172A)),
            bodyMedium: const TextStyle(color: Color(0xFF0F172A)),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F172A),
          elevation: 0,
          titleTextStyle: GoogleFonts.workSans(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          iconTheme: const IconThemeData(color: Color(0xFFB90538)),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
