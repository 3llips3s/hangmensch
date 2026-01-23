import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/gallows_specs.dart';
import '../../../../core/constants/ui_colors.dart';

class HangmenschPainter extends CustomPainter {
  final List<double> partOpacities; // List of opacities for each of the 7 parts
  final double swingValue; // -1.0 to 1.0 for pendulum swing

  HangmenschPainter({required this.partOpacities, this.swingValue = 0.0})
    : assert(partOpacities.length == 7);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = UIColors.red
          ..strokeWidth = GallowsDrawingSpecs.bodyStrokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    // Calculate swing offset
    final offsetX = swingValue * SwingParams.horizontalAmplitude;
    final offsetY = sin(swingValue.abs() * pi) * SwingParams.verticalBob;
    final swingOffset = Offset(offsetX, offsetY);

    // 1. Head
    if (partOpacities[0] > 0) {
      paint.color = UIColors.red.withOpacity(partOpacities[0]);
      canvas.drawCircle(
        GallowsDrawingSpecs.headCenter + swingOffset,
        GallowsDrawingSpecs.headRadius,
        paint,
      );
    }

    // 2. Left Arm
    if (partOpacities[1] > 0) {
      paint.color = UIColors.red.withOpacity(partOpacities[1]);
      canvas.drawLine(
        GallowsDrawingSpecs.leftArmStart + swingOffset,
        GallowsDrawingSpecs.leftArmEnd + swingOffset,
        paint,
      );
    }

    // 3. Right Arm
    if (partOpacities[2] > 0) {
      paint.color = UIColors.red.withOpacity(partOpacities[2]);
      canvas.drawLine(
        GallowsDrawingSpecs.rightArmStart + swingOffset,
        GallowsDrawingSpecs.rightArmEnd + swingOffset,
        paint,
      );
    }

    // 4. Left Leg
    if (partOpacities[3] > 0) {
      paint.color = UIColors.red.withOpacity(partOpacities[3]);
      canvas.drawLine(
        GallowsDrawingSpecs.leftLegStart + swingOffset,
        GallowsDrawingSpecs.leftLegEnd + swingOffset,
        paint,
      );
    }

    // 5. Skirt
    if (partOpacities[4] > 0) {
      paint.color = UIColors.red.withOpacity(partOpacities[4]);
      final path =
          Path()
            ..moveTo(
              GallowsDrawingSpecs.skirtHipCenter.dx + swingOffset.dx,
              GallowsDrawingSpecs.skirtHipCenter.dy + swingOffset.dy,
            )
            ..lineTo(
              GallowsDrawingSpecs.skirtOutRight.dx + swingOffset.dx,
              GallowsDrawingSpecs.skirtOutRight.dy + swingOffset.dy,
            )
            ..lineTo(
              GallowsDrawingSpecs.skirtHemRight.dx + swingOffset.dx,
              GallowsDrawingSpecs.skirtHemRight.dy + swingOffset.dy,
            )
            ..lineTo(
              GallowsDrawingSpecs.skirtHemLeft.dx + swingOffset.dx,
              GallowsDrawingSpecs.skirtHemLeft.dy + swingOffset.dy,
            )
            ..lineTo(
              GallowsDrawingSpecs.skirtOutLeft.dx + swingOffset.dx,
              GallowsDrawingSpecs.skirtOutLeft.dy + swingOffset.dy,
            )
            ..close();
      canvas.drawPath(path, paint);
    }

    // 6. Right Leg
    if (partOpacities[5] > 0) {
      paint.color = UIColors.red.withOpacity(partOpacities[5]);
      canvas.drawLine(
        GallowsDrawingSpecs.rightLegStart + swingOffset,
        GallowsDrawingSpecs.rightLegEnd + swingOffset,
        paint,
      );
    }

    // 7. Eyes (X X)
    if (partOpacities[6] > 0) {
      final eyePaint =
          Paint()
            ..color = UIColors.red.withOpacity(partOpacities[6])
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;

      // Left Eye X
      canvas.drawLine(
        GallowsDrawingSpecs.leftEyeX1 + swingOffset,
        GallowsDrawingSpecs.leftEyeX2 + swingOffset,
        eyePaint,
      );
      canvas.drawLine(
        GallowsDrawingSpecs.leftEyeX3 + swingOffset,
        GallowsDrawingSpecs.leftEyeX4 + swingOffset,
        eyePaint,
      );

      // Right Eye X
      canvas.drawLine(
        GallowsDrawingSpecs.rightEyeX1 + swingOffset,
        GallowsDrawingSpecs.rightEyeX2 + swingOffset,
        eyePaint,
      );
      canvas.drawLine(
        GallowsDrawingSpecs.rightEyeX3 + swingOffset,
        GallowsDrawingSpecs.rightEyeX4 + swingOffset,
        eyePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant HangmenschPainter oldDelegate) {
    return oldDelegate.partOpacities != partOpacities ||
        oldDelegate.swingValue != swingValue;
  }
}
