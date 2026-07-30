import 'package:flutter/material.dart';

import '../core/errors/app_error.dart';
import '../core/errors/error_presenter.dart';
import '../services/auth_service.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/gradient_button.dart';
import '../widgets/login_background.dart';
import '../widgets/login_card.dart';
import '../widgets/login_logo.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showCodeStep = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _requestCode() async {
    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.instance.requestPasswordReset(
      email: _emailController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (!result.success) {
      ErrorPresenter.showError(context, AppError.validation(result.message));
      return;
    }

    setState(() {
      _showCodeStep = true;
    });

    ErrorPresenter.showSuccess(
      context,
      '${result.message}\nCode : ${result.code}',
    );
  }

  Future<void> _resetPassword() async {
    if (_passwordController.text.length < 6) {
      ErrorPresenter.showError(
        context,
        AppError.validation(
          'Le mot de passe doit contenir au moins 6 caractères.',
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ErrorPresenter.showError(
        context,
        AppError.validation('Les mots de passe ne correspondent pas.'),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.instance.resetPassword(
      email: _emailController.text,
      code: _codeController.text,
      newPassword: _passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (!result.success) {
      ErrorPresenter.showError(context, AppError.validation(result.message));
      return;
    }

    ErrorPresenter.showSuccess(context, result.message);

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
                      'Mot de passe oublié',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _showCodeStep
                          ? 'Entrez le code reçu et choisissez un nouveau mot de passe.'
                          : 'Saisissez votre adresse email pour recevoir un code de réinitialisation.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 25),
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Adresse email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email,
                    ),
                    if (_showCodeStep) ...[
                      const SizedBox(height: 18),
                      CustomTextField(
                        controller: _codeController,
                        hintText: 'Code de vérification',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.lock_clock,
                      ),
                      const SizedBox(height: 18),
                      CustomTextField(
                        controller: _passwordController,
                        hintText: 'Nouveau mot de passe',
                        obscureText: _obscurePassword,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      CustomTextField(
                        controller: _confirmPasswordController,
                        hintText: 'Confirmer le mot de passe',
                        obscureText: _obscureConfirmPassword,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 25),
                    GradientButton(
                      text: _isLoading
                          ? (_showCodeStep ? 'Réinitialisation...' : 'Envoi...')
                          : (_showCodeStep
                                ? 'Réinitialiser'
                                : 'Envoyer le code'),
                      icon: _showCodeStep ? Icons.lock_reset : Icons.send,
                      onPressed: _isLoading
                          ? null
                          : (_showCodeStep ? _resetPassword : _requestCode),
                    ),
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Retour à la connexion'),
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
