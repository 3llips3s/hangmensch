import 'package:flutter/material.dart';
import '../../../../core/constants/gallows_specs.dart';
import '../../../../core/constants/ui_colors.dart';

/// Paints the hangmensch character with staggered opacities and offsets for animations.
class HangmenschPainter extends CustomPainter {
  /// The collection of opacities for each of the 7 character parts.
  final List<double> partOpacities;

  /// The collection of offsets for each part during the drop animation.
  final List<Offset> partOffsets;

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

    if (partOpacities[0] > 0) {
      paint.color = UIColors.red.withOpacity(partOpacities[0]);
      canvas.drawCircle(
        GallowsDrawingSpecs.headCenter + partOffsets[0],
        GallowsDrawingSpecs.headRadius,
        paint,
      );
    }

    if (partOpacities[1] > 0) {
      paint.color = UIColors.red.withOpacity(partOpacities[1]);
      canvas.drawLine(
        GallowsDrawingSpecs.leftArmStart + partOffsets[1],
        GallowsDrawingSpecs.leftArmEnd + partOffsets[1],
        paint,
      );
    }

    if (partOpacities[2] > 0) {
      paint.color = UIColors.red.withOpacity(partOpacities[2]);
      canvas.drawLine(
        GallowsDrawingSpecs.rightArmStart + partOffsets[2],
        GallowsDrawingSpecs.rightArmEnd + partOffsets[2],
        paint,
      );
    }

    if (partOpacities[3] > 0) {
      paint.color = UIColors.red.withOpacity(partOpacities[3]);
      canvas.drawLine(
        GallowsDrawingSpecs.leftLegStart + partOffsets[3],
        GallowsDrawingSpecs.leftLegEnd + partOffsets[3],
        paint,
      );
    }

    /// Renders the skirt component as a triangular path.
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

    if (partOpacities[5] > 0) {
      paint.color = UIColors.red.withOpacity(partOpacities[5]);
      canvas.drawLine(
        GallowsDrawingSpecs.rightLegStart + partOffsets[5],
        GallowsDrawingSpecs.rightLegEnd + partOffsets[5],
        paint,
      );
    }

    /// Renders cross-shaped eyes to indicate a lost state.
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

      final lx = center.dx - eyeOffset;
      final ly = center.dy - 2;
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
