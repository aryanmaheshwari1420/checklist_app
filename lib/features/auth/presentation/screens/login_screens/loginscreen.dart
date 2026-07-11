import 'package:checklist_app/app/app_routes.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // The background color is now handled by the theme's `scaffoldBackgroundColor`
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          // Using a Card which will be styled by the theme's `cardTheme`
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

                  Text(
                    "Welcome Back",
                    style: textTheme.headlineMedium,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Let's get things organised",
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),

                  const SizedBox(height: 35),

                  Expanded(
                    child: Image.asset(
                      "assets/images/welcome.png",
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    // This button is now styled by the theme's `elevatedButtonTheme`
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white,
                        child: Text(
                          // Using theme colors for the icon background and text
                          "G",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      label: const Text(
                        "Continue with Google",
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    // This button is now styled by the theme's `outlinedButtonTheme`
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.email_outlined),
                      label: const Text(
                        "Continue with Email",
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      // This button is now styled by the theme's `textButtonTheme`
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.signup);
                        },
                        child: const Text(
                          "Sign Up",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}