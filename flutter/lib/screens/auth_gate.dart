import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../screens/auth_screen.dart';
import '../screens/home_screen.dart';
import '../state/shop_state.dart';
import '../widgets/app_background.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.shopState});

  final ShopState shopState;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shopState,
      builder: (context, _) {
        if (!shopState.isInitialized) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: AppBackground(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        AppConfig.logoAsset,
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.storefront, size: 60, color: Color(0xFF0B4EDB)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (!shopState.isAuthenticated) {
          return AuthScreen(shopState: shopState);
        }

        return HomeScreen(shopState: shopState);
      },
    );
  }
}
