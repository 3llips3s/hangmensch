import 'package:flutter/material.dart';
import '../../../../core/constants/ui_colors.dart';
import '../../../../core/constants/layout_constants.dart';

class ArticleButton extends StatefulWidget {
  final String article;
  final VoidCallback onTap;
  final bool isEnabled;

  const ArticleButton({
    super.key,
    required this.article,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  State<ArticleButton> createState() => _ArticleButtonState();
}

class _ArticleButtonState extends State<ArticleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => widget.isEnabled ? _controller.forward() : null,
      onTapUp: (_) => widget.isEnabled ? _controller.reverse() : null,
      onTapCancel: () => widget.isEnabled ? _controller.reverse() : null,
      onTap: widget.isEnabled ? widget.onTap : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: widget.isEnabled ? 1.0 : 0.5,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
            decoration: BoxDecoration(
              border: Border.all(
                color: UIColors.gold,
                width: LayoutConstants.buttonBorderWidth,
              ),
              borderRadius: BorderRadius.circular(LayoutConstants.borderRadius),
              color: Colors.transparent,
            ),
            child: Text(
              widget.article,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: UIColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
