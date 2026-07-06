import 'package:flutter/material.dart';

class BackgroundGradient extends StatelessWidget {
  const BackgroundGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF2563EB),
            Color(0xFF60A5FA),
            Color(0xFFBFDBFE),
            Color(0xFFFFFFFF),
          ],
          stops: [
            0.0,
            0.25,
            0.55,
            0.82,
            1.0,
          ],
        ),
      ),
    );
  }
}