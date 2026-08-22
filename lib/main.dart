import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/pos_provider.dart';
import 'views/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => POSProvider()..initialize(),
      child: const SparkBillPOSApp(),
    ),
  );
}

class SparkBillPOSApp extends StatelessWidget {
  const SparkBillPOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<POSProvider>().isDarkMode;

    return MaterialApp(
      title: 'SparkBill POS',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(),
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.trackpad,
        },
      ),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFF43F5E),
          secondary: Color(0xFF515F74),
          surface: Color(0xFFF7F9FB),
          onSurface: Color(0xFF0F172A),
          error: Color(0xFFEF4444),
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
          iconTheme: const IconThemeData(color: Color(0xFFF43F5E)),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF43F5E),
          secondary: Color(0xFF94A3B8),
          surface: Color(0xFF1E293B),
          onSurface: Color(0xFFF1F5F9),
          error: Color(0xFFEF4444),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: GoogleFonts.workSansTextTheme(
          Theme.of(context).textTheme.copyWith(
            bodyLarge: const TextStyle(color: Color(0xFFF1F5F9)),
            bodyMedium: const TextStyle(color: Color(0xFFF1F5F9)),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1E293B),
          foregroundColor: const Color(0xFFF1F5F9),
          elevation: 0,
          titleTextStyle: GoogleFonts.workSans(
            color: const Color(0xFFF1F5F9),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          iconTheme: const IconThemeData(color: Color(0xFFF43F5E)),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
