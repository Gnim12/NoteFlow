import 'package:flutter/material.dart';

import 'background_painter.dart';

class LoginBackground extends StatelessWidget {
  final Widget child;

  const LoginBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          /// Dégradé adaptatif
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? const [
                        Color(0xFF050816),
                        Color(0xFF0F172A),
                        Color(0xFF1E3A8A),
                        Color(0xFF1E293B),
                        Color(0xFF121212),
                      ]
                    : const [
                        Color(0xFF1E3A8A),
                        Color(0xFF2563EB),
                        Color(0xFF3B82F6),
                        Color(0xFF93C5FD),
                        Color(0xFFFFFFFF),
                      ],
              ),
            ),
          ),

          CustomPaint(
            size: Size.infinite,
            painter: BackgroundPainter(),
          ),

          _buildCircle(
            top: -120,
            left: -120,
            size: 260,
            opacity: isDark ? .05 : .10,
          ),

          _buildCircle(
            top: 40,
            right: -80,
            size: 180,
            opacity: isDark ? .04 : .08,
          ),

          _buildCircle(
            top: 180,
            left: 25,
            size: 70,
            opacity: isDark ? .06 : .12,
          ),

          _buildCircle(
            top: 120,
            right: 45,
            size: 24,
            opacity: isDark ? .15 : .35,
          ),

          _buildCircle(
            bottom: 220,
            right: 30,
            size: 40,
            opacity: isDark ? .08 : .15,
          ),

          Positioned(
            top: 110,
            left: 25,
            child: DotPattern(isDark: isDark),
          ),

          Positioned(
            top: 330,
            right: 25,
            child: DotPattern(isDark: isDark),
          ),

          SafeArea(
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildCircle({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double size,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      ),
    );
  }
}

class DotPattern extends StatelessWidget {
  final bool isDark;

  const DotPattern({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(
          16,
          (index) => Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(
                isDark ? .18 : .45,
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}