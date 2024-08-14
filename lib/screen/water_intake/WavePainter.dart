import 'package:diet_app/common/color_extension.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class WavePainter extends CustomPainter {
  final Animation<double> animation;
  final double waveLength;
  final double waveHeight;

  WavePainter ({
    required this.animation,
    this.waveHeight = 10,
    this.waveLength = 200,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size){
    final Paint paint = Paint()
      ..color = TColor.secondaryColor2
      ..style = PaintingStyle.fill;

    final Path path = Path();

    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++ ){
      final y = size.height - waveHeight * math.sin((x / waveLength + animation.value * 2 * math.pi));
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate){
    return true;
  }
}