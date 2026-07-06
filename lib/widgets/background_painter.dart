import 'package:flutter/material.dart';

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint1 = Paint()
      ..color = Colors.white.withOpacity(.08)
      ..style = PaintingStyle.fill;

    final Paint paint2 = Paint()
      ..color = Colors.white.withOpacity(.14)
      ..style = PaintingStyle.fill;

    final Paint paint3 = Paint()
      ..color = Colors.white.withOpacity(.22)
      ..style = PaintingStyle.fill;

    /// ===========================
    /// Première vague
    /// ===========================

    Path path1 = Path();

    path1.moveTo(0, size.height * .18);

    path1.quadraticBezierTo(
      size.width * .25,
      size.height * .10,
      size.width * .55,
      size.height * .22,
    );

    path1.quadraticBezierTo(
      size.width * .82,
      size.height * .34,
      size.width,
      size.height * .18,
    );

    path1.lineTo(size.width, 0);
    path1.lineTo(0, 0);
    path1.close();

    canvas.drawPath(path1, paint1);

    /// ===========================
    /// Deuxième vague
    /// ===========================

    Path path2 = Path();

    path2.moveTo(0, size.height * .28);

    path2.quadraticBezierTo(
      size.width * .28,
      size.height * .18,
      size.width * .55,
      size.height * .33,
    );

    path2.quadraticBezierTo(
      size.width * .85,
      size.height * .48,
      size.width,
      size.height * .30,
    );

    path2.lineTo(size.width, 0);
    path2.lineTo(0, 0);
    path2.close();

    canvas.drawPath(path2, paint2);

    /// ===========================
    /// Troisième vague
    /// ===========================

    Path path3 = Path();

    path3.moveTo(0, size.height * .38);

    path3.quadraticBezierTo(
      size.width * .35,
      size.height * .28,
      size.width * .60,
      size.height * .43,
    );

    path3.quadraticBezierTo(
      size.width * .90,
      size.height * .58,
      size.width,
      size.height * .40,
    );

    path3.lineTo(size.width, 0);
    path3.lineTo(0, 0);
    path3.close();

    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}