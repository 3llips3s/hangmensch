import 'package:flutter/material.dart';

class GallowsDrawingSpecs {
  static const width = 220.0;
  static const height = 300.0;

  // Stroke widths
  static const gallowsStrokeWidth = 6.0;
  static const ropeStrokeWidth = 2.5;
  static const bodyStrokeWidth = 3.5;

  // === GALLOWS STRUCTURE (Asymmetric T) ===
  // Base (horizontal line at bottom, centered)
  static const baseStart = Offset(10, 275);
  static const baseEnd = Offset(160, 275);

  // Vertical pole (from base upward)
  static const poleStart = Offset(60, 275);
  static const poleEnd = Offset(60, 35);

  // Horizontal bar (asymmetric T: extended right for hanging)
  static const barStart = Offset(30, 35);
  static const barEnd = Offset(160, 35);

  // Rope (positioned for centered figure, further from pole)
  static const ropeStart = Offset(150, 35);
  static const ropeEnd = Offset(150, 55); // Gap before head

  // --- HANGMENSCH BODY PARTS (Floating - gaps between all parts) ---

  // 1. Head (floating with gap from rope)
  static const headCenter = Offset(150, 85);
  static const headRadius = 18.0;

  // 2. Left Arm (diagonal down and outward from head area)
  static const leftArmStart = Offset(
    142,
    120,
  ); // Gap from head bottom (85 + 18 + 5 gap)
  static const leftArmEnd = Offset(115, 135); // Angled down-left

  // 3. Right Arm (diagonal down and outward from head area)
  static const rightArmStart = Offset(158, 120); // Gap from head bottom
  static const rightArmEnd = Offset(185, 135); // Angled down-right

  // 4. Left Leg (straight vertical - the "man" leg)
  static const leftLegStart = Offset(
    138,
    145,
  ); // Gap from arms, same Y as right leg start
  static const leftLegEnd = Offset(138, 220); // Straight down

  // 5. Skirt (right side - the "woman" element)
  // Path: Start (top) -> Widen Out (diagonal) -> Hem Straight Across (horizontal) -> close
  // Starts at same Y as left leg (145), angles out, hems straight back horizontally
  static const skirtTopStart = Offset(
    162,
    145,
  ); // Same Y as left leg start, mirrored distance from center
  static const skirtWidePoint = Offset(
    185,
    200,
  ); // Widens out to the right AND down to hem level
  static const skirtHemIn = Offset(
    155,
    200,
  ); // Straight horizontal hem line back (same Y as widePoint)

  // 6. Right Leg (straight vertical from inner skirt hem)
  static const rightLegStart = Offset(
    162,
    200,
  ); // Gap from hem, starts at inner hem point
  static const rightLegEnd = Offset(162, 220); // Same Y as left leg end

  // Eyes (X X) relative to head center
  static const eyeOffset = 7.0;
  static const eyeSize = 5.0;

  // Drop animation parameters
  static const dropDistance = 60.0;
  static const dropDuration = 1200; // milliseconds
}

class SwingParams {
  // Legacy - kept for reference, but swing animation is being replaced
  static const horizontalAmplitude = 8.0;
  static const verticalBob = 2.0;
}

class DropAnimationParams {
  static const dropDistance = 60.0;
  static const fadeDuration = Duration(milliseconds: 1200);
  static const maxHorizontalDrift = 2.5;

  // Staggered delays for each body part (in milliseconds)
  static const headDelay = 0;
  static const leftArmDelay = 100;
  static const rightArmDelay = 150;
  static const leftLegDelay = 200;
  static const skirtDelay = 250;
  static const rightLegDelay = 300;
  static const eyesDelay = 0; // Same as head
}
