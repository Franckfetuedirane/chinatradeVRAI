import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/auth_gate.dart';
import 'state/shop_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FoesaApp());
}

class FoesaApp extends StatefulWidget {
  const FoesaApp({super.key});

  @override
  State<FoesaApp> createState() => _FoesaAppState();
}

class _FoesaAppState extends State<FoesaApp> {
  final ShopState _shopState = ShopState();

  @override
  void initState() {
    super.initState();
    _shopState.initialize();
  }

  @override
  void dispose() {
    _shopState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FOESA Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B4EDB),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F4EF),
        textTheme: GoogleFonts.manropeTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0B1324),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF0B1324)),
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          shadowColor: Color(0x140B1324),
          surfaceTintColor: Colors.white,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF4F6FB),
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(color: Color(0xFF0B4EDB), width: 1.4),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          indicatorColor: Color(0xFFDEE7FF),
          backgroundColor: Colors.white,
          height: 74,
        ),
      ),
      home: AuthGate(shopState: _shopState),
    );
  }
}
