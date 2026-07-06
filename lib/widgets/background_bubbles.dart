import 'package:flutter/material.dart';

class BackgroundBubbles extends StatelessWidget {
  const BackgroundBubbles({super.key});

  Widget bubble({
    required double size,
    required double opacity,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        Positioned(
          top: 120,
          left: 25,
          child: bubble(size: 18, opacity: .50),
        ),

        Positioned(
          top: 160,
          right: 45,
          child: bubble(size: 12, opacity: .40),
        ),

        Positioned(
          top: 250,
          left: 35,
          child: bubble(size: 70, opacity: .12),
        ),

        Positioned(
          top: 90,
          right: 25,
          child: bubble(size: 48, opacity: .18),
        ),

        Positioned(
          bottom: 180,
          right: 45,
          child: bubble(size: 30, opacity: .10),
        ),
      ],
    );
  }
}