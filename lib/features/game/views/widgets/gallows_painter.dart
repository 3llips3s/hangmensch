import 'package:flutter/material.dart';
import '../../../../core/constants/gallows_specs.dart';
import '../../../../core/constants/ui_colors.dart';

/// Paints the gallows structure with adjustable opacities for different components.
class GallowsPainter extends CustomPainter {
  /// The opacity of the gallows base.
  final double baseOpacity;

  /// The opacity of the vertical pole.
  final double poleOpacity;

  /// The opacity of the horizontal bar.
  final double barOpacity;

  /// The opacity of the rope.
  final double ropeOpacity;

  GallowsPainter({
    this.baseOpacity = 1.0,
    this.poleOpacity = 1.0,
    this.barOpacity = 1.0,
    this.ropeOpacity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = UIColors.gold
          ..strokeWidth = GallowsDrawingSpecs.gallowsStrokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    if (baseOpacity > 0) {
      paint.color = UIColors.gold.withOpacity(baseOpacity);
      canvas.drawLine(
        GallowsDrawingSpecs.baseStart,
        GallowsDrawingSpecs.baseEnd,
        paint,
      );
    }

    if (poleOpacity > 0) {
      paint.color = UIColors.gold.withOpacity(poleOpacity);
      canvas.drawLine(
        GallowsDrawingSpecs.poleStart,
        GallowsDrawingSpecs.poleEnd,
        paint,
      );
    }

    if (barOpacity > 0) {
      paint.color = UIColors.gold.withOpacity(barOpacity);
      canvas.drawLine(
        GallowsDrawingSpecs.barStart,
        GallowsDrawingSpecs.barEnd,
        paint,
      );
    }

    if (ropeOpacity > 0) {
      final ropePaint =
          Paint()
            ..color = UIColors.gold.withOpacity(ropeOpacity)
            ..strokeWidth = GallowsDrawingSpecs.ropeStrokeWidth
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        GallowsDrawingSpecs.ropeStart,
        GallowsDrawingSpecs.ropeEnd,
        ropePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GallowsPainter oldDelegate) {
    return oldDelegate.baseOpacity != baseOpacity ||
        oldDelegate.poleOpacity != poleOpacity ||
        oldDelegate.barOpacity != barOpacity ||
        oldDelegate.ropeOpacity != ropeOpacity;
  }
}
