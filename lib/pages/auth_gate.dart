import 'package:flutter/material.dart';

import '../data/auth_repository.dart';
import 'home_page.dart';
import 'login_page.dart';

/// The single choke point that makes the login gate real: this is the only
/// route into [HomePage]. Boxes are already open by the time this widget
/// builds (main() awaits Hive init before runApp), so it stays synchronous
/// — no loading spinner, no FutureBuilder.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthRepository.instance.currentUser != null;
    return isLoggedIn ? const HomePage() : const LoginPage();
  }
}
