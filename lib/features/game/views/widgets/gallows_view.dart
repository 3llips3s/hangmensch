import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/game_state.dart';
import 'gallows_painter.dart';
import 'hangmensch_painter.dart';
import '../../../../core/constants/gallows_specs.dart';
import '../../../../core/providers/sound_controller.dart';

/// A complex widget that manages the visual representation of the gallows and the hangmensch.
///
/// Handles multi-stage animations for gallows fading, individual body part appearance,
/// and the final drop animation during a game over.
class GallowsView extends ConsumerStatefulWidget {
  /// The current game state used to drive the visual representation.
  final GameState gameState;

  /// Callback triggered when the death animation (drop) is fully complete.
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
  /// Controller for the initial fade-in animation of the gallows structure.
  late AnimationController _fadeController;
  late Animation<double> _baseOpacity;
  late Animation<double> _poleOpacity;
  late Animation<double> _barOpacity;
  late Animation<double> _ropeOpacity;

  /// Tracks the last mistake count to trigger staggered part animations.
  int _lastMistakeCount = 0;

  /// Map of controllers for each body part's appearance animation.
  final Map<int, AnimationController> _partControllers = {};
  final Map<int, Animation<double>> _partAnimations = {};

  /// Map of controllers for the drop (death) animation of each part.
  final Map<int, AnimationController> _dropControllers = {};
  final Map<int, Animation<double>> _dropAnimations = {};

  /// Stores random horizontal drifts for each part during the drop animation.
  final Map<int, double> _randomDrifts = {};

  /// Flags to track the state of the death animation.
  bool _isDropAnimationRunning = false;
  bool _hasTriggeredDeathAnimation = false;

  /// Defined staggered delays for the drop animation in milliseconds.
  static const List<int> _dropDelays = [0, 100, 150, 200, 250, 300, 0];

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _lastMistakeCount = widget.gameState.mistakeCount;

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

    if (widget.gameState.status == GameStatus.idle) {
      _fadeController.forward();
    } else {
      _fadeController.value = 1.0;
    }

    for (int i = 1; i <= 7; i++) {
      _partControllers[i] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      );
      _partAnimations[i] = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _partControllers[i]!, curve: Curves.easeInOut),
      );
      if (i <= _lastMistakeCount) {
        _partControllers[i]!.value = 1.0;
      }
    }

    _initDropControllers();

    for (int i = 0; i < 7; i++) {
      _randomDrifts[i] =
          (_random.nextDouble() - 0.5) *
          2 *
          DropAnimationParams.maxHorizontalDrift;
    }
  }

  /// Initializes the controllers for the final death animation.
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

  /// Initiates the staggered drop animation and plays the associated sound.
  void _startDropAnimation() {
    if (_isDropAnimationRunning) return;
    _isDropAnimationRunning = true;

    ref.read(soundControllerProvider.notifier).playGameOver();

    for (int i = 0; i < 7; i++) {
      _randomDrifts[i] =
          (_random.nextDouble() - 0.5) *
          2 *
          DropAnimationParams.maxHorizontalDrift;
    }

    for (int i = 0; i < 7; i++) {
      Future.delayed(Duration(milliseconds: _dropDelays[i]), () {
        if (mounted) {
          _dropControllers[i]?.forward();
        }
      });
    }

    final totalDuration =
        _dropDelays.reduce(max) +
        DropAnimationParams.fadeDuration.inMilliseconds +
        300;

    Future.delayed(Duration(milliseconds: totalDuration), () {
      if (mounted && widget.onDeathAnimationComplete != null) {
        widget.onDeathAnimationComplete!();
      }
    });
  }

  /// Resets the death animation state.
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
      for (var controller in _partControllers.values) {
        controller.reset();
      }
      _resetDropAnimation();
      _lastMistakeCount = 0;
    } else if (widget.gameState.status != GameStatus.idle) {
      _fadeController.value = 1.0;
    }

    if (widget.gameState.mistakeCount > _lastMistakeCount) {
      final oldCount = _lastMistakeCount;
      final newCount = widget.gameState.mistakeCount;
      _lastMistakeCount = newCount;

      /// Delays body part animation to allow the player to view feedback first.
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;

        ref.read(soundControllerProvider.notifier).playWrong();

        for (int i = oldCount + 1; i <= newCount; i++) {
          _partControllers[i]?.forward();
        }
      });
    }

    if (widget.gameState.status == GameStatus.gameOver &&
        !_hasTriggeredDeathAnimation) {
      _hasTriggeredDeathAnimation = true;

      if (mounted) {
        _startDropAnimation();
      }
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

  /// Calculates the current opacity for each character part during animations.
  List<double> _getPartOpacities() {
    return List.generate(7, (index) {
      final appearOpacity = _partAnimations[index + 1]?.value ?? 0.0;
      final dropProgress = _dropAnimations[index]?.value ?? 0.0;
      return appearOpacity * (1.0 - dropProgress);
    });
  }

  /// Calculates the current visual offset for each part during the drop animation.
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
