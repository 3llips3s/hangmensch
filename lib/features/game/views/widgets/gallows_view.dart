import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import 'gallows_painter.dart';
import 'hangmensch_painter.dart';
import '../../../../core/constants/gallows_specs.dart';

class GallowsView extends StatefulWidget {
  final GameState gameState;

  const GallowsView({super.key, required this.gameState});

  @override
  State<GallowsView> createState() => _GallowsViewState();
}

class _GallowsViewState extends State<GallowsView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _baseOpacity;
  late Animation<double> _poleOpacity;
  late Animation<double> _barOpacity;
  late Animation<double> _ropeOpacity;

  late AnimationController _swingController;
  late Animation<double> _swingAnimation;

  int _lastMistakeCount = 0;
  final Map<int, AnimationController> _partControllers = {};
  final Map<int, Animation<double>> _partAnimations = {};

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

    // Swing Animation for Game Over
    _swingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _swingAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _swingController, curve: Curves.easeInOut),
    );

    if (widget.gameState.status == GameStatus.gameOver) {
      _swingController.repeat(reverse: true);
    }

    // Initialize part controllers for existing mistakes
    for (int i = 1; i <= 7; i++) {
      _partControllers[i] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
      _partAnimations[i] = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _partControllers[i]!, curve: Curves.easeInOut),
      );
      if (i <= _lastMistakeCount) {
        _partControllers[i]!.value = 1.0;
      }
    }
  }

  @override
  void didUpdateWidget(covariant GallowsView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.gameState.status == GameStatus.idle &&
        oldWidget.gameState.status != GameStatus.idle) {
      _fadeController.reset();
      _fadeController.forward();
      // Reset body parts
      for (var controller in _partControllers.values) {
        controller.reset();
      }
      _lastMistakeCount = 0;
    } else if (widget.gameState.status != GameStatus.idle) {
      _fadeController.value = 1.0;
    }

    if (widget.gameState.mistakeCount > _lastMistakeCount) {
      for (
        int i = _lastMistakeCount + 1;
        i <= widget.gameState.mistakeCount;
        i++
      ) {
        _partControllers[i]?.forward();
      }
      _lastMistakeCount = widget.gameState.mistakeCount;
    }

    if (widget.gameState.status == GameStatus.gameOver) {
      if (!_swingController.isAnimating) {
        _swingController.repeat(reverse: true);
      }
    } else {
      _swingController.stop();
      _swingController.reset();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _swingController.dispose();
    for (var controller in _partControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _fadeController,
        _swingController,
        ..._partControllers.values,
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
            partOpacities: List.generate(
              7,
              (index) => _partAnimations[index + 1]?.value ?? 0.0,
            ),
            swingValue:
                widget.gameState.status == GameStatus.gameOver
                    ? _swingAnimation.value
                    : 0.0,
          ),
        );
      },
    );
  }
}
