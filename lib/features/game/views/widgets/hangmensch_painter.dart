import 'package:flutter/material.dart';
import '../../../../core/constants/gallows_specs.dart';
import '../../../../core/constants/ui_colors.dart';

class HangmenschPainter extends CustomPainter {
  final List<double> partOpacities; // List of opacities for each of the 7 parts
  final List<Offset> partOffsets; // Offset for each part during drop animation

  HangmenschPainter({required this.partOpacities, List<Offset>? partOffsets})
    : partOffsets = partOffsets ?? List.filled(7, Offset.zero),
      assert(partOpacities.length == 7);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = UIColors.red
          ..strokeWidth = GallowsDrawingSpecs.bodyStrokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    // 1. Head
    if (partOpacities[0] > 0) {
      paint.color = UIColors.red.withOpacity(partOpacities[0]);
      canvas.drawCircle(
        GallowsDrawingSpecs.headCenter + partOffsets[0],
        GallowsDrawingSpecs.headRadius,
        paint,
      );
    }

    // 2. Left Arm
    if (partOpacities[1] > 0) {
      paint.color = UIColors.red.withOpacity(partOpacities[1]);
      canvas.drawLine(
        GallowsDrawingSpecs.leftArmStart + partOffsets[1],
        GallowsDrawingSpecs.leftArmEnd + partOffsets[1],
        paint,
      );
    }

    // 3. Right Arm
    if (partOpacities[2] > 0) {
      paint.color = UIColors.red.withOpacity(partOpacities[2]);
      canvas.drawLine(
        GallowsDrawingSpecs.rightArmStart + partOffsets[2],
        GallowsDrawingSpecs.rightArmEnd + partOffsets[2],
        paint,
      );
    }

    // 4. Left Leg
    if (partOpacities[3] > 0) {
      paint.color = UIColors.red.withOpacity(partOpacities[3]);
      canvas.drawLine(
        GallowsDrawingSpecs.leftLegStart + partOffsets[3],
        GallowsDrawingSpecs.leftLegEnd + partOffsets[3],
        paint,
      );
    }

    // 5. Skirt (Triangle with apex pointing down)
    if (partOpacities[4] > 0) {
      paint.color = UIColors.red.withOpacity(partOpacities[4]);
      final offset = partOffsets[4];
      final path =
          Path()
            ..moveTo(
              GallowsDrawingSpecs.skirtTopStart.dx + offset.dx,
              GallowsDrawingSpecs.skirtTopStart.dy + offset.dy,
            )
            ..lineTo(
              GallowsDrawingSpecs.skirtWidePoint.dx + offset.dx,
              GallowsDrawingSpecs.skirtWidePoint.dy + offset.dy,
            )
            ..lineTo(
              GallowsDrawingSpecs.skirtHemIn.dx + offset.dx,
              GallowsDrawingSpecs.skirtHemIn.dy + offset.dy,
            );
      canvas.drawPath(path, paint);
    }

    // 6. Right Leg
    if (partOpacities[5] > 0) {
      paint.color = UIColors.red.withOpacity(partOpacities[5]);
      canvas.drawLine(
        GallowsDrawingSpecs.rightLegStart + partOffsets[5],
        GallowsDrawingSpecs.rightLegEnd + partOffsets[5],
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

      final center = GallowsDrawingSpecs.headCenter + partOffsets[6];
      final eyeOffset = GallowsDrawingSpecs.eyeOffset;
      final eyeSize = GallowsDrawingSpecs.eyeSize;

      // Left Eye X
      final lx = center.dx - eyeOffset;
      final ly = center.dy - 2; // Slightly above center
      canvas.drawLine(
        Offset(lx - eyeSize / 2, ly - eyeSize / 2),
        Offset(lx + eyeSize / 2, ly + eyeSize / 2),
        eyePaint,
      );
      canvas.drawLine(
        Offset(lx + eyeSize / 2, ly - eyeSize / 2),
        Offset(lx - eyeSize / 2, ly + eyeSize / 2),
        eyePaint,
      );

      // Right Eye X
      final rx = center.dx + eyeOffset;
      final ry = center.dy - 2;
      canvas.drawLine(
        Offset(rx - eyeSize / 2, ry - eyeSize / 2),
        Offset(rx + eyeSize / 2, ry + eyeSize / 2),
        eyePaint,
      );
      canvas.drawLine(
        Offset(rx + eyeSize / 2, ry - eyeSize / 2),
        Offset(rx - eyeSize / 2, ry + eyeSize / 2),
        eyePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant HangmenschPainter oldDelegate) {
    return oldDelegate.partOpacities != partOpacities ||
        oldDelegate.partOffsets != partOffsets;
  }
}
