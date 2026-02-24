import 'package:flutter/material.dart';

/// Defines coordinates and dimensions for drawing the gallows and the hangmensch.
class GallowsDrawingSpecs {
  static const width = 220.0;
  static const height = 300.0;

  /// Defines stroke widths for the gallows and character components.
  static const gallowsStrokeWidth = 6.0;
  static const ropeStrokeWidth = 2.5;
  static const bodyStrokeWidth = 3.5;

  /// Defines the gallows structure as an asymmetric T-shape.
  ///
  /// The base is a horizontal line at the bottom, centered.
  static const baseStart = Offset(10, 275);
  static const baseEnd = Offset(160, 275);

  /// Vertical pole extending upward from the base.
  static const poleStart = Offset(60, 275);
  static const poleEnd = Offset(60, 35);

  /// Horizontal bar extending from the pole.
  static const barStart = Offset(30, 35);
  static const barEnd = Offset(160, 35);

  /// Rope positioned to hang the figure.
  static const ropeStart = Offset(150, 35);
  static const ropeEnd = Offset(150, 55);

  /// Defines the floating body parts of the hangmensch character.

  /// Represents the head of the character.
  static const headCenter = Offset(150, 85);
  static const headRadius = 18.0;

  /// Represents the left arm, angled down and outward.
  static const leftArmStart = Offset(142, 120);
  static const leftArmEnd = Offset(115, 135);

  /// Represents the right arm, angled down and outward.
  static const rightArmStart = Offset(158, 120);
  static const rightArmEnd = Offset(185, 135);

  /// Represents the left leg, drawn as a straight vertical line.
  static const leftLegStart = Offset(138, 145);
  static const leftLegEnd = Offset(138, 220);

  /// Represents the skirt component for the character.
  static const skirtTopStart = Offset(162, 145);
  static const skirtWidePoint = Offset(185, 200);
  static const skirtHemIn = Offset(155, 200);

  /// Represents the right leg, extending from the inner skirt hem.
  static const rightLegStart = Offset(162, 200);
  static const rightLegEnd = Offset(162, 220);

  /// Defines coordinates for the eyes relative to the head center.
  static const eyeOffset = 7.0;
  static const eyeSize = 5.0;

  /// Defines parameters for the drop animation.
  static const dropDistance = 60.0;
  static const dropDuration = 1200;
}

/// Defines parameters for swing animations.
class SwingParams {
  /// Defines horizontal amplitude for swing effects.
  static const horizontalAmplitude = 8.0;

  /// Defines vertical bobbing movement.
  static const verticalBob = 2.0;
}

/// Defines parameters for the character's drop animation after a game over.
class DropAnimationParams {
  static const dropDistance = 60.0;
  static const fadeDuration = Duration(milliseconds: 1200);
  static const maxHorizontalDrift = 2.5;

  /// Defines staggered delays for each body part in milliseconds.
  static const headDelay = 0;
  static const leftArmDelay = 100;
  static const rightArmDelay = 150;
  static const leftLegDelay = 200;
  static const skirtDelay = 250;
  static const rightLegDelay = 300;
  static const eyesDelay = 0;
}
