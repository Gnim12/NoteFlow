import 'package:flutter/material.dart';

class SplashBackground extends StatelessWidget {
  final Widget child;

  const SplashBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        /// Dégradé principal
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1E3A8A),
                Color(0xFF2563EB),
                Color(0xFF3B82F6),
                Color(0xFF60A5FA),
              ],
            ),
          ),
        ),

        /// Halo principal
        Positioned(
          top: -120,
          left: -120,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(.08),
            ),
          ),
        ),

        /// Halo droit
        Positioned(
          top: 80,
          right: -90,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(.05),
            ),
          ),
        ),

        /// Bulle
        Positioned(
          bottom: 130,
          left: 25,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(.08),
            ),
          ),
        ),

        /// Petite bulle
        Positioned(
          top: 180,
          right: 45,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(.30),
            ),
          ),
        ),

        /// Petite bulle
        Positioned(
          bottom: 220,
          right: 55,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(.20),
            ),
          ),
        ),

        /// Petits points
        Positioned(
          top: 120,
          left: 35,
          child: _DotPattern(),
        ),

        Positioned(
          bottom: 150,
          right: 25,
          child: _DotPattern(),
        ),

        SafeArea(
          child: child,
        ),
      ],
    );
  }
}

class _DotPattern extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(
          16,
          (index) => Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.35),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}