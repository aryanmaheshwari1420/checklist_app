import 'package:checklist_app/app/app_routes.dart';
import 'package:checklist_app/features/auth/presentation/providers/auth_controller.dart';
import 'package:checklist_app/features/checklist/domain/enums/checklist_status.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  late final ProviderSubscription<AsyncValue> _authListener;

  @override
  void initState() {
    super.initState();

    _authListener = ref.listenManual(authControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.createChecklist,
              arguments: {"mode": ChecklistMode.create, "showSkip": true},
            );
          }
        },
        error: (error, stackTrace) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        },
      );
    });
  }

  @override
  void dispose() {
    _authListener.close();

    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final loading = authState.isLoading;

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // The AppBar is now styled by the theme, providing a consistent back button and background
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              Text(
                "Sign Up",
                style: textTheme.headlineLarge,
              ),

              const SizedBox(height: 10),

              Text(
                "Create your account to get started",
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),

              const SizedBox(height: 45),

              _buildLabel("First Name"),

              const SizedBox(height: 10),

              _buildTextField(
                controller: firstNameController,
                hint: "Enter your first name",
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "First name is required";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 22),

              _buildLabel("Last Name"),

              const SizedBox(height: 10),

              _buildTextField(
                controller: lastNameController,
                hint: "Enter your last name",
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Last name is required";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 22),

              _buildLabel("Email"),

              const SizedBox(height: 10),

              _buildTextField(
                controller: emailController,
                hint: "Enter your email",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Email is required";
                  }

                  final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');

                  if (!emailRegex.hasMatch(value.trim())) {
                    return "Enter a valid email";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 22),

              _buildLabel("Password"),

              const SizedBox(height: 10),

              _buildTextField(
                controller: passwordController,
                hint: "Enter your password",
                icon: Icons.lock_outline,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Password is required";
                  }

                  if (value.length < 6) {
                    return "Minimum 6 characters";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 22),

              _buildLabel("Confirm Password"),

              const SizedBox(height: 10),

              _buildTextField(
                controller: confirmPasswordController,
                hint: "Confirm password",
                icon: Icons.lock_outline,
                obscureText: true,
                validator: (value) {
                  if (value != passwordController.text) {
                    return "Passwords don't match";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                   onPressed: loading
                      ? null
                      : () async {
                          FocusScope.of(context).unfocus();
                          if (!_formKey.currentState!.validate()) return;

                          await ref
                              .read(authControllerProvider.notifier)
                              .register(
                                firstName: firstNameController.text.trim(),
                                lastName: lastNameController.text.trim(),
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                              );
                        },

                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Create Account",
                          // Text style is handled by elevatedButtonTheme
                        ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Log In"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        // The prefixIcon color and all border/fill styles are now
        // handled by the theme's `inputDecorationTheme`.
        prefixIcon: Icon(icon),
        hintText: hint,
      ),
    );
  }
}
