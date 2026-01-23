import 'package:flutter/material.dart';

class GallowsDrawingSpecs {
  static const width = 200.0;
  static const height = 280.0;

  // Stroke widths
  static const gallowsStrokeWidth = 4.0;
  static const ropeStrokeWidth = 3.0;
  static const bodyStrokeWidth = 3.0;

  // === GALLOWS STRUCTURE (Asymmetric T) ===

  // Base (horizontal line at bottom, centered)
  static const baseStart = Offset(50, 260);
  static const baseEnd = Offset(150, 260);

  // Vertical pole (from base upward)
  static const poleStart = Offset(100, 260);
  static const poleEnd = Offset(100, 40);

  // Horizontal bar (asymmetric T: small left, long right)
  static const barStart = Offset(85, 40); // 15px left of pole
  static const barEnd = Offset(170, 40); // 70px right of pole

  // Rope (near right end, NOT flush - 10px before end)
  static const ropeStart = Offset(160, 40);
  static const ropeEnd = Offset(160, 75);

  // === HANGMENSCH BODY PARTS (Floating limbs, no torso) ===

  // Head (circle at rope end)
  static const headCenter = Offset(160, 95);
  static const headRadius = 18.0;

  // Left arm (from head area, angled down-left, floating)
  static const leftArmStart = Offset(160, 100);
  static const leftArmEnd = Offset(145, 120);

  // Right arm (from head area, angled down-right, floating)
  static const rightArmStart = Offset(160, 100);
  static const rightArmEnd = Offset(175, 120);

  // Left leg (straight down from head area, floating)
  static const leftLegStart = Offset(155, 130);
  static const leftLegEnd = Offset(150, 170);

  // Skirt (triangle: hip out, then back in - female representation)
  static const skirtHipCenter = Offset(165, 130);
  static const skirtOutRight = Offset(180, 150); // OUT to right
  static const skirtHemRight = Offset(172, 165); // BACK IN (hem right)
  static const skirtHemLeft = Offset(158, 165); // Hem left side
  static const skirtOutLeft = Offset(150, 150); // Back to left hip

  // Right leg (drops from skirt hem)
  static const rightLegStart = Offset(165, 165);
  static const rightLegEnd = Offset(165, 205);

  // X X Eyes (final stage - dead)
  static const leftEyeX1 = Offset(153, 92);
  static const leftEyeX2 = Offset(159, 98);
  static const leftEyeX3 = Offset(159, 92);
  static const leftEyeX4 = Offset(153, 98);

  static const rightEyeX1 = Offset(161, 92);
  static const rightEyeX2 = Offset(167, 98);
  static const rightEyeX3 = Offset(167, 92);
  static const rightEyeX4 = Offset(161, 98);
}

class SwingParams {
  static const horizontalAmplitude = 8.0;
  static const verticalBob = 2.0;
}
