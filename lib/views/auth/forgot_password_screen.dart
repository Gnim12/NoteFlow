import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../core/errors/app_error.dart';
import '../../core/errors/error_presenter.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/login_background.dart';
import '../../widgets/login_card.dart';
import '../../widgets/login_logo.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;

  Future<void> _sendResetEmail() async {
    setState(() {
      _isLoading = true;
    });

    final result = await AuthController.instance.sendPasswordResetEmail(
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
      _emailSent = true;
    });

    ErrorPresenter.showSuccess(context, result.message);
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
                      _emailSent
                          ? 'Un email vous a été envoyé. Suivez le lien qu’il contient pour choisir un nouveau mot de passe.'
                          : 'Saisissez votre adresse email pour recevoir un lien de réinitialisation.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 25),
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Adresse email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email,
                    ),
                    const SizedBox(height: 25),
                    GradientButton(
                      text: _isLoading ? 'Envoi...' : 'Envoyer le lien',
                      icon: Icons.send,
                      onPressed: _isLoading ? null : _sendResetEmail,
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
