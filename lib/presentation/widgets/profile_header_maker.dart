import 'package:chat_corner/constants/colors.dart';
import 'package:flutter/material.dart';

class ProfileCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint_0 = new Paint()..color = MyColor.violet;

    Path path_0 = Path();
    path_0.moveTo(size.width, size.height * 0.6839024);
    path_0.lineTo(size.width, 0);
    path_0.lineTo(0, 0);
    path_0.lineTo(0, size.height * 0.6824390);
    path_0.quadraticBezierTo(size.width * 0.1415000, size.height * 0.6364683,
        size.width * 0.2500000, size.height * 0.6809756);
    path_0.cubicTo(
        size.width * 0.3120000,
        size.height * 0.6814634,
        size.width * 0.3660000,
        size.height * 0.7312195,
        size.width * 0.4980000,
        size.height * 0.6829268);
    path_0.cubicTo(
        size.width * 0.6405000,
        size.height * 0.6380488,
        size.width * 0.6875000,
        size.height * 0.7004878,
        size.width * 0.7500000,
        size.height * 0.7004878);
    path_0.quadraticBezierTo(size.width * 0.8570000, size.height * 0.7534244,
        size.width, size.height * 0.6839024);
    path_0.close();

    canvas.drawPath(path_0, paint_0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
