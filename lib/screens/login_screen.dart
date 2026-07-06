import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/gradient_button.dart';
import '../widgets/login_background.dart';
import '../widgets/login_card.dart';
import '../widgets/login_logo.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_controller);

    _slide = Tween<Offset>(
      begin: const Offset(0, .10),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez remplir tous les champs.",
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final User? user = await AuthService.instance.login(
      email: emailController.text,
      password: passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Email ou mot de passe incorrect.",
          ),
        ),
      );
      return;
    }

    // ===========================
    // Sauvegarder la session
    // ===========================
    await SessionService.instance.saveUserId(
      user.id!,
    );

    // ===========================
    // Aller à l'accueil
    // ===========================
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          user: user,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoginBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 10,
          ),
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Column(
                children: [
                  const LoginLogo(),

                  const SizedBox(height: 45),

                  LoginCard(
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: emailController,
                          hintText: "Adresse email",
                          keyboardType:
                              TextInputType.emailAddress,
                          prefixIcon:
                              Icons.email_outlined,
                        ),

                        const SizedBox(height: 20),

                        CustomTextField(
                          controller: passwordController,
                          hintText: "Mot de passe",
                          prefixIcon:
                              Icons.lock_outline,
                          obscureText:
                              obscurePassword,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword =
                                    !obscurePassword;
                              });
                            },
                            icon: Icon(
                              obscurePassword
                                  ? Icons
                                      .visibility_off_rounded
                                  : Icons
                                      .visibility_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        GradientButton(
                          text: isLoading
                              ? "Connexion..."
                              : "Se connecter",
                          icon: Icons.login_rounded,
                          onPressed: isLoading
                              ? null
                              : login,
                        ),

                        const SizedBox(height: 20),

                        Wrap(
                          alignment:
                              WrapAlignment.center,
                          crossAxisAlignment:
                              WrapCrossAlignment
                                  .center,
                          children: [
                            Text(
                              "Pas encore de compte ?",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium,
                            ),

                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Créer un compte",
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
        ),
      ),
    );
  }
}