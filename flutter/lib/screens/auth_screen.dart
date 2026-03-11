import 'package:flutter/material.dart';

import '../state/shop_state.dart';
import '../widgets/app_background.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.shopState});

  final ShopState shopState;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginIdentity = TextEditingController();
  final _loginPassword = TextEditingController();

  final _regEmail = TextEditingController();
  final _regUsername = TextEditingController();
  final _regFirstName = TextEditingController();
  final _regLastName = TextEditingController();
  final _regPassword = TextEditingController();

  @override
  void dispose() {
    _loginIdentity.dispose();
    _loginPassword.dispose();
    _regEmail.dispose();
    _regUsername.dispose();
    _regFirstName.dispose();
    _regLastName.dispose();
    _regPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.shopState,
      builder: (context, _) {
        final state = widget.shopState;
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AppBackground(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HeaderCard(),
                        const SizedBox(height: 18),
                        DefaultTabController(
                          length: 2,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const TabBar(
                                    labelPadding: EdgeInsets.symmetric(vertical: 10),
                                    tabs: [
                                      Tab(text: 'Connexion'),
                                      Tab(text: 'Inscription'),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 420,
                                    child: TabBarView(
                                      children: [
                                        _buildLoginForm(),
                                        _buildRegisterForm(),
                                      ],
                                    ),
                                  ),
                                  if (state.authError.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      state.authError,
                                      style: const TextStyle(color: Color(0xFFC62828)),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginForm() {
    final state = widget.shopState;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Field(
          controller: _loginIdentity,
          label: 'Email ou nom utilisateur',
          icon: Icons.alternate_email,
        ),
        const SizedBox(height: 12),
        _Field(
          controller: _loginPassword,
          label: 'Mot de passe',
          icon: Icons.lock_outline,
          obscure: true,
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: state.isAuthLoading
              ? null
              : () async {
                  FocusScope.of(context).unfocus();
                  await state.login(
                    identity: _loginIdentity.text.trim(),
                    password: _loginPassword.text,
                  );
                },
          child: state.isAuthLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Se connecter'),
        ),
        const SizedBox(height: 14),
        const Text(
          'Votre session reste active pour une connexion unique sur l appareil.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Color(0xFF65708B)),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    final state = widget.shopState;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Field(
          controller: _regEmail,
          label: 'Email',
          icon: Icons.mail_outline,
        ),
        const SizedBox(height: 12),
        _Field(
          controller: _regUsername,
          label: 'Nom utilisateur',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _Field(
                controller: _regFirstName,
                label: 'Prenom',
                icon: Icons.badge_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Field(
                controller: _regLastName,
                label: 'Nom',
                icon: Icons.badge_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _Field(
          controller: _regPassword,
          label: 'Mot de passe',
          icon: Icons.lock_outline,
          obscure: true,
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: state.isAuthLoading
              ? null
              : () async {
                  FocusScope.of(context).unfocus();
                  await state.register(
                    email: _regEmail.text.trim(),
                    password: _regPassword.text,
                    username: _regUsername.text.trim().toLowerCase(),
                    firstName: _regFirstName.text.trim(),
                    lastName: _regLastName.text.trim(),
                  );
                },
          child: state.isAuthLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Creer mon compte'),
        ),
        const SizedBox(height: 10),
        const Text(
          'Mot de passe minimum 8 caracteres.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Color(0xFF65708B)),
        ),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'FOESA Mobile',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8),
            Text(
              'Connectez-vous une fois pour acceder au catalogue, aux filtres avances et au suivi de vos commandes.',
              style: TextStyle(color: Color(0xFF65708B)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
      ),
    );
  }
}
