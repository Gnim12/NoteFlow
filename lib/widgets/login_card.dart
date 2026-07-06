import 'package:flutter/material.dart';

class LoginCard extends StatelessWidget {
  final Widget child;

  const LoginCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bool isDark =
        theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),

      width: double.infinity,

      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 30,
      ),

      decoration: BoxDecoration(
        color: isDark
            ? theme.cardColor
            : Colors.white.withOpacity(.95),

        borderRadius: BorderRadius.circular(30),

        border: Border.all(
          color: isDark
              ? Colors.white12
              : Colors.white.withOpacity(.60),
          width: 1.2,
        ),

        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black45
                : Colors.black.withOpacity(.10),
            blurRadius: 35,
            spreadRadius: 2,
            offset: const Offset(0, 18),
          ),
        ],
      ),

      child: child,
    );
  }
}