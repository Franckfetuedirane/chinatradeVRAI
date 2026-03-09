import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A5FD7)),
        scaffoldBackgroundColor: const Color(0xFFF3F7FF),
        cardTheme: const CardThemeData(
          elevation: 5,
          shadowColor: Color(0x1A0B3C80),
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
        ),
      ),
      home: HomeScreen(shopState: _shopState),
    );
  }
}
