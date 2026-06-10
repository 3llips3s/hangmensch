import 'package:flutter/material.dart';
import '../../../../core/constants/ui_colors.dart';

/// A custom animated snackbar for desktop that shows two messages
/// sequentially within a single pill-shaped overlay.
///
/// Slides up from the bottom, crossfades between messages, then
/// slides back down while fading out.
class DesktopHintSnackbar extends StatefulWidget {
  /// Delay before the snackbar begins its entrance animation.
  final Duration initialDelay;

  /// Callback fired when the entire sequence finishes and snackbar is hidden.
  final VoidCallback? onComplete;

  const DesktopHintSnackbar({
    super.key,
    this.initialDelay = const Duration(milliseconds: 2800),
    this.onComplete,
  });

  @override
  State<DesktopHintSnackbar> createState() => _DesktopHintSnackbarState();
}

class _DesktopHintSnackbarState extends State<DesktopHintSnackbar>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _textController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _textFadeAnimation;

  /// 0 = first message visible, 1 = second message visible.
  int _messageIndex = 0;
  bool _visible = false;

  @override
  void initState() {
    super.initState();

    // Slide + overall fade controller (entrance and exit).
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeInOut));

    // Text crossfade controller.
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _textFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _beginSequence();
  }

  Future<void> _beginSequence() async {
    // Wait for game load animations to finish.
    await Future.delayed(widget.initialDelay);
    if (!mounted) return;

    // Slide up + fade in.
    setState(() => _visible = true);
    await _slideController.forward();
    if (!mounted) return;

    // Hold first message.
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    // Crossfade: fade out first message.
    await _textController.forward();
    if (!mounted) return;

    // Switch to second message and fade it in.
    setState(() => _messageIndex = 1);
    await _textController.reverse();
    if (!mounted) return;

    // Hold second message.
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;

    // Slide down + fade out.
    await _slideController.reverse();
    if (!mounted) return;
    setState(() => _visible = false);

    // Breathing room before the tap-to-start prompt appears.
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Widget _buildKey(String text, {double? width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: UIColors.darkGrey,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: UIColors.gold.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            offset: const Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: UIColors.gold,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    const textStyle = TextStyle(
      color: UIColors.gold,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    if (_messageIndex == 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildKey('SPACE', width: 64),
          const SizedBox(width: 8),
          const Text('=  Start / Neustart', style: textStyle),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildKey('R'),
          const SizedBox(width: 6),
          const Text('= der', style: textStyle),
          const SizedBox(width: 16),
          _buildKey('E'),
          const SizedBox(width: 6),
          const Text('= die', style: textStyle),
          const SizedBox(width: 16),
          _buildKey('S'),
          const SizedBox(width: 6),
          const Text('= das', style: textStyle),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: UIColors.darkGrey.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: UIColors.gold.withValues(alpha: 0.15),
                width: 0.5,
              ),
            ),
            child: FadeTransition(
              opacity: _textFadeAnimation,
              child: _buildMessageContent(),
            ),
          ),
        ),
      ),
    );
  }
}
