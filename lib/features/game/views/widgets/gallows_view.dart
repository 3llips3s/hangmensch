import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/game_state.dart';
import 'gallows_painter.dart';
import 'hangmensch_painter.dart';
import '../../../../core/constants/gallows_specs.dart';
import '../../../../core/providers/sound_controller.dart';

class GallowsView extends ConsumerStatefulWidget {
  final GameState gameState;
  final VoidCallback? onDeathAnimationComplete;

  const GallowsView({
    super.key,
    required this.gameState,
    this.onDeathAnimationComplete,
  });

  @override
  ConsumerState<GallowsView> createState() => _GallowsViewState();
}

class _GallowsViewState extends ConsumerState<GallowsView>
    with TickerProviderStateMixin {
  // Gallows fade-in controllers
  late AnimationController _fadeController;
  late Animation<double> _baseOpacity;
  late Animation<double> _poleOpacity;
  late Animation<double> _barOpacity;
  late Animation<double> _ropeOpacity;

  // Body part appearance controllers (for mistakes)
  int _lastMistakeCount = 0;
  final Map<int, AnimationController> _partControllers = {};
  final Map<int, Animation<double>> _partAnimations = {};

  // Drop animation controllers (for death)
  final Map<int, AnimationController> _dropControllers = {};
  final Map<int, Animation<double>> _dropAnimations = {};
  final Map<int, double> _randomDrifts = {};
  bool _isDropAnimationRunning = false;
  bool _hasTriggeredDeathAnimation = false;

  // Staggered delays for drop animation (in milliseconds)
  static const List<int> _dropDelays = [
    0, // Head (index 0)
    100, // Left arm (index 1)
    150, // Right arm (index 2)
    200, // Left leg (index 3)
    250, // Skirt (index 4)
    300, // Right leg (index 5)
    0, // Eyes (index 6) - same as head
  ];

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _lastMistakeCount = widget.gameState.mistakeCount;

    // Gallows Fade-In Animations
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _baseOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 300 / 1800, curve: Curves.easeIn),
      ),
    );
    _poleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(500 / 1800, 800 / 1800, curve: Curves.easeIn),
      ),
    );
    _barOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(1000 / 1800, 1300 / 1800, curve: Curves.easeIn),
      ),
    );
    _ropeOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(1500 / 1800, 1800 / 1800, curve: Curves.easeIn),
      ),
    );

    // Initial gallows fade-in if in idle state
    if (widget.gameState.status == GameStatus.idle) {
      _fadeController.forward();
    } else {
      _fadeController.value = 1.0;
    }

    // Initialize part controllers for body part appearance
    for (int i = 1; i <= 7; i++) {
      _partControllers[i] = AnimationController(
        vsync: this,
        duration: const Duration(
          milliseconds: 1500,
        ), // Longer, noticeable animation
      );
      _partAnimations[i] = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _partControllers[i]!, curve: Curves.easeInOut),
      );
      if (i <= _lastMistakeCount) {
        _partControllers[i]!.value = 1.0;
      }
    }

    // Initialize drop controllers for death animation
    _initDropControllers();

    // Generate random horizontal drifts for each part
    for (int i = 0; i < 7; i++) {
      _randomDrifts[i] =
          (_random.nextDouble() - 0.5) *
          2 *
          DropAnimationParams.maxHorizontalDrift;
    }
  }

  void _initDropControllers() {
    for (int i = 0; i < 7; i++) {
      _dropControllers[i] = AnimationController(
        vsync: this,
        duration: DropAnimationParams.fadeDuration,
      );
      _dropAnimations[i] = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _dropControllers[i]!, curve: Curves.easeIn),
      );
    }
  }

  void _startDropAnimation() {
    if (_isDropAnimationRunning) return;
    _isDropAnimationRunning = true;

    // PLAY TRAPDOOR SOUND HERE
    // Syncs exactly with the visual start of the drop
    ref.read(soundControllerProvider.notifier).playGameOver();

    // Generate new random drifts for this animation
    for (int i = 0; i < 7; i++) {
      _randomDrifts[i] =
          (_random.nextDouble() - 0.5) *
          2 *
          DropAnimationParams.maxHorizontalDrift;
    }

    // Start each part's drop animation with staggered delays
    for (int i = 0; i < 7; i++) {
      Future.delayed(Duration(milliseconds: _dropDelays[i]), () {
        if (mounted) {
          _dropControllers[i]?.forward();
        }
      });
    }

    // Calculate total animation time and trigger callback when complete
    final totalDuration =
        _dropDelays.reduce(max) +
        DropAnimationParams.fadeDuration.inMilliseconds +
        300; // 300ms pause after animation

    Future.delayed(Duration(milliseconds: totalDuration), () {
      if (mounted && widget.onDeathAnimationComplete != null) {
        widget.onDeathAnimationComplete!();
      }
    });
  }

  void _resetDropAnimation() {
    _isDropAnimationRunning = false;
    _hasTriggeredDeathAnimation = false;
    for (var controller in _dropControllers.values) {
      controller.reset();
    }
  }

  @override
  void didUpdateWidget(covariant GallowsView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.gameState.mistakeCount == 0 && _lastMistakeCount > 0) {
      // Mistake count reset, likely a restart or new game
      for (var controller in _partControllers.values) {
        controller.reset();
      }
      _resetDropAnimation();
      _lastMistakeCount = 0;
    }

    if (widget.gameState.status == GameStatus.idle &&
        oldWidget.gameState.status != GameStatus.idle) {
      _fadeController.reset();
      _fadeController.forward();
      // Reset body parts
      for (var controller in _partControllers.values) {
        controller.reset();
      }
      _resetDropAnimation();
      _lastMistakeCount = 0;
    } else if (widget.gameState.status != GameStatus.idle) {
      _fadeController.value = 1.0;
    }

    if (widget.gameState.mistakeCount > _lastMistakeCount) {
      // Capture values for delayed callback
      final oldCount = _lastMistakeCount;
      final newCount = widget.gameState.mistakeCount;
      _lastMistakeCount = newCount; // Update immediately

      // Delay body part animation by 1.2s to let player see feedback first
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;

        // Play rope/wrong sound exactly when parts start appearing
        ref.read(soundControllerProvider.notifier).playWrong();

        for (int i = oldCount + 1; i <= newCount; i++) {
          _partControllers[i]?.forward();
        }
      });
    }

    // Trigger drop animation on game over
    if (widget.gameState.status == GameStatus.gameOver &&
        !_hasTriggeredDeathAnimation) {
      _hasTriggeredDeathAnimation = true;

      // Sequencing Logic:
      // 1. Mistake 7 happens (in this update or immediately prior).
      // 2. We wait for:
      //    a) The 1200ms delay for the body part animation start (from mistakelogic above)
      //    b) The 1500ms duration of the body part animation (fade in)
      //    c) A small pause (300-500ms) for dramatic effect
      // Total delay = 1200 + 1500 + 300 = 3000ms.

      // If we are just restoring state (not a fresh loss), we might want to skip this,
      // but assuming this is the "kill" moment:

      const int mistakeDelayName = 1200;
      const int animationDuration = 1500;
      const int dramaticPause = 100; // Reduced from 500ms for snappier feel

      final totalSequenceDelay =
          mistakeDelayName + animationDuration + dramaticPause;

      Future.delayed(Duration(milliseconds: totalSequenceDelay), () {
        if (mounted) {
          _startDropAnimation();
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    for (var controller in _partControllers.values) {
      controller.dispose();
    }
    for (var controller in _dropControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  List<double> _getPartOpacities() {
    return List.generate(7, (index) {
      final appearOpacity = _partAnimations[index + 1]?.value ?? 0.0;
      final dropProgress = _dropAnimations[index]?.value ?? 0.0;
      // Fade out during drop: opacity = appearOpacity * (1 - dropProgress)
      return appearOpacity * (1.0 - dropProgress);
    });
  }

  List<Offset> _getPartOffsets() {
    return List.generate(7, (index) {
      final dropProgress = _dropAnimations[index]?.value ?? 0.0;
      final dropDistance = DropAnimationParams.dropDistance * dropProgress;
      final horizontalDrift = (_randomDrifts[index] ?? 0.0) * dropProgress;
      return Offset(horizontalDrift, dropDistance);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _fadeController,
        ..._partControllers.values,
        ..._dropControllers.values,
      ]),
      builder: (context, child) {
        return CustomPaint(
          size: const Size(
            GallowsDrawingSpecs.width,
            GallowsDrawingSpecs.height,
          ),
          painter: GallowsPainter(
            baseOpacity: _baseOpacity.value,
            poleOpacity: _poleOpacity.value,
            barOpacity: _barOpacity.value,
            ropeOpacity: _ropeOpacity.value,
          ),
          foregroundPainter: HangmenschPainter(
            partOpacities: _getPartOpacities(),
            partOffsets: _getPartOffsets(),
          ),
        );
      },
    );
  }
}
