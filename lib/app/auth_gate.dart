import 'package:checklist_app/features/auth/presentation/screens/login_screens/loginscreen.dart';
import 'package:checklist_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Logged In
        if (snapshot.hasData) {
          return DashboardScreen();
        }

        // Logged Out
        return const LoginScreen();
      },
    );
  }
}
