import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Painter extends CustomPainter {
  final List<Offset?> offsets;
  final Color drawColor;

  Painter({required this.offsets, required this.drawColor}) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = drawColor
      ..isAntiAlias = true
      ..strokeWidth = 6.0;

    for (int i = 0; i < offsets.length; i++) {
      if (shouldDrawLine(i)) {
        canvas.drawLine(offsets[i]!, offsets[i + 1]!, paint);
      }
      if (shouldDrawPoint(i)) {
        canvas.drawPoints(PointMode.points, [offsets[i]!], paint);
      }
    }
  }

  bool shouldDrawPoint(int i) {
    if (isLastElement(i)) {
      // es el último elemento?
      return hasPoint(i);
    }
    return hasPoint(i) && !hasPoint(i + 1);
  }

  bool hasPoint(int i) {
    return offsets[i] != null;
  }

  bool isLastElement(int i) {
    return i >= offsets.length - 1;
  }

  bool shouldDrawLine(int i) {
    if (isLastElement(i)) return false;
    return hasPoint(i) && hasPoint(i + 1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
