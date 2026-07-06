import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/gradient_button.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/login_background.dart';
import '../widgets/login_logo.dart';
import '../widgets/login_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });

    final error = await AuthService.instance.register(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Compte créé avec succès."),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return LoginBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              const SizedBox(height: 25),

              const LoginLogo(),

              const SizedBox(height: 25),

              LoginCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Créer un compte",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Créez votre compte NoteFlow",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                    ),

                    const SizedBox(height: 25),

                    CustomTextField(
                      controller: _nameController,
                      hintText: "Nom complet",
                      prefixIcon: Icons.person,
                    ),

                    const SizedBox(height: 18),

                    CustomTextField(
                      controller: _emailController,
                      hintText: "Adresse email",
                      keyboardType:
                          TextInputType.emailAddress,
                      prefixIcon: Icons.email,
                    ),

                    const SizedBox(height: 18),

                    CustomTextField(
                      controller: _passwordController,
                      hintText: "Mot de passe",
                      obscureText: _hidePassword,
                      prefixIcon: Icons.lock,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _hidePassword =
                                !_hidePassword;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 18),

                    CustomTextField(
                      controller:
                          _confirmPasswordController,
                      hintText:
                          "Confirmer le mot de passe",
                      obscureText:
                          _hideConfirmPassword,
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _hideConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _hideConfirmPassword =
                                !_hideConfirmPassword;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    GradientButton(
                      text: _isLoading
                          ? "Création..."
                          : "Créer le compte",
                      icon: Icons.person_add,
                      onPressed: _isLoading
                          ? null
                          : () {
                              _register();
                            },
                    ),

                    const SizedBox(height: 18),

                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          "Déjà un compte ? ",
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Se connecter",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}